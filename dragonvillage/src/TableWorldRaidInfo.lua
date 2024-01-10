local PARENT = TableClass
-------------------------------------
-- class TableWorldRaidInfo
-------------------------------------
TableWorldRaidInfo = class(PARENT, {
})

local instance = nil
-------------------------------------
---@function init
-------------------------------------
function TableWorldRaidInfo:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_world_raid_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
    self:makeAttrList()
end

-------------------------------------
-- @function getInstance
---@return TableWorldRaidInfo instance
-------------------------------------
function TableWorldRaidInfo:getInstance()
    if (instance == nil) then
        instance = TableWorldRaidInfo()
    end
    return instance
end