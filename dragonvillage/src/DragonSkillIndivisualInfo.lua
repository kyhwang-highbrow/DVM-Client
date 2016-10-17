-------------------------------------
-- class DragonSkillIndivisualInfo
-------------------------------------
DragonSkillIndivisualInfo = class({
        m_charType = 'string',
        m_skillID = 'number',
        m_tSkill = 'table',
        m_turnCount = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSkillIndivisualInfo:init(char_type, skill_id)
    self.m_charType = char_type
    self.m_skillID = skill_id

    local table_skill = TABLE:get(self.m_charType .. '_skill')
    self.m_tSkill = table_skill[skill_id]

    if (not self.m_tSkill) then
        error('skill_id ' .. skill_id)
    end

    self.m_turnCount = 0
end