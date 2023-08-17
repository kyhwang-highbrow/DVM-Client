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


-------------------------------------
-- function getLairStatStrByIds
-------------------------------------
function TableLairStatus:getLairStatStrByIds(l_ids)
    local table_option = TableOption()
    local str = ''

    for idx , id in ipairs(l_ids) do
        local option = self:getValue(id, 'key')
        local value = self:getValue(id, 'key_value')

        if idx > 1 then
            str = str .. ', ' .. table_option:getOptionDesc(option, value)
        else
            str = str .. table_option:getOptionDesc(option, value)
        end
    end

    return str
end

-------------------------------------
-- function getLairOverlapStatStrByIds
-------------------------------------
function TableLairStatus:getLairOverlapStatStrByIds(l_ids)
    local table_option = TableOption()
    local str = ''
    local buff_map = {}

    for idx , id in ipairs(l_ids) do
        local option = self:getValue(id, 'key')
        local value = self:getValue(id, 'key_value')

        if buff_map[option] == nil then
            buff_map[option] = value
        else
            buff_map[option] = buff_map[option] + value
        end
    end

    local idx = 1
    str = ''
    for option , value in pairs(buff_map) do
        if idx > 1 then
            str = str .. ', ' .. table_option:getOptionDesc(option, value)
        else
            str = str .. table_option:getOptionDesc(option, value)
        end
        idx = idx + 1
    end
    return str
end