local PARENT = StatusEffect_Bleed

-------------------------------------
-- class StatusEffect_Poison
-------------------------------------
StatusEffect_Poison = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Poison:init(file_name, body)
	self.m_triggerName = 'char_do_atk'
end

