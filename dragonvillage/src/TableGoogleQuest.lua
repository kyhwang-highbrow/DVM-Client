local PARENT = TableClass

-------------------------------------
-- class TableGoogleQuest
-------------------------------------
TableGoogleQuest = class(PARENT, {
    })

local THIS = TableGoogleQuest

-------------------------------------
-- function init
-------------------------------------
function TableGoogleQuest:init()
    self.m_tableName = 'table_google_quest'
    self.m_orgTable = TABLE:get(self.m_tableName)
end