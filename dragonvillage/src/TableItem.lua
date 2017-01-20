local PARENT = TableClass

-------------------------------------
-- class TableItem
-------------------------------------
TableItem = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableItem:init()
    self.m_tableName = 'item'
    self.m_orgTable = TABLE:get(self.m_tableName)
end