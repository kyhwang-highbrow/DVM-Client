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

        -- 스킬 추가 공격력
        m_skillAddAtk = 'number',

        -- 상태이상 유발
        m_lStatusEffectRate = 'table',

		m_atkDmgStat = 'str',
		m_bIgnoreDef = 'bool',
        
        m_realAttackType = 'str',
		m_attackType = 'str',		-- 일반공격인지 아닌지 구분
        m_critical = 'number',      -- 크리티컬 판정(1:발동 , 0:미발동, nil:판정안됨)
        m_lFlag = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ActivityCarrier:init()
    self.m_lFinalStat = {}
    self.m_skillId = nil
    self.m_skillCoefficient = 1
    self.m_skillAddAtk = 0
    self.m_lStatusEffectRate = {}
	self.m_atkDmgStat = 'atk'
	self.m_bIgnoreDef = false
    self.m_lFlag = {}
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
-- function getStatusEffectCount
-- @brief 공격자에게 해당 이름을 포함한 상태효과가 몇개가 존재하는지 카운트를 리턴
-------------------------------------
function ActivityCarrier:getStatusEffectCount(name, except_name)
    if (not self.m_activityCarrierOwner) then return false end

    return self.m_activityCarrierOwner:getStatusEffectCount(name, except_name)
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
-- function insertStatusEffectRate
-- @brief 상태이상 유발
-------------------------------------
function ActivityCarrier:insertStatusEffectRate(l_status_effect_struct)
	for i = 1, 2 do 
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
	
	activity_carrier.m_lFinalStat = clone(self.m_lFinalStat)

    return activity_carrier
end


--------------------------------------------------------------------------
-- GET SET FUNC
--------------------------------------------------------------------------

-------------------------------------
-- function setFlag
-------------------------------------
function ActivityCarrier:setFlag(k, v)
	self.m_lFlag[k] = v
end

-------------------------------------
-- function getFlag
-------------------------------------
function ActivityCarrier:getFlag(k)
	return self.m_lFlag[k]
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
        atk_dmg = self.m_atkDmgStat(self, target)
    else
        local stat = SkillHelper:getValid(self.m_atkDmgStat, 'atk')
        atk_dmg = self:getStat(stat)

        if (not atk_dmg) then
            error('invalid stat type : ' .. stat)
        end
    end
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

	-- 0~1 사이값
	if (power_rate >= 1) then 
		self.m_skillCoefficient = (power_rate / 100)
	else
		self.m_skillCoefficient = power_rate
	end
end

-------------------------------------
-- function getPowerRate
-------------------------------------
function ActivityCarrier:getPowerRate()
	return self.m_skillCoefficient
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
	return self.m_bIgnoreDef
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