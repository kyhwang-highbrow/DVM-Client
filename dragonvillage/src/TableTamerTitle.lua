local PARENT = TableClass

-------------------------------------
-- class TableTamerTitle
-------------------------------------
TableTamerTitle = class(PARENT, {
    })

local THIS = TableTamerTitle

-------------------------------------
-- function init
-------------------------------------
function TableTamerTitle:init()
    self.m_tableName = 'table_tamer_title'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getTamerTitleStr
-- @brief 테이머 칭호 문자열
-------------------------------------
function TableTamerTitle:getTamerTitleStr(tamer_title_id)
    local tamer_title_id = tonumber(tamer_title_id)

    if (not tamer_title_id) then
        return ''
    end

    if (tamer_title_id == 0) then
        return ''
    end

    if (self == THIS) then
        self = THIS()
    end

    local str = self:getValue(tamer_title_id, 't_name')
    if (not str) then
        if CppFunctionsClass:isTestMode() then
            error('tamer_title_id : ' .. tamer_title_id)
        else
            return ''
        end
    end
    str = Str(str)

    return str
end