local PARENT = Skill

-------------------------------------
-- class SkillEnumrate
-------------------------------------
SkillEnumrate = class(PARENT, {
		m_missileRes = 'string',
        m_motionStreakRes = 'string',

		m_skillLineNum = 'num',		-- 공격 하는 직선 갯수
		m_skillLineSize = 'num',	-- 직선의 두께

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
-- function init_SkillEnumrate
-------------------------------------
function SkillEnumrate:init_skill(missile_res, motionstreak_res, line_num, line_size)
	PARENT.init_skill(self)

	-- 1. 멤버 변수
    self.m_missileRes = missile_res
	self.m_motionStreakRes = motionstreak_res

	self.m_skillLineNum = line_num
	self.m_skillLineSize = line_size
	
	self.m_skillInterval = PENERATION_APPEAR_INTERVAR
	self.m_skillTotalTime = (self.m_skillLineNum * self.m_skillInterval) + PENERATION_FIRE_DELAY
	self.m_skillTimer = 0
	self.m_skillCount = 1

	self.m_skillStartPosList = nil
	self.m_skillTargetList = nil
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
	end

    owner.m_skillTimer = owner.m_skillTimer + dt
	if (owner.m_skillTimer > owner.m_skillInterval) then
		owner.m_skillTimer = owner.m_skillTimer - owner.m_skillInterval
        owner:fireMissile(owner.m_skillCount)
		owner.m_skillCount = owner.m_skillCount + 1
	end

	-- 탈출 조건 (모두 발사)
	if (owner.m_skillCount > owner.m_skillLineNum) then
        owner:changeState('dying')
	end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillEnumrate:fireMissile()
	error('SkillEnumrate의 fireMissile은 재정의 되어야 합니다.')
end

-------------------------------------
-- function fireMissile
-- @brief Public / 공격 대상 리스트 가져옴
-------------------------------------
function SkillEnumrate:getSkillTargetList()
	if (self.m_enumTargetType == 'enemy_random') then
		return self:getSkillTargetList_Random()
	else
		return {self.m_targetChar}
	end	
end

-------------------------------------
-- function getSkillTargetList_Random
-- @brief 공격 횟수에 맞춰 랜덤한 타겟 리스트를 생성한다.
-------------------------------------
function SkillEnumrate:getSkillTargetList_Random()
	local world = self.m_owner.m_world
	local l_target = self.m_owner:getOpponentList()
	local l_ret = {}

	for i = 1, self.m_skillLineNum do
		local target = table.getRandom(l_target)
		table.insert(l_ret, target)	
	end

	return l_ret
end

-------------------------------------
-- function getStartPosList
-- @brief 타입에 따른 공격 시작위치 가져옴
-------------------------------------
function SkillEnumrate:getStartPosList()
	if (self.m_enumPosType == 'linear') then
		return self:getStartPosList_Linear()
	elseif (self.m_enumPosType == 'pentagon') then
		return self:getStartPosList_Pentagon()
	else
		error('SkillEnumrate do not have m_enumPosType')
	end	
end

-------------------------------------
-- function getStartPosList_Pentagon
-- @brief 오각형 모양의 공격 시작 좌표 리턴
-------------------------------------
function SkillEnumrate:getStartPosList_Pentagon()
	local l_attack_pos = P_RANDOM_PENTAGON_POS

	return l_attack_pos
end

-------------------------------------
-- function getStartPosList_Linear
-- @brief 직선의 공격 시작 좌표 리턴
-------------------------------------
function SkillEnumrate:getStartPosList_Linear()
	local t_ret = {}
	
	local owner_pos = self.m_owner.pos
	local touch_x, touch_y = (self.m_targetPos.x - owner_pos.x), (self.m_targetPos.y - owner_pos.y)
	
	-- 원점과 터치지점 사이의 각도
	local main_angle = getDegree(0, 0, touch_x, touch_y)
	local half_num = math_floor(self.m_skillLineNum/2)
	local std_distance = PENERATION_TOTAL_LENGTH/self.m_skillLineNum

	-- 홀수인 경우 
	if ((self.m_skillLineNum % 2) == 1) then
		-- 센터 좌표 계산
		local move_pos = getPointFromAngleAndDistance(main_angle, PENERATION_ATK_START_POS_DIST)
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
		local move_pos = getPointFromAngleAndDistance(main_angle, PENERATION_ATK_START_POS_DIST)
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
-- function makeSkillInstance
-------------------------------------
function SkillEnumrate:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local motionstreak_res = (t_skill['res_2'] == 'x') and nil or string.gsub(t_skill['res_2'], '@', owner:getAttribute())

	local line_num = t_skill['hit']
	local line_size = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillEnumrate(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, line_num, line_size)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end