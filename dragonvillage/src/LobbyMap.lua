local PARENT = Camera

-------------------------------------
-- class LobbyMap
-- @brief 카메라
-------------------------------------
LobbyMap = class(PARENT, {
        m_groudNode = 'cc.Node',
        m_targetTamer = '',

        m_bPress = 'bool',
        m_touchPosition = 'cc.p',
        m_nodePosition = 'cc.p',

        m_bMoveState = 'bool',

        m_cbMoveStart = 'function',
        m_cbMoveEnd = 'function',

        m_lobbyIndicator = 'Animator',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyMap:init(parent, z_order)
    self:makeTouchLayer(self.m_rootNode)
    self.m_bMoveState = false
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
    local bottom = -320
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