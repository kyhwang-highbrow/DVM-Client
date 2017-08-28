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
    self.m_activityCarrier = self:makeActivityCarrier()
    self.m_activityCarrier:setIgnoreDef(true)
    self.m_activityCarrier:setParam('add_dmg', true)
end

-------------------------------------
-- function getActivityCarrier
-------------------------------------
function StatusEffectUnit_AddDmgOneTime:getActivityCarrier()
    return self.m_activityCarrier
end