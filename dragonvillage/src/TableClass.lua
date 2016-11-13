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