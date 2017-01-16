local PARENT = Skill

-------------------------------------
-- class SkillAoERound
-------------------------------------
SkillAoERound = class(PARENT, {
        m_maxAttackCnt = 'number',
		m_attackCnt = 'number',
		m_aoeRes = 'str', 

        m_multiAtkTimer = 'dt',
        m_hitInterval = 'number',

		m_addDamage = 'str',	-- @TODO 임시 추가 데미지 구현
		m_lTarget = 'characters'  -- @TODO 임시 구현
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
function SkillAoERound:init_skill(attack_count, range, aoe_res, add_damage)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_maxAttackCnt = attack_count 
    self.m_range = range
	self.m_aoeRes = aoe_res
	self.m_addDamage = add_damage
	self.m_hitInterval = 1/30
	
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)

	self:makeRangeEffect(RES_RANGE, range)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoERound:initState()
	self:setCommonState(self)
    self:addState('start', SkillAoERound.st_appear, 'appear', false)
    self:addState('attack', SkillAoERound.st_attack, 'idle', true)
	self:addState('disappear', SkillAoERound.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillAoERound.st_appear(owner, dt)
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
        owner:runAttack(false)
        owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
		owner.m_attackCnt = owner.m_attackCnt + 1
    end
	
	-- 공격 횟수 초과시 탈출
    if (owner.m_maxAttackCnt <= owner.m_attackCnt) then
		-- 상태효과 (self만 가능)
        --StatusEffectHelper:doStatusEffectByStr(owner.m_owner, owner.m_lTarget, owner.m_lStatusEffectStr)
        owner:doStatusEffect({ STATUS_EFFECT_CON__SKILL_HIT }, owner.m_lTarget)
        owner:changeState('disappear')
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillAoERound.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_rangeEffect:changeAni('disappear', false)
		owner.m_rangeEffect:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillAoERound:runAttack()
    local t_target = self:findTarget()
	self.m_lTarget = t_target

    for i, target_char in ipairs(t_target) do
		-- @TODO 중독 추가 데미지 임시 구현!!!
		local add_value = 0
		if string.find(self.m_addDamage, ';') then	
			local l_str = stringSplit(self.m_addDamage, ';')
			local add_type = l_str[1]
			add_Value = l_str[2]
			for type, status_effect in pairs(target_char:getStatusEffectList()) do
				if (status_effect.m_statusEffectName == add_type) then 
					add_value = l_str[2]
					break
				end
			end
		end
		-- 데미지를 공격시마다 계산
		self.m_activityCarrier.m_skillCoefficient = ((self.m_powerRate + add_value) / 100)

        -- 공격
        self:attack(target_char)
		
		-- @TODO 낙뢰와 같은 경우 타겟 마다 이펙트 생성 임시 구현
		if (self.m_maxAttackCnt == 1) then 
			self:makeEffect(target_char.pos.x, target_char.pos.y)
		end 
    end

	-- 스킬이 제거할 수 있는 미사일 제거
	self:removeDestructibleMissile()
end

-------------------------------------
-- function makeEffect
-- @breif 추가 이펙트 생성 .. 현재는 같은 리소스 사용
-------------------------------------
function SkillAoERound:makeEffect(x, y)
    -- 이팩트 생성
    local effect = MakeAnimator(self.m_aoeRes)
    effect:setPosition(x, y)
    effect:changeAni('idle', false)
    self.m_owner.m_world.m_missiledNode:addChild(effect.m_node, 0)
	effect:addAniHandler(function() 
		effect.m_node:runAction(cc.RemoveSelf:create())
	end)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
    local range = t_skill['val_1']		  -- 공격 반경
	local aoe_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())	  -- 광역 스킬 리소스

	local add_damage = t_skill['val_2'] -- 추가데미지 필드

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = nil
	-- 리소스를 개별적으로 찍어야 하는 경우에 기본 생성을 하지 않는다. 조건은 좀 더 고려해봐야함  
	if (attack_count == 1) then 
		skill = SkillAoERound(nil)
	else
		skill = SkillAoERound(aoe_res)
	end

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, range, aoe_res, add_damage)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
