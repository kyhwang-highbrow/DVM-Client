local PARENT = TableClass
-------------------------------------
-- class TableLairStatus
-------------------------------------
TableLairStatus = class(PARENT, {
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableLairStatus:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_lair_status'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableLairStatus instance
-------------------------------------
function TableLairStatus:getInstance()
    if (instance == nil) then
        instance = TableLairStatus()
    end
    return instance
end

-------------------------------------
-- function getLairStatsByIdList
-------------------------------------
function TableLairStatus:getLairStatsByIdList(l_ids)
    local l_buffs = {}

    for _ , id in ipairs(l_ids) do
        local key = self:getValue(id, 'key')
        local value = self:getValue(id, 'key_value')

        local t_ret = {}
        t_ret['buff_type'] = key
        t_ret['buff_value'] = value

        table.insert(l_buffs, t_ret)
    end

    return l_buffs
end