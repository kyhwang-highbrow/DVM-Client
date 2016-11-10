local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Trigger
-------------------------------------
StatusEffect_Trigger = class(PARENT, IEventListener:getCloneTable(), {
		m_triggerName = ''
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Trigger:init(file_name, body)
end

-------------------------------------
-- function init_trigger
-- @brief 트리거 설정하고 시전자 저장
-------------------------------------
function StatusEffect_Trigger:init_trigger(trigger_name, char)
	self.m_triggerName = trigger_name
	self.m_owner = char
	char:addListener(self.m_triggerName, self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function StatusEffect_Trigger:onEvent(event_name, ...)
    if (event_name == self.m_triggerName) then
        return self:onTrigger(...)
    end
end

-------------------------------------
-- function statusEffectReset
-------------------------------------
function StatusEffect_Trigger:release()
    self.m_owner:removeListener(self.m_triggerName, self)
	--@ TODO 상태효과 관리 구조 재설계 필요
	self.m_owner.m_tOverlabStatusEffect[self.m_statusEffectName] = nil
	PARENT.release(self)
end

-------------------------------------
-- function runSpatter
-------------------------------------
function StatusEffect_Trigger:onTrigger(defender)
	local t_status_effect_str = {self.m_subData['status_effect_1'], self.m_subData['status_effect_2']}
	StatusEffectHelper:doStatusEffectByStr(self.m_owner, {defender}, t_status_effect_str)
	return true
end