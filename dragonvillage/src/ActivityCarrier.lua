-------------------------------------
-- class ActivityCarrier
-------------------------------------
ActivityCarrier = class({
		m_activityCarrierOwner = 'character',

        m_attribute = 'attribute(number)',
        m_damageType = 'DMG_TYPE(number)', -- DMG_TYPE_PHYSICAL or DMG_TYPE_MAGICAL

        m_lFinalStat = 'list',

        -- 스킬 계수
        m_skillCoefficient = 'number',

        -- 스킬 추가 공격력
        m_skillAddAtk = 'number',

        -- 상태이상 유발
        m_lStatusEffectRate = 'table',

		-- @ 공격시점에서의 공격 대상의 상태 정보
		m_tEventInfo = '',

		m_atkDmgStat = 'str',
		m_bIgnoreDef = 'bool',
        m_bHighlight = 'boolean',   -- 피격 대상이 하일라이트 되어야하는지 여부

		m_attackType = 'str',		-- 일반공격인지 아닌지 구분
        m_lFlag = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ActivityCarrier:init()
    self.m_lFinalStat = {}
    self.m_skillCoefficient = 1
    self.m_skillAddAtk = 0
    self.m_lStatusEffectRate = {}
	self.m_tEventInfo = {}
	self.m_atkDmgStat = 'atk'
	self.m_bIgnoreDef = false
    self.m_bHighlight = false
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
-- function insertStatusEffectRate
-- @brief 상태이상 유발
-------------------------------------
function ActivityCarrier:insertStatusEffectRate(l_status_effect_str)
	for i = 1, 2 do 
		local l_effect = StatusEffectHelper:parsingStatusEffectStr(l_status_effect_str, i)
		if l_effect then 
			local type = l_effect['type']
            local _start_con = l_effect['start_con']
			local _rate = l_effect['rate']
            local _value = l_effect['value_1']

			if (not self.m_lStatusEffectRate[type]) then
				self.m_lStatusEffectRate[type] = {value = 0, rate = 0}
			end
			local value = self.m_lStatusEffectRate[type]['value']
			local rate = self.m_lStatusEffectRate[type]['rate']
			self.m_lStatusEffectRate[type] = { value = value + _value, rate = rate + _rate, start_con = _start_con }
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
	activity_carrier.m_damageType = self.m_damageType

	activity_carrier.m_lFinalStat = clone(self.m_lFinalStat)

    return activity_carrier
end


--------------------------------------------------------------------------
-- GET SET FUNC
--------------------------------------------------------------------------

-------------------------------------
-- function setEventInfo
-------------------------------------
function ActivityCarrier:setEventInfo(info)
	if (type(info) == 'table') then 
		self.m_tEventInfo = info 
	end
end

-------------------------------------
-- function getEventInfo
-------------------------------------
function ActivityCarrier:getEventInfo()
	return self.m_tEventInfo or {}
end

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
-- function getAtkDmgStat
-------------------------------------
function ActivityCarrier:getAtkDmgStat()
	return self.m_atkDmgStat
end

-------------------------------------
-- function setPowerRate
-------------------------------------
function ActivityCarrier:setPowerRate(power_rate)
	if (not power_rate) then
		error('power_rate 가 nil입니다.')
	end

	-- 0~1 사이값
	if (power_rate > 1) then 
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
-- function setHighlight
-------------------------------------
function ActivityCarrier:setHighlight(bool)
	self.m_bHighlight = bool
end

-------------------------------------
-- function isHighlight
-------------------------------------
function ActivityCarrier:isHighlight()
	return self.m_bHighlight
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
end

-------------------------------------
-- function getAttackType
-------------------------------------
function ActivityCarrier:getAttackType()
	return self.m_attackType
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