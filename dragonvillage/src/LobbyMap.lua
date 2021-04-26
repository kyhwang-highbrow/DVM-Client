local PARENT = class(Camera, IEventListener:getCloneTable(), IEventDispatcher:getCloneTable(), LobbyMapSpotMgr:getCloneTable())

-------------------------------------
-- class LobbyMap
-- @brief 카메라
-------------------------------------
LobbyMap = class(PARENT, {
        m_groudNode = 'cc.Node',
        m_targetTamer = '',

        m_bPress = 'bool',
        m_touchPosition = 'cc.p',

        m_bMoveState = 'bool',

        m_cbMoveStart = 'function',
        m_cbMoveEnd = 'function',

        m_lobbyIndicator = 'Animator',
        m_locationGuideRight = 'Animator',
        m_locationGuideLeft = 'Animator',

        m_lLobbyTamer = 'list',
        m_lLobbyTamerBotOnly = 'list',
		m_lobbyTamerUser = 'Tamer',

        -- 유저 주변의 테이머 갱신을 위한 변수들
        m_bUserPosDirty = 'bool',
        m_lChangedPosTamers = 'list',
        m_lNearUserList = 'list',

        m_touchTamer = '',

        -- 채팅서버와의 position 동기화 최적화
        m_chatServer_bDirtyPos = 'bool',
        m_chatServer_posSyncTimer = 'bool',
        m_chatServer_x = 'number',
        m_chatServer_y = 'number',

        m_touchStartTime = 'number',   -- 클릭인정 시간
        m_customTouchCb = 'function',
    })

LobbyMap.Z_ORDER_TYPE_SHADOW = 1
LobbyMap.Z_ORDER_TYPE_INDICATOR = 2
LobbyMap.Z_ORDER_TYPE_TAMER = 3
LobbyMap.Z_ORDER_TYPE_DRAGON = 4
LobbyMap.Z_ORDER_TYPE_UI = 5

-------------------------------------
-- function init
-------------------------------------
function LobbyMap:init(parent, z_order)
    self:makeTouchLayer(self.m_rootNode)
    self.m_bMoveState = false
    self.m_lLobbyTamer = {}
    self.m_lLobbyTamerBotOnly = {}
    self.m_bUserPosDirty = true
    self.m_lChangedPosTamers = {}
    self.m_lNearUserList = {}

    -- 채팅서버와의 position 동기화 최적화
    self.m_chatServer_bDirtyPos = false
    self.m_chatServer_posSyncTimer = 0
end

-------------------------------------
-- function addLayer_lobbyGround
-- @brief 터치 레이어 생성
-------------------------------------
function LobbyMap:addLayer_lobbyGround(node, perspective_ratio, perspective_ratio_y, ui_lobby)
    self:addLayer(node, perspective_ratio, perspective_ratio_y)
    self.m_groudNode = node
    
	-- 이동 인디케이터
    self.m_lobbyIndicator = MakeAnimator('res/ui/a2d/lobby_indicator/lobby_indicator.vrp')
    self.m_lobbyIndicator:setVisible(false)
    self.m_lobbyIndicator:changeAni('idle', true)
    node:addChild(self.m_lobbyIndicator.m_node, self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_INDICATOR))

    -- 로케이션 가이드 UI
    self:makeGuideUI()
end

