local PARENT = StatusEffect_Protection

-------------------------------------
-- class StatusEffect_Resist
-- @breif HP있는 실드 보호막 + resist 보호막
-------------------------------------
StatusEffect_Resist = class(PARENT, {
		m_resistRate = 'number', 
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Resist:init(file_name, body, ...)
end

-------------------------------------
-- function init_trigger
-------------------------------------
function StatusEffect_Resist:init_trigger(char, resist_rate)
	PARENT.init_trigger(self, char, 'hit_barrier', nil)
	
	self.m_resistRate = resist_rate/100 or 0
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Resist:getTriggerFunction()
	local trigger_func = function(t_event)
		self:changeState('hit')

		-- 1. 데미지를 직접 경감
		local damage = t_event['damage']
   		damage = damage * (1 + self.m_resistRate)
		t_event['damage'] = damage
		t_event['is_handled'] = true
	end

	return trigger_func
end
