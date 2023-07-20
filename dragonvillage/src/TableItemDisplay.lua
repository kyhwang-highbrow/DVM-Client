local PARENT = TableClass

-------------------------------------
-- class TableItem
-- @brief   아이템을 다른 아이템처럼 보이도록 처리하는 테이블
--          돌려쓰는 이벤트마다 같은 아이템인데 다른 아이템처럼 보이도록 처리
-------------------------------------
TableItemDisplay = class(PARENT, {
    })

local THIS = TableItemDisplay

-------------------------------------
-- function init
-------------------------------------
function TableItemDisplay:init()
    self.m_tableName = 'table_item_display'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getItemReplaceInfo
-------------------------------------
function TableItemDisplay:getItemReplaceInfo(id)
    if (self == THIS) then
        self = THIS()
    end

    return self:get(id)
end
