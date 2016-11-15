local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Trigger_Release
-- @brief StatusEffect_Trigger와는 다르게 trigger 발동시 해제된다. 해제만을 위해 클래스를 나눌 필요가 있는지는 고민중
-------------------------------------
StatusEffect_Trigger_Release = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Trigger_Release:init(file_name, body)
end

-------------------------------------
-- function runSpatter
-------------------------------------
function StatusEffect_Trigger_Release:onTrigger()
	self:changeState('end')
	return true
end