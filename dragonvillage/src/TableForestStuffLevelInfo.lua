local PARENT = TableClass

-------------------------------------
-- class TableForestStuffLevelInfo
-------------------------------------
TableForestStuffLevelInfo = class(PARENT, {
    })

local THIS = TableForestStuffLevelInfo

-------------------------------------
-- function init
-------------------------------------
function TableForestStuffLevelInfo:init()
    self.m_tableName = 'table_forest_stuff_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end