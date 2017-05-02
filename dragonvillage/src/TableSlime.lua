local PARENT = TableClass

-------------------------------------
-- class TableSlime
-------------------------------------
TableSlime = class(PARENT, {
    })

local THIS = TableSlime

-------------------------------------
-- function init
-------------------------------------
function TableSlime:init()
    self.m_tableName = 'table_slime'
    self.m_orgTable = TABLE:get(self.m_tableName)
end