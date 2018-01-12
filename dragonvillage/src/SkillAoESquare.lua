local PARENT = class(Skill, ISkillMultiAttack:getCloneTable(), IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillAoESquare
-------------------------------------
SkillAoESquare = class(PARENT, {
        m_skillWidth = 'number',
		m_skillHeight = 'number',
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
	self.m_maxAttackCount = hit 
    --self.m_hitInterval -> attack state에서 지정

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
-- function onAppear
-------------------------------------
function SkillAoESquare:onAppear()
end

-------------------------------------
-- function enterAttack
-- @brief 공격이 시작되는 시점에 실행
-------------------------------------
function SkillAoESquare:enterAttack()
	-- 이펙트 재생 단위 시간
	self:setAttackInterval()
	-- 첫프레임부터 공격하기 위해서 인터벌 타임으로 설정
	self.m_multiAtkTimer = self.m_hitInterval
	-- 공격 카운트 초기화
	self.m_attackCount = 0
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoESquare:escapeAttack()
	self:changeState('disappear')
end

-------------------------------------
-- function setAttackInterval
-------------------------------------
function SkillAoESquare:setAttackInterval()
	local duration = 0
    
    if (self.m_animator) then
        duration = self.m_animator:getDuration()
    end

	-- 이펙트 재생 단위 시간
    if (duration == 0) then
        self.m_hitInterval = 1 / self.m_maxAttackCount
    else
	    self.m_hitInterval = duration / self.m_maxAttackCount
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillAoESquare:findCollision()
    local l_target = self:getProperTargetList()
    local x = self.pos.x
	local y = self.pos.y
	local width = (self.m_skillWidth / 2)
	local height = (self.m_skillHeight / 2)

    local l_ret = SkillTargetFinder:findCollision_AoESquare(l_target, x, y, width, height)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
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
end
