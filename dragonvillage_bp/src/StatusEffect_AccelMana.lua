local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_AccelMana
-------------------------------------
StatusEffect_AccelMana = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_AccelMana:init(file_name, body)
end

-------------------------------------
-- function onStart
-------------------------------------
function StatusEffect_AccelMana:onStart()
    self.m_world:setManaAccelValue(1, not self.m_owner.m_bLeftFormation)
end

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_AccelMana:onEnd()
    self.m_world:setManaAccelValue(0, not self.m_owner.m_bLeftFormation)
end
