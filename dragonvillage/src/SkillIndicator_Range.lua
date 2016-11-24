-- Target Type(타겟형 or 단일형)
-- Range Type(범위형)
-- Straight Type(직선형)

-------------------------------------
-- class SkillIndicator_Range
-------------------------------------
SkillIndicator_Range = class(SkillIndicator, {
        m_indicatorAddEffect = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Range:init(hero)
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

    local t_collision_obj = self:findTarget(x, y, 150, 3)

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

    -- 타겟 위치
    self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 조정
    self.m_indicatorEffect:setPosition(x-pos_x, y-pos_y)
    self.m_indicatorAddEffect:setRotation(dir)

	-- 하이라이트 갱신
	self:setHighlightEffect(t_collision_obj)
end



-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Range:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

	-- 타겟 이펙트
    do
        local indicator = MakeAnimator(RES_INDICATOR['RANGE'])
        indicator:setTimeScale(5)
        indicator:changeAni('skill_range_normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end

	-- 사정거리 이펙트
    do
        local indicator = MakeAnimator(RES_INDICATOR['RANGE'])
        indicator:setTimeScale(5)
        indicator:changeAni('cast_range_normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Range:onChangeTargetCount(old_target_count, cur_target_count)
    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorEffect:changeAni('skill_range_enemy', true)
        self.m_indicatorAddEffect:changeAni('cast_range_enemy', true)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorEffect:changeAni('skill_range_normal', true)
        self.m_indicatorAddEffect:changeAni('cast_range_normal', true)
    end
end


-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_Range:findTarget(x, y, range, count)
    local target_formation_mgr = self.m_hero:getFormationMgr()
    local l_target = target_formation_mgr:findNearTarget(x, y, range, count, {})
    
    return l_target
end
