-------------------------------------
-- class EffectTimer
-------------------------------------
EffectTimer = class({
        m_node = 'cc.Node',
    })

-------------------------------------
-- function init
-------------------------------------
function EffectTimer:init()
    local sprite = cc.Sprite:create('res/temp_timer_effect.png')
    local progress_timer = cc.ProgressTimer:create(sprite)
    progress_timer:setScale(0.7)

    progress_timer:setType(0)
    progress_timer:setReverseDirection(true)
    progress_timer:setPercentage(100)

    self.m_node = progress_timer
end

-------------------------------------
-- function setPercentage
-------------------------------------
function EffectTimer:setPercentage(percentage)
    self.m_node:setPercentage(percentage)
end