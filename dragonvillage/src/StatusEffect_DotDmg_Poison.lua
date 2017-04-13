local PARENT = StatusEffect_DotDmg_Bleed

-------------------------------------
-- class StatusEffect_DotDmg_Poison
-------------------------------------
StatusEffect_DotDmg_Poison = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_DotDmg_Poison:init(file_name, body)
	self.m_trigger = 'hit'
end

