local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_PassiveSpatter
-- @TODO ��� ���ϴ� �� ..setTriggerPassive ���� �б� ó���ߴµ� �ű⼭ ���ǰ� �ʿ�
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
	return true
end
