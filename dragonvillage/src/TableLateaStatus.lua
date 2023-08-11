local PARENT = TableClass
-------------------------------------
-- class TableLateaStatus
-------------------------------------
TableLateaStatus = class(PARENT, {
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableLateaStatus:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_latea_status'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableLateaStatus instance
-------------------------------------
function TableLateaStatus:getInstance()
    if (instance == nil) then
        instance = TableLateaStatus()
    end
    return instance
end

-------------------------------------
-- function getLateaStatsByIdList
-------------------------------------
function TableLateaStatus:getLateaStatsByIdList(l_ids)
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