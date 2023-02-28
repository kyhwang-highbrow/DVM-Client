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
-- function CheckValidDateFromTableDataValue
-- @brief 테이블에서 사용되는 날짜 문자열 방식과 현재 날짜와 비교하여 유효한지 확인, 유효하면 true 반환
-- @parma date_min_str(str) '9999-12-31 23:59:59'
-- @parma date_max_str(str) '9999-12-31 23:59:59'
-------------------------------------
function CheckValidDateFromTableDataValue(date_min_str, date_max_str)
    local curr_timestamp = ServerTime:getInstance():getCurrentTimestampSeconds()

    -- date_min_str 값이 있는 경우 현재 날짜와 비교해서 데이터 처리
    if (date_min_str ~= nil) and (date_min_str ~= '') then
        -- ex. 9999-12-31 23:59:59
        local require_timestamp = ServerTime:getInstance():datestrToTimestampSec(date_min_str)
        -- 날짜 조건에 해당되지 않을 때 데이터 제거 
        if (require_timestamp > curr_timestamp) then 
            return false
        end
    end

    -- date_max_str 값이 있는 경우 현재 날짜와 비교해서 데이터 처리
    if (date_max_str ~= nil) and (date_max_str ~= '') then
        -- ex. 9999-12-31 23:59:59
        local require_timestamp = ServerTime:getInstance():datestrToTimestampSec(date_max_str)
        -- 날짜 조건에 해당되지 않을 때 데이터 제거 
        if (require_timestamp < curr_timestamp) then 
            return false
        end
    end

    return true
end

-------------------------------------
-- function filterTable_conditionDate
-- @brief 날짜 조건으로 현재 날짜와 비교해서 필터함
-------------------------------------
function TableClass:filterTable_conditionDate(min_column, max_column)
    local function condition_func(v)
        return CheckValidDateFromTableDataValue(v[min_column], v[max_column])
    end
    
    local t_ret = self:filterTable_condition(condition_func)
    return t_ret
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