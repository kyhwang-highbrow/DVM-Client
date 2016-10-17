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
-- @brief Ʈ���� �����ϰ� ������ ����
-------------------------------------
function StatusEffect_Trigger:init_trigger(trigger_name, char)
	self.m_triggerName = trigger_name
	self.m_targetChar = char
	char:addListener(self.m_triggerName, self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function StatusEffect_Trigger:onEvent(event_name, ...)
    if (event_name == self.m_triggerName) then
        self:onTrigger(...)
    end
end

-------------------------------------
-- function statusEffectReset
-------------------------------------
function StatusEffect_Trigger:release()
    self.m_targetChar:removeListener(self.m_triggerName, self)
	PARENT.release(self)
end

-------------------------------------
-- function runSpatter
-------------------------------------
function StatusEffect_Trigger:onTrigger(defender)
	local owner = nil
    local status_effect_type = self.m_subData['status_effect_type']
	local status_effect_rate = self.m_subData['status_effect_rate']
	
    if (string.find(status_effect_type, 'buff')) then
		owner = self.m_targetChar
	else
		owner = defender
	end
    
	StatusEffectHelper:doStatusEffectByType(owner, status_effect_type, status_effect_rate)
end