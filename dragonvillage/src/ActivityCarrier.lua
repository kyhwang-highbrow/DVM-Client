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

        -- 상태이상 유발
        m_lStatusEffectRate = 'table',

		-- @ 공격시점에서의 공격 대상의 상태 정보
		m_damagedInfo = '',

		m_atkDmgStat = 'str',
		m_bIgnoreDef = 'bool',

		m_attackType = 'str',		-- 일반공격인지 아닌지 구분
        m_lFlag = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ActivityCarrier:init()
    self.m_lFinalStat = {}
    self.m_skillCoefficient = 1
    self.m_lStatusEffectRate = {}
	self.m_damagedInfo = {}
	self.m_atkDmgStat = 'atk'
	self.m_bIgnoreDef = false
    self.m_lFlag = {}
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
function ActivityCarrier:insertStatusEffectRate(type, value, rate)
	-- type이나 value, rate가 비정상적이라면 return
	if (nil == rate) or (0 >= rate) then return end
	if (not value) then return end
	if (type == 'x') then return end

    if (not self.m_lStatusEffectRate[type]) then
        self.m_lStatusEffectRate[type] = {value = 0, rate = 0}
    end
	
	local _value = self.m_lStatusEffectRate[type]['value']
	local _rate = self.m_lStatusEffectRate[type]['rate']
    self.m_lStatusEffectRate[type] = {value = _value + value, rate = _rate + rate}
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
-- function setDamagedInfo
-------------------------------------
function ActivityCarrier:setDamagedInfo(info)
	if type(info) == 'table' then 
		self.m_damagedInfo = info 
	end
end

-------------------------------------
-- function getDamagedInfo
-------------------------------------
function ActivityCarrier:getDamagedInfo()
	return self.m_damagedInfo or {}
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
	self.m_attackType = attack_type
end

-------------------------------------
-- function getAttackType
-------------------------------------
function ActivityCarrier:getAttackType()
	return self.m_attackType
end