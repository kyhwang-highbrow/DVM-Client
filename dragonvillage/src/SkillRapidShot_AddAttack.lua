local PARENT = SkillRapidShot

-------------------------------------
-- class SkillRapidShot_AddAttack
-------------------------------------
SkillRapidShot_AddAttack = class(PARENT, {
		m_addAttackAcivityCarrier = 'ActivityCarrier',

        m_firstTargetPos = 'cc.p',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillRapidShot_AddAttack:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillRapidShot_AddAttack:init_skill(missile_res, motionstreak_res, target_count)
	PARENT.init_skill(self, missile_res, motionstreak_res, target_count)

	self.m_addAttackAcivityCarrier = self.m_activityCarrier:cloneForMissile()
	self.m_addAttackAcivityCarrier:setAttackType('basic')

    self.m_firstTargetPos = { x = 0, y = 0 }
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillRapidShot_AddAttack:initSkillSize()
    if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		--self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillRapidShot_AddAttack:fireMissile(collision, is_add_attack)
    local char = self.m_owner
    local collision = collision or self.m_lCollisionList[1]
    if (not collision) then return end

    local target = collision:getTarget()
    local target_body = target:getBody(collision:getBodyKey())
    local target_x = target.pos.x + target_body.x
    local target_y = target.pos.y + target_body.y

    local t_option = {}

    t_option['owner'] = char
	t_option['target'] = target
    t_option['target_body'] = target_body
	
    t_option['physics_body'] = {0, 0, 20}
    t_option['object_key'] = char:getMissilePhysGroup()
	t_option['attr_name'] = self.m_owner:getAttribute()

	if (is_add_attack) then
        t_option['attack_damage'] = self.m_addAttackAcivityCarrier

		t_option['pos_x'] = self.m_firstTargetPos['x']
		t_option['pos_y'] = self.m_firstTargetPos['y']
	else
		t_option['attack_damage'] = self.m_activityCarrier

		local attack_pos_x, attack_pos_y = self:getAttackPosition()
		local y_range = g_constant:get('SKILL', 'RAPIDSHOT_Y_POS_RANGE')
		t_option['pos_x'] = char.pos.x + attack_pos_x
		t_option['pos_y'] = char.pos.y + attack_pos_y + math_random(-y_range, y_range)
		t_option['accel_delay'] = g_constant:get('SKILL', 'RAPIDSHOT_FIRE_DELAY')

        self.m_firstTargetPos['x'] = target_x
        self.m_firstTargetPos['y'] = target_y
	end

	t_option['cbFunction'] = function(attacker, defender, x, y)
		self:onAttack(defender)

		if (not is_add_attack) then
			self:doAddAttack()
		end
	end

	t_option['dir'] = getDegree(t_option['pos_x'], t_option['pos_y'], target_x, target_y)
	t_option['rotation'] = t_option['dir']

	t_option['speed'] = 0
	t_option['h_limit_speed'] = 2000
	t_option['accel'] = 20000
	t_option['movement'] ='normal'
	t_option['missile_type'] = 'NORMAL'
	t_option['bFixedAttack'] = true

    t_option['missile_res_name'] = self.m_missileRes
	t_option['visual'] = ('move_' .. math_random(1, 5))
	t_option['scale'] = self.m_resScale
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

    -- 타격 횟수 설정
    t_option['max_hit_count'] = self.m_targetLimit

    -- 발사
    self:makeMissile(t_option)
end

-------------------------------------
-- function doAddAttack
-------------------------------------
function SkillRapidShot_AddAttack:doAddAttack()
    local l_collision = self.m_lCollisionList
    local count = #l_collision
	if (count <= 1) then return end

    local random_idx = math_random(2, #l_collision)
    local collision = l_collision[random_idx]

    if (collision) then
		self:fireMissile(collision, true)
	end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillRapidShot_AddAttack:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local motionstreak_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
	
	local attack_count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillRapidShot_AddAttack(nil)

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