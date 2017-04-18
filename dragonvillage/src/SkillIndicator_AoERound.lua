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

	-- 동그라미 인디케이터
    do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'round')
        local indicator = MakeAnimator(indicator_res)
        
		indicator:setScale(self.m_indicatorScale)
		self:initIndicatorEffect(indicator)

        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end

	-- 캐릭터로부터 연결된 인디케이터
    do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'target')
        local link_effect = EffectLink(indicator_res, 'bar_idle', 'start_idle', 'end_idle', 200, 200)
		
		link_effect:doNotUseHead()
        link_effect:setColor(COLOR['light_green'])

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
			self:onChangeIndicatorEffect(self.m_indicatorEffect, self.m_bonus, self.m_preBonusLevel)
			self:onChangeIndicatorEffect(self.m_indicatorAddEffect, self.m_bonus, self.m_preBonusLevel)
			self.m_preBonusLevel = self.m_bonus
		end

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_bonus = 0
		self:initIndicatorEffect(self.m_indicatorEffect)
		self:initIndicatorEffect(self.m_indicatorAddEffect)
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