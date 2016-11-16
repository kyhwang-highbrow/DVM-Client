local PARENT = TableClass

-------------------------------------
-- class TableFriendship
-------------------------------------
TableFriendship = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableFriendship:init()
    self.m_tableName = 'friendship'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function isMaxFriendshipLevel
-------------------------------------
function TableFriendship:isMaxFriendshipLevel(flv)
    local t_friendship = self:get(flv)
    return (t_friendship['req_exp'] == 0)
end