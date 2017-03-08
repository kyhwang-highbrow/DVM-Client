local PARENT = SkillRapidShot

-------------------------------------
-- class SkillRapidShot_AddAttack
-------------------------------------
SkillRapidShot_AddAttack = class(PARENT, {
		m_addAttackStatusEffect= 'str',
		m_addAttackAcivityCarrier = 'ActivityCarrier',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillRapidShot_AddAttack:init(file_name, body, ...)
end

-------------------------------------
-- function init_SkillRapidShot_AddAttack
-------------------------------------
function SkillRapidShot_AddAttack:init_skill(missile_res, motionstreak_res, target_count, add_attack_status_effect)
	PARENT.init_skill(self, missile_res, motionstreak_res, target_count)

	self.m_addAttackStatusEffect = add_attack_status_effect
	self.m_addAttackAcivityCarrier = clone(self.m_activityCarrier)
	self.m_addAttackAcivityCarrier:setAttackType('basic')
end

-------------------------------------
-- function initState
-------------------------------------
function SkillRapidShot_AddAttack:initState()
	self:setCommonState(self)
    self:addState('start', SkillRapidShot_AddAttack.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillRapidShot_AddAttack.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
	end

    owner.m_skillTimer = owner.m_skillTimer + dt
	if (owner.m_skillTimer > owner.m_skillInterval) then
		owner.m_skillTimer = owner.m_skillTimer - owner.m_skillInterval
        owner:fireMissile(owner.m_targetChar, false)
		owner.m_skillCount = owner.m_skillCount + 1
	end

	-- 탈출 조건 (모두 발사 또는 타겟 사망)
	if (owner.m_skillCount > owner.m_attackCount) 
		or (owner.m_targetChar.m_bDead) then
        owner:changeState('dying')
	end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillRapidShot_AddAttack:fireMissile(target, is_add_attack)
    local char = self.m_owner
    local world = self.m_world

    local t_option = {}

    t_option['owner'] = char
	t_option['target'] = target
	
    t_option['physics_body'] = {0, 0, 20}
    t_option['object_key'] = char:getAttackPhysGroup()
	t_option['attr_name'] = self.m_owner:getAttribute()

	if (is_add_attack) then
		t_option['attack_damage'] = self.m_addAttackAcivityCarrier
		t_option['pos_x'] = self.m_targetChar.pos.x
		t_option['pos_y'] = self.m_targetChar.pos.jy
	else
		t_option['attack_damage'] = self.m_activityCarrier
		local attack_pos_x, attack_pos_y = self:getAttackPosition()
		t_option['pos_x'] = char.pos.x + attack_pos_x
		t_option['pos_y'] = char.pos.y + attack_pos_y + math_random(-RAPIDSHOT_Y_POS_RANGE, RAPIDSHOT_Y_POS_RANGE)
		t_option['accel_delay'] = RAPIDSHOT_FIRE_DELAY
	end

	t_option['cbFunction'] = function()
		self.m_skillHitEffctDirector:doWork()

        -- 타격 카운트 갱신
        self:addHitCount()

		if (not is_add_attack) then
			self:ultimateActiveForClownDragon()
		end
	end

	t_option['dir'] = getDegree(t_option['pos_x'], t_option['pos_y'], target.pos.x, target.pos.y)
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

    -- 하이라이트
    t_option['highlight'] = self.m_bHighlight

    -- 발사
	world.m_missileFactory:makeMissile(t_option)
end

-------------------------------------
-- function ultimateActiveForClownDragon
-- @TODO 임시 코드
-------------------------------------
function SkillRapidShot_AddAttack:ultimateActiveForClownDragon()
	local l_target = self.m_owner:getOpponentList()
    local count = #l_target
    if (count <= 1) then return end

    -- 주 타겟은 제외한 랜덤한 대상을 얻는다
    local randomIdx = math_random(1, count - 1)
    local target

    for i, v in pairs(l_target) do
        if (v ~= self.m_targetChar and i >= randomIdx) then
            target = v
            break
        end
    end

    if target then 
		self:fireMissile(target, true)
		StatusEffectHelper:doStatusEffectByStr(self.m_owner, {target}, {self.m_addAttackStatusEffect})
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
	local add_attack_status_effect = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillRapidShot_AddAttack(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, attack_count, add_attack_status_effect)
	skill:initState()

	-- 3. state 시작
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        world.m_gameHighlight:addMissile(skill)
    end
end