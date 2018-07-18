-------------------------------------
-- class StructAiSkillInfo
-------------------------------------
StructAiSkillInfo = class({
		m_unit = 'Character',
		m_skillId = 'number',
        m_mAiAttr = 'table',
        m_aiAtk = 'number',
	})

    -------------------------------------
    -- function init
    -------------------------------------
    function StructAiSkillInfo:init(unit, skill_id, mAiAttr, aiAtk)
	    self.m_unit = unit
	    self.m_skillId = skill_id
        self.m_mAiAttr = mAiAttr or {}
	    self.m_aiAtk = aiAtk or 0
    end