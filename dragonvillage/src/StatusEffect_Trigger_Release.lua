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
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Trigger_Release:getTriggerFunction()
	local trigger_func = function()
		if (not self.m_bApply and not self.m_bReset) then
			-- 생성된 이후 아직 미적용 상태인 경우
		else
			self:changeState('end')
			return true
		end
	end

	return trigger_func
end
