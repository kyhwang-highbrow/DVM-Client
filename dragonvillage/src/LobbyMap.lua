local PARENT = class(Camera, IEventListener:getCloneTable(), LobbyMapSpotMgr:getCloneTable())

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
        m_lLobbyTamer = 'list',
        m_lLobbyTamerBotOnly = 'list',
		m_lobbyTamerUser = 'Tamer',

        -- 유저 주변의 테이머 갱신을 위한 변수들
        m_bUserPosDirty = 'bool',
        m_lChangedPosTamers = 'list',
        m_lNearUserList = 'list',

        -- 아이템 박스
        m_lItemBox = 'list',

        m_touchTamer = '',
        m_dragonTouchIndicator = '',

        m_lLobbyObject = '',
        m_lNearLobbyObjectList = 'list',
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
    self.m_lItemBox = {} 
    self.m_lNearLobbyObjectList = {}
end

-------------------------------------
-- function addLayer_lobbyGround
-- @brief 터치 레이어 생성
-------------------------------------
function LobbyMap:addLayer_lobbyGround(node, perspective_ratio, perspective_ratio_y, ui_lobby)
    self:addLayer(node, perspective_ratio, perspective_ratio_y)

    self.m_lobbyIndicator = MakeAnimator('res/ui/a2d/lobby_indicator/lobby_indicator.vrp')
    self.m_lobbyIndicator:setVisible(false)
    self.m_lobbyIndicator:changeAni('idle', true)
    node:addChild(self.m_lobbyIndicator.m_node, self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_INDICATOR))

    self.m_dragonTouchIndicator = MakeAnimator('res/indicator/indicator_effect_target/indicator_effect_target.vrp')
    self.m_dragonTouchIndicator:setVisible(false)
    self.m_dragonTouchIndicator:changeAni('idle_ally', true)
    node:addChild(self.m_dragonTouchIndicator.m_node, 1)

    do -- 오브젝트 버튼
        self.m_lLobbyObject = {}
        table.insert(self.m_lLobbyObject, MakeLobbyObjectUI(node, ui_lobby, UI_LobbyObject.BATTLE))
        table.insert(self.m_lLobbyObject, MakeLobbyObjectUI(node, ui_lobby, UI_LobbyObject.BOARD))
        table.insert(self.m_lLobbyObject, MakeLobbyObjectUI(node, ui_lobby, UI_LobbyObject.DRAGON_MANAGE))
        table.insert(self.m_lLobbyObject, MakeLobbyObjectUI(node, ui_lobby, UI_LobbyObject.SHIP))
        table.insert(self.m_lLobbyObject, MakeLobbyObjectUI(node, ui_lobby, UI_LobbyObject.SHOP))
    end
end

-------------------------------------
-- function makeTouchLayer
-- @brief 터치 레이어 생성
-------------------------------------
function LobbyMap:makeTouchLayer(target_node)
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
-- function onTouchBegan
-------------------------------------
function LobbyMap:onTouchBegan(touches, event)
    local location = touches[1]:getLocation()
    self.m_touchPosition = location

    if (self:onTouchBegan_touchBox() == true) then
        return
    end

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
            local t_dragon_data = self.m_touchTamer.m_userData['leader']
            if (not t_dragon_data) then
                t_dragon_data = UI_SimpleDragonInfoPopup:makeDragonData(self.m_touchTamer.m_dragon.m_dragonID)
            end
            UI_SimpleDragonInfoPopup(t_dragon_data)
        end
        self.m_touchTamer = nil
    end

    self.m_dragonTouchIndicator:setVisible(false)
end

-------------------------------------
-- function onTouchBegan_touchBox
-------------------------------------
function LobbyMap:onTouchBegan_touchBox()
    local node_pos = self.m_groudNode:convertToNodeSpace(self.m_touchPosition)

    -- item_box 순회
    for i,v in ipairs(self.m_lItemBox) do
        -- item_box의 센터위치 얻어옴
        local x, y = v.m_rootNode:getPosition()
        y = y + 40

        -- 터치된 item_box가 있을 경우
        local distance = getDistance(node_pos['x'], node_pos['y'], x, y)
        if (distance <= 80) then
            self:onTouchBox(v)
            return true
        end
    end

    return false
end

-------------------------------------
-- function onTouchBox
-------------------------------------
function LobbyMap:onTouchBox(item_box)
    self.m_targetTamer:setAttack(item_box)
