local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_PassiveSpatter
-- @TODO 사용 안하는 중 ..setTriggerPassive 에서 분기 처리했는데 거기서 논의가 필요
-------------------------------------
StatusEffect_PassiveSpatter = class(PARENT, {
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
	SkillSpatter:makeSkillInstance(self.m_owner, self.m_subData)
end
