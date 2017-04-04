local PARENT = Skill

local VOLTES_ATK_STEP_1 = 1
local VOLTES_ATK_STEP_2 = VOLTES_ATK_STEP_1 + 1
local VOLTES_ATK_STEP_FINAL = VOLTES_ATK_STEP_2 + 1
local VOLTES_ATK_STEP_END = VOLTES_ATK_STEP_FINAL + 1

-------------------------------------
-- class SkillVoltesX
-------------------------------------
SkillVoltesX = class(PARENT, {
		m_lineSize = 'num',

		m_attackStep = 'num',
		m_hasFinalAttack = 'bool',
		m_skillAniName = 'str',

		m_multiAtkTimer = 'dt',
        m_hitInterval = 'number',

		m_attackCnt = 'number',
		m_maxAttackCnt = 'number',
		m_maxFinalAttackCnt = 'number',
		m_attckInterval = 'number',
		m_finalAttackTime = 'number',
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
function SkillVoltesX:init_skill(attack_count, has_final_attack, final_attack_count)
    PARENT.init_skill(self)

	-- 멤버변수 초기화
	self.m_lineSize = g_constant:get('SKILL', 'VOLTES_LINE_SIZE')
	self.m_attackStep = VOLTES_ATK_STEP_1
	self.m_hasFinalAttack = has_final_attack
	
	self.m_maxAttackCnt = attack_count 
	self.m_maxFinalAttackCnt = final_attack_count
	self.m_attackCnt = 0

	self.m_hitInterval = ONE_FRAME * 5
	self.m_multiAtkTimer = self.m_hitInterval
	self.m_attckInterval = g_constant:get('SKILL', 'VOLTES_ATTACK_INTERVAL')
	self.m_finalAttackTime = g_constant:get('SKILL', 'VOLTES_FINAL_ATTACK_TIME')

	-- 궁극기 여부에 따라 애니메이션 이름 설정
	if (self.m_hasFinalAttack) then
		self.m_skillAniName = 'idle_02'
	else
		self.m_skillAniName = 'idle_01'
	end

	-- 스킬 위치 타겟 위치로 
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillVoltesX:initState()
	self:setCommonState(self)
	self:addState('start', SkillVoltesX.st_idle, self.m_skillAniName, false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillVoltesX.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then

	-- ATK STEP 1
	elseif (owner.m_stateTimer > owner.m_attckInterval) and (owner.m_attackStep == VOLTES_ATK_STEP_1) then
		owner:updateLoopAttack({1}, dt)

	-- ATK STEP 2
	elseif (owner.m_stateTimer > owner.m_attckInterval*2) and (owner.m_attackStep == VOLTES_ATK_STEP_2) then
		owner:updateLoopAttack({2}, dt)

    end
	
	-- 궁극 강화 여부에 따라 나뉨
	if (owner.m_hasFinalAttack) then
		-- ATK STEP FINAL
		if (owner.m_stateTimer > owner.m_finalAttackTime) and (owner.m_attackStep == VOLTES_ATK_STEP_FINAL) then
			owner.m_maxAttackCnt = owner.m_maxFinalAttackCnt
			owner:updateLoopAttack({1, 2}, dt)

		-- ATK STEP END
		elseif (owner.m_attackStep == VOLTES_ATK_STEP_END) then
			owner.m_animator:addAniHandler(function()
				owner:changeState('dying')
			end)
		end
	else
		-- 일반 스킬이라면 ATK STEP FINAL 일떄 탈출
		if (owner.m_attackStep == VOLTES_ATTACK_STEP_FINAL) then 
			owner.m_animator:addAniHandler(function()
				owner:changeState('dying')
			end)
		end	
	end
end


-------------------------------------
-- function doLoopAttack
-- @breif 반복공격을 실행한다
-------------------------------------
function SkillVoltesX:initLoopAttack()
	self.m_multiAtkTimer = self.m_hitInterval
	self.m_attackCnt = 0
end

-------------------------------------
-- function updateLoopAttack
-- @breif 반복공격용 update
-------------------------------------
function SkillVoltesX:updateLoopAttack(t_idx, dt)
	self.m_multiAtkTimer = self.m_multiAtkTimer + dt
		
	if (self.m_multiAtkTimer > self.m_hitInterval) then
		for _, idx in pairs(t_idx) do 
			self:runAttack(idx)
		end
		self.m_multiAtkTimer = self.m_multiAtkTimer - self.m_hitInterval
		self.m_attackCnt = self.m_attackCnt + 1
	end

	-- 공격 횟수 초과시 초기화 하면서 탈출
	if (self.m_maxAttackCnt <= self.m_attackCnt) then
		self:initLoopAttack()
		self.m_attackStep = self.m_attackStep + 1
	end
end


-------------------------------------
-- function doStatusEffect
-- @brief l_start_con 조건에 해당하는 statusEffect를 적용
-------------------------------------
function SkillVoltesX:doStatusEffect(l_start_con, t_target)
    if (not t_target) then return end
    
    Skill.doStatusEffect(self, l_start_con, t_target)
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
    self:doStatusEffect({
        STATUS_EFFECT_CON__SKILL_HIT,
        STATUS_EFFECT_CON__SKILL_HIT_CRI
    }, t_target)
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillVoltesX:findTarget(idx)
	local l_target = self.m_owner:getTargetListByType(self.m_targetType, self.m_targetFormation)
	local t_ret = {}
	
    local radius = 20
	local std_width = (CRITERIA_RESOLUTION_X / 2)
	local std_height = (CRITERIA_RESOLUTION_Y / 2)
	
	local target_x, target_y = self.m_targetPos.x, self.m_targetPos.y

	-- 레이저에 충돌된 모든 객체 리턴
	local t_collision_obj = self:findTargetEachLine(l_target, target_x, target_y, std_width, std_height, idx)
		
	for i, obj in pairs(t_collision_obj) do 
		table.insert(t_ret, obj)
	end
	
	return t_ret
end

-------------------------------------
-- function findTargetEachLine
-------------------------------------
function SkillVoltesX:findTargetEachLine(l_target, target_x, target_y, std_width, std_height, idx)
	local start_x = target_x - std_width
	local start_y = target_y - (std_height * (math_pow(-1, idx)))
		
	local end_x = target_x + std_width
	local end_y = target_y + (std_height * (math_pow(-1, idx)))

	return SkillTargetFinder:findTarget_Bar(l_target, start_x, start_y, end_x, end_y, self.m_lineSize/2)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillVoltesX:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local attack_count = t_skill['hit']
	local has_final_attack = (t_skill['val_1'] == 1)
	local final_attack_count = t_skill['val_2']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillVoltesX(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, has_final_attack, final_attack_count)
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
        --world.m_gameHighlight:addMissile(skill)
    end
end
