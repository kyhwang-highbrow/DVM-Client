local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Sleep
-------------------------------------
StatusEffect_Sleep = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Sleep:init(file_name, body)
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Sleep:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self:addTrigger('under_atk', self:getTriggerFunction(), g_constant:get('INGAME', 'STATUEEFFECT_GLOBAL_COOL'))
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Sleep:getTriggerFunction()
	local trigger_func = function()
        if (self.m_bApply) then
			self:changeState('end')
			return true
		end
	end

	return trigger_func
end
