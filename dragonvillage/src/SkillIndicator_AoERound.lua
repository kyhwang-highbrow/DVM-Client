local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_AoERound
-------------------------------------
SkillIndicator_AoERound = class(PARENT, {
        m_indicatorAddEffect = '',
        m_range = 'num',            -- 반지름
		m_isFixedOnTarget = 'bool', 
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoERound:init(hero, t_skill, isFixedOnTarget)
    self.m_isFixedOnTarget = isFixedOnTarget 
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoERound:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', skill_size)  

		self.m_indicatorScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoERound:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

	local touch_x, touch_y = x, y
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local t_collision_obj = self:findTargetList(touch_x, touch_y, self.m_range, self.m_isFixedOnTarget)
    self.m_targetChar = t_collision_obj[1]
	
	if self.m_isFixedOnTarget and self.m_targetChar then
        touch_x = self.m_targetChar.pos.x
        touch_y = self.m_targetChar.pos.y
		-- 다시계산한다..!
		t_collision_obj = self:findTargetList(touch_x, touch_y, self.m_range, self.m_isFixedOnTarget)
    end

    self.m_targetPosX = touch_x
    self.m_targetPosY = touch_y
	
    -- 이펙트 위치
	self:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function setIndicatorPosition
-------------------------------------
function SkillIndicator_AoERound:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
	self.m_indicatorEffect:setPosition(touch_x - pos_x, touch_y - pos_y)
	EffectLink_refresh(self.m_indicatorAddEffect, 0, 0, touch_x - pos_x, touch_y - pos_y)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoERound:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'round')
        local indicator = MakeAnimator(indicator_res)
        indicator:setScale(self.m_indicatorScale)
        indicator:changeAni('idle', false)
		indicator.m_node:setColor(COLOR_CYAN)
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
function SkillIndicator_AoERound:onChangeTargetCount(old_target_count, cur_target_count)
    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
		self.m_indicatorEffect.m_node:setColor(COLOR_RED)
        
		self.m_indicatorAddEffect.m_startPointNode:changeAni('enemy_start_idle', true)
        self.m_indicatorAddEffect.m_effectNode:changeAni('enemy_bar_idle', true)
        self.m_indicatorAddEffect.m_endPointNode:changeAni('enemy_end_idle', true)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_indicatorEffect.m_node:setColor(COLOR_CYAN)
        
		self.m_indicatorAddEffect.m_startPointNode:changeAni('normal_start_idle', true)
        self.m_indicatorAddEffect.m_effectNode:changeAni('normal_bar_idle', true)
        self.m_indicatorAddEffect.m_endPointNode:changeAni('normal_end_idle', true)
    end
end

-------------------------------------
-- function findTargetList
-------------------------------------
function SkillIndicator_AoERound:findTargetList(x, y, range, isFixedOnTarget)
	local pos_x = x
	local pos_y = y

	local l_ret = {}
	if isFixedOnTarget then
		local target_formation_mgr = self.m_hero:getFormationMgr(true)
		l_ret = target_formation_mgr:findNearTarget(x, y, range, -1, EMPTY_TABLE)
	else
		local l_target = self.m_hero:getTargetListByType(self.m_targetType, self.m_targetFormation)
		for _, target in pairs(l_target) do
			if isCollision(pos_x, pos_y, target, range) then 
				table.insert(l_ret, target)
			end
		end
    end
    
	return l_ret
end