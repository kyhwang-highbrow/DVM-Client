-------------------------------------
-- class EffectMotionStreak
-------------------------------------
EffectMotionStreak = class({
        m_node = 'cc.MotionStreak'
     })

-------------------------------------
-- function init
-------------------------------------
function EffectMotionStreak:init(world, t_param)
    local res = t_param['res'] or RES_SE_MS
    local x = t_param['x'] or 0
    local y = t_param['y'] or 0
    local tar_x = t_param['tar_x'] or 0
    local tar_y = t_param['tar_y'] or 0
    local color = t_param['color']
    local course = t_param['course'] or math_random(-1, 1)
    local cb_end = t_param['cb_end'] or function() end

    self.m_node = cc.MotionStreak:create(1, -1, 50, cc.c3b(255, 255, 255), res)
    self.m_node:setPosition(x, y)
    world:addChild2(self.m_node, DEPTH_ITEM_GOLD)

	if (color) then
		self.m_node:setColor(color)
	end

    local bezier = getBezier(tar_x, tar_y, x, y, course)

    self.m_node:setBezierMode(true)
    self.m_node:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.05),
        cc.BezierBy:create(0.5, bezier, true),
        cc.CallFunc:create(cb_end),
        cc.RemoveSelf:create()
    ))
end