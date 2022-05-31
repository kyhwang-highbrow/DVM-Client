-------------------------------------
-- class TableClass
-------------------------------------
TableClass = class({
        m_tableName = 'string',
        m_orgTable = 'table',
        m_currKey = '',
    })

-------------------------------------
-- function init
-------------------------------------
function TableClass:init(table_name, key)
    self.m_tableName = table_name
    self.m_orgTable = TABLE:get(table_name)
end

-------------------------------------
-- function setKey
-------------------------------------
function TableClass:setKey(key)
    self.m_currKey = key
end

-------------------------------------
-- function exists
-------------------------------------
function TableClass:exists(key)
    local t_table = self.m_orgTable[key]

    if t_table then
        return true
    else
        return false
    end
end

-------------------------------------
-- function get
-------------------------------------
function TableClass:get(key, skip_error_msg)
    
    local key = key or self.m_currKey
    self.m_currKey = key
    local t_table = self.m_orgTable[key]

    if (skip_error_msg == nil) then
        skip_error_msg = (IS_TEST_MODE() == false)
    end

    if (not t_table) and (not skip_error_msg) then
        cclog('######################################')
        cclog('# error "' .. self.m_tableName .. '.csv"테이블에서 ' .. key .. ' 데이터가 없습니다.')
        cclog('######################################')
    end

    return t_table
end

-------------------------------------
-- function getValue
-------------------------------------
function TableClass:getValue(primary, column)
    local t_table = self:get(primary)

    if t_table then
        return t_table[column]
    end

    return nil
end

-------------------------------------
-- function filterTable
-------------------------------------
function TableClass:filterTable(key, value)
    local t_ret = {}

    for i,v in pairs(self.m_orgTable) do 
        if (v[key] == value) then
            t_ret[i] = v
        end
    end

    return t_ret
end

-------------------------------------
-- function filterList
-------------------------------------
function TableClass:filterList(key, value)
    local l_ret = {}

    for i,v in pairs(self.m_orgTable) do 
        if (v[key] == value) then
            table.insert(l_ret, v)
        end
    end

    return l_ret
end

-------------------------------------
-- function filterTable_condition
-------------------------------------
function TableClass:filterTable_condition(condition_func)
    local t_ret = {}

    for i,v in pairs(self.m_orgTable) do
        if condition_func(v) then
            t_ret[i] = v
        end
    end

    return t_ret
end

-------------------------------------
-- function filterList_condition
-------------------------------------
function TableClass:filterList_condition(condition_func)
    local l_ret = {}

    for i,v in pairs(self.m_orgTable) do 
        if condition_func(v) then
            table.insert(l_ret, v)
        end
    end

    return l_ret
end

-------------------------------------
-- function getRandomRow
-------------------------------------
function TableClass:getRandomRow()
    local cnt = table.count(self.m_orgTable)
    local rand_num = math_random(1, cnt)

    local idx = 1
    for i,v in pairs(self.m_orgTable) do
        if (idx == rand_num) then
            return clone(v)
        end

        idx = (idx + 1)
    end
end

-------------------------------------
-- function getCommaSeparatedValues
-------------------------------------
function TableClass:getCommaSeparatedValues(primary, column, trim_execution)
    local t_table = self:get(primary)

    if (not t_table) then
        return nil
    end

    local str = t_table[column]
    return self:seperate(str, ',', trim_execution)
end

-------------------------------------
-- function getSemicolonSeparatedValues
-------------------------------------
function TableClass:getSemicolonSeparatedValues(primary, column, trim_execution)
    local t_table = self:get(primary)

    if (not t_table) then
        return nil
    end

    local str = t_table[column]
    return self:seperate(str, ';', trim_execution)
end

-------------------------------------
-- function seperate
-------------------------------------
function TableClass:seperate(str, divider, trim_execution)
    if (str == nil) or (str == '') then
        return {}
    end

    local l_values = seperate(str, divider)
    if (not l_values) then
        if trim_execution then
            str = trim(str)
        end
        return {str}
    end

    if trim_execution then
        for i,v in ipairs(l_values) do
            l_values[i] = trim(v)
        end
    end

    return l_values
end

-------------------------------------
-- function cloneOrgTable
-------------------------------------
function TableClass:cloneOrgTable()
    return clone(self.m_orgTable)
end