local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Trigger
-------------------------------------
StatusEffect_Trigger = class(PARENT, IEventListener:getCloneTable(), {
		m_triggerName = '',
		m_eventFunction = '',

		m_preActedTime = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Trigger:init(file_name, body)
	self.m_eventFunction = nil
	self.m_preActedTime = 0
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
function StatusEffect_Trigger:onEvent(event_name, ...)
    if (event_name == self.m_triggerName) then
		if (self.m_preActedTime == 0) then
			self.m_preActedTime = self.m_stateTimer
			return self:onTrigger(...)

		elseif (self.m_stateTimer > self.m_preActedTime + STATUEEFFECT_GLOBAL_COOL) then
			self.m_preActedTime = self.m_stateTimer
			return self:onTrigger(...)

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
function StatusEffect_Trigger:onTrigger(defender)
	if (self.m_eventFunction) then 
		self.m_eventFunction(defender)
		return true
	end

	local t_status_effect_str = {self.m_subData['status_effect_1'], self.m_subData['status_effect_2']}
	StatusEffectHelper:doStatusEffectByStr(self.m_owner, {defender}, t_status_effect_str)
	return true
end