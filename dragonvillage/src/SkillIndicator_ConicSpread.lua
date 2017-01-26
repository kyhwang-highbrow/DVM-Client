local PARENT = SkillIndicator_Conic

-------------------------------------
-- class SkillIndicator_ConicSpread
-------------------------------------
SkillIndicator_ConicSpread = class(SkillIndicator_Conic, {
		m_lSpreadEffect = '',
		m_skillType = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_ConicSpread:init(hero, t_skill)
	PARENT.init(self, hero, t_skill)

	self.m_skillRadius = t_skill['val_1']
	self.m_lSpreadEffect = {}
	self.m_skillType = t_skill['type']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_ConicSpread:onTouchMoved(x, y)
	if (self.m_siState == SI_STATE_READY) then
        return
    end

    local pos_x, pos_y = self:getAttackPosition()
    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
	
	-- 1. 각도 제한
	local t_ret = self:checkIndicatorLimit(dir, nil)
    dir = t_ret['angle']

	if (t_ret['is_change']) then 
		self.m_targetPosX = x
		self.m_targetPosY = y
	end
    
	-- 이펙트 조정
	self.m_indicatorEffect:setRotation(dir)

	-- 하이라이트 갱신
	local t_collision_obj = self:findTargetList(x, y, dir)
    self:setHighlightEffect(t_collision_obj)

	-- 전이 이펙트
	self:spreadStatusEffect(t_collision_obj, 'burn', 225)
end

-------------------------------------
-- function spreadStatusEffect
-- @brief 특정 상태이상을 전이... 시킨다
-------------------------------------
function SkillIndicator_ConicSpread:spreadStatusEffect(l_target, status_effect_type)
	local count = 1

	for i, v in pairs(self.m_lSpreadEffect) do 
		v:setVisible(false)
	end

	for i, target in pairs(l_target) do 
		-- 1. 공격 대상의 상태 효과 검색
		if (target:getStatusEffectList()[status_effect_type]) then 
			if (self.m_lSpreadEffect[count]) then 
				local effect = self.m_lSpreadEffect[count]
				effect:setPosition(target.pos.x - self.m_hero.pos.x, target.pos.y - self.m_hero.pos.y)
				effect:setVisible(true)
				count = count + 1
			else
				-- 2. 범위 지정 연출
				local effect1 = MakeAnimator(RES_INDICATOR['CONE'])
				effect1:changeAni('circle', true)
				effect1:setAlpha(0.6)
				effect1:setScale(225/150)
				self.m_indicatorRootNode:addChild(effect1.m_node, 0)
				effect1:setPosition(target.pos.x - self.m_hero.pos.x, target.pos.y - self.m_hero.pos.y)
				table.insert(self.m_lSpreadEffect, effect1)
			end
		end
	end

end