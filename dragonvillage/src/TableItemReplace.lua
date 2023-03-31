local PARENT = TableClass

-------------------------------------
-- class TableItemReplace
-------------------------------------
TableItemReplace = class(PARENT, {
    })

local THIS = TableItemReplace

-------------------------------------
-- function init
-------------------------------------
function TableItemReplace:init()
    self.m_tableName = 'table_item_replace'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getItemReplaceInfo
-------------------------------------
function TableItemReplace:getItemReplaceInfo(id)
    if (self == THIS) then
        self = THIS()
    end

    return self:get(id)
end