-------------------------------------
-- function makeTouchLayer
-- @brief 터치 레이어 생성
-------------------------------------
function LobbyMap:makeTouchLayer(target_node, customTouchCb)
    if (customTouchCb) then
        -- 중복이벤트 등록 방지
        self.m_customTouchCb = customTouchCb
        return
    end

    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(function(touches, event) return self:onTouchBegan(touches, event) end, cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(function(touches, event) return self:onTouchMoved(touches, event) end, cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(function(touches, event) return self:onTouchEnded(touches, event) end, cc.Handler.EVENT_TOUCHES_ENDED)
    listener:registerScriptHandler(function(touches, event) return self:onTouchEnded(touches, event) end, cc.Handler.EVENT_TOUCHES_CANCELLED)

    local eventDispatcher = target_node:getEventDispatcher()
    --eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)

    target_node:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
end

-------------------------------------
-- function makeGuideUI
-------------------------------------
function LobbyMap:makeGuideUI()    
    -- 오른쪽 가이드
    do
        local pos_x = self.m_lobbySpotPos[1] - 50
        local pos_y = self.m_lobbySpotPos[2] + 150

        local guide_animator = MakeAnimator('res/ui/a2d/lobby/lobby.vrp')
        guide_animator:setVisible(false)
        guide_animator:changeAni('arrow_right', true)
        guide_animator:setPosition(pos_x, pos_y)
        self.m_groudNode:addChild(guide_animator.m_node, 9990000)

        self.m_locationGuideRight = guide_animator
    end
    -- 왼쪽 가이드
    do
        local pos_x = self.m_clanLobbySpotPos[1]
        local pos_y = self.m_clanLobbySpotPos[2] + 150

        local guide_animator = MakeAnimator('res/ui/a2d/lobby/lobby.vrp')
        guide_animator:setVisible(false)
        guide_animator:changeAni('arrow_left', true)
        guide_animator:setPosition(pos_x, pos_y)
        self.m_groudNode:addChild(guide_animator.m_node, 9990000)

        self.m_locationGuideLeft = guide_animator
    end
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function LobbyMap:onTouchBegan(touches, event)
    -- 터치 처리가 되었을 경우 skip
    if event:isStopped() or (event.isStoppedForMenu and event:isStoppedForMenu()) then
        return false
    end

    -- 터치 시작 시 저장
    self.m_touchStartTime = tonumber(socket.gettime() * 1000)

    local location = touches[1]:getLocation()
    self.m_touchPosition = location

    if (self:onTouchBegan_touchDragon() == true) then
        return
    end

    self.m_bPress = true

    self.m_lobbyIndicator:changeAni('appear', false)
    self.m_lobbyIndicator:addAniHandler(function()
            self.m_lobbyIndicator:changeAni('idle', true)
        end)
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function LobbyMap:onTouchMoved(touches, event)
    local location = touches[1]:getLocation()
    self.m_touchPosition = location

    if self.m_touchTamer then
        self:onTouchBegan_touchDragon()
    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function LobbyMap:onTouchEnded(touches, event)
    self.m_bPress = false

    if self.m_touchTamer then
        if self:checkDragonTouch(touches[1]:getLocation(), self.m_touchTamer) then
            self.m_touchTamer:showEmotionEffect()
        end
        self.m_touchTamer = nil
    else
        -- 드래곤 터치를 안먹었으면 커스텀 터치 ㄲ
        -- 꾸욱 누르면서 이동 중일 수도 있기 때문에 0.2초의 클릭 판정을 만들어줌 
        if (not self.m_touchPosition) then return end

        local is_dragon_touched = self:checkDragonTouch(self.m_touchPosition, self.m_lobbyTamerUser)
        local is_touch_event = self.m_touchStartTime > 0 and (tonumber(socket.gettime() * 1000) - self.m_touchStartTime) <= 200

        if ( is_dragon_touched == false) and (self.m_customTouchCb) and (is_touch_event == true) then
            self.m_customTouchCb(touches, event)
        end
    end

    self.m_touchStartTime = - 1
end

-------------------------------------
-- function onTouchBegan_touchDragon
-------------------------------------
function LobbyMap:onTouchBegan_touchDragon()
    local touch_pos = self.m_touchPosition

	-- 내 드래곤 터치 체크
	if (self.m_lobbyTamerUser) then
		if (self:checkDragonTouch(touch_pos, self.m_lobbyTamerUser)) then
			self.m_lobbyTamerUser.m_dragon:clickUserDragon()
			return true
		end
	end

    return false 
end

-------------------------------------
-- function checkDragonTouch
-------------------------------------
function LobbyMap:checkDragonTouch(touch_pos, tamer)
    local dragon = tamer.m_dragon

    if (not dragon) then
        return false
    end

    --dragon.m_rootNode:getPosition()
    local world_pos = convertToWorldSpace(dragon.m_animator.m_node)

    -- 화면상에 보이는 Y스케일을 얻어옴
    local transform = dragon.m_rootNode:getNodeToWorldTransform()
    local scale_y = transform[5 + 1]

    local std_distance = (70 * scale_y)

    local distance = getDistance(touch_pos['x'], touch_pos['y'], world_pos['x'], world_pos['y'])

    if (distance <= std_distance) then
        return true
    else
        return false
    end
end


-------------------------------------
-- function getGroundRange
-------------------------------------
function LobbyMap:getGroundRange()
    local left = -1740
    local right = 1920 - 50
    local bottom = -370
    local top = -80

    return left, right, bottom, top
end

-------------------------------------
-- function getLobbyMapRandomPos
-------------------------------------
function LobbyMap:getLobbyMapRandomPos()
    local left, right, bottom, top = self:getGroundRange()
    local x = math_random(left, right)
    local y = math_random(bottom, top)

    return x, y
end

-------------------------------------
-- function getScaleAtYPosY
-------------------------------------
function LobbyMap:getScaleAtYPosY(pos_y)
    local left, right, bottom, top = self:getGroundRange()
    local base_scale = g_lobbyChangeMgr:getTamerBaseScale()

    local max_scale = 1.0 * base_scale
    local min_scale = 0.85 * base_scale
    local max_y = top
    local min_y = bottom

    local data = (pos_y - min_y)
    local gap = (max_y - min_y)

    local rate = (data / gap)
    local scale = min_scale + ((max_scale - min_scale) * (1 - rate))

    return scale
end

-------------------------------------
-- function update
-------------------------------------
function LobbyMap:update(dt)
    if (not self.m_targetTamer) then
        return
    end

    -- 플레이어 유저 이동
    if self.m_bUserPosDirty then
        local x, y = self.m_targetTamer.m_rootNode:getPosition()
        self.m_chatServer_bDirtyPos = true
        self.m_chatServer_x = x
        self.m_chatServer_y = y
    end

    self:update_chatServerPosSync(dt)

    if self.m_bPress then
        local node_pos = self.m_groudNode:convertToNodeSpace(self.m_touchPosition)

        local left, right, bottom, top = self:getGroundRange()

        node_pos['x'] = math_clamp(node_pos['x'], left, right)
        node_pos['y'] = math_clamp(node_pos['y'], bottom, top)

        self.m_targetTamer:setMove(node_pos['x'], node_pos['y'], 400)
        self.m_lobbyIndicator:setPosition(node_pos['x'], node_pos['y'])
    end

    local x, y = self.m_targetTamer.m_rootNode:getPosition()

    x = -x
    --y = 0
    y = -(y + 150)

    x, y = self:adjustPos(x, y)

    if (self.m_posX == x) and (self.m_posY == y) then
        self:setMoveState(false)
    else
        self:setMoveState(true)
        self:setPosition(x, y, true)
    end

    self:updateUserTamerArea()
    self:updateUserTamerActionArea()
end

-------------------------------------
-- function update_chatServerPosSync
-- @brief 채팅 서버 위치 동기화 업데이트
-------------------------------------
function LobbyMap:update_chatServerPosSync(dt)

    -- 타이머 시간 감소(0이 되면 동작 확인)
    if (0 < self.m_chatServer_posSyncTimer) then
        self.m_chatServer_posSyncTimer = (self.m_chatServer_posSyncTimer - dt)
    end

    -- 타이머가 0 이하이고, 위치 동기화가 필요한 경우
    if self.m_chatServer_bDirtyPos and (self.m_chatServer_posSyncTimer <= 0) then
        self.m_chatServer_posSyncTimer = 1
        local x = self.m_chatServer_x
        local y = self.m_chatServer_y
        self.m_chatServer_bDirtyPos = false

        -- 채팅 서버로 위치 동기화 요청
        self:dispatch('LobbyMap_CHARACTER_MOVE', {['x']=x, ['y']=y})
    end
end

-------------------------------------
-- function setMoveState
-------------------------------------
function LobbyMap:setMoveState(b_move_state)
    if (self.m_bMoveState == b_move_state) then
        return
    end

    self.m_bMoveState = b_move_state

    if b_move_state and self.m_cbMoveStart then
        self.m_cbMoveStart()
    end

    if (not b_move_state) and self.m_cbMoveEnd then
        self.m_cbMoveEnd()
    end
end

-------------------------------------
-- function setMoveStartCB
-------------------------------------
function LobbyMap:setMoveStartCB(func)
    self.m_cbMoveStart = func
end

-------------------------------------
-- function setMoveEndCB
-------------------------------------
function LobbyMap:setMoveEndCB(func)
    self.m_cbMoveEnd = func
end

-------------------------------------
-- function makeLobbyTamerBot
-------------------------------------
function LobbyMap:makeLobbyTamerBot(struct_user_info)

    -- 복사를 해서 사용함 (변경 여부를 관리하기 위해)
    local struct_user_info = clone(struct_user_info)

    local lobby_map = self
    local lobby_ground = self.m_groudNode
    local player_uid = g_userData:get('uid')
    local uid = struct_user_info:getUid()
    local is_bot = (tostring(player_uid) ~= uid)
	
    local tamer
    if is_bot then
        --tamer = LobbyTamerBot(struct_user_info)
        tamer = LobbyTamer(struct_user_info)
    else
        tamer = LobbyTamer(struct_user_info)
    end

    -- 테이머 리소스 (tamer id에 따라 받아옴)
    local tamer_res = struct_user_info:getSDRes()
	tamer:initAnimator(tamer_res)

    local flip = (math_random(1, 2) == 1) and true or false

    tamer:initState()
    tamer:changeState('idle')
    tamer:initSchedule()
    
    lobby_ground:addChild(tamer.m_rootNode)

    tamer.m_animator:setFlip(flip)

    self:addLobbyTamer(tamer, is_bot, struct_user_info)
    self:addLobbyDragon(tamer, is_bot, struct_user_info)

    if is_bot then
        --[[
        local pos = self:getRandomSpot(uid)
        tamer:setPosition(pos[1], pos[2])

        tamer.m_funcGetRandomPos = function()
            local ret_pos = self:getRandomSpot(uid)
            return ret_pos[1], ret_pos[2]
        end
        --]]
    else
        self.m_targetTamer = tamer

        --[[
        local x, y = 0, -150
        tamer:setPosition(x, y)
        --]]
    end

    -- 첫 위치 지정
    local x, y = struct_user_info:getPosition()
    tamer:setPosition(x, y)

    return tamer
end

-------------------------------------
-- function addLobbyTamer
-------------------------------------
function LobbyMap:addLobbyTamer(tamer, is_bot, t_user_info)
    table.insert(self.m_lLobbyTamer, tamer)

    if (is_bot) then
        table.insert(self.m_lLobbyTamerBotOnly, tamer)
	else
		self.m_lobbyTamerUser = tamer
    end

    do -- 그림자 생성
        local lobby_shadow = LobbyShadow(1)
        self.m_groudNode:addChild(lobby_shadow.m_rootNode, self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_SHADOW))
        tamer.m_shadow = lobby_shadow

        -- 그림자 이동 이벤트 등록
        lobby_shadow:addListener('lobby_shadow_move', self)

        -- 테이머가 이동하면 그림자도 함께 이동
        tamer:addListener('lobby_character_move', lobby_shadow)
    end

    do -- UI 생성
        local lobby_user_status_ui = LobbyUserStatusUI(t_user_info)
        self.m_groudNode:addChild(lobby_user_status_ui.m_rootNode, 100000)

        -- UI 이동 이벤트 등록
        lobby_user_status_ui:addListener('lobby_user_status_ui_move', self)

        -- 테이머가 이동하면 UI도 함께 이동
        tamer:addListener('lobby_character_move', lobby_user_status_ui)

        tamer.m_ui = lobby_user_status_ui
    end

    -- 유저 테이머에만 추가
    if (not is_bot) then
        tamer:addListener('lobby_character_move_start', self)
        tamer:addListener('lobby_character_move_end', self)
    end

    -- 테이머가 이동했을 때 LobbyMap에서 ZOrder와 Scale을 변경
    tamer:addListener('lobby_character_move', self)
