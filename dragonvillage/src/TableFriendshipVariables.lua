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

-------------------------------------
-- function getFeelMax
-------------------------------------
function TableFriendshipVariables:getFeelMax()
    local v = self:getValue('value', 'feel_max')
    return v
end

-------------------------------------
-- function getAtkMax
-------------------------------------
function TableFriendshipVariables:getAtkMax()
    local v = self:getValue('value', 'atk_max')
    return v
end

-------------------------------------
-- function getDefMax
-------------------------------------
function TableFriendshipVariables:getDefMax()
    local v = self:getValue('value', 'def_max')
    return v
end

-------------------------------------
-- function getHpMax
-------------------------------------
function TableFriendshipVariables:getHpMax()
    local v = self:getValue('value', 'hp_max')
    return v
end