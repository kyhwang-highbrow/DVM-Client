local PARENT = class(Camera, IEventListener:getCloneTable(), IEventDispatcher:getCloneTable())

FOREST_ZORDER = 
{
    ['SHADOW'] = math_pow(2, 7),
    ['INDICATOR'] = math_pow(2, 4),
    ['STUFF'] = math_pow(2, 6),
    ['CHAR'] = math_pow(2, 10),
    ['STAT_UI'] = math_pow(2, 12),
}

-------------------------------------
-- class ForestTerritory
-- @brief 카메라
-------------------------------------
ForestTerritory = class(PARENT, {   
        -- 터치 관련
        m_isPressMove = 'bool',
        m_touchPosition = 'cc.p',
        m_touchedDragon = 'ForestDragon',
        m_isTouchingDragon = 'bool',
        m_moveIndicator = 'Animator',

        -- 오브젝트
        m_ground = 'Animator',
        m_tamer = 'ForestTamer',
        m_lDragonList = 'List<ForestDragon>',
        m_lStuffList = 'List<ForestStuff>',

        -- background 관련
        m_bgCurrPosX = 'number',

    })

local VISIBLE_SIZE= cc.Director:getInstance():getVisibleSize()

local BG_WIDTH = 2560
local BG_HEIGHT = 960
local BG_POS_Y = 0
local BG_RANGE_X = (BG_WIDTH - VISIBLE_SIZE['width'])

-------------------------------------
-- function init
-------------------------------------
function ForestTerritory:init(parent, z_order)
    -- 변수 초기화    
    self:setContainerSize(BG_WIDTH, BG_HEIGHT)
    self.m_bgCurrPosX = 0
    self.m_lDragonList = {}
    self.m_lStuffList = {}
    self.m_isTouchingDragon = false

    -- 오브젝트 생성
    self:initBackground()
    self:initTamer()
    self:initDragons()
    self:initStuffs()

    -- 터치 영역 생성
    self:makeTouchLayer(self.m_rootNode)
    self:initIndicator()

    -- update 시작
    self.m_rootNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
end

-------------------------------------
-- function makeTouchLayer
-- @brief 터치 레이어 생성
-------------------------------------
function ForestTerritory:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(function(touches, event) return self:onTouchBegan(touches, event) end, cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(function(touches, event) return self:onTouchMoved(touches, event) end, cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(function(touches, event) return self:onTouchEnded(touches, event) end, cc.Handler.EVENT_TOUCHES_ENDED)
    listener:registerScriptHandler(function(touches, event) return self:onTouchEnded(touches, event) end, cc.Handler.EVENT_TOUCHES_CANCELLED)

    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function initIndicator
-- @brief 이동 인디케이터 생성 : m_moveIndicator
-------------------------------------
function ForestTerritory:initIndicator()
    self.m_moveIndicator = MakeAnimator('res/ui/a2d/lobby_indicator/lobby_indicator.vrp')
    self.m_moveIndicator:setVisible(false)
    self.m_moveIndicator:changeAni('idle', true)

    self.m_ground:addChild(self.m_moveIndicator.m_node, FOREST_ZORDER['INDICATOR'])
end

-------------------------------------
-- function initBackground
-- @brief 배경 생성 : m_ground
-------------------------------------
function ForestTerritory:initBackground()
    -- 하늘
    self:addLayer(self:makeForestLayer(3), 0.7)

    -- 숲
    self:addLayer(self:makeForestLayer(2), 0.9)

    -- 땅
    local ground_node = self:makeForestLayer(1)
    self:addLayer(ground_node, 1) 
    self.m_ground = ground_node
    
    -- 근경
    self:addLayer(self:makeForestLayer(0, true), 1.3, 1)
end

-------------------------------------
-- function makeForestLayer
-------------------------------------
function ForestTerritory:makeForestLayer(idx, use_center)
    local node = cc.Node:create()
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))

    local layer_path = 'res/bg/dragon_forest/dragon_forest_layer_%.2d_%s.png'
    local skip_error_msg = true
    local pos_x = BG_WIDTH/4

    local animator = MakeAnimator(string.format(layer_path, idx, 'left'), skip_error_msg)
    if (animator.m_node) then
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:setPositionX(-pos_x)
        node:addChild(animator.m_node)
    end

    local animator = MakeAnimator(string.format(layer_path, idx, 'center'), skip_error_msg)
    if (animator.m_node) then
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        node:addChild(animator.m_node)
    end

	local animator = MakeAnimator(string.format(layer_path, idx, 'right'), skip_error_msg)
    if (animator.m_node) then
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:setPositionX(pos_x)
        node:addChild(animator.m_node)
    end

    return node
