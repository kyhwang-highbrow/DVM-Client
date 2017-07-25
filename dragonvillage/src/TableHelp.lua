local PARENT = TableClass

-------------------------------------
-- class TableHelp
-------------------------------------
TableHelp = class(PARENT, {
    })

local THIS = TableHelp

-------------------------------------
-- function init
-------------------------------------
function TableHelp:init()
    self.m_tableName = 'table_help'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

