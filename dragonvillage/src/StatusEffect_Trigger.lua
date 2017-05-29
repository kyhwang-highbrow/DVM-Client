local PARENT = class(StatusEffect, IEventListener:getCloneTable())

-------------------------------------
-- class StatusEffect_Trigger
-------------------------------------
StatusEffect_Trigger = class(PARENT, {
		m_triggerName = 'str',
		m_statusEffectInterval = 'number',
		m_triggerFunc = 'function',

        m_tSkill = 'table',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Trigger:init(file_name, body)
	self.m_statusEffectInterval = g_constant:get('INGAME', 'STATUEEFFECT_GLOBAL_COOL')

    self.m_triggerFunc = self:getTriggerFunction()
end

-------------------------------------
-- function onStart
-------------------------------------
function StatusEffect_Trigger:onStart()
    -- listner 등록
    self.m_owner:addListener(self.m_triggerName, self)
end

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_Trigger:onEnd()
    -- listener 해제
    self.m_owner:removeListener(self.m_triggerName, self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function StatusEffect_Trigger:onEvent(event_name, t_event, ...)
    if (event_name == self.m_triggerName) then

		-- 트리거 쿨타임을 사용하지 않는 경우
		if (self.m_statusEffectInterval == 0) then
			if (self.m_triggerFunc) then
				self.m_triggerFunc(t_event, ...)
			end

		-- 트리거 쿨타임 사용
		else
			if (self.m_stateTimer > self.m_statusEffectInterval) then
				self.m_stateTimer = self.m_stateTimer - self.m_statusEffectInterval
				if (self.m_triggerFunc) then
					self.m_triggerFunc(t_event, ...)
				end
			end
		end
    end
end

-------------------------------------
-- function getTriggerFunction
-- @brief 트리거에서 사용될 함수를 정의
-------------------------------------
function StatusEffect_Trigger:getTriggerFunction()
end
