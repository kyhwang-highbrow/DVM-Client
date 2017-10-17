local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_X
-------------------------------------
SkillIndicator_X = class(PARENT, {
		m_indicatorAddEffect = '',
		m_lineSize = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_X:init(hero, t_skill)
	self.m_lineSize = g_constant:get('SKILL', 'VOLTES_LINE_SIZE')
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_X:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local l_collision = self:findCollision(x, y)
    
    self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 위치
    self.m_indicatorEffect:setPosition(x - pos_x, y - pos_y)
	self.m_indicatorAddEffect:setPosition(x - pos_x, y - pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(l_collision)
end



-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_X:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- X
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'voltes_x')
        local indicator = MakeAnimator(indicator_res)
        
		self:initIndicatorEffect(indicator)

		root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end

    do -- Cursor
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'round')
        local indicator = MakeAnimator(indicator_res)
        
		indicator:setScale(0.2)
		self:initIndicatorEffect(indicator)

        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end
end


-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_X:onChangeTargetCount(old_target_count, cur_target_count)
    -- 활성화
    if (cur_target_count > 0) then
		-- 타겟수에 따른 보너스 등급 저장
		self.m_bonus = DragonSkillBonusHelper:getBonusLevel(self.m_hero, cur_target_count)

		if (self.m_preBonusLevel ~= self.m_bonus) then
			self:onChangeIndicatorEffect(self.m_indicatorEffect, self.m_bonus, self.m_preBonusLevel)
			self:onChangeIndicatorEffect(self.m_indicatorAddEffect, self.m_bonus, self.m_preBonusLevel)
		end

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_bonus = -1
		self:initIndicatorEffect(self.m_indicatorEffect)
		self:initIndicatorEffect(self.m_indicatorAddEffect)
    end

	self.m_preBonusLevel = self.m_bonus
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillIndicator_X:findCollision(pos_x, pos_y)
	local l_target = self:getProperTargetList()
		
    local std_width = CRITERIA_RESOLUTION_X
	local std_height = CRITERIA_RESOLUTION_Y
	
	local target_x, target_y = pos_x, pos_y

    local collisions1 = self:findCollisionEachLine(l_target, target_x, target_y, std_width, std_height, 1)
    local collisions2 = self:findCollisionEachLine(l_target, target_x, target_y, std_width, std_height, 2)
    
	-- 하나의 리스트로 merge
    local l_ret = mergeCollisionLists({
        collisions1,
        collisions2
    })

    -- 거리순으로 정렬(필요할 경우)
    table.sort(l_ret, function(a, b)
        return (a:getDistance() < b:getDistance())
    end)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)
	
	return l_ret
end

-------------------------------------
-- function findCollisionEachLine
-------------------------------------
function SkillIndicator_X:findCollisionEachLine(l_target, target_x, target_y, std_width, std_height, idx)
	local start_x = target_x - std_width
	local start_y = target_y - (std_height * (math_pow(-1, idx)))
		
	local end_x = target_x + std_width
	local end_y = target_y + (std_height * (math_pow(-1, idx)))

	return SkillTargetFinder:findCollision_Bar(l_target, start_x, start_y, end_x, end_y, self.m_lineSize/2)
end