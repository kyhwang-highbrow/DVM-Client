local PARENT = class(Entity, ISkill:getCloneTable())

-------------------------------------
-- class SkillAoERound
-------------------------------------
SkillAoERound = class(PARENT, {
        m_maxAttackCnt = 'number',
		m_attackCnt = 'number',
		m_aoeRes = 'str', 

        m_multiAtkTimer = 'dt',
        m_hitInterval = 'number',
		m_effect = 'effect',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoERound:init_skill(attack_count, range, aoe_res)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_maxAttackCnt = attack_count 
    self.m_range = range
	self.m_aoeRes = aoe_res

	-- 이펙트 생성 
    --self:makeEffect(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initActvityCarrier
-------------------------------------
function SkillAoERound:initActvityCarrier(t_skill)    
    PARENT.initActvityCarrier(self, t_skill)  
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoERound:initState()
    self:addState('appear', SkillAoERound.st_idle, 'appear', true)
    self:addState('attack', SkillAoERound.st_attack, 'idle', true)
	self:addState('disappear', SkillAoERound.st_disappear, 'disappear', false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)  
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillAoERound.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 이펙트 재생 단위 시간
		owner.m_hitInterval = owner.m_animator:getDuration()
	elseif (owner.m_stateTimer > owner.m_hitInterval) then
		owner:changeState('attack')
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillAoERound.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 이펙트 재생 단위 시간
		owner.m_hitInterval = owner.m_animator:getDuration()
		-- 첫프레임부터 공격하기 위해서 인터벌 타임으로 설정
        owner.m_multiAtkTimer = owner.m_hitInterval

		owner.m_attackCnt = 0
    end

	-- 반복 공격
    owner.m_multiAtkTimer = owner.m_multiAtkTimer + dt
    if (owner.m_multiAtkTimer > owner.m_hitInterval) then
        owner:attack()
        owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
		owner.m_attackCnt = owner.m_attackCnt + 1
    end
	
	-- 공격 횟수 초과시 탈출
	cclog(owner.m_attackCnt)
    if (owner.m_maxAttackCnt <= owner.m_attackCnt) then
        owner:changeState('dying')
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillAoERound.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 이펙트 재생 단위 시간
		owner.m_hitInterval = owner.m_animator:getDuration()
	elseif (owner.m_stateTimer > owner.m_hitInterval) then
		owner:changeState('dying')
    end
end

-------------------------------------
-- function getDefaultTargetPos
-- @brief 디폴트 타겟 좌표
-------------------------------------
function SkillAoERound:getDefaultTargetPos()
    return PARENT.getDefaultTargetPos(self) 
end

-------------------------------------
-- function findTarget
-- @brief 공격 대상 찾음
-------------------------------------
function SkillAoERound:findTarget(x, y, range)
    return PARENT.findTarget(self, x, y, range) 
end

-------------------------------------
-- function attack
-------------------------------------
function SkillAoERound:attack()
    local t_targets = self:findTarget()
	
    for i,target_char in ipairs(t_targets) do
        -- 공격
        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
		
		-- @TODO 패시브를 자동으로 태우기 위해서는 어디에 있어야..		
		if self.m_statusEffectType then 
			self:makeEffect(target_char.pos.x, target_char.pos.y)
			StatusEffectHelper:doStatusEffectByType(target_char, self.m_statusEffectType, self.m_statusEffectRate)
		end
    end
end

-------------------------------------
-- function makeEffect
-------------------------------------
function SkillAoERound:makeEffect(x, y)
    -- 이팩트 생성
    local effect = effectaoeround(self.m_aoeres)
    effect.m_maxattackcnt = self.m_maxattackcnt
    effect:setposition(x, y)
	effect:initstate()
    effect:changestate('appear')
	
	-- duration 가져오기 위해 저장
	self.m_effect = effect.m_animator

    self.m_owner.m_world.m_missilednode:addchild(effect.m_rootnode, 0)
    self.m_owner.m_world:addtounitlist(effect)
end

-------------------------------------
-- function makeSkillInstnce
-------------------------------------
function SkillAoERound:makeSkillInstnce(owner, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target, attack_count, range, aoe_res)
	-- 1. 스킬 생성
    local skill = SkillAoERound(aoe_res)

	-- 2. 초기화 관련 함수
	skill:setParams(owner, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target)
    skill:init_skill(attack_count, range, aoe_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('appear')

    -- 4. Physics, Node, GameMgr에 등록
    local world = owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillAoERound:makeSkillInstnceFromSkill(owner, t_skill, t_data)
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
	local attack_count = t_skill['hit']	  -- 공격 횟수
    local range = t_skill['val_1']		  -- 공격 반경
	local aoe_res = t_skill['res_1']	  -- 광역 스킬 리소스
	
    SkillAoERound:makeSkillInstnce(owner, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target, attack_count, range, aoe_res)
end



-------------------------------------
-- function st_idle
-------------------------------------
function SkillAoERound:update(dt)
	cclog(self.m_state, self.m_hitInterval)
end
---------------------------------------------------------------------------------------------------------------


-------------------------------------
-- class EffectAoERound
-------------------------------------
EffectAoERound = class(Entity, {
        m_owner = 'Character',
        m_maxAttackCnt = 'number',
		m_hitInterval = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function EffectAoERound:init(file_name, body, ...)
	self.m_hitInterval = 1/30
end

-------------------------------------
-- function initState
-------------------------------------
function EffectAoERound:initState()
    self:addState('appear', EffectAoERound.st_idle, 'appear', false)
    self:addState('idle', EffectAoERound.st_attack, 'idle', true)
    self:addState('disappear', EffectAoERound.st_disappear, 'disappear', false)
    self:addState('dying', function(owner, dt) return true end, nil, false, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function EffectAoERound.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 이펙트 재생 단위 시간
		owner.m_hitInterval = owner.m_animator:getDuration() or 1/30
	elseif (owner.m_stateTimer > owner.m_hitInterval) then
		owner:changeState('idle')
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function EffectAoERound.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 이펙트 재생 단위 시간
		owner.m_hitInterval = owner.m_animator:getDuration() or 1/30
    elseif (owner.m_stateTimer > owner.m_hitInterval * owner.m_maxAttackCnt) then
        owner:changeState('disappear')
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function EffectAoERound.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 이펙트 재생 단위 시간
		owner.m_hitInterval = owner.m_animator:getDuration() or 1/30
	elseif (owner.m_stateTimer > owner.m_hitInterval) then
		owner:changeState('dying')
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function EffectAoERound:update(dt)
	cclog(self.m_state, self.m_hitInterval)
end