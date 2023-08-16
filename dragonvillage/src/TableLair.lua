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
-- function getLat
-------------------------------------
function TableLair:getIndivPassName(id)
    return Str(self:getValue(id, 't_pass_name'))
end