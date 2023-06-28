local PARENT = TableClass

-------------------------------------
-- class TableRuneFilterPoint
-------------------------------------
TableRuneFilterPoint = class(PARENT, {
})

local THIS = TableRuneFilterPoint
local instance = nil

-------------------------------------
-- function init
-------------------------------------
function TableRuneFilterPoint:init()
    self.m_tableName = 'table_rune_filter_point'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableRuneFilterPoint
-------------------------------------
function TableRuneFilterPoint:getInstance()
    if (instance == nil) then
        instance = TableRuneFilterPoint()
    end
    return instance
end

-------------------------------------
-- function getRuneLevelPoint
-------------------------------------
function TableRuneFilterPoint:getRuneLevelPoint(grade, lv)
    if (self == THIS) then
        self = THIS()
    end

    if self:exists(lv) == false then
        return 0
    end
    
    local filter_point = self:getValue(lv, tostring(grade)) or 0
    return filter_point
end