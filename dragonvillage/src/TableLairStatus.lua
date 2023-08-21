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
-- function getLairStatLevel
-------------------------------------
function TableLairStatus:getLairStatLevel(id)
    return self:getValue(id, 'rate')
end

-------------------------------------
-- function getLairStatOptionKey
-------------------------------------
function TableLairStatus:getLairStatOptionKey(id)
    return self:getValue(id, 'key')
end

-------------------------------------
-- function getLairStatOptionValue
-------------------------------------
function TableLairStatus:getLairStatOptionValue(id)
    return self:getValue(id, 'key_value')
end

-------------------------------------
-- function getLairStatOptionIdList
-------------------------------------
function TableLairStatus:getLairStatOptionIdList(option_key)
    local id_list = self:filterColumnList('key', option_key, 'lid')
    table.sort(id_list, function(a, b) return a < b end)
    return id_list
end

-------------------------------------
-- function getLairRepresentOptionKeyListByType
-------------------------------------
function TableLairStatus:getLairRepresentOptionKeyListByType(type_id)
    local id_list = self:filterColumnList('type', type_id, 'lid')
    local result = {}
    local key_map = {}

    for _, id in ipairs(id_list) do
        local key = self:getLairStatOptionKey(id)
        if key_map[key] == nil then
            key_map[key] = true
            table.insert(result, key)
        end
    end

    --table.sort(result, function(a, b) return a < b end)
    return result
end


-------------------------------------
-- function getLairStatsByIdList
-------------------------------------
function TableLairStatus:getLairStatsByIdList(l_ids)
    local l_buffs = {}
    local count_map = {}

    for _ , id in ipairs(l_ids) do
        if count_map[id] == nil then
            count_map[id] = 1
        else
            count_map[id] = count_map[id] + 1
        end

        local key = self:getValue(id, 'key')
        local value = self:getValue(id, 'key_value')

        local t_ret = {}
        t_ret['buff_type'] = key
        t_ret['buff_value'] = value

        table.insert(l_buffs, t_ret)
    end

    for id, count in pairs(count_map) do
        local key = self:getValue(id, 'key')
        local value = self:getValue(id, 'key_value')

        if count >= 3 then
            local t_ret = {}
            t_ret['buff_type'] = key
            t_ret['buff_value'] = value * (count - 3 + 1)
            table.insert(l_buffs, t_ret)
        end
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
-- function getLairBonusStatStrByIds
-------------------------------------
function TableLairStatus:getLairBonusStatStrByIds(l_ids)
    local table_option = TableOption()
    local str = ''

    local count_map = {}
    for _ , id in ipairs(l_ids) do
        if count_map[id] == nil then
            count_map[id] = 1
        else
            count_map[id] = count_map[id] + 1
        end
    end


    local idx = 1
    for id, count in pairs(count_map) do
        local option = self:getValue(id, 'key')
        local value = self:getValue(id, 'key_value')

        if count >= 3 then
            value = value * (count - 3 + 1)
            if idx > 1 then
                str = str .. ', ' .. table_option:getOptionDesc(option, value)
            else
                str = str .. table_option:getOptionDesc(option, value)
            end

            idx = idx + 1
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