end

-------------------------------------
-- function removeLobbyTamer
-------------------------------------
function LobbyMap:removeLobbyTamer(uid)
    local idx = nil
    for i,v in pairs(self.m_lLobbyTamer) do
        if (v.m_userData:getUid() == uid) then
            idx = i
            break
        end
    end

    if (not idx) then
        return
    end

    for i,v in pairs(self.m_lLobbyTamerBotOnly) do
        if (v.m_userData:getUid() == uid) then
            table.remove(self.m_lLobbyTamerBotOnly, i)
            break
        end
    end

    for i,v in pairs(self.m_lChangedPosTamers) do
        if (v.m_userData:getUid() == uid) then
            table.remove(self.m_lChangedPosTamers, i)
            break
        end
    end

    self.m_lLobbyTamer[idx]:release()
    table.remove(self.m_lLobbyTamer, idx)
end

-------------------------------------
-- function updateLobbyTamer
-- @breif 외부에서 테이머의 정보가 변경되었을 경우 (테이머, 드래곤, 유저 레벨, 유저 닉네임 등등등)
-------------------------------------
function LobbyMap:updateLobbyTamer(uid, struct_user_info)
    local tamer = nil

    for i,v in pairs(self.m_lLobbyTamer) do
        if (v.m_userData:getUid() == uid) then
            tamer = v
        end
    end

    if (not tamer) then
        return
    end

    -- 테이머가 변경되었을 경우
    if (tamer.m_userData.m_tamerID ~= struct_user_info.m_tamerID) or (tamer.m_userData.m_tamerCostumeID ~= struct_user_info.m_tamerCostumeID) then
        -- 테이머 리소스 (tamer id에 따라 받아옴)
        local tamer_res = struct_user_info:getSDRes()
	    tamer:initAnimator(tamer_res)
    end

    -- 리더 드래곤
    local prev_dragon = tamer.m_userData:getLeaderDragonObject()
    local curr_dragon = struct_user_info:getLeaderDragonObject()
    if (prev_dragon:getDid() ~= curr_dragon:getDid()) or 
       (prev_dragon:getEvolution() ~= curr_dragon:getEvolution()) or 
       (prev_dragon:getTransform() ~= curr_dragon:getTransform()) then
		local lobby_dragon = tamer.m_dragon

        -- did 변경
        lobby_dragon.m_dragonID = curr_dragon:getDid()
		lobby_dragon.m_evolution = curr_dragon:getEvolution()

        -- res 변경
        local res = curr_dragon:getIngameRes()
        lobby_dragon:initAnimator(res)
		
		-- 위치 갱신
		lobby_dragon:moveToTamer()
    end

    -- 복사를 해서 사용함 (변경 여부를 관리하기 위해)
    -- UI는 변경여부 상관없이 무조건 갱신 (퍼포먼스 이슈가 거의 없음)
    tamer:refresh(clone(struct_user_info))
