local PARENT = Skill

-------------------------------------
-- class SkillRapidShot
-------------------------------------
SkillRapidShot = class(PARENT, {
		m_missileRes = 'string',
		m_motionStreakRes = 'string',
		m_attackCount = 'number',

		m_skillTimer = 'time',
		m_skillInterval = 'time',
		m_skillCount = 'num',

        m_lCollisionList = 'collision list',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillRapidShot:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillRapidShot:init_skill(missile_res, motionstreak_res, target_count)
	PARENT.init_skill(self)

	-- 1. 멤버 변수
    self.m_missileRes = missile_res
    self.m_motionStreakRes = motionstreak_res
    self.m_attackCount = target_count

	self.m_skillInterval = g_constant:get('SKILL', 'RAPIDSHOT_INTERVAL')
	self.m_skillTimer = 0
	self.m_skillCount = 1

    self.m_lCollisionList = self:getProperCollisionList()

    local collision = self.m_lCollisionList[1]
    if (collision) then
        self.m_targetChar = collision:getTarget()
    end
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillRapidShot:initSkillSize()
    if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		--self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillRapidShot:initState()
	self:setCommonState(self)
    self:addState('start', SkillRapidShot.st_idle, 'idle', true)
	self:addState('end', SkillRapidShot.st_end, nil, false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillRapidShot.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
	end

    owner.m_skillTimer = owner.m_skillTimer + dt
	if (owner.m_skillTimer > owner.m_skillInterval) then
		owner.m_skillTimer = owner.m_skillTimer - owner.m_skillInterval
        owner:fireMissile()
		owner.m_skillCount = owner.m_skillCount + 1
	end

	-- 탈출 조건 (모두 발사 또는 타겟 사망)
	if (owner.m_skillCount > owner.m_attackCount) 
		or (owner.m_targetChar:isDead()) then
        owner:changeState('end')
	end
end

-------------------------------------
-- function st_end
-------------------------------------
function SkillRapidShot.st_end(owner, dt)
	if (owner.m_stateTimer > 2) then
		owner:changeState('dying')
	end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillRapidShot:fireMissile()
    local char = self.m_owner
    local collision = self.m_lCollisionList[1]
    if (not collision) then return end

    local target = collision:getTarget()
    local target_body = target:getBody(collision:getBodyKey())
    local target_x = target.pos.x + target_body.x
    local target_y = target.pos.y + target_body.y
    local attack_pos_x, attack_pos_y = self:getAttackPosition()

    local t_option = {}

    t_option['owner'] = char
    t_option['pos_x'] = char.pos.x + attack_pos_x
    t_option['pos_y'] = char.pos.y + attack_pos_y + math_random(-50, 50)
	t_option['target'] = target
    t_option['target_body'] = target_body
    
	t_option['dir'] = getDegree(t_option['pos_x'], t_option['pos_y'], target_x, target_y)
	t_option['rotation'] = t_option['dir']

    t_option['physics_body'] = {0, 0, 40}
    t_option['attack_damage'] = self.m_activityCarrier
    t_option['object_key'] = char:getMissilePhysGroup()
	t_option['attr_name'] = self.m_owner:getAttribute()

	t_option['speed'] = 0
	t_option['h_limit_speed'] = 2000
	t_option['accel'] = 20000
	t_option['accel_delay'] = 0.5
	t_option['movement'] ='normal'
	t_option['missile_type'] = 'NORMAL'
	t_option['bFixedAttack'] = true

    t_option['missile_res_name'] = self.m_missileRes
	t_option['visual'] = ('move_' .. math_random(1, 5))
	t_option['scale'] = self.m_resScale
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

    t_option['cbFunction'] = function(attacker, defender, x, y)
		self:onAttack(defender)
	end

    -- 발사
    self:makeMissile(t_option)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillRapidShot:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local motionstreak_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
	local attack_count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillRapidShot(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, attack_count)
	skill:initState()

	-- 3. state 시작
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end