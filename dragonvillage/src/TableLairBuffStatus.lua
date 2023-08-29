local PARENT = TableClass
-------------------------------------
-- class TableLairBuffStatus
-------------------------------------
TableLairBuffStatus = class(PARENT, {
    m_mapOptionMaxLevel = 'Map<string, number>',
    m_mapTypeMaxLevel = 'Map<string, number>',
    m_listUniqueOptionId = 'List<number>',
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableLairBuffStatus:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_lair_buff_status'
    self.m_orgTable = TABLE:get(self.m_tableName)

    self.m_mapOptionMaxLevel = {}
    self.m_listUniqueOptionId = {}
    self.m_mapTypeMaxLevel = {}

    for id, v in pairs(self.m_orgTable) do
        local key = v['key']

        if self.m_mapOptionMaxLevel[key] == nil then
            self.m_mapOptionMaxLevel[key] = 1
            table.insert(self.m_listUniqueOptionId, id)
        else
            self.m_mapOptionMaxLevel[key] = self.m_mapOptionMaxLevel[key] + 1
        end
--[[
        local type = v['type']
        local option_level = v['option_level'] 

        if self.m_mapTypeMaxLevel[type] == nil then
            self.m_mapTypeMaxLevel[type] = option_level
        end

        if self.m_mapTypeMaxLevel[type] < option_level then
            self.m_mapTypeMaxLevel[type] = option_level
        end ]]
    end

    table.sort(self.m_listUniqueOptionId, function(a, b) return a < b  end)
end

-------------------------------------
-- function getInstance
---@return TableLairBuffStatus instance
-------------------------------------
function TableLairBuffStatus:getInstance()
    if (instance == nil) then
        instance = TableLairBuffStatus()
    end
    return instance
end

-------------------------------------
-- function getLairStatLevel
-------------------------------------
function TableLairBuffStatus:getLairStatLevel(id)
    return self:getValue(id, 'option_level')
end

-------------------------------------
-- function getLairStatOptionKey
-------------------------------------
function TableLairBuffStatus:getLairStatOptionKey(id)
    return self:getValue(id, 'key')
end

-------------------------------------
-- function getLairStatOptionValue
-------------------------------------
function TableLairBuffStatus:getLairStatOptionValue(id)
    return self:getValue(id, 'key_value')
end

-------------------------------------
-- function getLairStatMaxLevelByType
-------------------------------------
function TableLairBuffStatus:getLairStatMaxLevelByType(type)
    return self.m_mapTypeMaxLevel[type]
end


-------------------------------------
-- function getLairStatMaxLevelByOptionKey
-------------------------------------
function TableLairBuffStatus:getLairStatMaxLevelByOptionKey(option_key)
    return self.m_mapOptionMaxLevel[option_key] or 1
end

-------------------------------------
-- function getLairStatOptionIdList
-------------------------------------
function TableLairBuffStatus:getLairStatOptionIdList(option_key)
    local id_list = self:filterColumnList('key', option_key, 'lid')
    table.sort(id_list, function(a, b) return a < b end)
    return id_list
end

-------------------------------------
-- function getLairRepresentOptionKeyListByType
-------------------------------------
function TableLairBuffStatus:getLairRepresentOptionKeyListByType(type_id)
    local result = {}
    for _, id in ipairs(self.m_listUniqueOptionId) do
        local key = self:getLairStatOptionKey(id)
        if self:getValue(id, 'type') == type_id then
            table.insert(result, key)
        end
    end
    return result
end

-------------------------------------
-- function getLairStatsByIdList
-------------------------------------
function TableLairBuffStatus:getLairStatsByIdList(l_ids)
    local l_buffs = {}
    local count_map = {}

    for _ , id in ipairs(l_ids) do
--[[         if count_map[id] == nil then
            count_map[id] = 1
        else
            count_map[id] = count_map[id] + 1
        end ]]

        local key = self:getValue(id, 'key')
        local value = self:getValue(id, 'key_value')

        local t_ret = {}
        t_ret['buff_type'] = key
        t_ret['buff_value'] = value

        table.insert(l_buffs, t_ret)
    end

--[[     for id, count in pairs(count_map) do
        local key = self:getValue(id, 'key')
        local value = self:getValue(id, 'key_value')

        if count >= 3 then
            local t_ret = {}
            t_ret['buff_type'] = key
            t_ret['buff_value'] = value * (count - 3 + 1)
            table.insert(l_buffs, t_ret)
        end
    end ]]

    return l_buffs
end

-------------------------------------
-- function getLairStatStrByIds
-------------------------------------
function TableLairBuffStatus:getLairStatStrByIds(l_ids)
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
function TableLairBuffStatus:getLairOverlapStatStrByIds(l_ids)
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