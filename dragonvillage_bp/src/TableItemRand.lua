local PARENT = TableClass

-------------------------------------
-- class TableItemRand
-------------------------------------
TableItemRand = class(PARENT, {
    })

local THIS = TableItemRand

-------------------------------------
-- function init
-------------------------------------
function TableItemRand:init()
    self.m_tableName = 'table_item_rand'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRandItemList
-------------------------------------
function TableItemRand:getRandItemList(item_id)
    if (self == THIS) then
        self = THIS()
    end

    local l_item_id = self:getValue(item_id, 'item_id')
    return l_item_id
end