end

-------------------------------------
-- function updateLobbyObject
-- @breif 유저의 입장, 퇴장때 로비 월드에 배치된 오브젝트가 갱신되야 하는 경우
-------------------------------------
function LobbyMap:updateLobbyObject(struct_user_info)
    local type = g_lobbyChangeMgr:getLobbyType()
    if (type == LOBBY_TYPE.CLAN) then
        g_clanLobbyManager:changeBedRes()
    end
end

-------------------------------------
-- function addLobbyDragon
-------------------------------------
function LobbyMap:addLobbyDragon(tamer, is_bot, struct_user_info)
    -- 임시 랜덤 드래곤
    local table_dragon = TableDragon()
    local t_dragon = nil

    local leader_dragon = struct_user_info:getLeaderDragonObject()
    if (not leader_dragon) then
        return
    end

    local evolution = leader_dragon:getEvolution()
    local did = leader_dragon:getDid()
	local flv = leader_dragon:getFlv()

    -- 서버에서 오류로 인해 did가 0으로 넘어오는 이슈가 있어서 예외처리함
    if (did == 0) then
        local t_random_data = table_dragon:getRandomRow()
        did = t_random_data['did']
    end

    t_dragon = table_dragon:get(did)

	-- 드래곤 추가하는 시기에 빈번한 에러를 방지하자
	if (IS_TEST_MODE()) then
		if (t_dragon == nil) then
			ccdisplay(string.format("존재하지 않는 did : %d", did))
			t_dragon = table_dragon:get(120011)
		end
	end

    -- 외형 변환 적용된 경우
    if (evolution >= POSSIBLE_TRANSFORM_CHANGE_EVO) then
        local transform = leader_dragon['transform']
        if (transform) then
            evolution = transform
        end
    end

    local res = AnimatorHelper:getDragonResName(t_dragon['res'], evolution, t_dragon['attr'])

    -- 드래곤 생성
    local lobby_dragon = LobbyDragon(t_dragon['did'], flv, evolution, is_bot)
    lobby_dragon:initAnimator(res)
    self.m_groudNode:addChild(lobby_dragon.m_rootNode)

    lobby_dragon:initState()
    lobby_dragon:changeState('idle')
    lobby_dragon:initSchedule()

    do -- 그림자 생성
        local lobby_shadow = LobbyShadow(0.5)
        self.m_groudNode:addChild(lobby_shadow.m_rootNode, self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_SHADOW))
        lobby_dragon.m_shadow = lobby_shadow

        -- 그림자 이동 이벤트 등록
        lobby_shadow:addListener('lobby_shadow_move', self)

        -- 드래곤이 이동하면 그림자도 함께 이동
        lobby_dragon:addListener('lobby_character_move', lobby_shadow)
    end

    -- 테이머가 이동하면 드래곤 함께 이동
    tamer:addListener('lobby_character_move', lobby_dragon)

    -- 드래곤이 이동했을 때 LobbyMap에서 ZOrder와 Scale을 변경
    lobby_dragon:addListener('lobby_character_move', self)

    tamer.m_dragon = lobby_dragon
