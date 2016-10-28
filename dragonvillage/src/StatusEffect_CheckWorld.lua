local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_CheckWorld
-------------------------------------
StatusEffect_CheckWorld = class(PARENT, {
		m_statusEffectType = 'str',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_CheckWorld:init(file_name, body)
end

-------------------------------------
-- function init_type
-------------------------------------
function StatusEffect_CheckWorld:init_checkWorld(status_effect_type)
	self.m_statusEffectType = status_effect_type
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect_CheckWorld:update(dt)
	local formation_mgr = self.m_targetChar:getFormationMgr('opposite')
	local char_list = formation_mgr:getEntireCharList()
	for _, char in pairs(char_list) do 
		for status_effect_type, status_effect in pairs(char:getStatusEffectList()) do
			if (status_effect_type == self.m_statusEffectType) then 
				local status_effect_type = self.m_subData['status_effect_type']
				local status_effect_rate = self.m_subData['status_effect_rate']
				StatusEffectHelper:invokeStatusEffect(self.m_targetChar, status_effect_type, status_effect_rate)
			end
		end
	end

    PARENT.update(self, dt)
end
