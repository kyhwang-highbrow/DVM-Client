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
function SkillIndicator_X:onTouchMoved(x, y, is_virtual_test)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local l_collision = self:findCollision(x, y)
    
    self.m_targetPosX = x
    self.m_targetPosY = y

    if (is_virtual_test) then
        self.m_collisionListByVirtualTest = l_collision

    else
        -- 이펙트 위치
        self.m_indicatorEffect:setPosition(x - pos_x, y - pos_y)
	    self.m_indicatorAddEffect:setPosition(x - pos_x, y - pos_y)

	    -- 하이라이트 갱신
        self:setHighlightEffect(l_collision)
    end
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

-------------------------------------
-- function optimizeIndicatorData
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator_X:optimizeIndicatorData(l_target, fixed_target)
    local max_count = -1
    local t_best
    
    local gap_size = self.m_lineSize / 2
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    
    local count_x = math_floor(CRITERIA_RESOLUTION_X / gap_size) - 1
    local count_y = math_floor(CRITERIA_RESOLUTION_Y / gap_size) - 1
    local center_x
    local center_y

    do
        local target = l_target[1]
        center_x = target['pos']['x']
        center_y = target['pos']['y']
    end

    for i = 1, count_y do
        for j = 1, count_x do
            local x = j * gap_size + cameraHomePosX
            local y = i * gap_size + cameraHomePosY - CRITERIA_RESOLUTION_Y / 2

            local count = self:getCollisionCountByVirtualTest(x, y, fixed_target)
            local distance = getDistance(x, y, center_x, center_y)

            local b = false

            if (max_count < count) then
                max_count = count
                b = true

            elseif (max_count == count) then
                if (t_best and t_best['distance'] > distance) then
                    b = true
                end
            end

            if (b) then
                t_best = { 
                    target = self.m_targetChar,
                    x = x,
                    y = y,
                    distance = distance
                }
            end
        end
    end

    if (max_count > 0) then
        self:setIndicatorData(t_best['x'], t_best['y'])
        return true
    end

    return false
end

-------------------------------------
-- function optimizeIndicatorDataByArena
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator_X:optimizeIndicatorDataByArena(l_target)
    local max_value = -1
    local t_best
    
    local gap_size = self.m_lineSize / 2
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    
    local count_x = math_floor(CRITERIA_RESOLUTION_X / gap_size) - 1
    local count_y = math_floor(CRITERIA_RESOLUTION_Y / gap_size) - 1
    local center_x
    local center_y

    do
        local target = l_target[1]
        center_x = target['pos']['x']
        center_y = target['pos']['y']
    end

    for i = 1, count_y do
        for j = 1, count_x do
            local x = j * gap_size + cameraHomePosX
            local y = i * gap_size + cameraHomePosY - CRITERIA_RESOLUTION_Y / 2

            local value = self:getTotalSortValueByVirtualTest(x, y)
            local distance = getDistance(x, y, center_x, center_y)

            local b = false

            if (max_value < value) then
                max_value = value
                b = true

            elseif (max_value == value) then
                if (t_best and t_best['distance'] > distance) then
                    b = true
                end
            end

            if (b) then
                t_best = { 
                    target = self.m_targetChar,
                    x = x,
                    y = y,
                    distance = distance
                }
            end
        end
    end

    if (max_value > 0) then
        self:setIndicatorData(t_best['x'], t_best['y'])
        return true
    end

    return false
end