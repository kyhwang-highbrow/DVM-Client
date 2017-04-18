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
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local touch_x, touch_y = x, y
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local t_collision_obj, l_collision_bodys = self:findTarget(touch_x, touch_y, self.m_range, self.m_isFixedOnTarget)
    
    self.m_targetChar = t_collision_obj[1]
	
	if self.m_isFixedOnTarget and self.m_targetChar then
        local body_keys = l_collision_bodys[1]
        local body = self.m_targetChar:getBody(body_keys[1])
        
        touch_x = self.m_targetChar.pos.x + body['x']
        touch_y = self.m_targetChar.pos.y + body['y']
		-- 다시계산한다..!
		t_collision_obj, l_collision_bodys = self:findTarget(touch_x, touch_y, self.m_range, self.m_isFixedOnTarget)
    end

    self.m_targetPosX = touch_x
    self.m_targetPosY = touch_y
	
    -- 이펙트 위치
	self:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj, l_collision_bodys)
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
        
		indicator.m_node:setColor(COLOR_CYAN)
		indicator:setScale(self.m_indicatorScale)

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
    if (cur_target_count > 0) then
		-- 타겟수에 따른 보너스 등급 저장
		self.m_bonus = DragonSkillBonusHelper:getBonusLevel(self.m_hero, cur_target_count)

		if (self.m_preBonusLevel ~= self.m_bonus) then
			if (self.m_bonus == 0) then
				self.m_indicatorEffect:changeAni('idle', true)
				self.m_indicatorEffect.m_node:setColor(cc.c3b(50, 255, 0))
			elseif (self.m_bonus == 1) then
				self.m_indicatorEffect:changeAni('idle', true)
				self.m_indicatorEffect.m_node:setColor(cc.c3b(250, 120, 0))
			elseif (self.m_bonus == 2) then
				self.m_indicatorEffect:changeAni('idle_2', true)
				self.m_indicatorEffect.m_node:setColor(cc.c3b(255, 0, 0))
			elseif (self.m_bonus == 3) then
				self.m_indicatorEffect:changeAni('idle_2', true)
				self.m_indicatorEffect.m_node:setColor(cc.c3b(255, 0, 255))
			end

			self.m_preBonusLevel = self.m_bonus
		end

		if (old_target_count == 0) then
			self.m_indicatorAddEffect:activateIndicator(true)
		end

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_bonus = 0
		self.m_indicatorEffect.m_node:setColor(COLOR_CYAN)
		self.m_indicatorEffect:changeAni('idle', true)
		self.m_indicatorAddEffect:activateIndicator(false)
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_AoERound:findTarget(x, y, range, isFixedOnTarget)
    local l_target = self:getProperTargetList()

	local pos_x = x
	local pos_y = y

	local l_ret
    local l_bodys

	if isFixedOnTarget then
        l_ret, l_bodys = SkillTargetFinder:findTarget_Near(l_target, pos_x, pos_y, range)
	else
		l_ret, l_bodys = SkillTargetFinder:findTarget_AoERound(l_target, pos_x, pos_y, range)
    end
    
	return l_ret, l_bodys
end