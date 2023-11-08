local PARENT = TableClass
-------------------------------------
--- @class TableResearch
-------------------------------------
TableResearch = class(PARENT, {
})

local instance = nil
-------------------------------------
--- @function init
-------------------------------------
function TableResearch:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_research'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
--- @function getInstance
---@return TableResearch instance
-------------------------------------
function TableResearch:getInstance()
    if (instance == nil) then
        instance = TableResearch()
    end
    return instance
end