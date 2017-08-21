local PARENT = TableClass

-------------------------------------
-- class TableFruit
-------------------------------------
TableFruit = class(PARENT, {
    })

local THIS = TableFruit

-------------------------------------
-- function init
-------------------------------------
function TableFruit:init()
    self.m_tableName = 'fruit'
    self.m_orgTable = TABLE:get(self.m_tableName)
end


-------------------------------------
-- function getFruitFeel
-------------------------------------
function TableFruit:getFruitFeel(fid)
    if (self == THIS) then
        self = THIS()
    end

    local feel = self:getValue(fid, 'cumulative_exp')
    return feel
end