local PARENT = TableClass

-------------------------------------
-- class TableSkillSound
-------------------------------------
TableSkillSound = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableSkillSound:init()
    self.m_tableName = 'skill_sound'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function get
-------------------------------------
function TableSkillSound:get(key, skip_error_msg)
    return PARENT.get(self, key, true)
end