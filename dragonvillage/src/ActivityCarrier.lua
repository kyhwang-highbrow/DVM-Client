-------------------------------------
-- class ActivityCarrier
-------------------------------------
ActivityCarrier = class({
		m_activityCarrierOwner = 'character',

        m_attribute = 'attribute(number)',
        
        m_lFinalStat = 'list',

        -- 스킬 아이디
        m_skillId = 'number',
        
        -- 스킬 계수
        m_skillCoefficient = 'number',

        -- 스킬 치명타시 추가 계수
        m_skillAddCriCoefficient = 'number',

        -- 스킬 추가 공격력
        m_skillAddAtk = 'number',

        -- 스킬 히트 수
        m_skillHitCount = 'number',

        -- 상태이상 유발
        m_lStatusEffectRate = 'table',

		m_atkDmgStat = 'str',

        -- 피격시 무시할 요소들(차후 맵형태 테이블로 변경해야할듯...)
        m_bIgnoreAll = 'bool',
        m_bIgnoreCalc = 'bool',     -- 데미지 계산 무시(순수 공격력만 사용)
		m_bIgnoreDef = 'bool',
        m_bIgnoreAvoid = 'bool',
        m_bIgnoreBarrier = 'bool',  -- 보호막(무적 제외)
        m_bIgnoreProtect = 'bool',  -- 피해면역(무적)
        m_bIgnoreRevive = 'bool',
        m_bIgnoreGuardian = 'bool', -- 대신맞기

        m_ignoreTable = 'table',    -- 무시요소들을 모아놓은 테이블

        m_bDefiniteDeath = 'bool',  -- 피격 대상을 무조건 죽임
        
        m_realAttackType = 'str',
		m_attackType = 'str',		-- 일반공격인지 아닌지 구분
        m_critical = 'number',      -- 크리티컬 판정(1:발동 , 0:미발동, nil:판정안됨)
        m_tParam = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ActivityCarrier:init()
    self.m_lFinalStat = {}
    self.m_skillId = nil
    self.m_skillCoefficient = 100
    self.m_skillAddCriCoefficient = 0
    self.m_skillAddAtk = 0
    self.m_skillHitCount = 1
    self.m_lStatusEffectRate = {}
	self.m_atkDmgStat = 'atk'
    self.m_bIgnoreAll = false
    self.m_bIgnoreCalc = false
	self.m_bIgnoreDef = false
    self.m_bIgnoreAvoid = false
    self.m_bIgnoreBarrier = false
    self.m_bIgnoreProtect = false
    self.m_bIgnoreRevive = false
    self.m_bIgnoreGuardian = false
    self.m_bDefiniteDeath = false
    self.m_tParam = {}
end

-------------------------------------
-- function setStatuses
-------------------------------------
function ActivityCarrier:setStatuses(status_calc)
    for key,_ in pairs(status_calc.m_lStatusList) do
        self.m_lFinalStat[key] = status_calc:getFinalStat(key)
    end
end

-------------------------------------
-- function mergeStat
-------------------------------------
function ActivityCarrier:mergeStat(add_activity_carrier)
    for key, _ in pairs(self.m_lFinalStat) do
        self.m_lFinalStat[key] = self.m_lFinalStat[key] + add_activity_carrier:getStat(key)
    end
end

-------------------------------------
-- function getStat
-------------------------------------
function ActivityCarrier:getStat(type)
    if (self.m_attackType and self.m_attackType == 'active' and self.m_activityCarrierOwner) then
        return self.m_activityCarrierOwner:getStat(type)
    end

    return self.m_lFinalStat[type]
end

-------------------------------------
-- function getBuffStat
-- @brief 현재 적용된 버프수치를 가져온다
-------------------------------------
function ActivityCarrier:getBuffStat(type)
    if (not self.m_activityCarrierOwner) then return 0 end

    return self.m_activityCarrierOwner:getBuffStat(type)
end

-------------------------------------
-- function getHp
-- @brief 공격자의 현재 HP 정보를 가져온다
-------------------------------------
function ActivityCarrier:getHp()
    if (not self.m_activityCarrierOwner) then return 0 end

    return self.m_activityCarrierOwner:getHp()
end

-------------------------------------
-- function getHpRate
-- @brief 공격자의 현재 HP 비율값을 가져온다
-------------------------------------
function ActivityCarrier:getHpRate()
    if (not self.m_activityCarrierOwner) then return 0 end

    return self.m_activityCarrierOwner:getHpRate()
end

-------------------------------------
-- function getRarity
-- @breif 공격자의 rarity정보를 리턴
-------------------------------------
function ActivityCarrier:getRarity()
    if (not self.m_activityCarrierOwner) then return 1 end

    return self.m_activityCarrierOwner:getRarity()
end

-------------------------------------
-- function getGrade
-- @breif 공격자의 grade정보를 리턴
-------------------------------------
function ActivityCarrier:getGrade()
    if (not self.m_activityCarrierOwner) then return 1 end

    return self.m_activityCarrierOwner:getGrade()
end

-------------------------------------
-- function getTotalLevel
-- @breif 공격자의 누적 레벨값을 리턴
-------------------------------------
function ActivityCarrier:getTotalLevel()
    if (not self.m_activityCarrierOwner) then return 1 end

    return self.m_activityCarrierOwner:getTotalLevel()
end

-------------------------------------
-- function getRole
-- @breif 공격자의 role정보를 리턴
-------------------------------------
function ActivityCarrier:getRole()
    if (not self.m_activityCarrierOwner) then return end

    return self.m_activityCarrierOwner:getRole()
end

-------------------------------------
-- function getAttribute
-- @breif 속성 정보를 문자열로 리턴
-------------------------------------
function ActivityCarrier:getAttribute()
    return attributeStrToNum(self.m_attribute)
end

-------------------------------------
-- function getTargetChar
-------------------------------------
function ActivityCarrier:getTargetChar()
    if (not self.m_activityCarrierOwner) then return end

    return self.m_activityCarrierOwner:getTargetChar()
end

-------------------------------------
-- function getStatusEffectCount
-- @breif 파라미터의 칼럼과 값으로부터 동일한 상태효과가 존재하는 카운트를 리턴
-------------------------------------
function ActivityCarrier:getStatusEffectCount(column, value)
    if (not self.m_activityCarrierOwner) then return false end

    return self.m_activityCarrierOwner:getStatusEffectCount(column, value)
end

-------------------------------------
-- function isExistStatusEffectName
-- @brief 공격자가 해당 상태효과가 존재하는지 여부
-------------------------------------
function ActivityCarrier:isExistStatusEffectName(name, except_name)
    if (not self.m_activityCarrierOwner) then return false end

    return self.m_activityCarrierOwner:isExistStatusEffectName(name, except_name)
end

-------------------------------------
-- function isExistStatusEffect
-- @brief 파라미터의 칼럼과 값으로부터 동일한 상태효과가 존재하는지 여부
-------------------------------------
function ActivityCarrier:isExistStatusEffect(column, value)
    if (not self.m_activityCarrierOwner) then return false end

    return self.m_activityCarrierOwner:isExistStatusEffect(column, value)
end

-------------------------------------
-- function insertStatusEffectRate
-- @brief 상태이상 유발
-------------------------------------
function ActivityCarrier:insertStatusEffectRate(l_status_effect_struct)
	for i = 1, 4 do 
		local status_effect_struct = l_status_effect_struct[i]
		if (status_effect_struct) and (status_effect_struct.m_type) then
			local type = status_effect_struct.m_type
            local _start_con = status_effect_struct.m_trigger
            local _rate = status_effect_struct.m_rate
            local _value = status_effect_struct.m_value
            local _source = status_effect_struct.m_source
            local _duration = status_effect_struct.m_duration

			if (not self.m_lStatusEffectRate[type]) then
				self.m_lStatusEffectRate[type] = {value = 0, rate = 0}
			end
			local value = self.m_lStatusEffectRate[type]['value']
			local rate = self.m_lStatusEffectRate[type]['rate']
			self.m_lStatusEffectRate[type] = {
                value = value + _value,
                rate = rate + _rate,
                start_con = _start_con,
                source = _source,
                duration = _duration
            }
		end
	end
end

-------------------------------------
-- function cloneForMissile
-- @brief 미사일에서 사용할때 복사(영웅or적군 -> 미사일)
-------------------------------------
function ActivityCarrier:cloneForMissile()
    local activity_carrier = ActivityCarrier()
	
	activity_carrier.m_activityCarrierOwner = self.m_activityCarrierOwner
	activity_carrier.m_attribute = self.m_attribute

    activity_carrier:setAtkDmgStat(self.m_atkDmgStat)
    activity_carrier:setAttackType(self.m_realAttackType)
    activity_carrier:setSkillId(self.m_skillId)
    activity_carrier:setSkillHitCount(self.m_skillHitCount)
    activity_carrier:setPowerRate(self.m_skillCoefficient)
    activity_carrier:setAddCriPowerRate(self.m_skillAddCriCoefficient)

    activity_carrier:setIgnoreByTable(self.m_ignoreTable)

    --[[
    activity_carrier:setIgnoreAll(self:isIgnoreAll())
    activity_carrier:setIgnoreDef(self:isIgnoreDef())
    activity_carrier:setIgnoreAvoid(self:isIgnoreAvoid())
    ]]

    activity_carrier:setDefiniteDeath(self:isDefiniteDeath())
	
	activity_carrier.m_lFinalStat = clone(self.m_lFinalStat)
    activity_carrier.m_lStatusEffectRate = clone(self.m_lStatusEffectRate)

    return activity_carrier
end


--------------------------------------------------------------------------
-- GET SET FUNC
--------------------------------------------------------------------------

-------------------------------------
-- function setParam
-------------------------------------
function ActivityCarrier:setParam(k, v)
	self.m_tParam[k] = v
end

-------------------------------------
-- function getParam
-------------------------------------
function ActivityCarrier:getParam(k)
	return self.m_tParam[k]
end

-------------------------------------
-- function setAtkDmgStat
-------------------------------------
function ActivityCarrier:setAtkDmgStat(stat_type)
	self.m_atkDmgStat = stat_type
end

-------------------------------------
-- function getAtkDmg
-------------------------------------
function ActivityCarrier:getAtkDmg(target)
    
    local atk_dmg

    if (type(self.m_atkDmgStat) == 'function') then
        atk_dmg = self.m_atkDmgStat(self, target, self.m_tParam, self.m_skillId)

    elseif (type(self.m_atkDmgStat) == 'number') then
        atk_dmg = self.m_atkDmgStat

    else
        local stat = SkillHelper:getValid(self.m_atkDmgStat, 'atk')

        atk_dmg = self:getStat(stat)
        
        if (not atk_dmg) then
            error('invalid stat type : ' .. stat)
        end
    end

    -- 음수가 나오지 않도록 처리
    atk_dmg = math_max(atk_dmg, 0)

	return atk_dmg
end

-------------------------------------
-- function getFinalAtkDmg
-------------------------------------
function ActivityCarrier:getFinalAtkDmg(target)
    local atk_dmg = self:getAtkDmg(target)

    -- 스킬 계수 적용
	atk_dmg = atk_dmg * self:getPowerRate() / 100
        
	-- 스킬 추가 공격력 적용
    atk_dmg = atk_dmg + self:getAbsAttack()

    return atk_dmg
end

-------------------------------------
-- function setSkillId
-------------------------------------
function ActivityCarrier:setSkillId(skill_id)
    self.m_skillId = skill_id
end

-------------------------------------
-- function getSkillId
-------------------------------------
function ActivityCarrier:getSkillId()
    return self.m_skillId
end

-------------------------------------
-- function setPowerRate
-------------------------------------
function ActivityCarrier:setPowerRate(power_rate)
	if (not power_rate) or (power_rate == '') then
		error('power_rate 가 nil입니다.')
	end

	self.m_skillCoefficient = power_rate
end

-------------------------------------
-- function getPowerRate
-------------------------------------
function ActivityCarrier:getPowerRate()
	return self.m_skillCoefficient
end

-------------------------------------
-- function setAddCriPowerRate
-------------------------------------
function ActivityCarrier:setAddCriPowerRate(power_rate)
    if (not power_rate) or (power_rate == '') then
        return
    end

	self.m_skillAddCriCoefficient = power_rate or 0
end

-------------------------------------
-- function getAddCriPowerRate
-------------------------------------
function ActivityCarrier:getAddCriPowerRate()
	return self.m_skillAddCriCoefficient
end

-------------------------------------
-- function setIgnoreAll
-------------------------------------
function ActivityCarrier:setIgnoreAll(bool)
	self.m_bIgnoreAll = bool
end

-------------------------------------
-- function isIgnoreAll
-------------------------------------
function ActivityCarrier:isIgnoreAll()
	return self.m_bIgnoreAll
end

-------------------------------------
-- function setIgnoreCalc
-------------------------------------
function ActivityCarrier:setIgnoreCalc(bool)
	self.m_bIgnoreCalc = bool
end

-------------------------------------
-- function isIgnoreCalc
-------------------------------------
function ActivityCarrier:isIgnoreCalc()
	return self.m_bIgnoreCalc or self.m_bIgnoreAll
end

-------------------------------------
-- function setIgnoreDef
-------------------------------------
function ActivityCarrier:setIgnoreDef(bool)
	self.m_bIgnoreDef = bool
end

-------------------------------------
-- function isIgnoreDef
-------------------------------------
function ActivityCarrier:isIgnoreDef()
	return self.m_bIgnoreDef or self.m_bIgnoreAll
end

-------------------------------------
-- function setIgnoreAvoid
-------------------------------------
function ActivityCarrier:setIgnoreAvoid(bool)
	self.m_bIgnoreAvoid = bool
end

-------------------------------------
-- function isIgnoreAvoid
-------------------------------------
function ActivityCarrier:isIgnoreAvoid()
	return self.m_bIgnoreAvoid or self.m_bIgnoreAll
end

-------------------------------------
-- function setIgnoreBarrier
-------------------------------------
function ActivityCarrier:setIgnoreBarrier(bool)
	self.m_bIgnoreBarrier = bool
end

-------------------------------------
-- function isIgnoreBarrier
-------------------------------------
function ActivityCarrier:isIgnoreBarrier()
	return self.m_bIgnoreBarrier or self.m_bIgnoreAll
end

-------------------------------------
-- function setIgnoreProtect
-------------------------------------
function ActivityCarrier:setIgnoreProtect(bool)
	self.m_bIgnoreProtect = bool
end

-------------------------------------
-- function isIgnoreProtect
-------------------------------------
function ActivityCarrier:isIgnoreProtect()
	return self.m_bIgnoreProtect or self.m_bIgnoreAll
end
-------------------------------------
-- function setIgnoreRevive
-------------------------------------
function ActivityCarrier:setIgnoreRevive(bool)
	self.m_bIgnoreRevive = bool
end

-------------------------------------
-- function isIgnoreRevive
-------------------------------------
function ActivityCarrier:isIgnoreRevive()
	return self.m_bIgnoreRevive or self.m_bIgnoreAll
end

-------------------------------------
-- function setIgnoreGuardian
-------------------------------------
function ActivityCarrier:setIgnoreGuardian(bool)
	self.m_bIgnoreGuardian = bool
end

-------------------------------------
-- function isIgnoreGuardian
-------------------------------------
function ActivityCarrier:isIgnoreGuardian()
	return self.m_bIgnoreGuardian or self.m_bIgnoreAll
end

-------------------------------------
-- function setDefiniteDeath
-------------------------------------
function ActivityCarrier:setDefiniteDeath(bool)
	self.m_bDefiniteDeath = bool
end

-------------------------------------
-- function isDefiniteDeath
-------------------------------------
function ActivityCarrier:isDefiniteDeath()
	return self.m_bDefiniteDeath
end

-------------------------------------
-- function setAttackType
-- @brief 기본탄/공통탄/일반탄 인지 스킬인지 구분하기 위함
-------------------------------------
function ActivityCarrier:setAttackType(attack_type)
	if string.find(attack_type, 'basic') then
		self.m_attackType = 'basic'
	else
		self.m_attackType = attack_type
	end
    self.m_realAttackType = attack_type
end

-------------------------------------
-- function getAttackType
-------------------------------------
function ActivityCarrier:getAttackType()
	return self.m_attackType, self.m_realAttackType
end

-------------------------------------
-- function setCritical
-------------------------------------
function ActivityCarrier:setCritical(critical)
    self.m_critical = critical
end

-------------------------------------
-- function getCritical
-------------------------------------
function ActivityCarrier:getCritical()
    if (self.m_critical == nil) then return nil end

    return (self.m_critical == 1)
end

-------------------------------------
-- function setAbsAttack
-------------------------------------
function ActivityCarrier:setAbsAttack(power_abs)
	self.m_skillAddAtk = power_abs or 0
end

-------------------------------------
-- function getAbsAttack
-------------------------------------
function ActivityCarrier:getAbsAttack()
	return self.m_skillAddAtk
end

-------------------------------------
-- function setSkillHitCount
-------------------------------------
function ActivityCarrier:setSkillHitCount(count)
    self.m_skillHitCount = count
end

-------------------------------------
-- function getSkillHitCount
-------------------------------------
function ActivityCarrier:getSkillHitCount()
    return self.m_skillHitCount
end

-------------------------------------
-- function setActivityOwner
-------------------------------------
function ActivityCarrier:setActivityOwner(char)
	self.m_activityCarrierOwner = char
end

-------------------------------------
-- function getActivityOwner
-------------------------------------
function ActivityCarrier:getActivityOwner()
	return self.m_activityCarrierOwner
end

-------------------------------------
-- function findSkillInfoByID
-------------------------------------
function ActivityCarrier:findSkillInfoByID()
	if (not self.m_activityCarrierOwner) then return nil end

    local target = self.m_activityCarrierOwner:getTargetChar()

    if (target) then return target:findSkillInfoByID() end

    return nil
end


-------------------------------------
-- function setIgnoreByTable
-------------------------------------
function ActivityCarrier:setIgnoreByTable(ignore_table)
    self.m_ignoreTable = ignore_table and ignore_table or self.m_ignoreTable

    if (not self.m_ignoreTable) then return end

	-- 전체 무시
    if (self.m_ignoreTable['all']) then
        self:setIgnoreAll(true)
        return
    end

    -- 방무
    if (self.m_ignoreTable['def']) then
		self:setIgnoreDef(true)
    end

    -- 저항무시
    if (self.m_ignoreTable['avoid']) then
		self:setIgnoreAvoid(true)
    end

    -- 보호막 무시
    if (self.m_ignoreTable['barrier']) then 
		self:setIgnoreBarrier(true)
    end

    -- 무적무시
    if (self.m_ignoreTable['protect']) then 
		self:setIgnoreProtect(true)
    end

    -- 부활무시
    if (self.m_ignoreTable['resurrect']) then 
		self:setIgnoreRevive(true)
	end

    -- 트루뎀지
    if (self.m_ignoreTable['calc']) then
		self:setIgnoreCalc(true)
    end

    -- 대신맞기
    if (self.m_ignoreTable['guardian']) then
		self:setIgnoreGuardian(true)
    end
    
end