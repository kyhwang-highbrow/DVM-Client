-------------------------------------
-- class EffectMotionStreak
-------------------------------------
EffectMotionStreak = class({
        m_node = 'cc.MotionStreak'
     })

-------------------------------------
-- function init
-------------------------------------
function EffectMotionStreak:init(world, x, y, tar_x, tar_y, res, color)
    self.m_node = cc.MotionStreak:create(1, -1, 50, cc.c3b(255, 255, 255), res)
    self.m_node:setPosition(x, y)
	if (color) then
		self.m_node:setColor(color)
	end

    world:addChild2(self.m_node, DEPTH_ITEM_GOLD)

    local course = math_random(-1, 1)
    local bezier = getBezier(tar_x, tar_y, x, y, course)

    self.m_node:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.05),
        cc.BezierBy:create(0.5, bezier),
        cc.RemoveSelf:create()
    ))
end

--EffectMotionStreak(world, x, y, hero.pos.x, hero.pos.y, 'res/effect/motion_streak/motion_streak_fire.png')