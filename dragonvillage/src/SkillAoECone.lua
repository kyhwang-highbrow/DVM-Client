local PARENT = class(Skill, ISkillMultiAttack:getCloneTable())

-------------------------------------
-- class SkillAoECone
-- @brief 목표 지점에 특정 각도의 원뿔 공격 실행
-------------------------------------
SkillAoECone = class(PARENT, {
		m_angle = 'num',
		m_dir = 'num', 
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoECone:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoECone:init_skill(attack_count, dir)
    PARENT.init_skill(self)

	-- 멤버 변수
	self.m_maxAttackCount = attack_count
    self.m_range = g_constant:get('SKILL', 'CONE_RANGE')
	
	-- 고정 각도
	if (type(dir) == 'number') then
		self.m_dir = dir
	-- 변동 각도
	else
		self.m_dir = getAdjustDegree(getDegree(self.m_owner.pos.x, self.m_owner.pos.y, self.m_targetPos.x, self.m_targetPos.y))
	end

	-- 위치 설정
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoECone:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('target_cone', self.m_skillSize)  

		--self.m_resScale = t_data['scale']
		self.m_angle = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoECone:initState()
	self:setCommonState(self)
	self:addState('start', SkillAoECone.st_appear, 'appear', false)
    self:addState('attack', SkillAoECone.st_attack, 'idle_'..self.m_angle, true)
	self:addState('disappear', SkillAoECone.st_disappear, 'disappear', false)
end

-------------------------------------
-- function enterAttack
-------------------------------------
function SkillAoECone:enterAttack()
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
function SkillAoECone:escapeAttack()
	self:changeState('disappear')
end

-------------------------------------
-- function setAttackInterval
-- @brief 스킬에 따라 오버라이딩 해서 사용
-------------------------------------
function SkillAoECone:setAttackInterval()
	-- 이펙트 재생 단위 시간
	self.m_hitInterval = (self.m_animator:getDuration() / self.m_maxAttackCount)
end

-------------------------------------
-- function findCollision
-- @brief 모든 충돌 대상 찾음(Body 기준)
-------------------------------------
function SkillAoECone:findCollision()
    local l_target = self:getProperTargetList()
    local l_ret = SkillTargetFinder:findCollision_AoECone(l_target, self.m_targetPos.x, self.m_targetPos.y, self.m_dir, self.m_range, self.m_angle)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoECone:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	local attack_count = t_skill['hit']
    local dir = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoECone(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, dir)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
