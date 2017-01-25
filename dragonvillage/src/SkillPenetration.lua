local PARENT = Skill

-------------------------------------
-- class SkillPenetration
-------------------------------------
SkillPenetration = class(PARENT, {
		m_missileRes = 'string',

		m_skillLineNum = 'num',		-- 공격 하는 직선 갯수
		m_skillLineSize = 'num',	-- 직선의 두께
		
		m_skillLineGap = 'num',		-- 직선 간의 간격
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
function SkillPenetration:init_skill(missile_res, line_num, line_size)
	PARENT.init_skill(self)

	-- 1. 멤버 변수
    self.m_missileRes = missile_res
	self.m_skillLineNum = line_num
	self.m_skillLineSize = line_size
	
	self.m_skillLineGap = nil
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
        owner:fireMissile()
        owner:changeState('dying')
    end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillPenetration:fireMissile()
    local targetPos = self.m_targetPos
    if (not targetPos) then
        return 
    end

    local char = self.m_owner
    local world = self.m_world

    local t_option = {}

    t_option['owner'] = char

    t_option['pos_x'] = 100 --char.pos.x
    t_option['pos_y'] = 0

    t_option['object_key'] = char:getAttackPhysGroup()
    t_option['physics_body'] = {0, 0, self.m_skillLineSize}
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['attr_name'] = char:getAttribute()

    t_option['speed'] = 0
	t_option['h_limit_speed'] = 3000
	t_option['accel'] = 20000
	t_option['accel_delay'] = 0.5

	t_option['missile_type'] = 'PASS'
    t_option['movement'] ='normal' 

    t_option['missile_res_name'] = self.m_missileRes
	t_option['scale'] = 0.5 --self.m_resScale
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes
    
	t_option['cbFunction'] = function()
		self.m_skillHitEffctDirector:doWork()
	end

	-- fire!!
	local l_attack_pos = self:getAttackPositionList()
	local l_dir = self:getDirList(l_attack_pos)
    for i = 1, self.m_skillLineNum do 
		t_option['pos_y'] = l_attack_pos[i].y
		t_option['dir'] = l_dir[i]
		t_option['rotation'] = t_option['dir']
        world.m_missileFactory:makeMissile(t_option)
    end

end

-------------------------------------
-- function getAttackPositionList
-------------------------------------
function SkillPenetration:getAttackPositionList()
	local t_ret = {}
	
	local pos_x, pos_y = self:getAttackPosition()

	for i = 1, self.m_skillLineNum do
		table.insert(t_ret, {x = 100, y = -300 + (i * 100)})
	end

    return t_ret
end

-------------------------------------
-- function getDirList
-------------------------------------
function SkillPenetration:getDirList(l_attack_pos)
	local t_ret = {}
	
	local tar_x = self.m_targetPos.x
	local tar_y = self.m_targetPos.y
	local l_attack_pos = l_attack_pos or {}

	local start_pos
	for i = 1, self.m_skillLineNum do
		start_pos = l_attack_pos[i]
		dir = getAdjustDegree(getDegree(start_pos.x, start_pos.y, tar_x, tar_y))
		table.insert(t_ret, dir)
	end

    return t_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillPenetration:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])
	
	local line_num = t_skill['hit']
	local line_size = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillPenetration(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, line_num, line_size)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end