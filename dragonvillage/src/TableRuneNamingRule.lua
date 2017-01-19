local PARENT = TableClass

-------------------------------------
-- class TableRuneNamingRule
-------------------------------------
TableRuneNamingRule = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableRuneNamingRule:init()
    self.m_tableName = 'rune_naming_rule'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRunePrefix
-- @brief 룬 아이템 접두어
-------------------------------------
function TableRuneNamingRule:getRunePrefix(mopt_1_type, mopt_2_type)

    if (self == TableRuneNamingRule) then
        self = TableRuneNamingRule()
    end

    -- 메인옵션 1, 메인옵션 2의 타입을 조합해서 key로 사용
    local key = mopt_1_type .. '&' .. (mopt_2_type or '')

    local t_table = self:get(key)
    local prefix = Str(t_table['t_name'])

    return prefix
end