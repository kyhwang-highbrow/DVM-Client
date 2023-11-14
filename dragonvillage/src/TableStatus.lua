local PARENT = TableClass

-------------------------------------
-- class TableStatus
-------------------------------------
TableStatus = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableStatus:init()
    self.m_tableName = 'status'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function isPercentValue
-------------------------------------
function TableStatus:isPercentValue(type)
    local val = self:getValue(type, 'is_percent')
    return val == 1
end