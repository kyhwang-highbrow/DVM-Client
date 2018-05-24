local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_AoECone
-------------------------------------
SkillIndicator_AoECone = class(PARENT, {
		m_indicatorAddEffect = '',
		m_skillRadius = 'num',
		m_skillAngle = 'num',
		m_skillDir = 'num',
		m_isVariableDir = 'boolean'
    })
	 
-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoECone:init(hero, t_skill)
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoECone:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	self.m_skillRadius = g_constant:get('SKILL', 'CONE_RANGE')
	self.m_indicatorAngleLimit = g_constant:get('SKILL', 'ANGLE_LIMIT')
	
	-- 고정 각도
	if (type(t_skill['val_1']) == 'number') then
		self.m_isVariableDir = false
		self.m_skillDir = t_skill['val_1']
	-- 변동 각도
	else
		self.m_isVariableDir = true
	end

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('target_cone', skill_size)  

		--self.m_indicatorScale = t_data['scale']
		self.m_skillAngle = t_data['size']
	end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoECone:onTouchMoved(x, y, is_virtual_test)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

	local touch_x, touch_y = x, y
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

	self.m_targetPosX = touch_x
    self.m_targetPosY = touch_y
	if (self.m_isVariableDir) then
		self.m_skillDir = getAdjustDegree(getDegree(pos_x, pos_y, touch_x, touch_y))
	end

	local l_collision = self:findCollision(touch_x, touch_y)

    if (is_virtual_test) then
        self.m_collisionListByVirtualTest = l_collision

    else
        -- 이펙트 위치
	    self:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)

        -- 하이라이트 갱신
        self:setHighlightEffect(l_collision)
    end
end

-------------------------------------
-- function setIndicatorPosition
-------------------------------------
function SkillIndicator_AoECone:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
	self.m_indicatorEffect:setPosition(touch_x - pos_x, touch_y - pos_y)
	self.m_indicatorEffect:setRotation(self.m_skillDir)
	EffectLink_refresh(self.m_indicatorAddEffect, 0, 0, touch_x - pos_x, touch_y - pos_y)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoECone:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'target_cone_' .. self.m_skillAngle)
        local indicator = MakeAnimator(indicator_res)
		
		self:initIndicatorEffect(indicator)
		indicator:setPosition(self:getAttackPosition())
		indicator:setRotation(0)
        
		root_node:addChild(indicator.m_node)
		self.m_indicatorEffect = indicator
    end

	do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'target')
        local link_effect = EffectLink(indicator_res, 'bar_idle', 'start_idle', 'end_idle', 200, 200)
		
        self:initIndicatorEffect(link_effect)
		link_effect:doNotUseHead()

		root_node:addChild(link_effect.m_node)
        self.m_indicatorAddEffect = link_effect
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_AoECone:onChangeTargetCount(old_target_count, cur_target_count)
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
function SkillIndicator_AoECone:findCollision(x, y)
    local l_target = self:getProperTargetList()
    local l_ret = SkillTargetFinder:findCollision_AoECone(l_target, x, y, self.m_skillDir, self.m_skillRadius, self.m_skillAngle)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function optimizeIndicatorData
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator_AoECone:optimizeIndicatorData(l_target, fixed_target)
    local max_count = -1
    local t_best = {}
    
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

    for _, v in ipairs(l_target) do
        for i, body in ipairs(v:getBodyList()) do
            local x = v.pos['x'] + body['x']
            local y = v.pos['y'] + body['y']
            local distance = getDistance(pos_x, pos_y, x, y) - self.m_skillRadius - body['size']
            local start_dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y)) - (self.m_skillAngle / 2)
            local add_dir = self.m_skillAngle / 10
            
            for i = 0, 10 do
                local dir = start_dir + i * add_dir
                local pos = getPointFromAngleAndDistance(dir, distance)
                local count = self:getCollisionCountByVirtualTest(pos_x + pos['x'], pos_y + pos['y'], fixed_target)

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

            if (max_count >= self.m_targetLimit) then break end
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
function SkillIndicator_AoECone:optimizeIndicatorDataByArena(l_target)
    local t_best
    
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

    for _, v in ipairs(l_target) do
        for i, body in ipairs(v:getBodyList()) do
            local x = v.pos['x'] + body['x']
            local y = v.pos['y'] + body['y']
            local distance = getDistance(pos_x, pos_y, x, y) - self.m_skillRadius - body['size']
            local start_dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y)) - (self.m_skillAngle / 2)
            local add_dir = self.m_skillAngle / 10
            
            for i = 0, 10 do
                local dir = start_dir + i * add_dir
                local pos = getPointFromAngleAndDistance(dir, distance)
                local value, count = self:getTotalSortValueByVirtualTest(pos_x + pos['x'], pos_y + pos['y'])
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
        end
    end

    if (t_best) then
        self:setIndicatorData(t_best['x'], t_best['y'])
        return true
    end

    return false
end