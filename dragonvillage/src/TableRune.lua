local PARENT = TableClass

-------------------------------------
-- class TableRune
-------------------------------------
TableRune = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableRune:init()
    self.m_tableName = 'rune'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRuneFullName
-- @brief 룬의 풀 네임 리턴
-------------------------------------
function TableRune:getRuneFullName(rid, mopt_1_type, mopt_2_type, rarity)
    if (self == TableRune) then
        self = TableRune()
    end

    -- Ex. "3성 쾌속의 벨라리아 D"
    local t_table = self:get(rid)

    -- 등급
    local grade = t_table['grade']

    -- 접두어
    local prefix = TableRuneNamingRule:getRunePrefix(mopt_1_type, mopt_2_type)
    
    -- 슬롯 타입
    local t_name = t_table['t_name']
    
    -- 희귀도
    local rarity = string.upper(rarity or 'D')

    -- 룬의 풀 네임 조합
    local full_name = Str('{1}성 {2} {3} {4}', grade, prefix, t_name, rarity)

    return full_name
end