end

-------------------------------------
-- function onTouchBegan_touchDragon
-------------------------------------
function LobbyMap:onTouchBegan_touchDragon()
    local touch_pos = self.m_touchPosition

    for i,v in ipairs(self.m_lLobbyTamerBotOnly) do
        if (self.m_touchTamer ~= v) and self:checkDragonTouch(touch_pos, v) then
            self.m_touchTamer = v

            -- 드래곤 터치 이펙트 출력
            self.m_dragonTouchIndicator.m_node:retain()
            self.m_dragonTouchIndicator.m_node:removeFromParent()
            self.m_touchTamer.m_dragon.m_rootNode:addChild(self.m_dragonTouchIndicator.m_node, 5)
            self.m_dragonTouchIndicator.m_node:release()
            self.m_dragonTouchIndicator:setVisible(true)
            self.m_dragonTouchIndicator:setPosition(0, 150)
            self.m_dragonTouchIndicator:changeAni2('appear_ally', 'idle_ally', true)

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

    local max_scale = 1.0
    local min_scale = 0.85
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

    if self.m_bPress then
        local node_pos = self.m_groudNode:convertToNodeSpace(self.m_touchPosition)

        local left, right, bottom, top = self:getGroundRange()

        node_pos['x'] = math_clamp(node_pos['x'], left, right)
        node_pos['y'] = math_clamp(node_pos['y'], bottom, top)

        self.m_targetTamer:setMove(node_pos['x'], node_pos['y'], 400)
        self.m_lobbyIndicator:setPosition(node_pos['x'], node_pos['y'])
        g_lobbyUserListData.m_posX = node_pos['x']
        g_lobbyUserListData.m_posY = node_pos['y']
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

    self:updateLobbyObjectArea()
    self:updateUserTamerArea()
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
function LobbyMap:makeLobbyTamerBot(t_user_info)
    local lobby_map = self
    local lobby_ground = self.m_groudNode
    local uid = g_serverData:get('local', 'uid')
    local is_bot = (tostring(uid) ~= t_user_info['uid'])
	
    local sum_random = SumRandom()
    sum_random:addItem(1, 'res/character/tamer/dede/dede.spine')
    sum_random:addItem(1, 'res/character/tamer/goni/goni.spine')
	sum_random:addItem(1, 'res/character/tamer/nuri/nuri.spine')
	sum_random:addItem(1, 'res/character/tamer/kesath/kesath.spine')
	sum_random:addItem(1, 'res/character/tamer/durun/durun.spine')
	sum_random:addItem(1, 'res/character/tamer/mokoji/mokoji.spine')
    local res = sum_random:getRandomValue()

    local tamer
    if is_bot then
        tamer = LobbyTamerBot(t_user_info)
    else
        tamer = LobbyTamer(t_user_info)
        res = g_userData:getTamerInfo('res_sd')
    end

	tamer:initAnimator(res)

    local flip = (math_random(1, 2) == 1) and true or false

    tamer:initState()
    tamer:changeState('idle')
    tamer:initSchedule()
    
    lobby_ground:addChild(tamer.m_rootNode)

    tamer.m_animator:setFlip(flip)

    self:addLobbyTamer(tamer, is_bot, t_user_info)
    self:addLobbyDragon(tamer, t_user_info, flip)

    if is_bot then
        local pos = self:getRandomSpot(t_user_info['uid'])
        tamer:setPosition(pos[1], pos[2])

        tamer.m_funcGetRandomPos = function()
            local ret_pos = self:getRandomSpot(t_user_info['uid'])
            return ret_pos[1], ret_pos[2]
        end
    else
        self.m_targetTamer = tamer
        local x, y = 0, -150
        if (g_lobbyUserListData.m_posX and g_lobbyUserListData.m_posY) then
            x, y = g_lobbyUserListData.m_posX, g_lobbyUserListData.m_posY
        end
        tamer:setPosition(x, y)
        tamer:changeState('idle')
    end
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
-- function addLobbyDragon
-------------------------------------
function LobbyMap:addLobbyDragon(tamer, t_user_info, flip)
    -- 임시 랜덤 드래곤
    local table_dragon = TableDragon()
    local t_dragon = nil

    local evolution = t_user_info['leader']['evolution']

    local did = t_user_info['leader']['did']

    -- 서버에서 오류로 인해 did가 0으로 넘어오는 이슈가 있어서 예외처리함
    if (did == 0) then
        local t_random_data = table_dragon:getRandomRow()
        did = t_random_data['did']
    end

    t_dragon = table_dragon:get(did)
    local res = AnimatorHelper:getDragonResName(t_dragon['res'], evolution, t_dragon['attr'])

    -- 드래곤 생성
    local lobby_dragon = LobbyDragon(t_dragon['did'])
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
            if (tostring(uid) == lobby_tamer.m_userData['uid']) then
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
        
    end
