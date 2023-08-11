local PARENT = TableClass
-------------------------------------
-- class TableLatea
-------------------------------------
TableLatea = class(PARENT, {
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableLatea:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_latea'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableLatea instance
-------------------------------------
function TableLatea:getInstance()
    if (instance == nil) then
        instance = TableLatea()
    end
    return instance
end

-------------------------------------
-- function getLat
-------------------------------------
function TableLatea:getIndivPassName(id)
    return Str(self:getValue(id, 't_pass_name'))
end