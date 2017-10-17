local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_Penetration
-------------------------------------
SkillIndicator_Penetration = class(PARENT, {
		m_lIndicatorEffectList = 'indicator list',
		m_indicatorAddEffect = 'Indicator',
		
		m_skillLineNum = 'num',		-- 공격 하는 직선 갯수
		m_skillLineSize = 'num',	-- 직선의 두께

		m_lEffectList = 'Effect',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Penetration:init(hero, t_skill)
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_Penetration:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

    self.m_indicatorAngleLimit = g_constant:get('SKILL', 'ENUMRATE_ANGLE_LIMIT')
	self.m_indicatorDistanceLimit = g_constant:get('SKILL', 'ENUMRATE_DIST_LIMIT')

	self.m_lIndicatorEffectList = {}
	self.m_lEffectList = {}

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('fan', skill_size)  

		self.m_indicatorScale = t_data['scale'] * 0.1
		self.m_skillLineSize = t_data['size']
	end
		
	self.m_skillLineNum = t_skill['hit']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Penetration:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

	-- 1. 각도 및 거리 제한
    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
	local distance = getDistance(pos_x, pos_y, x, y)

	local t_ret = self:checkIndicatorLimit(dir, distance)
    dir = t_ret['angle']
	distance = t_ret['distance']

    -- 최초 시작 위치가 제한 범위를 넘을 경우를 위한 처리
    if (not t_ret['is_change']) then
        if (not self.m_targetPosX or not self.m_targetPosY) then
            t_ret['is_change'] = true

            local point = getPointFromAngleAndDistance(dir, distance)
            x = point.x + pos_x
            y = point.y + pos_y
        end
    end

	if (t_ret['is_change']) then 
        -- root node 상에서 터치된 좌표 위치 환산
		local touch_x, touch_y = (x - pos_x), (y - pos_y)

		-- @TODO 여기서 x, y 좌표를 보내게 되면 Skill에서 연산을 할때 위 touch_x, touch_y를 다시 구해야 한다...
		self.m_targetPosX = x
		self.m_targetPosY = y

		-- 이펙트 조정
		local l_dir = {}
		local l_attack_pos = self:getAttackPositionList(touch_x, touch_y)
		
		for i, indicator in pairs(self.m_lIndicatorEffectList) do
			local attack_pos = l_attack_pos[i]
			local dir = getAdjustDegree(getDegree(attack_pos.x, attack_pos.y, touch_x, touch_y))
			indicator:setRotation(dir)
			indicator:setPosition(attack_pos.x, attack_pos.y)
			table.insert(l_dir, dir)
			
			--@TEST
			self.m_lEffectList[i]:setPosition(attack_pos.x, attack_pos.y)
		end
		self.m_indicatorAddEffect:setPosition(touch_x, touch_y)

		-- 하이라이트 갱신
		local l_collision = self:findCollision(l_attack_pos, l_dir)
        self.m_additionalInfo = l_dir

		self:setHighlightEffect(l_collision)
	end
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Penetration:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

	-- 인디케이터 다발
	local indicator_res = g_constant:get('INDICATOR', 'RES', 'fan')
    for i = 1, self.m_skillLineNum do
        local indicator = MakeAnimator(indicator_res)
		indicator:setIgnoreLowEndMode(true)
		self:initIndicatorEffect(indicator)
		
		root_node:addChild(indicator.m_node)
		table.insert(self.m_lIndicatorEffectList, indicator)
    end

	-- 겹치는 부분 가리는 추가 인디케이터
	local indicator_res = g_constant:get('INDICATOR', 'RES', 'round')
	do
        local indicator = MakeAnimator(indicator_res)
        indicator:setIgnoreLowEndMode(true)
		indicator:setScale(0.1)

        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end

	-- @TEST 좌표 확인용
    for i = 1, self.m_skillLineNum do
        local indicator = MakeAnimator(indicator_res)
        indicator:setIgnoreLowEndMode(true)
        indicator:setScale(0.1)
		
		root_node:addChild(indicator.m_node)
		table.insert(self.m_lEffectList, indicator)
    end

	return true
end

-------------------------------------
-- function onEnterAppear
-------------------------------------
function SkillIndicator_Penetration:onEnterAppear()
    for _, indicator in pairs(self.m_lIndicatorEffectList) do
		indicator:changeAni('appear')
		indicator:addAniHandler(function()
			indicator:changeAni('idle', true)
		end)
	end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Penetration:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
    if (cur_target_count > 0) then
		-- 타겟수에 따른 보너스 등급 저장
		self.m_bonus = DragonSkillBonusHelper:getBonusLevel(self.m_hero, cur_target_count)

		if (self.m_preBonusLevel ~= self.m_bonus) then
			for _, indicator in pairs(self.m_lIndicatorEffectList) do
				self:onChangeIndicatorEffect(indicator, self.m_bonus, self.m_preBonusLevel)
			end
		end

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_bonus = -1
		for _, indicator in pairs(self.m_lIndicatorEffectList) do
			self:initIndicatorEffect(indicator)
		end
    end

	self.m_preBonusLevel = self.m_bonus
end

-------------------------------------
-- function getAttackPositionList
-------------------------------------
function SkillIndicator_Penetration:getAttackPositionList(touch_x, touch_y)
	local t_ret = {}

	local start_pos_dist = g_constant:get('SKILL', 'PENERATION_ATK_START_POS_DIST')

	-- 원점과 터치지점 사이의 각도
	local main_angle = getDegree(0, 0, touch_x, touch_y)
	local half_num = math_floor(self.m_skillLineNum/2)
	local std_distance = g_constant:get('SKILL', 'PENERATION_TOTAL_LENGTH')/self.m_skillLineNum

	-- 홀수인 경우 
	if ((self.m_skillLineNum % 2) == 1) then
		-- 센터 좌표 계산
		local move_pos = getPointFromAngleAndDistance(main_angle, start_pos_dist)
		local center_pos = move_pos

		-- 좌측 좌표
		for i = 1, half_num do
			local move_pos = getPointFromAngleAndDistance(main_angle + 90, std_distance * (half_num - i + 1))
			local each_pos = {x = center_pos.x + move_pos.x, y = center_pos.y + move_pos.y}
			table.insert(t_ret, each_pos)
		end

		-- 센터 좌표 추가 (순서 맞추기 위해서 중간에서 추가)
		table.insert(t_ret, center_pos)
		
		-- 우측 좌표
		for i = 1, half_num do
			local move_pos = getPointFromAngleAndDistance(main_angle - 90, std_distance * i)
			local each_pos = {x = center_pos.x + move_pos.x, y = center_pos.y + move_pos.y}
			table.insert(t_ret, each_pos)
		end

	-- 짝수인 경우
	else
		-- 센터 좌표 계산 (추가는 하지 않는다)
		local move_pos = getPointFromAngleAndDistance(main_angle, start_pos_dist)
		local center_pos = move_pos

		-- 좌측 좌표
		for i = 1, half_num do
			local move_pos = getPointFromAngleAndDistance(main_angle + 90, std_distance * (half_num - i + 0.5))
			local each_pos = {x = center_pos.x + move_pos.x, y = center_pos.y + move_pos.y}
			table.insert(t_ret, each_pos)
		end

		-- 우측 좌표
		for i = 1, half_num do
			local move_pos = getPointFromAngleAndDistance(main_angle - 90, std_distance * (i - 0.5))
			local each_pos = {x = center_pos.x + move_pos.x, y = center_pos.y + move_pos.y}
			table.insert(t_ret, each_pos)
		end
	end

    return t_ret
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillIndicator_Penetration:findCollision(l_attack_pos, l_dir)
	local l_target = self:getProperTargetList()

    local temp = {}

    for i = 1, self.m_skillLineNum do
		-- 각 줄의 충돌 체크
		local collisions = self:findCollisionEachLine(l_target, l_attack_pos[i], l_dir[i])

        -- 타겟 수 만큼만 얻어옴(라인별)
        collisions = table.getPartList(collisions, self.m_targetLimit)

        table.insert(temp, collisions)
    end

    -- 하나의 리스트로 merge
    local l_ret = mergeCollisionLists(temp)
	return l_ret
end

-------------------------------------
-- function findCollisionEachLine
-------------------------------------
function SkillIndicator_Penetration:findCollisionEachLine(l_target, start_pos, dir)
    -- 참조하는 좌표
	local end_pos = getPointFromAngleAndDistance(dir, 2560)
	local hero_pos = self.m_hero.pos

	-- 실제 사용할 좌표
	-- 계산한 start_pos는 incator_root_node를 기반(0, 0)으로 한것이므로 영웅 좌표를 더해서 월드에서 계산할수 있도록 한다
	local start_x = start_pos.x + hero_pos.x
	local start_y = start_pos.y + hero_pos.y
    local end_x = start_x + end_pos['x']
    local end_y = start_y + end_pos['y']

	return SkillTargetFinder:findCollision_Bar(l_target, start_x, start_y, end_x, end_y, self.m_skillLineSize/2)
end