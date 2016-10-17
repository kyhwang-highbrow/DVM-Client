local PARENT = class(Entity, ISkill:getCloneTable())

-------------------------------------
-- class SkillConicAtk
-------------------------------------
SkillConicAtk = class(PARENT, {
		m_range = 'number',
		m_attackCount = 'number',
		m_maxAttackCount = 'number',

		m_degree = 'degree',

		m_hitInterval = 'number',
		m_multiAtkTimer = 'dt',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillConicAtk:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillConicAtk:init_skill(attack_count, range)
    PARENT.init_skill(self)

	-- 멤버 변수
	self.m_maxAttackCount = attack_count
    self.m_range = range
	self.m_degree = getDegree(self.m_owner.pos.x, self.m_owner.pos.y, self.m_targetPos.x, self.m_targetPos.y)

	-- 위치 설정
	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

	-- 애니메이션 설정
    self.m_animator:setRotation(self.m_degree)
	self.m_animator:setPosition(self:getAttackPosition())
end

-------------------------------------
-- function initState
-------------------------------------
function SkillConicAtk:initState()
    self:addState('idle', SkillConicAtk.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, 'idle', nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillConicAtk.st_idle(owner, dt)
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
        owner:attack()
        owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
		owner.m_attackCount = owner.m_attackCount + 1
    end
	
	-- 공격 횟수 초과시 탈출
    if (owner.m_attackCount >= owner.m_maxAttackCount) then
        owner:changeState('dying')
    end
end

-------------------------------------
-- function getDefaultTargetPos
-- @brief 디폴트 타겟 좌표
-------------------------------------
function SkillConicAtk:getDefaultTargetPos()
    local l_target = self.m_owner:getTargetList(self.m_tSkill)
    local target = l_target[1]

    if target then
        return target.pos.x, target.pos.y
    else
        return self.m_owner.pos.x, self.m_owner.pos.y
    end
end

-------------------------------------
-- function attack
-------------------------------------
function SkillConicAtk:attack()
    local t_targets = self:findTarget(self.m_owner.pos.x, self.m_owner.pos.y, self.m_range, self.m_degree)

    for i,target_char in ipairs(t_targets) do
        -- 공격
        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
		
		-- @TODO 공격에 묻어나는 이펙트 Carrier 에 담아서..
		StatusEffectHelper:doStatusEffectByType(target_char, self.m_statusEffectType, self.m_statusEffectRate)
    end
end

-------------------------------------
-- function findTarget
-- @brief 공격 대상 찾음
-------------------------------------
function SkillConicAtk:findTarget(x, y, range, degree)
    local world = self.m_world
	
	local t_data = {}
	t_data['x'] = x -- 시작 좌표
	t_data['y'] = y
	t_data['dir'] = degree -- 방향
	t_data['radius'] = range -- 거리
    t_data['angle_range'] = 20 -- 각도 범위

	local l_target = world:getTargetList(self.m_owner, x, y, 'enemy', 'x', 'fan_shape', t_data)

    return l_target
end

-------------------------------------
-- function makeSkillInstnce
-------------------------------------
function SkillConicAtk:makeSkillInstnce(owner, missile_res, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target, attack_count, range)
	-- 1. 스킬 생성
    local skill = SkillConicAtk(missile_res)

	-- 2. 초기화 관련 함수
	skill:setParams(owner, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target)
    skill:init_skill(attack_count, range)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('idle')

    -- 4. Physics, Node, GameMgr에 등록
    local world = owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillConicAtk:makeSkillInstnceFromSkill(owner, t_skill, t_data)
    local owner = owner
		
	-- 1. 공통 변수
	local power_rate = t_skill['power_rate']
	local target_type = t_skill['target_type']
	local status_effect_type = t_skill['status_effect_type']
	local status_effect_rate = t_skill['status_effect_rate']
	local skill_type = t_skill['type']
	local tar_x = t_data.x
	local tar_y = t_data.y
	local target = t_data.target

	-- 2. 특수 변수
	local attack_count = t_skill['hit']
    local range = t_skill['val_1']
	local missile_res = t_skill['res_1']

    SkillConicAtk:makeSkillInstnce(owner, missile_res, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target, attack_count, range)
end