end

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyMap:onEvent(event_name, t_event, ...)
    -- 테이머의 위치가 변경되었을 경우
    if (event_name == 'lobby_user_status_ui_move') then
        local arg = {...}
        local lobby_user_status_ui = arg[1]
        local x = arg[2]
        local y = arg[3]

        -- Y위치에 따라 ZOrder를 변경
        local z_order = self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_UI, y)
        lobby_user_status_ui.m_rootNode:setLocalZOrder(z_order)

        -- Y위치에 따라 Scale을 변경
        local scale = self:getScaleAtYPosY(y)
        lobby_user_status_ui.m_rootNode:setScale(scale)

    -- 테이머의 위치가 변경되었을 경우
    elseif (event_name == 'lobby_character_move') then
        local arg = {...}
        local lobby_tamer = arg[1]
        local x = arg[2]
        local y = arg[3]

        local is_tamer = isInstanceOf(lobby_tamer, LobbyTamer)
        local is_dragon = isInstanceOf(lobby_tamer, LobbyDragon)

        -- Y위치에 따라 ZOrder를 변경
        local z_order
        if is_dragon then
            z_order = self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_TAMER, y)
        else
            z_order = self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_DRAGON, y)
        end
        lobby_tamer.m_rootNode:setLocalZOrder(z_order)

        -- Y위치에 따라 Scale을 변경
        local scale = self:getScaleAtYPosY(y)
        lobby_tamer.m_rootNode:setScale(scale)

        -- 테이머의 이동일 경우
        if is_tamer then
            local uid = g_userData:get('uid')
            local bot_uid = tostring(lobby_tamer.m_userData:getUid())
            if (tostring(uid) == bot_uid) then
                self.m_bUserPosDirty = true
            else
                table.insert(self.m_lChangedPosTamers, lobby_tamer)
            end
        end

    -- 그림자의 위치가 변경되었을 경우
    elseif (event_name == 'lobby_shadow_move') then
        local arg = {...}
        local lobby_shadow = arg[1]
        local x = arg[2]
        local y = arg[3]

        -- Y위치에 따라 Scale을 변경
        local scale = self:getScaleAtYPosY(y)
        lobby_shadow.m_rootNode:setScale(scale)
    
    -- 유저 테이머 이동 시작/종료
    elseif (event_name == 'lobby_character_move_start') then
        self.m_lobbyIndicator:setVisible(true)
    elseif (event_name == 'lobby_character_move_end') then
        self.m_lobbyIndicator:setVisible(false)

    -- 드래곤 자유 이동
    elseif (event_name == 'forest_dragon_move_free') then
        -- 받은 정보
        local dragon = t_event:getObject()
        local speed = t_event:getSpeed()
        local pos_x, pos_y = t_event:getPosition()
        
        -- 랜덤 좌표
        local tar_x, tar_y = self:getRandomPos()
        
        -- 거리 제한이 있는 좌표 계산
        local distance = getDistance(pos_x, pos_y, tar_x, tar_y)
        if (distance > (speed * 2)) then
            local angle = getAdjustDegree(getDegree(pos_x, pos_y, tar_x, tar_y))
            local new_dist = speed * (math_random(20, 25) / 10)
            local pos = getPointFromAngleAndDistance(angle, new_dist)
            tar_x = pos_x + pos.x
            tar_y = pos_y + pos.y
        end

        dragon:setMove(tar_x, tar_y, speed)

        -- Y위치에 따라 ZOrder를 변경
        local z_order = self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_DRAGON, pos_y)
        dragon.m_rootNode:setLocalZOrder(z_order)

        -- Y위치에 따라 Scale을 변경
        local scale = self:getScaleAtYPosY(pos_y)
        dragon.m_rootNode:setScale(scale)
    end
