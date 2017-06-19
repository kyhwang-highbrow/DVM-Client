local PARENT = TableClass

-------------------------------------
-- class TableDragonCombine
-------------------------------------
TableDragonCombine = class(PARENT, {
    })

local THIS = TableDragonCombine

-------------------------------------
-- function init
-------------------------------------
function TableDragonCombine:init()
    self.m_tableName = 'table_dragon_combine'
    self.m_orgTable = TABLE:get(self.m_tableName)
end