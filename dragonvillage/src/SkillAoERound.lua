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
		owner:setAttackInterval()

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
		local t_target = owner:findTarget()
        owner:doStatusEffect({ STATUS_EFFECT_CON__SKILL_HIT }, t_target)
        owner:changeState('disappear')
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillAoERound.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 타격범위 이펙트
		owner.m_rangeEffect:changeAni('disappear', true)

		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillAoERound:runAttack()
    local t_target = self:findTarget()

	-- 특수한 부가 효과 구현
	self:doSpecailEffect(t_target)

    for i, target_char in ipairs(t_target) do
		
		local add_value = self:getPoisonAddDamage(target_char)

		-- 데미지를 공격시마다 계산
		self.m_activityCarrier:setPowerRate(self.m_powerRate + add_value)

        -- 공격
        self:attack(target_char)
		
		-- 타겟별 리소스
		self:makeEffect(self.m_aoeRes, target_char.pos.x, target_char.pos.y)
    end

	-- 스킬이 제거할 수 있는 미사일 제거
	self:removeDestructibleMissile()
end

-------------------------------------
-- function setAttackInterval
-------------------------------------
function SkillAoERound:setAttackInterval()
	-- 이펙트 재생 단위 시간
	self.m_hitInterval = self.m_animator:getDuration()
end

-------------------------------------
-- function doSpecailEffect
-------------------------------------
function SkillAoERound:doSpecailEffect(t_target)
end

-------------------------------------
-- function getPoisonAddDamage
-- @TODO 중독 추가 데미지 임시 구현!!!
-------------------------------------
function SkillAoERound:getPoisonAddDamage(target_char)
	local add_value = 0

	if (self.m_addDamage) then 
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
	end

	return add_value
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
    local range = t_skill['val_1']		  -- 공격 반경
	local add_damage = t_skill['val_2'] -- 추가데미지 필드
	
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 개별 타겟 이펙트 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound(missile_res)

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
