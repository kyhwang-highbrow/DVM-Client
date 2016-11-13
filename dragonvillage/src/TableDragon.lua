local PARENT = TableClass

-------------------------------------
-- class TableDragon
-------------------------------------
TableDragon = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDragon:init()
    self.m_tableName = 'dragon'
    self.m_orgTable = TABLE:get(self.m_tableName)
end