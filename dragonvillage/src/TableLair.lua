local PARENT = TableClass
-------------------------------------
-- class TableLair
-------------------------------------
TableLair = class(PARENT, {
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableLair:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_lair'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableLair instance
-------------------------------------
function TableLair:getInstance()
    if (instance == nil) then
        instance = TableLair()
    end
    return instance
end

-------------------------------------
-- function getLairIdListByType
-------------------------------------
function TableLair:getLairIdListByType(type_id)
    local list = self:filterColumnList('type', type_id, 'id')
    table.sort(list, function (a, b) return a < b end)

    local list_id = list[#list]
    table.insert(list, list_id + 1)
    return list
end

-------------------------------------
-- function getLairRequireCount
-------------------------------------
function TableLair:getLairRequireCount(lair_id)
    return self:getValue(lair_id, 'req_cnt')
end