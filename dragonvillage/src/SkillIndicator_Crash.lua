local PARENT = SkillIndicator
-------------------------------------
-- class SkillIndicator_Crash
-- @brief 가루다의 액티스 스킬 (skill_crash)
-- t_skill
-- ['res_1']        충격파 이펙트
-- ['res_2']        돌진 이펙트 (드래곤에 붙어서 출력)
-- ['power_rate']   충격 데미지 (%)
-- ['val_1']        충격파 데미지 (%)
-- ['val_2']        충격파 반지름
-------------------------------------
SkillIndicator_Crash = class(PARENT, {
        m_indicatorAddEffect = '',
        m_skillRadius = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Crash:init(hero, t_skill)
    -- 충격파 반지름
    self.m_skillRadius = t_skill['val_2']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Crash:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

    self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 위치
    EffectLink_refresh(self.m_indicatorEffect, 0, 0, x - pos_x, y - pos_y)
    self.m_indicatorAddEffect:setPosition(x - pos_x, y - pos_y)

	-- 하이라이트 갱신
    local t_collision_obj = self:findShockwaveTarget(x, y)
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Crash:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

	-- 충돌후 파장 이펙트
    do
        local indicator = MakeAnimator(RES_INDICATOR['COMMON'])
        indicator:changeAni('fan_shape_enemy', true)
        indicator:setRotation(0)
        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end

	-- 타겟 링크이펙트
    do
        local link_effect = EffectLink(RES_INDICATOR['TARGET'], 'normal_bar_idle', 'normal_start_idle', 'normal_end_idle', 200, 200)
        link_effect:doNotUseHead()
		root_node:addChild(link_effect.m_node)
		self.m_indicatorEffect = link_effect
    end    
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Crash:onChangeTargetCount(old_target_count, cur_target_count)

    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorEffect.m_startPointNode:changeAni('enemy_start_idle', true)
        self.m_indicatorEffect.m_effectNode:changeAni('enemy_bar_idle', true)
        self.m_indicatorEffect.m_endPointNode:changeAni('enemy_end_idle', true)

        self.m_indicatorAddEffect:changeAni('fan_shape_enemy')

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorEffect.m_startPointNode:changeAni('normal_start_idle', true)
        self.m_indicatorEffect.m_effectNode:changeAni('normal_bar_idle', true)
        self.m_indicatorEffect.m_endPointNode:changeAni('normal_end_idle', true)

        self.m_indicatorAddEffect:changeAni('fan_shape_normal')

    end
end

-------------------------------------
-- function findShockwaveTarget
-------------------------------------
function SkillIndicator_Crash:findShockwaveTarget(x, y)
    local dir

    if (self.m_hero.m_bLeftFormation) then
        dir = 0
    else
        dir = 180
    end

    local l_target = self.m_owner:getTargetListByType(self.m_targetType, self.m_targetFormation)
    return SkillTargetFinder:findTarget_AoECone(l_target, x, y, dir, self.m_skillRadius, 60)

    --[[
    local world = self:getWorld()

    local t_data = {}
    t_data['x'] = x
    t_data['y'] = y
    t_data['dir'] = 0
    t_data['angle_range'] = 60 -- 변경되지 않는 값
    t_data['radius'] = self.m_skillRadius

    if self.m_hero.m_bLeftFormation then
        t_data['dir'] = 0
    else
        t_data['dir'] = 180
    end

    return world:getTargetList(self.m_hero, self.m_hero.pos.x, self.m_hero.pos.y, 'enemy', nil, 'fan_shape', t_data)
    ]]--
end