end

-------------------------------------
-- function initTamer
-- @brief 테이머 생성
-------------------------------------
function ForestTerritory:initTamer()
    local struct_user_info = ServerData_Forest:getInstance():getMyUserInfo()
    self:makeTamer(struct_user_info)

    -- 친구 방문시 친구 테이머 만들기 추가
end

-------------------------------------
-- function makeTamer
-- @brief 테이머 생성
-------------------------------------
function ForestTerritory:makeTamer(struct_user_info)
    -- 테이머 생성
    local tamer = ForestTamer(struct_user_info)
    do
        local res = struct_user_info:getSDRes()
        local left, right, bottom, top = self:getGroundRange()
    
        tamer:initAnimator(res)
        tamer:initState()
        tamer:changeState('idle')
        tamer:initSchedule()    
        tamer:setForestZOrder()
        
        local pos_x = math_random(left, right)
        local pos_y = (bottom + top)/2
        tamer:setPosition(pos_x, pos_y)
    
        self.m_ground:addChild(tamer.m_rootNode)
        self.m_tamer = tamer
    end

    -- 그림자 생성
    local forest_shadow = ForestShadow()
    do
        forest_shadow:initAnimator(1)
        forest_shadow:setPosition(tamer:getPosition())

        self.m_ground:addChild(forest_shadow.m_rootNode)
        tamer.m_shadow = forest_shadow
    end

    -- UI 생성
    local user_status_ui = ForestUserStatusUI(struct_user_info)
    do
        user_status_ui.m_rootNode:setPosition(tamer:getPosition())
        self.m_ground:addChild(user_status_ui.m_rootNode)
        tamer.m_ui = user_status_ui
    end

    -- 이벤트 등록
    do
        -- 테이머 이동 이벤트
        tamer:addListener('forest_tamer_move_start', self)
        tamer:addListener('forest_tamer_move_end', self)

        -- 테이머가 이동 시 함께 이동
        tamer:addListener('forest_character_move', forest_shadow)
        tamer:addListener('forest_character_move', user_status_ui)
    end
end

-------------------------------------
-- function initDragons
-- @brief 드래곤들 생성
-------------------------------------
function ForestTerritory:initDragons()
    --local t_dragon_object = ServerData_Forest:getInstance():getMyDragons()
    --for doid, struct_dragon_object in pairs(t_dragon_object) do
        --self:makeDragon(struct_dragon_object)
    --end
    self:changeDragon_random()
end

-------------------------------------
-- function makeDragon
-- @brief 하나의 드래곤 생성 로직
-------------------------------------
function ForestTerritory:makeDragon(struct_dragon_object)
    -- 드래곤 생성
    local dragon = ForestDragon(struct_dragon_object)
    do
        local left, right, bottom, top = self:getGroundRange()

        dragon:initState()
        dragon:changeState('idle')
        dragon:initSchedule()
        dragon:setPosition(self:getRandomPos())
        dragon:setMove(dragon:getPosition())
        dragon:setForestZOrder()

        self.m_ground:addChild(dragon.m_rootNode)
        table.insert(self.m_lDragonList, dragon)
    end
 
    -- 그림자 생성
    local forest_shadow = ForestShadow()
    do
        local evolution = struct_dragon_object:getEvolution()
        local scale = 0.5 + (0.25 * (evolution - 1))
        forest_shadow:initAnimator(scale)

        self.m_ground:addChild(forest_shadow.m_rootNode)
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
-- function initStuffs
-- @brief 가구 생성
-------------------------------------
function ForestTerritory:initStuffs()
    for i = 1, 5 do
        local stuff = ForestStuff(i)
        stuff:initSchedule()
        stuff:initAnimator()
        self.m_ground:addChild(stuff.m_rootNode, FOREST_ZORDER['STUFF'])
        self.m_lStuffList[stuff:getStuffType()] = stuff
    end
