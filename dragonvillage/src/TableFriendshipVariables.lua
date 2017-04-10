local PARENT = TableClass

-------------------------------------
-- class TableFriendshipVariables
-------------------------------------
TableFriendshipVariables = class(PARENT, {
    })

local THIS = TableFriendshipVariables

-------------------------------------
-- function init
-------------------------------------
function TableFriendshipVariables:init()
    self.m_tableName = 'table_dragon_friendship_variables'
    self.m_orgTable = TABLE:get(self.m_tableName)
end