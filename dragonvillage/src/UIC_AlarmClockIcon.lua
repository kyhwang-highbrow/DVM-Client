-- ¾Ë¶÷ 
local PARENT = UIC_Node

-------------------------------------
-- class UIC_AlarmClockIcon
-------------------------------------
UIC_AlarmClockIcon = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_AlarmClockIcon:init(node)
end

-------------------------------------
-- function create
-------------------------------------
function UIC_AlarmClockIcon:create()
    local node = cc.Sprite:create('res/ui/frames/deadline_frame_0101.png')
    node:setDockPoint(cc.p(0.5, 1))
    node:setAnchorPoint(cc.p(0.5, 0))
    node:setPositionY(-15)


    local clock_icon = cc.Sprite:create('res/ui/icons/deadline_0101.png')
    clock_icon:setDockPoint(cc.p(0.5, 0.5))
    clock_icon:setAnchorPoint(cc.p(0.5, 0.5))
    clock_icon:setPositionY(5)

    node:addChild(clock_icon)

    return UIC_AlarmClockIcon(node)
end

-------------------------------------
-- function runAction
-------------------------------------
function UIC_AlarmClockIcon:runAction()
    local node = self.m_node
    node:stopAllActions()
    node:setScale(0)

    local appear = cc.EaseElasticOut:create(cc.ScaleTo:create(0.5, 1, 1), 0.3)

    --local idle = cc.DelayTime:create(2)
    local idle
    do
        local angle = 5
        local start_action = cc.RotateTo:create(0.05, angle)
        local end_action = cc.EaseElasticOut:create(cc.RotateTo:create(1.5, 0), 0.1)
        local sequence = cc.Sequence:create(start_action, end_action)
        idle = sequence
    end
    local disappear = cc.EaseElasticOut:create(cc.ScaleTo:create(0.5, 0, 0), 0.3)
    local delay = cc.DelayTime:create(1)
    local sequence = cc.Sequence:create(appear, idle, disappear, delay)
    
    node:runAction(cc.RepeatForever:create(sequence))
end