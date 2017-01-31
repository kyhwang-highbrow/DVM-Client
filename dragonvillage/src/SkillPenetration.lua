local PARENT = Skill

-------------------------------------
-- class SkillPenetration
-------------------------------------
SkillPenetration = class(PARENT, {
		m_missileRes = 'string',
        m_motionStreakRes = 'string',

		m_skillLineNum = 'num',		-- 공격 하는 직선 갯수
		m_skillLineSize = 'num',	-- 직선의 두께
		
		m_skillLineGap = 'num',		-- 직선 간의 간격

		m_skillTimer = 'time',
		m_skillTotalTime = 'time',	-- 적절하게 계산된 총 등장 시간
		m_skillInterval = 'time',
		m_skillCount = 'num',

		m_skillAttackPosList = 'pos list',
		m_skillDirList = 'dir list',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillPenetration:init(file_name, body, ...)
end

-------------------------------------
-- function init_SkillPenetration
-------------------------------------
function SkillPenetration:init_skill(missile_res, motionstreak_res, line_num, line_size)
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

	self.m_skillLineGap = nil
	self.m_skillAttackPosList = nil
	self.m_skillDirList = nil
end

-------------------------------------
-- function initState
-------------------------------------
function SkillPenetration:initState()
	self:setCommonState(self)
    self:addState('start', SkillPenetration.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillPenetration.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner.m_skillAttackPosList = owner:getAttackPositionList()
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
function SkillPenetration:fireMissile(idx)
    local char = self.m_owner
    local world = self.m_world

    local t_option = {}

    t_option['owner'] = char

    t_option['pos_x'] = char.pos.x + self.m_skillAttackPosList[idx].x
	t_option['pos_y'] = char.pos.y + self.m_skillAttackPosList[idx].y
	t_option['dir'] = self:getAttackDir(idx)
	t_option['rotation'] = t_option['dir']

    t_option['object_key'] = char:getAttackPhysGroup()
    t_option['physics_body'] = {0, 0, self.m_skillLineSize}
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['attr_name'] = char:getAttribute()

    t_option['speed'] = 0
	t_option['h_limit_speed'] = 2000
	t_option['accel'] = 20000
	t_option['accel_delay'] = self.m_skillTotalTime - (self.m_skillInterval * idx)

	t_option['missile_type'] = 'PASS'
    t_option['movement'] ='normal' 

    t_option['missile_res_name'] = self.m_missileRes
	t_option['scale'] = self.m_resScale
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes
    
	t_option['cbFunction'] = function()
		self.m_skillHitEffctDirector:doWork()
	end

	-- fire!!
    world.m_missileFactory:makeMissile(t_option)
end

-------------------------------------
-- function getAttackPositionList
-------------------------------------
function SkillPenetration:getAttackPositionList()
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
function SkillPenetration:getAttackDir(idx)
	local owner_pos = self.m_owner.pos
	local tar_x = self.m_targetPos.x - owner_pos.x
	local tar_y = self.m_targetPos.y - owner_pos.y
	local start_pos = self.m_skillAttackPosList[idx]
	
    return getAdjustDegree(getDegree(start_pos.x, start_pos.y, tar_x, tar_y))
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillPenetration:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])
	local motionstreak_res = (t_skill['res_2'] == 'x') and nil or string.gsub(t_skill['res_2'], '@', owner.m_charTable['attr'])

	local line_num = t_skill['hit']
	local line_size = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillPenetration(nil)

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