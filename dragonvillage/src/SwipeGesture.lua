-------------------------------------
-- class SwipeGesture
-- @brief 카메라
-------------------------------------
SwipeGesture = class({
        m_bTouchDown = 'boolean',

        m_initialTouchPosX = 'number',
        m_initialTouchPosY = 'number',
        m_currTouchPosX = 'number',
        m_currTouchPosY = 'number',

        m_visibleSize = 'cc.Size',
        m_sensitivity = 'number', -- 감도

        m_cbSwipeEvent = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function SwipeGesture:init(target_node, cb_swipe_event)
    self.m_cbSwipeEvent = cb_swipe_event

    self.m_visibleSize = cc.Director:getInstance():getVisibleSize()
    self.m_sensitivity = 0.05

    self:makeTouchLayer(target_node)

    target_node:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function makeTouchLayer
-- @brief 터치 레이어 생성
-------------------------------------
function SwipeGesture:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = target_node:getEventDispatcher()
    --eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function SwipeGesture:onTouchBegan(touch, event)
    local location = touch:getLocation()
    self.m_initialTouchPosX = location['x']
    self.m_initialTouchPosY = location['y']
    self.m_currTouchPosX = location['x']
    self.m_currTouchPosY = location['y']

    self.m_bTouchDown = true

    return true
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SwipeGesture:onTouchMoved(touch, event)
    local location = touch:getLocation()
    self.m_currTouchPosX = location['x']
    self.m_currTouchPosY = location['y']
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function SwipeGesture:onTouchEnded(touch, event)
    self.m_bTouchDown = false
end

-------------------------------------
-- function update
-------------------------------------
function SwipeGesture:update(dt)
    if (not self.m_bTouchDown) then
        return
    end

    if (self.m_initialTouchPosX - self.m_currTouchPosX) > (self.m_visibleSize['width'] * self.m_sensitivity) then
        --cclog('SWIPE LEFT')
        self.m_bTouchDown = false
        self:event('left')

    elseif (self.m_initialTouchPosX - self.m_currTouchPosX) < -(self.m_visibleSize['width'] * self.m_sensitivity) then
        --cclog('SWIPE RIGHT')
        self.m_bTouchDown = false
        self:event('right')

    elseif (self.m_initialTouchPosY - self.m_currTouchPosY) > (self.m_visibleSize['height'] * self.m_sensitivity) then
        --cclog('SWIPE DOWN')
        self.m_bTouchDown = false
        self:event('down')

    elseif (self.m_initialTouchPosY - self.m_currTouchPosY) < -(self.m_visibleSize['height'] * self.m_sensitivity) then
        --cclog('SWIPE UP')
        self.m_bTouchDown = false
        self:event('up')

    end
end

-------------------------------------
-- function event
-------------------------------------
function SwipeGesture:event(type)
    if (not self.m_cbSwipeEvent) then
        return
    end

    self.m_cbSwipeEvent(type)
end