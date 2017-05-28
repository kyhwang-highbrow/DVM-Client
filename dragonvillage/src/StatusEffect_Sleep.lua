local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Sleep
-- @brief StatusEffect_Trigger와는 다르게 trigger 발동시 해제된다. 해제만을 위해 클래스를 나눌 필요가 있는지는 고민중
-------------------------------------
StatusEffect_Sleep = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Sleep:init(file_name, body)
    self.m_triggerName = 'undergo_attack'
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Sleep:getTriggerFunction()
	local trigger_func = function()
		if (not self.m_bApply) then
			-- 생성된 이후 아직 미적용 상태인 경우
		else
			self:changeState('end')
			return true
		end
	end

	return trigger_func
end