end

-------------------------------------
-- function changeDragon_Random
-- @brief 드래곤을 랜덤 교체한다.
-------------------------------------
function ForestTerritory:changeDragon_Random()
    -- 기존 드래곤 삭제
    self:removeAllDragons()

    -- 전체 드래곤중 랜덤하게 가져옴
    local l_dragon_list = g_dragonsData:getDragonsList()
    l_dragon_list = table.getRandomList(l_dragon_list, 20)

    for i, v in pairs(l_dragon_list) do
        self:makeDragon(v)
    end
end

-------------------------------------
-- function removeAllDragons
-- @brief 모든 드래곤을 삭제한다.
-------------------------------------
function ForestTerritory:removeAllDragons()
    for i, dragon in pairs(self.m_lDragonList) do
        dragon:release()
    end

    self.m_lDragonList = {}
end














-------------------------------------
-- function onTouchBegan
-------------------------------------
function ForestTerritory:onTouchBegan(touches, event)
    -- 터치 처리가 되었을 경우 skip
    if event:isStopped() or (event.isStoppedForMenu and event:isStoppedForMenu()) then
        return false
    end

    local location = touches[1]:getLocation()
    self.m_touchPosition = location

    -- 터치된 드래곤이 있다면 등록
    for _, dragon in ipairs(self.m_lDragonList) do
        if (self:checkObjectTouch(location, dragon)) then
            self.m_touchedDragon = dragon
            return
        end
    end

    -- Stuff 터치 체크
    for _, stuff in pairs(self.m_lStuffList) do
        if (self:checkObjectTouch(location, stuff)) then
            stuff:showEmotionEffect()
            return
        end
    end

    -- 드래곤을 터치한게 아니라면 테이머를 이동 시킴
    local move_pos = self:getForestMovePos(location)
    self.m_tamer:setMove(move_pos['x'], move_pos['y'])

    -- 인디케이터 표시
    self.m_moveIndicator:setPosition(move_pos['x'], move_pos['y'])
    self.m_moveIndicator:changeAni('appear', false)
    self.m_moveIndicator:addAniHandler(function()
        self.m_moveIndicator:changeAni('idle', true)
    end)
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function ForestTerritory:onTouchMoved(touches, event)
    local location = touches[1]:getLocation()
    self.m_touchPosition = location

    -- 터치된 드래곤 옮기기
    if (self.m_touchedDragon) then
        -- 터치된 상태로 전환
        if (not self.m_isTouchingDragon) then
            self.m_isTouchingDragon = true
            self.m_touchedDragon:changeState('touched')
        end

        -- 드래곤 이동
        local move_pos = self:getForestMovePos(location)
        self.m_touchedDragon:setPosition(move_pos['x'], move_pos['y'])

    -- press move 
    else
        if (not self.m_isPressMove) then
            self.m_isPressMove = true
        end

    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function ForestTerritory:onTouchEnded(touches, event)
    self.m_isPressMove = false
    
    -- 터치된 드래곤 삭제
    if (self.m_touchedDragon) then
        self.m_touchedDragon:changeState('touched_end')
        self.m_touchedDragon = nil
        self.m_isTouchingDragon = false
    end
end

