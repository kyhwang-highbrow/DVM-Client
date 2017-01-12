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
    self.m_range = t_skill['val_1']
    self.m_isFixedOnTarget = isFixedOnTarget 
	
    self.m_indicatorScale = (self.m_range * 2) / 321 -- 인디케이터 'skill_range_normal' 의 지름
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoERound:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local t_collision_obj = self:findTargetList(x, y, self.m_range, self.m_isFixedOnTarget)
    self.m_targetChar = t_collision_obj[1]

    if self.m_isFixedOnTarget and self.m_targetChar then
        x = self.m_targetChar.pos.x
        y = self.m_targetChar.pos.y
    end
    
    self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 위치
    EffectLink_refresh(self.m_indicatorEffect, 0, 0, x - pos_x, y - pos_y)
    self.m_indicatorAddEffect:setPosition(x-pos_x, y-pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj)
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
        local link_effect = EffectLink(RES_INDICATOR['TARGET'], 'normal_bar_idle', 'normal_start_idle', 'normal_end_idle', 200, 200)
		link_effect:doNotUseHead()
        root_node:addChild(link_effect.m_node)
        self.m_indicatorEffect = link_effect
    end

    do
        local indicator = MakeAnimator(RES_INDICATOR['RANGE'])
        indicator:setTimeScale(5)
        indicator:setScale(self.m_indicatorScale)
        indicator:changeAni('skill_range_normal', false)
        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_AoERound:onChangeTargetCount(old_target_count, cur_target_count)
    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorEffect.m_startPointNode:changeAni('enemy_start_idle', true)
        self.m_indicatorEffect.m_effectNode:changeAni('enemy_bar_idle', true)
        self.m_indicatorEffect.m_endPointNode:changeAni('enemy_end_idle', true)
        self.m_indicatorAddEffect:changeAni('skill_range_enemy', true)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorEffect.m_startPointNode:changeAni('normal_start_idle', true)
        self.m_indicatorEffect.m_effectNode:changeAni('normal_bar_idle', true)
        self.m_indicatorEffect.m_endPointNode:changeAni('normal_end_idle', true)
        self.m_indicatorAddEffect:changeAni('skill_range_normal', true)
    end
end


-------------------------------------
-- function findTargetList
-------------------------------------
function SkillIndicator_AoERound:findTargetList(x, y, range, isFixedOnTarget)
    local x = x
	local y = y

	if isFixedOnTarget then
		local target = self:_findTarget(x, y, -1)
		if target then 
			x, y = target.pos.x, target.pos.y
		end
    end

    local world = self.m_world
	local l_target = world:getTargetList(self.m_hero, x, y, 'enemy', 'x', 'distance_line')
    
	local l_ret = {}
    local distance = 0

    for _, target in pairs(l_target) do
		if isCollision(x, y, target, range) then 
			table.insert(l_ret, target)
		end
    end
    
    return l_ret
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_AoERound:_findTarget(x, y, range)
    local target_formation_mgr = self.m_hero:getFormationMgr()
    local l_target = target_formation_mgr:findNearTarget(x, y, range, 1, EMPTY_TABLE)
    
    return l_target[1]
end