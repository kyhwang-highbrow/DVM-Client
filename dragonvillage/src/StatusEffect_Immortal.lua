local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Immortal
-- @breif 일정시간동안 죽지 않음
-------------------------------------
StatusEffect_Immortal = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Immortal:init(file_name, body, ...)
    -- 트리거 쿨타임을 적용하지 않는다.
	self.m_statusEffectInterval = 0

    self.m_triggerName = 'character_set_hp'
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Immortal:getTriggerFunction()
	local trigger_func = function(t_event)
        -- 해당 상태효과 중일때는 체력이 1이하로 내려가지 않음
		if (t_event['hp'] < 1) then
            t_event['hp'] = 1
        end
	end

	return trigger_func
end
