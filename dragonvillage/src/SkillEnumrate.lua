local PARENT = Skill

-------------------------------------
-- class SkillEnumrate
-------------------------------------
SkillEnumrate = class(PARENT, {
		m_missileRes = 'string',
        m_motionStreakRes = 'string',

		m_skillLineNum = 'num',		-- 공격 하는 직선 갯수
		m_skillLineSize = 'num',	-- 직선의 두께
		m_skillLineTotalWidth = 'num', -- 나열된 직선의 총 길이

		m_skillTimer = 'time',
		m_skillTotalTime = 'time',	-- 적절하게 계산된 총 등장 시간
		m_skillInterval = 'time',
		m_skillCount = 'num',

		m_enumTargetType = '',		-- 공격 대상의 타입 - enemy_random : 각 탄별로 랜덤한 적, - target : 지정된 대상의 적 
		m_enumPosType = '',			-- 탄 배치 타입 - linear : 일직선, pentagon : 오각형 ...
		
		m_skillStartPosList = 'pos list',
		m_skillTargetList = 'character list',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillEnumrate:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillEnumrate:init_skill(missile_res, motionstreak_res, line_num, pos_type, target_type)
	PARENT.init_skill(self)
	 
	-- 1. 멤버 변수
    self.m_missileRes = missile_res
	self.m_motionStreakRes = motionstreak_res

	self.m_skillLineNum = line_num
	--self.m_skillLineSize --> initSkillSize에서 지정
	self.m_skillLineTotalWidth = g_constant:get('SKILL', 'ENUMRATE_TOTAL_LENGTH')		-- 직선으로 배치될경우 총 길이
	
	self.m_skillInterval = g_constant:get('SKILL', 'ENUMRATE_APPEAR_INTERVAR')		-- 순차적으로 발사될 탄의 발사 간격
	self.m_skillTotalTime = (self.m_skillLineNum * self.m_skillInterval) + g_constant:get('SKILL', 'ENUMRATE_FIRE_DELAY') -- 발사 간격 * 발사 수 + 발사 딜레이
	self.m_skillTimer = 0
	self.m_skillCount = 1

	self.m_enumTargetType = target_type
	self.m_enumPosType = pos_type

	self.m_skillStartPosList = nil
	self.m_skillTargetList = nil
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillEnumrate:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('fan', self.m_skillSize)  

		--self.m_resScale = t_data['scale']
		self.m_skillLineSize = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillEnumrate:initState()
	self:setCommonState(self)
    self:addState('start', SkillEnumrate.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillEnumrate.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
		-- idle state 진입함과 동시에 탄 배치 좌표 및 공격 대상 리스트를 구한다.
		owner.m_skillStartPosList = owner:getStartPosList()
		owner.m_skillTargetList = owner:getSkillTargetList()
		--owner.m_skillCount = 1
	end

    owner.m_skillTimer = owner.m_skillTimer + dt
	if (owner.m_skillTimer > owner.m_skillInterval) then
		-- 탈출 조건 (모두 발사)
		if (owner.m_skillCount > owner.m_skillLineNum) then
			owner:changeState('dying')
		else
			owner.m_skillTimer = owner.m_skillTimer - owner.m_skillInterval
			owner:fireMissile(owner.m_skillCount)
			owner.m_skillCount = owner.m_skillCount + 1
		end
	end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillEnumrate:fireMissile()
	error('SkillEnumrate의 fireMissile은 재정의 되어야 합니다.')
end

-------------------------------------
-- function getSkillTargetList
-- @brief Public / 공격 대상 리스트 가져옴
-------------------------------------
function SkillEnumrate:getSkillTargetList()
	if (self.m_enumTargetType == 'random') then
		return self:getSkillTargetList_Random()
	elseif (self.m_enumTargetType == 'one') then
		return { self.m_targetChar }
    else
        return self:getSkillTargetList_Random()
	end	
end

-------------------------------------
-- function getSkillTargetList_Random
-- @brief 공격 횟수에 맞춰 랜덤한 타겟 리스트를 생성한다.
-------------------------------------
function SkillEnumrate:getSkillTargetList_Random()
	local l_target = self:getProperTargetList()
	return l_target
end

-------------------------------------
-- function getStartPosList
-- @brief 타입에 따른 공격 시작위치 가져옴
-------------------------------------
function SkillEnumrate:getStartPosList()
	if (self.m_enumPosType == 'linear') then
		return self:getStartPosList_Linear()
	elseif (self.m_enumPosType == 'polygons') then
		return self:getStartPosList_Polygons()
	else
		return self:getStartPosList_Polygons()
	end	
end

-------------------------------------
-- function getStartPosList_Polygons
-- @brief 다각형 모양의 공격 시작 좌표 리턴
-------------------------------------
function SkillEnumrate:getStartPosList_Polygons()
	local l_attack_pos = {}
	local angle_unit = (360 / self.m_skillLineNum)
	local distance = 100

	-- 좌표 계산
	for i = 1, self.m_skillLineNum do
		local angle = angle_unit * (i - 1)
		local pos = getPointFromAngleAndDistance(angle, distance)
		table.insert(l_attack_pos, pos)
	end

	return l_attack_pos
end

-------------------------------------
-- function getStartPosList_Linear
-- @brief 직선의 공격 시작 좌표 리턴
-------------------------------------
function SkillEnumrate:getStartPosList_Linear()
	local t_ret = {}
	
	local start_pos_dist = g_constant:get('SKILL', 'ENUMRATE_ATK_START_POS_DIST')

	local owner_pos = self.m_owner.pos
	local touch_x, touch_y = (self.m_targetPos.x - owner_pos.x), (self.m_targetPos.y - owner_pos.y)
	
	-- 원점과 터치지점 사이의 각도
	local main_angle = getDegree(0, 0, touch_x, touch_y)
	local half_num = math_floor(self.m_skillLineNum/2)
	local std_distance = self.m_skillLineTotalWidth/self.m_skillLineNum

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
-- function getAttackDir
-------------------------------------
function SkillEnumrate:getAttackDir(idx)
	local owner_pos = self.m_owner.pos
	local tar_x = self.m_targetPos.x - owner_pos.x
	local tar_y = self.m_targetPos.y - owner_pos.y
	local start_pos = self.m_skillStartPosList[idx]
	
    return getAdjustDegree(getDegree(start_pos.x, start_pos.y, tar_x, tar_y))
end

-------------------------------------
-- function getNextTarget
-------------------------------------
function SkillEnumrate:getNextTarget(idx)
	local target_char = self.m_skillTargetList[idx]
	if (not target_char or target_char:isDead()) then
		local l_target = self:getSkillTargetList()
        target_char = l_target[1]
	end
	return target_char
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillEnumrate:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local motionstreak_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)

	local line_num = t_skill['hit']
	local pos_type = t_skill['val_1']
	local target_type = t_skill['val_2']

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillEnumrate(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, line_num, pos_type, target_type)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end