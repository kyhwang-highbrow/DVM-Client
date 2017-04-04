local PARENT = Skill

-------------------------------------
-- class SkillAoESquare
-------------------------------------
SkillAoESquare = class(PARENT, {
        m_skillWidth = 'number',
		m_skillHeight = 'number',

		m_multiAtkTimer = 'dt',
        m_hitInterval = 'number',

		m_attackCnt = 'number',
		m_maxAttackCnt = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoESquare:init(file_name, body, ...)
	self.m_skillWidth = g_constant:get('SKILL', 'LONG_LENGTH')
	self.m_skillHeight = g_constant:get('SKILL', 'LONG_LENGTH')
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquare:init_skill(hit)
    PARENT.init_skill(self)

	-- 멤버 변수
	self.m_maxAttackCnt = hit 
    self.m_attackCnt = 0
    self.m_hitInterval = 0.3
	self.m_multiAtkTimer = self.m_hitInterval

	-- 위치 설정
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoESquare:initState()
	self:setCommonState(self)
	self:addState('start', SkillAoESquare.st_appear, 'appear', false)
    self:addState('attack', SkillAoESquare.st_attack, 'idle', true)
	self:addState('disappear', SkillAoESquare.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillAoESquare.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
		if (not owner.m_targetChar) then 
			owner:changeState('dying') 
		end
		owner.m_animator:addAniHandler(function()
			owner:changeState('attack')
		end)
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillAoESquare.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:enterAttack()
	end

	owner.m_multiAtkTimer = owner.m_multiAtkTimer + dt

	-- 반복 공격	
	if (owner.m_multiAtkTimer > owner.m_hitInterval) then
		owner:runAttack()
		owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
		owner.m_attackCnt = owner.m_attackCnt + 1
	end

	-- 탈출
	if (owner.m_maxAttackCnt <= owner.m_attackCnt) then
		owner:escapeAttack()
	end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillAoESquare.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillAoESquare:runAttack()
    local t_target = self:findTarget()

    for i, target_char in ipairs(t_target) do
		self:attack(target_char)	
    end

	-- 스킬이 제거할 수 있는 미사일 제거
	self:removeDestructibleMissile()
end

-------------------------------------
-- function enterAttack
-- @brief 공격이 시작되는 시점에 실행
-------------------------------------
function SkillAoESquare:enterAttack()
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoESquare:escapeAttack()
	self.m_animator:addAniHandler(function()
		local t_target = self:findTarget()
		self:doStatusEffect({ STATUS_EFFECT_CON__SKILL_HIT }, t_target)
		self:changeState('disappear')
	end)
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillAoESquare:findTarget()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType, self.m_targetFormation)
    local x = self.pos.x
	local y = self.pos.y
	local width = (self.m_skillWidth / 2)
	local height = (self.m_skillHeight / 2)

    return SkillTargetFinder:findTarget_AoESquare(l_target, x, y, width, height)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
    
	local hit = t_skill['hit'] -- 공격 횟수
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(hit)
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
