local PARENT = Skill

-------------------------------------
-- class SkillAoECone
-------------------------------------
SkillAoECone = class(PARENT, {
		m_angle = 'num',
		m_dir = 'num', 

		m_attackCount = 'number',
		m_maxAttackCount = 'number',
		
		m_hitInterval = 'number',
		m_multiAtkTimer = 'dt',
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
function SkillAoECone:init_skill(attack_count, range, angle)
    PARENT.init_skill(self)

	-- 멤버 변수
	self.m_maxAttackCount = attack_count
    self.m_range = range
	self.m_angle = angle
	self.m_dir = getDegree(self.m_owner.pos.x, self.m_owner.pos.y, self.m_targetPos.x, self.m_targetPos.y)

	-- 위치 설정
	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

	-- 애니메이션 설정
	self:initConeAnimator()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoECone:initState()
	self:setCommonState(self)
    self:addState('start', SkillAoECone.st_idle, 'idle', true)
end

-------------------------------------
-- function initConeAnimator
-------------------------------------
function SkillAoECone:initConeAnimator()
    self.m_animator:setRotation(self.m_dir)
	self.m_animator:setPosition(self:getAttackPosition())
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillAoECone.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 이펙트 재생 단위 시간
		owner.m_hitInterval = (owner.m_animator:getDuration() / owner.m_maxAttackCount)
		-- 첫프레임부터 공격하기 위해서 인터벌 타임으로 설정
        owner.m_multiAtkTimer = owner.m_hitInterval

		owner.m_attackCount = 0
    end
	
	-- 반복 공격
    owner.m_multiAtkTimer = owner.m_multiAtkTimer + dt
    if (owner.m_multiAtkTimer > owner.m_hitInterval) then
		owner.m_attackCount = owner.m_attackCount + 1
        owner:runAttack()
        owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
    end
	
	-- 공격 횟수 초과시 탈출
    if (owner.m_attackCount >= owner.m_maxAttackCount) then
        owner:escapeAttack()
    end
end

-------------------------------------
-- function findTarget
-- @brief 공격 대상 찾음
-------------------------------------
function SkillAoECone:findTarget()
    local world = self.m_world
	
	local t_data = {}
	t_data['x'] = self.pos.x				-- 시작 좌표
	t_data['y'] = self.pos.y
	t_data['dir'] = self.m_dir				-- 방향
	t_data['radius'] = self.m_range			-- 거리
    t_data['angle_range'] = self.m_angle	-- 각도 범위

	local l_target = world:getTargetList(self.m_owner, x, y, 'enemy', 'x', 'fan_shape', t_data)

    return l_target
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoECone:escapeAttack()
	self:changeState('dying')
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoECone:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']
    local range = t_skill['val_1']
	local angle = t_skill['val_2']
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoECone(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, range, angle)
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
