local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_addAttack
-------------------------------------
StatusEffect_addAttack = class(PARENT,{
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_addAttack:init(file_name, body)
end

-------------------------------------
-- function onTrigger
-------------------------------------
function StatusEffect_addAttack:onTrigger(target)
    local owner = self.m_owner
    local t_skill = self.m_subData
	local target = target
	
	-- 확률체크
    --if (math_random(1, 1000) > t_skill['status_effect_rate'] * 10) then return end

    SkillAddAttack:makeSkillInstance(owner, t_skill, target)
end