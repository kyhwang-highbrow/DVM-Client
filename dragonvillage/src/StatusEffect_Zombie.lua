local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Zombie
-- @breif HP 1 상태로 죽지 않고 일정시간 뒤 사망처리
-------------------------------------
StatusEffect_Zombie = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Zombie:init(file_name, body, ...)
	-- 트리거 쿨타임을 적용하지 않는다.
	self.m_statusEffectInterval = 0

    self.m_triggerName = 'dead'
end

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_Zombie:onEnd()
    PARENT.onEnd(self)
    
    -- TODO: 종료시 사망처리
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Zombie:getTriggerFunction()
	local trigger_func = function(t_event)
        -- 해당 상태효과 중일때는 죽지 않고 체력을 1만 남김
		t_event['is_dead'] = false
		t_event['hp'] = 1
	end

	return trigger_func
end
