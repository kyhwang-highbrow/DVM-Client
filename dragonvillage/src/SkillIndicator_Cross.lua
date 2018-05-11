local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_Cross
-------------------------------------
SkillIndicator_Cross = class(PARENT, {
        m_indicatorAddEffect = '',
        m_lineSize = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Cross:init(hero, t_skill)
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_Cross:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('cross', skill_size)  

		self.m_indicatorScale = t_data['scale']
		self.m_lineSize = t_data['size']
	else
        self.m_indicatorScale = 1
        self.m_lineSize = g_constant:get('SKILL', 'CROSS_SIZE')
    end
end

  
-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Cross:onTouchMoved(x, y)
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
function SkillIndicator_Cross:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- cross
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'cross')
        local indicator = MakeAnimator(indicator_res)
        
        indicator:setScale(self.m_indicatorScale)
		self:initIndicatorEffect(indicator)

		root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end

    do -- Cursor
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'round')
        local indicator = MakeAnimator(indicator_res)
        
		indicator:setScale(0.2 * self.m_indicatorScale)
		self:initIndicatorEffect(indicator)

        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Cross:onChangeTargetCount(old_target_count, cur_target_count)
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
function SkillIndicator_Cross:findCollision(pos_x, pos_y)
    local l_target = self:getProperTargetList()
		
	local std_width = CRITERIA_RESOLUTION_X
	local std_height = CRITERIA_RESOLUTION_Y
	
	local target_x, target_y = pos_x, pos_y

    local collisions1 = self:findCollisionEachLine(l_target, target_x, target_y, 0, std_height, 1)
    local collisions2 = self:findCollisionEachLine(l_target, target_x, target_y, std_width, 0, 2)
    
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
function SkillIndicator_Cross:findCollisionEachLine(l_target, target_x, target_y, std_width, std_height, idx)
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
function SkillIndicator_Cross:optimizeIndicatorData(l_target, fixed_target)
    local max_count = -1
    local t_best = {}
    
    local setIndicator = function(target, x, y)
        self.m_targetChar = target
        self.m_targetPosX = x
        self.m_targetPosY = y
        self.m_critical = nil
        self.m_bDirty = true

        self:getTargetForHighlight() -- 타겟 리스트를 사용하지 않고 충돌리스트 수로 체크

        local list = self.m_collisionList or {}
        local count = #list

        -- 반드시 포함되어야하는 타겟이 존재하는지 확인
        if (fixed_target) then
            if (not table.find(self.m_highlightList, fixed_target)) then
                count = -1
            end
        end
        
        return count
    end

    local half_line_size = self.m_lineSize / 2
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    
    local count_x = math_floor(CRITERIA_RESOLUTION_X / half_line_size) - 1
    local count_y = math_floor(CRITERIA_RESOLUTION_Y / half_line_size) - 1
    local center_x
    local center_y

    do
        local target = l_target[1]
        center_x = target['pos']['x']
        center_y = target['pos']['y']
    end

    for i = 1, count_y do
        for j = 1, count_x do
            local x = j * half_line_size + cameraHomePosX
            local y = i * half_line_size + cameraHomePosY - CRITERIA_RESOLUTION_Y / 2

            local count = setIndicator(nil, x, y)
            local distance = getDistance(x, y, center_x, center_y)

            local b = false

            if (max_count < count) then
                max_count = count
                b = true

            elseif (max_count == count) then
                if (t_best['distance'] > distance) then
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
        setIndicator(t_best['target'], t_best['x'], t_best['y'])
        return true
    end

    return false
end