end

-------------------------------------
-- function updateLobbyObjectArea
-- @brief
-------------------------------------
function LobbyMap:updateLobbyObjectArea()
    if (not self.m_bUserPosDirty) then
        return
    end

    -- 유저 테이머의 위치
    local user_x, user_y = self.m_targetTamer.m_rootNode:getPosition()

    local rate = 0.66
    local reaction_distance = 600 * rate
    local opacity_reaction_distance_min = 300 * rate
    local opacity_reaction_distance_max = 550 * rate

    for i,v in ipairs(self.m_lLobbyObject) do
        local x, y = v.root:getPosition()
        local distance = math_abs(user_x - x)

        if (distance <= reaction_distance) then
            if (not self.m_lNearLobbyObjectList[v.m_type]) then
                v:setActive(true)
            end
            self.m_lNearLobbyObjectList[v.m_type] = v
        else
            if (self.m_lNearLobbyObjectList[v.m_type]) then
                v:setActive(false)
            end
            self.m_lNearLobbyObjectList[v.m_type] = nil
        end
        

        if (distance <= reaction_distance) then
            local min = opacity_reaction_distance_min
            local max = opacity_reaction_distance_max
            distance = math_clamp(distance, min, max)
            local n = (distance - min)
            local range = (max-min)
            local opacity = 255 * ((range-n) / range)
            v.vars['image']:setOpacity(opacity)
        end
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
        return
    end

    -- 유저 테이머의 위치
    local user_x, user_y = self.m_targetTamer.m_rootNode:getPosition()
    
    -- 확인해야 할 테이머들과의 거리를 확인
    for i,bot in ipairs(target_list) do
        local bot_x, bot_y = bot.m_rootNode:getPosition()
        local uid = bot.m_userData['uid']
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


    self.m_bUserPosDirty = false
    self.m_lChangedPosTamers = {}
end

-------------------------------------
-- function tempItemBox
-- @brief
-------------------------------------
function LobbyMap:tempItemBox()
    local item_box = LobbyItemBox()
    item_box:initAnimator('res/ui/a2d/ui_dropbox/ui_dropbox.vrp')
    item_box.m_animator:changeAni('ui_box_rainbow_idle', true)

    local x, y = self:getLobbyMapRandomPos()

    -- Y위치에 따라 ZOrder를 변경
    local z_order = self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_TAMER, y)
    
    self.m_groudNode:addChild(item_box.m_rootNode, z_order)
    item_box.m_rootNode:setPosition(x, y)

    local lobby_shadow = LobbyShadow(1)
    self.m_groudNode:addChild(lobby_shadow.m_rootNode, self:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_SHADOW))
    lobby_shadow.m_rootNode:setPosition(x, y)
    item_box.m_shadow = lobby_shadow
   
   
   self.m_lItemBox = {} 

   table.insert(self.m_lItemBox, item_box)
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
    -- 드래곤 터치 이펙트 출력
    self.m_dragonTouchIndicator.m_node:retain()
    self.m_dragonTouchIndicator.m_node:removeFromParent()
    self.m_rootNode:addChild(self.m_dragonTouchIndicator.m_node, 1)
    self.m_dragonTouchIndicator.m_node:release()

    for i,v in ipairs(self.m_lLobbyTamer) do
        v:release()
    end

    self.m_targetTamer = nil

    self.m_lLobbyTamer = {}
    self.m_lLobbyTamerBotOnly = {}

    self.m_touchTamer = nil

    -- 유저 주변의 테이머 갱신을 위한 변수들
    self.m_bUserPosDirty = true
    self.m_lChangedPosTamers = {}
    self.m_lNearUserList = {}
end

-------------------------------------
-- function refreshLobbyTamerUser
-------------------------------------
function LobbyMap:refreshLobbyTamerUser()
	local lobby_tamer = self.m_lobbyTamerUser
	local res = g_userData:getTamerInfo('res_sd')
	lobby_tamer:initAnimator(res)
end