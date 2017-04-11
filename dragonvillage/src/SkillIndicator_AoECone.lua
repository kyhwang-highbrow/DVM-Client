local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_AoECone
-------------------------------------
SkillIndicator_AoECone = class(PARENT, {
		m_indicatorAddEffect = '',
		m_skillRadius = 'num',
		m_skillAngle = 'num',
		m_skillDir = 'num',
    })
	 
-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoECone:init(hero, t_skill)
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoECone:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	self.m_skillRadius = g_constant:get('SKILL', 'CONE_RANGE')
	self.m_indicatorAngleLimit = g_constant:get('SKILL', 'ANGLE_LIMIT')
	self.m_skillDir = t_skill['val_1']

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('target_cone', skill_size)  

		--self.m_indicatorScale = t_data['scale']
		self.m_skillAngle = t_data['size']
	end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoECone:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

	local touch_x, touch_y = x, y
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

	self.m_targetPosX = touch_x
    self.m_targetPosY = touch_y

	-- 이펙트 위치
	self:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)

	-- 하이라이트 갱신
	local t_collision_obj, l_collision_bodys = self:findTarget(touch_x, touch_y)
    self:setHighlightEffect(t_collision_obj, l_collision_bodys)
end

-------------------------------------
-- function setIndicatorPosition
-------------------------------------
function SkillIndicator_AoECone:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
	self.m_indicatorEffect:setPosition(touch_x - pos_x, touch_y - pos_y)
	EffectLink_refresh(self.m_indicatorAddEffect, 0, 0, touch_x - pos_x, touch_y - pos_y)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoECone:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'target_cone_' .. self.m_skillAngle)
        local indicator = MakeAnimator(indicator_res)
		
		indicator:setColor(COLOR_CYAN)
		indicator:setPosition(self:getAttackPosition())
		indicator:setRotation(self.m_skillDir)
        
		root_node:addChild(indicator.m_node)
		self.m_indicatorEffect = indicator
    end

	do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'target')
        local link_effect = EffectLink(indicator_res, 'normal_bar_idle', 'normal_start_idle', 'normal_end_idle', 200, 200)
		
		link_effect:doNotUseHead()
        
		root_node:addChild(link_effect.m_node)
        self.m_indicatorAddEffect = link_effect
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_AoECone:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
	if (old_target_count == 0) and (cur_target_count > 0) then
		self.m_indicatorEffect.m_node:setColor(COLOR_RED)
		self.m_indicatorAddEffect:activateIndicator(true)

	-- 비활성화
	elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_indicatorEffect.m_node:setColor(COLOR_CYAN)
		self.m_indicatorAddEffect:activateIndicator(false)
	end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_AoECone:findTarget(x, y)
    local l_target = self:getProperTargetList()
    return SkillTargetFinder:findTarget_AoECone(l_target, x, y, self.m_skillDir, self.m_skillRadius, self.m_skillAngle)
end