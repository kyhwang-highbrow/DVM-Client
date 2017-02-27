local PARENT = TableClass

-------------------------------------
-- class TableTamerSkill
-------------------------------------
TableTamerSkill = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableTamerSkill:init()
    self.m_tableName = 'tamer_skill'
    self.m_orgTable = TABLE:get(self.m_tableName)
end