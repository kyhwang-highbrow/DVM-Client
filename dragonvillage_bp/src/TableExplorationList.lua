local PARENT = TableClass

-------------------------------------
-- class TableExplorationList
-------------------------------------
TableExplorationList = class(PARENT, {
    })

local THIS = TableExplorationList

-------------------------------------
-- function init
-------------------------------------
function TableExplorationList:init()
    self.m_tableName = 'table_exploration_list'
    self.m_orgTable = TABLE:get(self.m_tableName)
end