local PARENT = EffectLinearDot
-------------------------------------
-- class EffectBezierLink
-------------------------------------
EffectBezierLink = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function EffectBezierLink:init(res)
end

-------------------------------------
-- function refreshEffect
-------------------------------------
function EffectBezierLink:refreshEffect(tar_x, tar_y, pos_x, pos_y, dir)
    local x = tar_x - pos_x
    local y = tar_y - pos_y

	-- 1. 베지어는 상대좌표로 계산
    local t_bezier_pos = getBezierPosList(x, y, 0, 0, dir)

	-- 2. 일단 전부 끈다 
	for i, effect_animator in pairs(self.m_lEffectAnimator) do
		effect_animator:setVisible(false)
	end
	
	-- 3. 각 이미지를 rotate 하기 위해서 이전 좌표 저장
	local pre_pos_x = 0
	local pre_pos_y = 0

	-- 4. 이펙트 생성 밑 불러오기
	local degree = nil 
	local effect_animator = nil
	for i, bezier_pos in ipairs(t_bezier_pos) do
		if (nil == self.m_lEffectAnimator[i]) then
			-- 없을 경우 생성
			effect_animator = self:createWithParent(self.m_node, bezier_pos['x'], bezier_pos['y'], 0, self.m_resName, 'idle', true)
			effect_animator:setAnchorPoint(cc.p(0.5, 0))
			table.insert(self.m_lEffectAnimator, effect_animator)
		else
			-- 있을 경우 꺼내와서 위치 지정
			effect_animator = self.m_lEffectAnimator[i]
			effect_animator:setVisible(true)
            effect_animator:setPosition(bezier_pos['x'], bezier_pos['y'])
		end

		degree = getDegree(pre_pos_x, pre_pos_y, bezier_pos['x'], bezier_pos['y'])
		effect_animator:setRotation(degree)
		pre_pos_x = bezier_pos['x']
		pre_pos_y = bezier_pos['y']
    end
end