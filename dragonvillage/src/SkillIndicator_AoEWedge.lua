local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_AoEWedge
-------------------------------------
SkillIndicator_AoEWedge = class(PARENT, {
		m_skillRange = 'num',
		m_skillAngle = 'num',
    })
	 
-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoEWedge:init(hero, t_skill)
	self.m_skillRange = g_constant:get('SKILL', 'LONG_LENGTH')
	self.m_indicatorAngleLimit = g_constant:get('SKILL', 'ANGLE_LIMIT')
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoEWedge:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('wedge', skill_size)  

		self.m_indicatorScale = 1
		self.m_skillAngle = t_data['size']
	end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoEWedge:onTouchMoved(x, y, is_virtual_test)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local pos_x, pos_y = self:getAttackPosition()
	local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
	
	-- 1. 각도 제한
	local t_ret = self:checkIndicatorLimit(dir, nil)
    dir = t_ret['angle']

	if (t_ret['is_change']) then 
		self.m_targetPosX = x
		self.m_targetPosY = y
	end

    local l_collision = self:findCollision(pos_x, pos_y, dir)

    if (is_virtual_test) then
        self.m_collisionListByVirtualTest = l_collision
	
    else
	    -- 이펙트 조정
	    self.m_indicatorEffect:setRotation(dir)

	    -- 하이라이트 갱신
	    self:setHighlightEffect(l_collision)
    end
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoEWedge:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'wedge'..self.m_skillAngle)
        local indicator = MakeAnimator(indicator_res)
		
		indicator:setPosition(self:getAttackPosition())
		indicator:setScale(self.m_indicatorScale)
		self:initIndicatorEffect(indicator)

        root_node:addChild(indicator.m_node)
		self.m_indicatorEffect = indicator
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillIndicator_AoEWedge:findCollision(pos_x, pos_y, dir)
	local l_target = self:getProperTargetList()
	local l_ret = SkillTargetFinder:findCollision_AoECone(l_target, pos_x, pos_y, dir, self.m_skillRange, self.m_skillAngle)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function optimizeIndicatorData
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator_AoEWedge:optimizeIndicatorData(l_target, fixed_target)
    local max_count = -1
    local t_best = {}
    
    local x, y = self:getAttackPosition()
    local l_dir = {}
    local dir = 0

    while (dir < (self.m_indicatorAngleLimit * 2)) do
        local temp

        if (self.m_hero.m_bLeftFormation) then
            temp = dir - self.m_indicatorAngleLimit
        else
            temp = dir + 180 - self.m_indicatorAngleLimit
        end

        table.insert(l_dir, getAdjustDegree(temp))

        dir = dir + 1    
    end

    -- 각도 리스트를 한번 섞는다(랜덤한 위치로 사용되도록 하기 위함)
    l_dir = randomShuffle(l_dir)

    for _, dir in ipairs(l_dir) do
        local pos = getPointFromAngleAndDistance(dir, self.m_skillRange)
        local count = self:getCollisionCountByVirtualTest(x + pos['x'], y + pos['y'], fixed_target)

        if (max_count < count) then
            max_count = count

            t_best = { 
                target = self.m_targetChar,
                x = self.m_targetPosX,
                y = self.m_targetPosY
            }
        end

        if (max_count >= self.m_targetLimit) then break end
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
function SkillIndicator_AoEWedge:optimizeIndicatorDataByArena(l_target)
    local t_best
    
    local x, y = self:getAttackPosition()
    local l_dir = {}
    local dir = 0

    while (dir < (self.m_indicatorAngleLimit * 2)) do
        local temp

        if (self.m_hero.m_bLeftFormation) then
            temp = dir - self.m_indicatorAngleLimit
        else
            temp = dir + 180 - self.m_indicatorAngleLimit
        end

        table.insert(l_dir, getAdjustDegree(temp))

        dir = dir + 1    
    end

    -- 각도 리스트를 한번 섞는다(랜덤한 위치로 사용되도록 하기 위함)
    l_dir = randomShuffle(l_dir)

    for _, dir in ipairs(l_dir) do
        local pos = getPointFromAngleAndDistance(dir, self.m_skillRange)
        local value, count = self:getTotalSortValueByVirtualTest(x + pos['x'], y + pos['y'])
        local b = false

        if (count > 0) then
            if (not t_best) then
                b = true
            elseif (t_best['value'] < value) then
                b = true
            elseif (t_best['value'] == value and t_best['count'] < count) then
                b = true
            end
        end

        if (b) then
            t_best = { 
                target = self.m_targetChar,
                x = self.m_targetPosX,
                y = self.m_targetPosY,
                value = value,
                count = count
            }
        end
    end
        
    if (t_best) then
        self:setIndicatorData(t_best['x'], t_best['y'])
        return true
    end

    return false
end