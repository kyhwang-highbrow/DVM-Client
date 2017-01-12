local PARENT = Skill

-------------------------------------
-- class SkillVoltesX
-------------------------------------
SkillVoltesX = class(PARENT, {
		m_physGroup = 'str',

		m_attackStep = 'num',
		m_hasFinalAttack = 'bool',
		m_skillAniName = 'str',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillVoltesX:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillVoltesX:init_skill(attack_count, has_final_attack)
    PARENT.init_skill(self)
	self.m_physGroup = self.m_owner:getAttackPhysGroup()
	self.m_attackStep = 0
	self.m_hasFinalAttack = has_final_attack

	if (self.m_hasFinalAttack) then
		self.m_skillAniName = 'idle_02'
	else
		self.m_skillAniName = 'idle_01'
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillVoltesX:initState()
	self:setCommonState(self)
	self:addState('start', SkillVoltesX.st_idle, self.m_skillAniName, true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillVoltesX.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:setPosition(owner.m_targetPos.x, owner.m_targetPos.y)
		owner.m_animator:addAniHandler(function() 
			owner:changeState('dying')
		end)

	elseif (owner.m_stateTimer > VOLTES_ATTACK_INTERVAL) and (owner.m_attackStep == 0) then
		owner:runAttack(1)
		owner.m_attackStep = owner.m_attackStep + 1

	elseif (owner.m_stateTimer > VOLTES_ATTACK_INTERVAL*2) and (owner.m_attackStep == 1) then
		owner:runAttack(2)
		owner.m_attackStep = owner.m_attackStep + 1
    end
	
	if (owner.m_hasFinalAttack) then 
		if (owner.m_stateTimer > VOLTES_FINAL_ATTACK_TIME) and (owner.m_attackStep == 2) then
			owner:runAttack(1)
			owner:runAttack(2)
			owner.m_attackStep = owner.m_attackStep + 1

		elseif (owner.m_attackStep == 3) then
			owner.m_world.m_shakeMgr:doShakeUpDown(0.5, 30)
			owner.m_attackStep = owner.m_attackStep + 1
		end
	end
end

-------------------------------------
-- function runAttack
-- @brief findtarget으로 찾은 적에게 공격을 실행한다. 
-------------------------------------
function SkillVoltesX:runAttack(idx)
	local t_target = self:findTarget(idx)
	
    for i,target_char in ipairs(t_target) do
		self:attack(target_char)
    end
	
	-- 스킬이 제거할 수 있는 미사일 제거
	self:removeDestructibleMissile()

	-- 상태효과
	StatusEffectHelper:doStatusEffectByStr(self.m_owner, t_target, self.m_lStatusEffectStr)
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillVoltesX:findTarget(idx)
	local t_collision_obj = nil
	local t_ret = {}
	
    local radius = 20
	local std_width = (1280 / 2)
	local std_height = (720 / 2)
	
	local target_x, target_y = self.m_targetPos.x, self.m_targetPos.y
	local start_x, start_y = nil, nil
	local end_x, end_y = nil, nil

	-- 레이저에 충돌된 모든 객체 리턴
	start_x = target_x - std_width
	start_y = target_y - (std_height * (math_pow(-1, idx)))
		
	end_x = target_x + std_width
	end_y = target_y + (std_height * (math_pow(-1, idx)))
		
	t_collision_obj = self.m_world.m_physWorld:getLaserCollision(
		start_x, start_y,
		end_x, end_y, radius, self.m_physGroup)
		
	for i, obj in pairs(t_collision_obj) do 
		table.insert(t_ret, obj['obj'])
	end
	
	return t_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillVoltesX:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = 'res/effect/skill_optatio_x/skill_optatio_x_water.vrp' --string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local attack_count = t_skill['hit']
	local has_final_attack = (t_skill['val_1'] == 1)

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillVoltesX(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, has_final_attack)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
