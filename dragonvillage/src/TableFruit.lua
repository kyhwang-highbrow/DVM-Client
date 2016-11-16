local PARENT = TableClass

-------------------------------------
-- class TableFruit
-------------------------------------
TableFruit = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableFruit:init()
    self.m_tableName = 'fruit'
    self.m_orgTable = TABLE:get(self.m_tableName)
end