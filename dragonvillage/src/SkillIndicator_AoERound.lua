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
    self.m_isFixedOnTarget = isFixedOnTarget 
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoERound:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', skill_size)  

		self.m_indicatorScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoERound:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local touch_x, touch_y = x, y
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local l_collision = self:findCollision(touch_x, touch_y, self.m_range, self.m_isFixedOnTarget)
    local collision = l_collision[1]
    
    if self.m_isFixedOnTarget and collision then
        self.m_targetChar = collision:getTarget()

        local body = self.m_targetChar:getBody(collision:getBodyKey())
               
        touch_x = self.m_targetChar.pos.x + body['x']
        touch_y = self.m_targetChar.pos.y + body['y']
		-- 다시계산한다..!
		l_collision = self:findCollision(touch_x, touch_y, self.m_range, self.m_isFixedOnTarget)
    end

    self.m_targetPosX = touch_x
    self.m_targetPosY = touch_y
	
    -- 이펙트 위치
	self:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(l_collision)
end

-------------------------------------
-- function setIndicatorPosition
-------------------------------------
function SkillIndicator_AoERound:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
	self.m_indicatorEffect:setPosition(touch_x - pos_x, touch_y - pos_y)
	EffectLink_refresh(self.m_indicatorAddEffect, 0, 0, touch_x - pos_x, touch_y - pos_y)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoERound:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

	-- 동그라미 인디케이터
    do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'round')
        local indicator = MakeAnimator(indicator_res)
        
		indicator:setScale(self.m_indicatorScale)
		self:initIndicatorEffect(indicator)

        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end

	-- 캐릭터로부터 연결된 인디케이터
    do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'target')
        local link_effect = EffectLink(indicator_res, 'bar_idle', 'start_idle', 'end_idle', 200, 200)
		
		link_effect:doNotUseHead()
        link_effect:setColor(COLOR['light_green'])

		root_node:addChild(link_effect.m_node)
        self.m_indicatorAddEffect = link_effect
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_AoERound:onChangeTargetCount(old_target_count, cur_target_count)
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
function SkillIndicator_AoERound:findCollision(x, y, range, isFixedOnTarget)
    local l_target = self:getProperTargetList()

	local pos_x = x
	local pos_y = y

	local l_ret
    
	if isFixedOnTarget then
        l_ret = SkillTargetFinder:findCollision_AoERound(l_target, pos_x, pos_y, range)
	else
		l_ret = SkillTargetFinder:findCollision_AoERound(l_target, pos_x, pos_y, range)
    end

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)
    
	return l_ret
end

-------------------------------------
-- function optimizeIndicatorData
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator_AoERound:optimizeIndicatorData(l_target, fixed_target)
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

    for _, v in ipairs(l_target) do
        for i, body in ipairs(v:getBodyList()) do
            local x = v.pos['x'] + body['x']
            local y = v.pos['y'] + body['y']
            local skill_half = self.m_range
            local distance = body['size'] + skill_half
            local dir = 0

            while (dir < 360) do
                local pos = getPointFromAngleAndDistance(dir, distance - 1)
                local count = setIndicator(v, x + pos['x'], y + pos['y'])

                if (max_count < count) then
                    max_count = count

                    t_best = { 
                        target = self.m_targetChar,
                        x = self.m_targetPosX,
                        y = self.m_targetPosY
                    }
                end

                dir = dir + 5

                if (max_count >= self.m_targetLimit) then break end
            end

            if (max_count >= self.m_targetLimit) then break end
        end
    end
    
    if (max_count > 0) then
        setIndicator(t_best['target'], t_best['x'], t_best['y'])
        return true
    end

    return false
end