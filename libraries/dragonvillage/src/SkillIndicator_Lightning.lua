-------------------------------------
-- class SkillIndicator_Lightning
-------------------------------------
SkillIndicator_Lightning = class(SkillIndicator, {
        m_range = 'num',            -- 반지름
        m_indicatorEffect01 = '',
        m_indicatorLinkEffect = '',
        m_indicatorScale = 'num',
        m_isFixedOnTarget = 'bool', 
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Lightning:init(hero, t_skill, isFixedOnTarget)
    self.m_range = t_skill['val_2']
    self.m_isFixedOnTarget = isFixedOnTarget 
    
    if (self.m_range < 1) then 
        self.m_range = 150
    end

    self.m_indicatorScale = 1
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Lightning:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local x, y = x, y
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

    local t_collision_obj = self:findTargetList(x, y, self.m_range, self.m_isFixedOnTarget)
    self.m_targetChar = t_collision_obj[1]

    if self.m_isFixedOnTarget and self.m_targetChar then
        x = self.m_targetChar.pos.x
        y = self.m_targetChar.pos.y
    end

    -- 이펙트 위치
    LinkEffect_refresh(self.m_indicatorLinkEffect, 0, 0, x - pos_x, y - pos_y)
    self.m_indicator2:setPosition(x-pos_x, y-pos_y)
    
    self.m_targetPosX = x
    self.m_targetPosY = y

    local skill_indicator_mgr = self:getSkillIndicatorMgr()

    local old_target_count = 0

    local old_highlight_list = self.m_highlightList

    if self.m_highlightList then
        old_target_count = #self.m_highlightList
    end

    --local t_collision_obj = self:findTarget(x, y)

    for i,target in ipairs(t_collision_obj) do            
        if (not target.m_targetEffect) then
            skill_indicator_mgr:addHighlightList(target)
            self:makeTargetEffect(target)
        end
    end

    if old_highlight_list then
        for i,v in ipairs(old_highlight_list) do
            local find = false
            for _,v2 in ipairs(t_collision_obj) do
                if (v == v2) then
                    find = true
                    break
                end
            end
            if (find == false) then
                if (v ~= self.m_hero) then
                    skill_indicator_mgr:removeHighlightList(v)
                else
                    v:removeTargetEffect(v)
                end
            end
        end
    end

    self.m_highlightList = t_collision_obj

    local cur_target_count = #self.m_highlightList
    self:onChangeTargetCount(old_target_count, cur_target_count)
end



-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Lightning:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator('res/indicator/indicator_effect_cast/indicator_effect_cast.vrp')
        indicator:setTimeScale(5)
        indicator:changeAni('normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect01 = indicator
    end

    do
        local link_effect = LinkEffect('res/indicator/indicator_type_target/indicator_type_target.vrp', 'normal_bar_idle', 'normal_start_idle', 'normal_end_idle', 200, 200)
        root_node:addChild(link_effect.m_node)
        self.m_indicatorLinkEffect = link_effect
    end

    do
        local indicator = MakeAnimator('res/indicator/indicator_type_range/indicator_type_range.vrp')
        indicator:setTimeScale(5)
        indicator:setScale(self.m_indicatorScale)
        indicator:changeAni('skill_range_normal', false)
        root_node:addChild(indicator.m_node)
        self.m_indicator2 = indicator
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Lightning:onChangeTargetCount(old_target_count, cur_target_count)
    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorLinkEffect.m_startPointNode:changeAni('enemy_start_idle', true)
        self.m_indicatorLinkEffect.m_effectNode:changeAni('enemy_bar_idle', true)
        self.m_indicatorLinkEffect.m_endPointNode:changeAni('enemy_end_idle', true)
        self.m_indicator2:changeAni('skill_range_enemy', true)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorLinkEffect.m_startPointNode:changeAni('normal_start_idle', true)
        self.m_indicatorLinkEffect.m_effectNode:changeAni('normal_bar_idle', true)
        self.m_indicatorLinkEffect.m_endPointNode:changeAni('normal_end_idle', true)
        self.m_indicator2:changeAni('skill_range_normal', true)
    end
end


-------------------------------------
-- function findTargetList
-------------------------------------
function SkillIndicator_Lightning:findTargetList(x, y, range, isFixedOnTarget)
    local target = self:_findTarget(x, y, range, isFixedOnTarget)

    if isFixedOnTarget and target then
        x, y = target.pos.x, target.pos.y
    end

    local world = self:getWorld()
    local target_formation_mgr = nil

    if self.m_hero.m_bLeftFormation then
        target_formation_mgr = world.m_rightFormationMgr
    else
        target_formation_mgr = world.m_leftFormationMgr
    end

    local l_target = target_formation_mgr:findNearTarget(x, y, range, -1, EMPTY_TABLE)
    
    return l_target
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_Lightning:_findTarget(x, y, range, isFixedOnTarget)
    local world = self:getWorld()
    local target_formation_mgr = nil

    if self.m_hero.m_bLeftFormation then
        target_formation_mgr = world.m_rightFormationMgr
    else
        target_formation_mgr = world.m_leftFormationMgr
    end

    if isFixedOnTarget then
        range = -1 -- 전역에서 적 선택
    end
     
    local l_target = target_formation_mgr:findNearTarget(x, y, range, 1, EMPTY_TABLE)
    
    return l_target[1]
end