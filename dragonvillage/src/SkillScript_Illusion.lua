local PARENT = SkillScript_ClanRaidBoss

local CON_SKILL_IDLE = 'skill_idle'

-------------------------------------
-- class SkillScript_ClanRaidBoss
-------------------------------------
SkillScript_Illusion = class(PARENT, {})

-------------------------------------
-- function init_skill
-------------------------------------
function SkillScript_Illusion:init_skill(script_name, duration)
    PARENT.init_skill(self, script_name, duration)

    -- 받는 피해 증가 상태효과 설정
    local struct_status_effect = StructStatusEffect({
        type = 'cldg_dmg_add',
		target_type = 'self',
		target_count = 1,
		trigger = CON_SKILL_IDLE,
		duration = self.m_duration + 0.5,
		rate = 100,
		value = 250,
        source = '',
    })
    table.insert(self.m_lStatusEffect, struct_status_effect)

    -- 다중 광폭화 상태효과 설정
    local struct_status_effect = StructStatusEffect({
        type = 'passive_fury',
		target_type = 'ally_all',
		target_count = '',
		trigger = CON_SKILL_END,
		duration = -1,
		rate = 100,
		value = 30,
        source = '',
    })
    table.insert(self.m_lStatusEffect, struct_status_effect)
end
