-- Target Type(타겟형 or 단일형)
-- Range Type(범위형)
-- Straight Type(직선형)

-------------------------------------
-- class SkillIndicator_Range
-------------------------------------
SkillIndicator_Range = class(SkillIndicator, {
        m_indicatorEffect01 = '',
        m_bUseHighlight = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Range:init(hero)
    self.m_bUseHighlight = true
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Range:onTouchMoved(x, y)

    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local x, y = x, y
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()


    -- 1. 각도를 구한다.
    local dir = getDegree(pos_x, pos_y, x, y)

    -- 2. 거리를 구한다.
    local distance = getDistance(pos_x, pos_y, x, y)    

    -- 3. 거리를 벗어나면 보정을 한다. (600 픽셀 이내로)
    if (distance > 600) then
        local new_pos = getPointFromAngleAndDistance(dir, 600)
        x = pos_x + new_pos['x']
        y = pos_y + new_pos['y']
    end

    -- 인디케이터 위치 보정
    self.m_indicatorEffect01:setRotation(dir)
    self.m_indicator2:setPosition(x-pos_x, y-pos_y)


    if self.m_bUseHighlight then
        local skill_indicator_mgr = self:getSkillIndicatorMgr()

        local old_target_count = 0

        local old_highlight_list = self.m_highlightList

        if self.m_highlightList then
            old_target_count = #self.m_highlightList
        end

        local t_collision_obj = self:findTarget(x, y, 150, 3)

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
                    skill_indicator_mgr:removeHighlightList(v)
                end
            end
        end

        self.m_highlightList = t_collision_obj

        local cur_target_count = #self.m_highlightList
        self:onChangeTargetCount(old_target_count, cur_target_count)
    end

    -- 타겟 위치
    self.m_targetPosX = x
    self.m_targetPosY = y
end



-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Range:initIndicatorNode()
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
        local indicator = MakeAnimator('res/indicator/indicator_type_range/indicator_type_range.vrp')
        indicator:setTimeScale(5)
        indicator:changeAni('cast_range_normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicator1 = indicator
    end

    do
        local indicator = MakeAnimator('res/indicator/indicator_type_range/indicator_type_range.vrp')
        indicator:setTimeScale(5)
        indicator:changeAni('skill_range_normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicator2 = indicator
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Range:onChangeTargetCount(old_target_count, cur_target_count)

    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorEffect01:changeAni('enemy', true)
        self.m_indicator1:changeAni('cast_range_enemy', true)
        self.m_indicator2:changeAni('skill_range_enemy', true)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorEffect01:changeAni('normal', true)
        self.m_indicator1:changeAni('cast_range_normal', true)
        self.m_indicator2:changeAni('skill_range_normal', true)
    end

end


-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_Range:findTarget(x, y, range, count)

    local world = self:getWorld()
    local target_formation_mgr = nil

    if self.m_hero.m_bLeftFormation then
        target_formation_mgr = world.m_rightFormationMgr
    else
        target_formation_mgr = world.m_leftFormationMgr
    end

    local l_remove = {}
    -- 본인도 포함하도록 변경
    --l_remove[self.m_owner.phys_idx] = true

    local l_target = target_formation_mgr:findNearTarget(x, y, range, count, l_remove)
    
    return l_target
end
