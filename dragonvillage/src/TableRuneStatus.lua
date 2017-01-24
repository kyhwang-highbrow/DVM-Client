local PARENT = TableClass

-------------------------------------
-- class TableRuneStatus
-------------------------------------
TableRuneStatus = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableRuneStatus:init()
    self.m_tableName = 'rune_status'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getMainOptionStatus
-- @brief 주 옵션 능력치
-- @param grade 1~5성
-- @param category 'atk', 'def', 'hp', 'aspd', 'cri_chance' ...
-- @param rarity 'S', 'A', 'B', 'C', 'D'
-------------------------------------
function TableRuneStatus:getMainOptionStatus(grade, category, lv)
    if (self == TableRuneStatus) then
        self = TableRuneStatus()
    end

    local vid = category .. '_' .. grade
    local lv_key = 'lv' .. lv
    local value = self:getValue(vid, lv_key)
    value = math_floor(value)

    return {category=category, value=value}
end

-------------------------------------
-- function getSubOptionStatus
-- @brief 서브 옵션 능력치
-- @param category 'atk', 'def', 'hp', 'aspd', 'cri_chance' ...
-- @param rarity 'S', 'A', 'B', 'C', 'D'
-------------------------------------
function TableRuneStatus:getSubOptionStatus(grade, category, rarity)
    if (self == TableRuneStatus) then
        self = TableRuneStatus()
    end

    -- 10레벨 기준 능력치를 얻어옴
    local vid = category .. '_' .. grade
    local lv_key = 'lv10'
    local value = self:getValue(vid, lv_key)

    -- 희귀도에 따라 가중치 적용
    local table_rune_grade = TableRuneGrade()
    local rate = table_rune_grade:getValue(grade, rarity .. '_coef')
    value = math_floor(value * rate)

    return {category=category, value=value}
end

-------------------------------------
-- function makeRuneOptionStr
-- @brief 룬의 옵션 문자열 생성 (주옵션 or 부옵션)
-------------------------------------
function TableRuneStatus:makeRuneOptionStr(l_mopt)
    local str = ''

    for i,v in ipairs(l_mopt) do
        local category = v['category']
        local value = comma_value(v['value'])

        if (str ~= '') then
            str = (str .. '\n')
        end

        if (category == 'atk') then
            str = str .. Str('공격력 +{1}', value)

        elseif (category == 'def') then
            str = str .. Str('방어력 +{1}', value)

        elseif (category == 'hp') then
            str = str .. Str('체력 +{1}', value)

        elseif (category == 'aspd') then
            str = str .. Str('공격속도 +{1}', value)

        elseif (category == 'cri_chance') then
            str = str .. Str('치명타 확률 +{1}%', value)

        elseif (category == 'cri_dmg') then
            str = str .. Str('치명타 피해량 +{1}%', value)

        elseif (category == 'cri_avoid') then
            str = str .. Str('치명타 회피율 +{1}%', value)

        elseif (category == 'hit_rate') then
            str = str .. Str('적중률 +{1}%', value)

        elseif (category == 'avoid') then
            str = str .. Str('회피율 +{1}%', value)

        end
    end

    return str
end