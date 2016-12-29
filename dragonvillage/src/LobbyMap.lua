local PARENT = Camera

-------------------------------------
-- class LobbyMap
-- @brief 카메라
-------------------------------------
LobbyMap = class(PARENT, {
        m_groudNode = 'cc.Node',
        m_targetTamer = '',

        m_bPress = 'bool',
        m_nodePosition = 'cc.p',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyMap:init(parent, z_order)
    self:makeTouchLayer(self.m_rootNode)
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
    local node_pos = self.m_groudNode:convertToNodeSpace(location)
    self.m_nodePosition = node_pos

    self.m_bPress = true
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function LobbyMap:onTouchMoved(touches, event)
    local location = touches[1]:getLocation()
    local node_pos = self.m_groudNode:convertToNodeSpace(location)
    self.m_nodePosition = node_pos
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function LobbyMap:onTouchEnded(touches, event)
    self.m_bPress = false
end


-------------------------------------
-- function update
-------------------------------------
function LobbyMap:update(dt)
    if (not self.m_targetTamer) then
        return
    end

    if self.m_bPress then
        self.m_targetTamer:setMove(self.m_nodePosition['x'], self.m_nodePosition['y'], 400)
    end

    local x, y = self.m_targetTamer.m_rootNode:getPosition()

    self:setPosition(-x, 0, true)
end