-------------------------------------
-- function update
-------------------------------------
function ForestTerritory:update(dt)
    -- 테이머 이동에 따라 화면 이동
    do
        local x, y = self.m_tamer:getPosition()
        x = -x
        y = -(y + 150)

        if (self.m_posX == x) and (self.m_posY == y) then
            -- nothing to do 
        else
            self:setPosition(x, y, true)
        end
    end

    -- press move
    if (self.m_isPressMove) then
        local move_pos = self:getForestMovePos(self.m_touchPosition)
        self.m_tamer:setMove(move_pos['x'], move_pos['y'])
        self.m_moveIndicator:setPosition(move_pos['x'], move_pos['y'])
    end
end








-------------------------------------
-- function getGroundRange
-- @brief ground의 범위를 정의한다.
-------------------------------------
function ForestTerritory:getGroundRange()
    local left = -BG_WIDTH/2
    local right = -left
    local bottom = -(BG_POS_Y + 500)
    local top = -(BG_POS_Y + 100)

    return left, right, bottom, top
end

-------------------------------------
-- function getRandomPos
-- @brief 범위안의 임의의 좌표
-------------------------------------
function ForestTerritory:getRandomPos()
    local left, right, bottom, top = self:getGroundRange()
    local pos_x = math_random(left, right)
    local pos_y = math_random(bottom, top)

    return pos_x, pos_y
end

-------------------------------------
-- function getForestMovePos
-- @brief 테이머가 움직일 좌표를 계산한다.
-------------------------------------
function ForestTerritory:getForestMovePos(location)
    local node_pos = self.m_ground:convertToNodeSpace(location)
    local left, right, bottom, top = self:getGroundRange()
    node_pos['x'] = math_clamp(node_pos['x'], left, right)
    node_pos['y'] = math_clamp(node_pos['y'], bottom, top)
    return node_pos
end

-------------------------------------
-- function dragBackground
-- @brief 배경을 드래그 한다.
-- @comment 미사용
-------------------------------------
function ForestTerritory:dragBackground(location)
    local dt_x = self.m_touchPosition['x'] - location['x']
    self.m_bgCurrPosX = self.m_bgCurrPosX - (dt_x * 0.5)
    self.m_touchPosition = location

    local range = BG_RANGE_X/2
    if (self.m_bgCurrPosX > range) then
        self.m_bgCurrPosX = range
    elseif (self.m_bgCurrPosX < -range) then
        self.m_bgCurrPosX = -range
    end

    self:setPosition(self.m_bgCurrPosX, BG_POS_Y, false)
end

-------------------------------------
-- function checkObjectTouch
-- @brief 해당 물체를 터치했는지 체크
-------------------------------------
function ForestTerritory:checkObjectTouch(touch_pos, forest_object)
    if (not forest_object) then
        return
    end

    local world_pos = convertToWorldSpace(forest_object.m_animator.m_node)
    local distance = getDistance(touch_pos['x'], touch_pos['y'], world_pos['x'], world_pos['y'])

    return (distance <= 70)
end








-------------------------------------
-- function onEvent
-------------------------------------
function ForestTerritory:onEvent(event_name, struct_event)
    -- 드래곤 자유 이동
    if (event_name == 'forest_dragon_move_free') then
        local dragon = struct_event:getObject()
        local pos_x, pos_y = self:getRandomPos()
        local speed = struct_event:getSpeed()
        dragon:setMove(pos_x, pos_y, speed)
    
    -- 물체 앞에서 이동 왜일까?
    elseif (event_name == 'forest_dragon_move_stuff') then
        local dragon = struct_event:getObject()
        local stuff_type = struct_event:getStuff()
        local curr_x, _ = dragon:getPosition()
        local pos_x, pos_y = self.m_lStuffList[stuff_type]:getPosition()
        local factor_x = (curr_x < pos_x) and 1 or -1
        factor_x = factor_x * math_random(50, 150)
        local factor_y = -100
        local speed = math_random(100, 400)
        dragon:setMove(pos_x + factor_x, pos_y + factor_y, speed)

    -- 테이머 이동 시작/종료
    elseif (event_name == 'forest_tamer_move_start') then
        self.m_moveIndicator:setVisible(true)
    elseif (event_name == 'forest_tamer_move_end') then
        self.m_moveIndicator:setVisible(false)
        
    end
end