-- skillMenu
-- skillNode2

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function ChargeSystem:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function ChargeSystem:onTouchBegan(touch, event)
    
    -- 테이머 스킬 충전이 되어있지 않은 경우
    if self.m_tamerGauge < TAMER_SKILL_CHARGE_COUNT then
        return false
    end

    -- 버튼을 터치했을 경우
    if self:isContainPoint(touch) then
        --g_gameScene:gamePause()
        return true
    else
        return false
    end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function ChargeSystem:onTouchMoved(touch, event)
    -- 버튼을 터치했을 경우
    if self:isContainPoint(touch) then
        g_gameScene:gameResume()
    else
        g_gameScene:gamePause()
    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function ChargeSystem:onTouchEnded(touch, event)
    g_gameScene:gameResume()
end

-------------------------------------
-- function isContainPoint
-- @brief 테이머 스킬을 터치했는지 여부
-------------------------------------
function ChargeSystem:isContainPoint(touch)
    local button = self.m_ui.root
    local location = touch:getLocation()
    local node_pos = button:getParent():convertToNodeSpace(location)
    local bounding_box = button:getBoundingBox()

    if cc.rectContainsPoint(bounding_box, node_pos) then
        return true
    else
        return false
    end
end