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

		m_idleAniName = 'idle',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoESquare:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquare:init_skill(skill_width, skill_height, hit)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_skillWidth = skill_width
	self.m_skillHeight = skill_height

	self.m_maxAttackCnt = hit 
    self.m_attackCnt = 0
    self.m_hitInterval = ONE_FRAME * 7
	self.m_multiAtkTimer = self.m_hitInterval
	
	-- 하드코딩..
	self.m_idleAniName = 'idle'

	-- 위치 설정
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoESquare:initState()
	self:setCommonState(self)
    self:addState('start', SkillAoESquare.st_attack, self.m_idleAniName, true)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillAoESquare.st_attack(owner, dt)
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
-- function escapeAttack
-------------------------------------
function SkillAoESquare:escapeAttack()
	self:changeState('dying')
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillAoESquare:findTarget()
    local x = self.pos.x
	local y = self.pos.y

    local world = self.m_world

    local l_target = world:getTargetList(self.m_owner, x, y, self.m_findTargetType, 'x', 'distance_x')
    
    local l_ret = {}

    local std_width = (self.m_skillWidth / 2)
	local std_height = (self.m_skillHeight / 2)

    for i,v in ipairs(l_target) do
		if isCollision_Rect(x, y, v, std_width, std_height) then
            table.insert(l_ret, v)
		end
    end

    return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	local skill_width = t_skill['val_1']		-- 공격 반경 가로
	local skill_height = t_skill['val_2']		-- 공격 반경 세로
    
	local hit = t_skill['hit'] -- 공격 횟수
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(skill_width, skill_height, hit)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
