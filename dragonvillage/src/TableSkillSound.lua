local PARENT = TableClass

-------------------------------------
-- class TableSkillSound
-------------------------------------
TableSkillSound = class(PARENT, {
    })

local THIS = TableSkillSound

-------------------------------------
-- function init
-------------------------------------
function TableSkillSound:init()
    self.m_tableName = 'skill_sound'
    self.m_orgTable = TABLE:get(self.m_tableName)
end