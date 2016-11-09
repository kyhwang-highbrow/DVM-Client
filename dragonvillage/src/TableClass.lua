-------------------------------------
-- class TableClass
-------------------------------------
TableClass = class({
        m_tableName = 'string',
        m_orgTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function TableClass:init(table_name)
    self.m_tableName = table_name
    self.m_orgTable = TABLE:get(table_name)
end

-------------------------------------
-- function get
-------------------------------------
function TableClass:get(key)
    return self.m_orgTable[key]
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