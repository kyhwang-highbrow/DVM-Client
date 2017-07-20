local PARENT = StatusEffectUnit

-------------------------------------
-- class StatusEffectUnit_AddDmgOneTime
-------------------------------------
StatusEffectUnit_AddDmgOneTime = class(PARENT, {
    m_activityCarrier = 'ActivityCarrier',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit_AddDmgOneTime:init()
    self.m_activityCarrier = self.m_caster:makeAttackDamageInstance()
	self.m_activityCarrier:setPowerRate(self.m_value)
    self.m_activityCarrier:setAtkDmgStat(self.m_source)
	self.m_activityCarrier:setFlag('add_dmg', true)
end

-------------------------------------
-- function getActivityCarrier
-------------------------------------
function StatusEffectUnit_AddDmgOneTime:getActivityCarrier()
    return self.m_activityCarrier
end