local PARENT = TableClass

-------------------------------------
-- class TableDrop
-------------------------------------
TableDrop = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDrop:init()
    self.m_tableName = 'drop'
    self.m_orgTable = TABLE:get(self.m_tableName)
end