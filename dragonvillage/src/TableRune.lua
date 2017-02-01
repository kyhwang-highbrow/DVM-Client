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
function TableRune:getRuneFullName(rid, mopt_1_type, mopt_2_type, rarity, lv)
    if (self == TableRune) then
        self = TableRune()
    end

    -- Ex. "3성 쾌속의 벨라리아 D"
    local t_table = self:get(rid)

    -- 등급
    local grade = t_table['grade']

    -- 접두어
    local prefix, alphabet_idx = TableRuneNamingRule:getRunePrefix(mopt_1_type, mopt_2_type)
    
    -- 슬롯 타입
    local t_name = t_table['t_name']
    
    -- 희귀도
    local rarity = string.upper(rarity or 'D')

    -- 룬의 풀 네임 조합
    --local full_name = Str('{1}성 {2} {3} {4} +{5}', grade, prefix, t_name, rarity, lv)
    local full_name = Str('{2} {3} {4} +{5}', grade, prefix, t_name, rarity, lv)

    return full_name, alphabet_idx
end

-------------------------------------
-- function getRuneUnequipFee
-- @brief 룬 장착 해제 가격 리턴
-------------------------------------
function TableRune:getRuneUnequipFee(rid)
    if (self == TableRune) then
        self = TableRune()
    end

    local grade = self:getValue(rid, 'grade')

    local table_rune_grade = TableRuneGrade()
    local fee = table_rune_grade:getValue(grade, 'off_fee')

    return fee
end

-------------------------------------
-- function getEnchantMaterialExp
-- @brief 룬 강화의 재료로 사용될 때 경험치
-------------------------------------
function TableRune:getMaterialExp(rid)
    if (self == TableRune) then
        self = TableRune()
    end

    rid = tonumber(rid)
    local exp = self:getValue(rid, 'exp')
    if (exp == '') or (exp == 'x') then
        local grade = self:getValue(rid, 'grade')
        exp = TableRuneGrade():getValue(grade, 'exp')
    end

    return exp
end