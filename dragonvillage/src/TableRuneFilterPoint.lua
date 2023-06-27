local PARENT = TableClass

-------------------------------------
-- class TableRuneFilterPoint
-------------------------------------
TableRuneFilterPoint = class(PARENT, {
})

local THIS = TableRuneFilterPoint
-------------------------------------
-- function init
-------------------------------------
function TableRuneFilterPoint:init()
    self.m_tableName = 'table_rune_filter_point'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRuneSetId
-------------------------------------
function TableRuneFilterPoint:getRuneSetId(rune_id)
    if (self == THIS) then
        self = THIS()
    end

    if self.m_orgTable == nil or self:exists(rune_id) == false then
        return getDigit(rune_id, 100, 2)
    end

    local set_id = self:getValue(rune_id, 'set_id')
    return set_id
end
