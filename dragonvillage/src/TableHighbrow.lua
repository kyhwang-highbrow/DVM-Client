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
-- function init
-------------------------------------
function TableHighbrow:find(game, code)
    if (self == THIS) then
        self = THIS()
    end

    for i, v in pairs(self.m_orgTable) do
        if (v['game'] == game) and (v['code'] == code) then
            return v
        end
    end
end