end

-------------------------------------
-- function updateUserTamerArea
-- @brief 유저의 테이머와 상대위치가 특정 거리 이내로 들어온 테이머 봇을 체크
-------------------------------------
function LobbyMap:updateUserTamerArea()
    local target_list

    -- 유저가 이동하였을 경우 전체 테이머들을 대상
    if self.m_bUserPosDirty then
        target_list = self.m_lLobbyTamerBotOnly
    else
        target_list = self.m_lChangedPosTamers
    end

    -- 확인할 리스트가 없으면 리턴
    if (#target_list <= 0) then
        self.m_bUserPosDirty = false
        return
    end

    -- 유저 테이머의 위치
    local user_x, user_y = self.m_targetTamer.m_rootNode:getPosition()
    
    -- 확인해야 할 테이머들과의 거리를 확인
    for i,bot in ipairs(target_list) do
        if (bot.m_rootNode) then
            local bot_x, bot_y = bot.m_rootNode:getPosition()
            local uid = bot.m_userData:getUid()
            local distance = getDistance(user_x, user_y, bot_x, bot_y)

            if (distance <= 150) then
                if (not self.m_lNearUserList[uid]) then
                    --cclog('가까이 들어옴!!! ' .. uid)
                    bot:showEmotionEffect()
                    bot.m_ui:setActive(true)
                end
                self.m_lNearUserList[uid] = bot
            else
                if (self.m_lNearUserList[uid]) then
                    --cclog('######## 멀어짐!!! ' .. uid)
                    bot.m_ui:setActive(false)
                end
                self.m_lNearUserList[uid] = nil
            end
        end
    end

    self.m_bUserPosDirty = false
    self.m_lChangedPosTamers = {}
end

-------------------------------------
-- function updateUserTamerActionArea
-- @brief 유저의 테이머가 특정 위치에 도착하면 Action 발생
-------------------------------------
function LobbyMap:updateUserTamerActionArea()
    -- 유저 테이머의 위치
    local user_x, user_y = self.m_targetTamer.m_rootNode:getPosition()
    local location_guide_area = 700

    -- 로비 이동
    local cur_lobby = g_lobbyChangeMgr:getLobbyType() -- 현재 로비 타입
    -- 마을 -> 클랜 로비
    if (cur_lobby == LOBBY_TYPE.NORMAL) then
        -- 클랜 미가입시 체크 안함
        if (g_clanData:isClanGuest()) then
            return
        end

        local clan_lobby_spot_pos = self.m_clanLobbySpotPos

        -- 가이드 액션 
        local visible = (user_x <= clan_lobby_spot_pos[1] + location_guide_area) 
        self:showLocationGuideUI(LOBBY_TYPE.CLAN, visible)

        if (user_x <= clan_lobby_spot_pos[1] and user_y >= clan_lobby_spot_pos[2]) then
            -- 현재 붙어있는 채팅서버 테이머 위치 랜덤으로
            g_lobbyManager:requestCharacterMove(self:getRandomSpot())
            g_lobbyChangeMgr:changeTypeAndGotoLobby(LOBBY_TYPE.CLAN)
        end

    -- 클랜 로비 -> 마을 
    elseif (cur_lobby == LOBBY_TYPE.CLAN) then
        local lobby_spot_pos = self.m_lobbySpotPos

        -- 가이드 액션 
        local visible = (user_x >= lobby_spot_pos[1] - location_guide_area)
        self:showLocationGuideUI(LOBBY_TYPE.NORMAL, visible)

        if (user_x >= lobby_spot_pos[1] and user_y >= lobby_spot_pos[2]) then
            -- 현재 붙어있는 채팅서버 테이머 위치 랜덤으로
            g_clanLobbyManager:requestCharacterMove(self:getRandomSpot())
            g_lobbyChangeMgr:changeTypeAndGotoLobby(LOBBY_TYPE.NORMAL)
           
        end
    end
end

-------------------------------------
-- function showLocationGuideUI
-- @brief 유저의 테이머가 특정 위치에 도착하면 화살표 표시
-------------------------------------
function LobbyMap:showLocationGuideUI(type, visible)
    if (not self.m_locationGuideRight or not self.m_locationGuideLeft) then
        return
    end

    if (type == LOBBY_TYPE.CLAN) then
        self.m_locationGuideRight:setVisible(false)
        self.m_locationGuideLeft:setVisible(visible)

    elseif (type == LOBBY_TYPE.NORMAL) then
        self.m_locationGuideLeft:setVisible(false)
        self.m_locationGuideRight:setVisible(visible)
    end
end

-------------------------------------
-- function makeLobbyMapZorder
-------------------------------------
function LobbyMap:makeLobbyMapZorder(type, pos_y, unique_idx)
    -- 그림자와 바닥 인디게이터는 즉시 리턴
    if (type == LobbyMap.Z_ORDER_TYPE_SHADOW) then
        return 10
    elseif (type == LobbyMap.Z_ORDER_TYPE_INDICATOR) then
        return 20
    end

    unique_idx = (unique_idx or math_random(0, 999))

    -- 기본 z_order
    local z_order = 0

    -- 드래곤
    if (type == LobbyMap.Z_ORDER_TYPE_TAMER) then
        z_order = 1000 - 1

    elseif (type == LobbyMap.Z_ORDER_TYPE_DRAGON) then
        z_order = 1000

    elseif (type == LobbyMap.Z_ORDER_TYPE_UI) then
        z_order = 10000
    end

    -- Y위치가 낮을 수록 위쪽으로 표현
    z_order = (z_order - pos_y)


    -- unique_idx를 적용하기 위해 1000을 곱함 (unique_idx는 0~999까지 사용 가능)
    z_order = (z_order * 1000)
    z_order = (z_order + unique_idx)

    return z_order
end

-------------------------------------
-- function clearAllUser
-------------------------------------
function LobbyMap:clearAllUser()
    for i,v in ipairs(self.m_lLobbyTamer) do
        v:release()
    end

    self.m_targetTamer = nil
    self.m_lobbyTamerUser = nil
    self.m_lLobbyTamer = {}
    self.m_lLobbyTamerBotOnly = {}

    self.m_touchTamer = nil

    -- 유저 주변의 테이머 갱신을 위한 변수들
    self.m_bUserPosDirty = true
    self.m_lChangedPosTamers = {}
    self.m_lNearUserList = {}
end

-------------------------------------
-- function refreshUserTamer
-------------------------------------
function LobbyMap:refreshUserTamer()
	local lobby_tamer = self.m_lobbyTamerUser
	local res = g_tamerData:getCurrTamerTable('res_sd')
	lobby_tamer:initAnimator(res)
end

-------------------------------------
-- function refreshUserDragon
-------------------------------------
function LobbyMap:refreshUserDragon()
	local lobby_dragon = self.m_lobbyTamerUser.m_dragon
    cclog('lobby_dragon')
    ccdump(lobby_dragon)
	local res = g_tamerData:getCurrTamerTable('res_sd')

	lobby_dragon:initAnimator(res)
end

-------------------------------------
-- function onDestroy
-------------------------------------
function LobbyMap:onDestroy()
    self:release_EventDispatcher()
    self:release_EventListener()
end


-------------------------------------
-- function makeDragon
-- @brief 하나의 드래곤 생성 로직
-------------------------------------
function LobbyMap:makeDragon(struct_dragon_object)
    -- 드래곤 생성
    local dragon = ForestDragon_Simple(struct_dragon_object)
    do
        local left, right, bottom, top = self:getGroundRange()

        dragon:initState()
        dragon:changeState('idle')
        dragon:initSchedule()
        dragon:setPosition(self:getRandomPos())
        dragon:setMove(dragon:getPosition())

        local pos_x, pos_y = dragon.m_rootNode:getPosition()
        local z_order = self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_DRAGON, pos_y)

        self.m_groudNode:addChild(dragon.m_rootNode, z_order)
    end
 
    -- 그림자 생성
    local forest_shadow = ForestShadow()
    do
        local evolution = struct_dragon_object:getEvolution()
        local scale = 0.5 + (0.25 * (evolution - 1))
        forest_shadow:initAnimator(scale)

        self.m_groudNode:addChild(forest_shadow.m_rootNode)
        dragon.m_shadow = forest_shadow
    end

    -- 이벤트 등록
    do
        -- 드래곤 -> 마이룸
        dragon:addListener('forest_dragon_move_free', self)
        dragon:addListener('forest_dragon_move_stuff', self)

        -- 드래곤 -> 그림자
        dragon:addListener('forest_character_move', forest_shadow)
        dragon:addListener('forest_dragon_jump', forest_shadow)
    end

    return dragon
end

-------------------------------------
-- function getRandomPos
-- @brief 범위안의 임의의 좌표
-------------------------------------
function LobbyMap:getRandomPos()
    local left, right, bottom, top = self:getGroundRange()
    local pos_x = math_random(left, right)
    local pos_y = math_random(bottom, top)

    return pos_x, pos_y
end
