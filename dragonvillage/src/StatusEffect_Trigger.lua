local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Trigger
-------------------------------------
StatusEffect_Trigger = class(PARENT, IEventListener:getCloneTable(), {
		m_triggerName = 'str',
		m_eventFunction = 'function',

		m_preActedTime = 'number',

		m_statusEffectInterval = 'number',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Trigger:init(file_name, body)
	self.m_eventFunction = nil
	self.m_preActedTime = 0
	self.m_statusEffectInterval = STATUEEFFECT_GLOBAL_COOL
end

-------------------------------------
-- function init_trigger
-- @brief 트리거 설정하고 시전자 저장
-------------------------------------
function StatusEffect_Trigger:init_trigger(char, trigger_name, event_function)
	self.m_owner = char
	self.m_triggerName = trigger_name
	self.m_eventFunction = event_function

	char:addListener(self.m_triggerName, self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function StatusEffect_Trigger:onEvent(event_name, t_event, ...)
    if (event_name == self.m_triggerName) then

		-- 트리거 쿨타임을 사용하지 않는 경우
		if (self.m_statusEffectInterval == 0) then
			self:onTrigger(t_event, ...)

		-- 트리거 쿨타임 사용
		else
			if (self.m_stateTimer > self.m_statusEffectInterval) then
				self.m_stateTimer = self.m_stateTimer - self.m_statusEffectInterval
				self:onTrigger(t_event, ...)

			end
		end
    end
end

-------------------------------------
-- function statusEffectReset
-------------------------------------
function StatusEffect_Trigger:release()
    self.m_owner:removeListener(self.m_triggerName, self)
    
	--@ TODO 상태효과 관리 구조 재설계 필요
	self:statusEffectReset()
	PARENT.release(self)
end

-------------------------------------
-- function onTrigger
-------------------------------------
function StatusEffect_Trigger:onTrigger(t_event, defender)
	if (self.m_eventFunction) then 
		self.m_eventFunction(defender)
		return true
	end

	local t_status_effect_str = {self.m_subData['status_effect_1'], self.m_subData['status_effect_2']}
	StatusEffectHelper:doStatusEffectByStr(self.m_owner, {defender}, t_status_effect_str)
	return true
end