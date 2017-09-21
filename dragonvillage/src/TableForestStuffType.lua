local PARENT = TableClass

-------------------------------------
-- class TableForestStuffType
-------------------------------------
TableForestStuffType = class(PARENT, {
    })

local THIS = TableForestStuffType

-------------------------------------
-- function init
-------------------------------------
function TableForestStuffType:init()
    self.m_tableName = 'table_forest_stuff_type'
    self.m_orgTable = TABLE:get(self.m_tableName)
end