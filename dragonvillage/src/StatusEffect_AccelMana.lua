local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_AccelMana
-------------------------------------
StatusEffect_AccelMana = class(PARENT, {
    m_world = 'GamaWorld',
    m_formation = 'bool',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_AccelMana:init(file_name, body)
end


-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_AccelMana:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)
    self.m_world = target_char.m_world
    self.m_formation = target_char.m_bLeftFormation
end

-------------------------------------
-- function onStart
-------------------------------------
function StatusEffect_AccelMana:onStart()
    self.m_world:setManaAccelValue(1, self.m_formation)
end


-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_AccelMana:onEnd()
    self.m_world:setManaAccelValue(0, self.m_formation)
end
