local PARENT = class(Skill, ISkillMultiAttack:getCloneTable())

-------------------------------------
-- class SkillAoEWedge
-------------------------------------
SkillAoEWedge = class(PARENT, {
		m_angle = 'num',
		m_dir = 'num', 
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoEWedge:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoEWedge:init_skill(attack_count)
    PARENT.init_skill(self)

	-- 멤버 변수
	self.m_maxAttackCount = attack_count
    self.m_range = g_constant:get('SKILL', 'LONG_LENGTH')
	self.m_dir = getAdjustDegree(getDegree((self.m_owner.pos.x + self.m_attackPosOffsetX), (self.m_owner.pos.y + self.m_attackPosOffsetY), self.m_targetPos.x, self.m_targetPos.y))
	
	-- 위치 설정
	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

	-- 애니메이션 설정
	self:initConeAnimator()
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoEWedge:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('wedge', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_angle = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoEWedge:initState()
	self:setCommonState(self)
    self:addState('start', SkillAoEWedge.st_appear, 'appear', false)
    self:addState('attack', SkillAoEWedge.st_attack, 'idle', false)
	self:addState('disappear', SkillAoEWedge.st_disappear, 'disappear', false)
end

-------------------------------------
-- function initConeAnimator
-------------------------------------
function SkillAoEWedge:initConeAnimator()
    self.m_animator:setRotation(self.m_dir)
	self.m_animator:setPosition(self:getAttackPosition())
end

-------------------------------------
-- function setAttackInterval
-- @brief 스킬에 따라 오버라이딩 해서 사용
-------------------------------------
function SkillAoEWedge:setAttackInterval()
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
-- function enterAttack
-------------------------------------
function SkillAoEWedge:enterAttack()
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
function SkillAoEWedge:escapeAttack()
	self:changeState('disappear')
end

-------------------------------------
-- function findCollision
-- @brief 공격 대상 찾음
-------------------------------------
function SkillAoEWedge:findCollision()
	local l_target = self:getProperTargetList()
	local pos_x = (self.pos.x + self.m_attackPosOffsetX)
	local pos_y = (self.pos.y + self.m_attackPosOffsetY)
    local l_ret = SkillTargetFinder:findCollision_AoECone(l_target, pos_x, pos_y, self.m_dir, self.m_range, self.m_angle)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoEWedge:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	local attack_count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoEWedge(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
