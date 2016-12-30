local PARENT = class(Camera, IEventListener:getCloneTable())

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
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyMap:init(parent, z_order)
    self:makeTouchLayer(self.m_rootNode)
    self.m_bMoveState = false
    self.m_lLobbyTamer = {}
    self.m_lLobbyTamerBotOnly = {}
end

-------------------------------------
-- function addLayer_lobbyGround
-- @brief 터치 레이어 생성
-------------------------------------
function LobbyMap:addLayer_lobbyGround(node, perspective_ratio, perspective_ratio_y)
    self:addLayer(node, perspective_ratio, perspective_ratio_y)

    self.m_lobbyIndicator = MakeAnimator('res/ui/a2d/lobby_indicator/lobby_indicator.vrp')
    self.m_lobbyIndicator:changeAni('idle', true)
    node:addChild(self.m_lobbyIndicator.m_node, 0)
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

    self.m_bPress = true

    self.m_lobbyIndicator:changeAni('appear', false)
    self.m_lobbyIndicator:addAniHandler(function()
            self.m_lobbyIndicator:changeAni('idle', true)
        end)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function LobbyMap:onTouchMoved(touches, event)
    local location = touches[1]:getLocation()
    self.m_touchPosition = location
    
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function LobbyMap:onTouchEnded(touches, event)
    self.m_bPress = false
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

    local max_scale = 1.05
    local min_scale = 0.8
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

    do -- 이펙트위치 체크
        if (self.m_targetTamer.m_state == 'move') then
            self.m_lobbyIndicator:setVisible(true)
        else
            self.m_lobbyIndicator:setVisible(false)
        end
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
function LobbyMap:makeLobbyTamerBot()
    local lobby_map = self
    local lobby_ground = self.m_groudNode

    local tamer = LobbyTamerBot()
    if (math_random(1, 2) == 1) then
        tamer:initAnimator('res/character/tamer/leon/leon.spine')
    else
        tamer:initAnimator('res/character/tamer/nuri/nuri.spine')
    end

    local flip = (math_random(1, 2) == 1) and true or false

    tamer:initState()
    tamer:changeState('idle')
    tamer:initSchedule()

    do
        local table_dragon = TableDragon()
        local t_dragon = table_dragon:getRandomRow()
        local res = AnimatorHelper:getDragonResName(t_dragon['res'], 1, t_dragon['attr'])

        tamer:initDragonAnimator(res, flip)
    end
    
    lobby_ground:addChild(tamer.m_rootNode)

    

    tamer.m_animator:setFlip(flip)


    tamer.m_funcGetRandomPos = function()
        return lobby_map:getLobbyMapRandomPos()
    end

    self:addLobbyTamer(tamer, true)

    local x, y = lobby_map:getLobbyMapRandomPos()
    tamer:setPosition(x, y)
end

-------------------------------------
-- function addLobbyTamer
-------------------------------------
function LobbyMap:addLobbyTamer(tamer, is_bot)
    table.insert(self.m_lLobbyTamer, tamer)

    if (is_bot) then
        table.insert(self.m_lLobbyTamerBotOnly, tamer)
    end

    do -- 그림자 생성
        local lobby_shadow = LobbyShadow(1)
        self.m_groudNode:addChild(lobby_shadow.m_rootNode)

        -- 그림자가 이동 이벤트 등록
        lobby_shadow:addListener('lobby_shadow_move', self)

        -- 테이머가 이동하면 그림자도 함께 이동
        tamer:addListener('lobby_tamer_move', lobby_shadow)
    end

    -- 테이머가 이동했을 때 LobbyMap에서 ZOrder와 Scale을 변경
    tamer:addListener('lobby_tamer_move', self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyMap:onEvent(event_name, ...)
    -- 테이머의 위치가 변경되었을 경우
    if (event_name == 'lobby_tamer_move') then
        local arg = {...}
        local lobby_tamer = arg[1]
        local x = arg[2]
        local y = arg[3]

        -- Y위치에 따라 ZOrder를 변경
        local z_order = 100 + (10000 - y)
        lobby_tamer.m_rootNode:setLocalZOrder(z_order)

        -- Y위치에 따라 Scale을 변경
        local scale = self:getScaleAtYPosY(y)
        lobby_tamer.m_rootNode:setScale(scale)

    -- 그림자의 위치가 변경되었을 경우
    elseif (event_name == 'lobby_shadow_move') then
        local arg = {...}
        local lobby_shadow = arg[1]
        local x = arg[2]
        local y = arg[3]

        -- Y위치에 따라 Scale을 변경
        local scale = self:getScaleAtYPosY(y)
        lobby_shadow.m_rootNode:setScale(scale)
    end
end