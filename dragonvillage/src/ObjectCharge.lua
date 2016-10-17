-------------------------------------
-- class ObjectCharge
-------------------------------------
ObjectCharge = class({
        m_world = '',
        m_animator = '',
        m_target = '',
        m_targetChargeSkill = '',
     })

local OBJECT_CHARGE_SCALE = 1

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function ObjectCharge:init(world, x, y, target)
    self.m_world = world
    self.m_animator = MakeAnimator(EMPTY_PNG)
    self.m_animator:setVisible(false)

    self.m_targetChargeSkill = target
    self.m_target = target.m_ownerChar


    self.m_animator:setPosition(x, y)
    self.m_world:addChild2(self.m_animator.m_node, DEPTH_ITEM_CHARGE)

    self.m_animator:setScale(OBJECT_CHARGE_SCALE)

    -- Action 생성
    local bezier
    if math_random(1, 2) == 1 then
        bezier = {
            cc.p(x, y),
            cc.p(x + math_random(0, 50), y + math_random(50, 180)),
            cc.p(x + math_random(0, 100), y - math_random(-50, 50))
        }
    else
        bezier = {
            cc.p(x, y),
            cc.p(x - math_random(0, 50), y + math_random(50, 180)),
            cc.p(x - math_random(0, 100), y - math_random(-50, 50))
        }
    end
    local last_pos = bezier[3]
    
    local orb_scale = (math_random(2, 6) / 10) * OBJECT_CHARGE_SCALE

    -- 드롭, 딜레이 액션
    local time = math_random(20, 60) / 100
    local spawn1 = cc.Spawn:create(cc.BezierTo:create(time * 1.6, bezier), cc.ScaleTo:create(time, orb_scale, orb_scale))
    self.m_animator:runAction(cc.Sequence:create(spawn1, cc.DelayTime:create(1.4), cc.CallFunc:create(function() self:action2() end)))
end

-------------------------------------
-- function action2
-------------------------------------
function ObjectCharge:action2()

    local target = self.m_target

    if target then
        local x, y = self.m_animator.m_node:getPosition()
        local distance = getDistance(x, y, target.pos.x, target.pos.y)
        local duration = distance / 1500
        local move_action = cc.MoveTo:create(duration, cc.p(target.pos.x, target.pos.y))
        local move_ease = cc.EaseOut:create(move_action, 0.5)
        self.m_animator:runAction(cc.Sequence:create(move_ease,
            cc.CallFunc:create(function() self:charge() end),
            cc.RemoveSelf:create()))

    else
        self.m_animator:runAction(cc.Sequence:create(cc.ScaleTo:create(OBJECT_CHARGE_SCALE * 0.5, 0), cc.RemoveSelf:create()))
    end

end

-------------------------------------
-- function charge
-------------------------------------
function ObjectCharge:charge()
    self.m_targetChargeSkill:addGauge(SKILL_CARGE_OBJECT)
end