-------------------------------------
-- class EffectLinearDot
-------------------------------------
EffectLinearDot = class({
        m_node = 'CCNode',
        m_resName = '',
        m_bar_visual = '',
        m_lEffectAnimator = 'CCNode',
    })

-------------------------------------
-- function init
-------------------------------------
function EffectLinearDot:init(res_name)
    self.m_lEffectAnimator = {}
    self.m_resName = res_name

    -- node 생성
    self.m_node = cc.Node:create()
end

-------------------------------------
-- function setVisible
-------------------------------------
function EffectLinearDot:setVisible(visible)
    self.m_node:setVisible(visible)
end

-------------------------------------
-- function refreshEffect
-------------------------------------
function EffectLinearDot:refreshEffect(tar_x, tar_y, pos_x, pos_y, dir)
    local t_line_pos = {}
	
	local degree = getDegree(tar_x, tar_y, pos_x, pos_y) + dir * g_constant:get('SKILL', 'LEAF_STRAIGHT_ANGLE')
	local std_dist = 60
    local rad = math_rad(degree)

    local factor_y = math.tan(rad)
	local dist_x = tar_x - pos_x
	local dist_y = tar_y - pos_y
    
	-- 2. 일단 전부 끈다 
	for i, effect_animator in pairs(self.m_lEffectAnimator) do
		effect_animator:setVisible(false)
	end

	-- 임의의 숫자 20개까지 만듬
	for i = 1, 20 do
        local x = dist_x + (std_dist * i)
        local y = dist_y + (std_dist * i * factor_y)
        table.insert(t_line_pos, {x = x, y = y})
    end

	-- 이펙트 생성 밑 불러오기
	local effect_animator = nil
	for i, line_pos in ipairs(t_line_pos) do
		if (nil == self.m_lEffectAnimator[i]) then
			-- 없을 경우 생성 
			effect_animator = self:createWithParent(self.m_node, line_pos['x'], line_pos['y'], 0, self.m_resName, 'idle', true)
			effect_animator.m_node:setAnchorPoint(cc.p(0.5, 0))
			table.insert(self.m_lEffectAnimator, effect_animator)
		else
			-- 있을 경우 위치 지정
			effect_animator = self.m_lEffectAnimator[i]
			effect_animator:setVisible(true)
            effect_animator:setPosition(line_pos['x'], line_pos['y'])
		end

        effect_animator:setRotation(degree + 180)
    end
end

-------------------------------------
-- function createWithParent
-------------------------------------
function EffectLinearDot:createWithParent(parent, x, y, z_order, res_name, visual_name, is_repeat)
    local animator = MakeAnimator(res_name)
    animator:changeAni(visual_name, is_repeat)
    animator.m_node:setPosition(x, y)
    parent:addChild(animator.m_node, z_order)

    return animator
end

-------------------------------------
-- function changeAni
-------------------------------------
function EffectLinearDot:changeAni(ani_name, loop, cb)
    local loop = (loop or false)

    for i, animator in pairs(self.m_lEffectAnimator) do
		animator:changeAni(ani_name, loop)
		if (cb) then
			animator:addAniHandler(function()
				cb(animator)
			end)
		end
	end
end

-------------------------------------
-- function setColor
-------------------------------------
function EffectLinearDot:setColor(color)
    for i, animator in pairs(self.m_lEffectAnimator) do
		animator:setColor(color)
	end
end

-------------------------------------
-- function release
-------------------------------------
function EffectLinearDot:release()
    for i, node in pairs(self.m_lEffectAnimator) do
        node:removeFromParent(true)
    end
    self.m_lEffectAnimator = nil
    
    if self.m_node then
        self.m_node:removeFromParent(true)
        self.m_node = nil
    end
end