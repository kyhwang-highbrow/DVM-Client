local PARENT = TableClass

-------------------------------------
-- class TableHighbrow
-------------------------------------
TableHighbrow = class(PARENT, {

})

local THIS = TableHighbrow

-------------------------------------
-- function init
-------------------------------------
function TableHighbrow:init()
    self.m_tableName = 'table_highbrow'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function find
-- @param v2 : code or name
-------------------------------------
function TableHighbrow:find(game, v2)
    if (self == THIS) then
        self = THIS()
    end

    for i, v in pairs(self.m_orgTable) do
        if (v['game'] == game) and ((v['code'] == v2) or (v['name'] == v2))then
            return v
        end
    end
end