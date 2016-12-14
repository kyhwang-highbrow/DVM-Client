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
-- function get
-------------------------------------
function TableClass:get(key)
    local key = key or self.m_currKey
    self.m_currKey = key

    local t_table = self.m_orgTable[key]

    if (not t_table) then
        cclog('######################################')
        cclog('# error "table_' .. self.m_tableName .. '.csv"테이블에서 ' .. key .. ' 데이터가 없습니다.')
        cclog('######################################')
    end

    return t_table
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