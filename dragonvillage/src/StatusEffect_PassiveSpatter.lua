local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_PassiveSpatter
-------------------------------------
StatusEffect_PassiveSpatter = class(PARENT, {
		m_spatterTriggerName = ''
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_PassiveSpatter:init(file_name, body)
end

-------------------------------------
-- function onTrigger
-------------------------------------
function StatusEffect_PassiveSpatter:onTrigger()
    local owner = self.m_owner
    local t_skill = self.m_subData
    SkillSpatter:makeSkillInstnceFromSkill(owner, t_skill)
end