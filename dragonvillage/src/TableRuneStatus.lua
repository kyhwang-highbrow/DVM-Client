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

    -- sub_status 기준 능력치를 얻어옴
    local vid = category .. '_' .. grade
    local lv_key = 'sub_status'
    local value = self:getValue(vid, lv_key)

    -- 희귀도에 따라 가중치 적용
    local table_rune_grade = TableRuneGrade()
    local rate = table_rune_grade:getValue(grade, rarity .. '_coef')
    value = math_floor(value * rate)

    return {category=category, value=value}
end

-------------------------------------
-- function getCategoryStr
-- @brief
-------------------------------------
function TableRuneStatus:getCategoryStr(category)
    local str = ''
    if (category == 'atk') then             str = Str('공격력')
    elseif (category == 'def') then         str = Str('방어력')
    elseif (category == 'hp') then          str = Str('체력')
    elseif (category == 'aspd') then        str = Str('공격속도')
    elseif (category == 'cri_chance') then  str = Str('치명타 확률')
    elseif (category == 'cri_dmg') then     str = Str('치명타 피해량')
    elseif (category == 'cri_avoid') then   str = Str('치명타 회피율')
    elseif (category == 'hit_rate') then    str = Str('적중률')
    elseif (category == 'avoid') then       str = Str('회피율')
    else                                    error('category : ' .. category)
    end
    return str
end

-------------------------------------
-- function getStatusValueStr
-- @brief
-------------------------------------
function TableRuneStatus:getStatusValueStr(category, value)
    local str = ''
    if (category == 'atk') then             str = Str('+{1}', value)
    elseif (category == 'def') then         str = Str('+{1}', value)
    elseif (category == 'hp') then          str = Str('+{1}', value)
    elseif (category == 'aspd') then        str = Str('+{1}', value)
    elseif (category == 'cri_chance') then  str = Str('+{1}%', value)
    elseif (category == 'cri_dmg') then     str = Str('+{1}%', value)
    elseif (category == 'cri_avoid') then   str = Str('+{1}%', value)
    elseif (category == 'hit_rate') then    str = Str('+{1}%', value)
    elseif (category == 'avoid') then       str = Str('+{1}%', value)
    else                                    error('category : ' .. category)
    end
    return str
end

-------------------------------------
-- function getStatusMultiplyValueStr
-- @brief
-------------------------------------
function TableRuneStatus:getStatusMultiplyValueStr(category, value)
    local str = ''
    if (category == 'atk') then             str = Str('+{1}%', value)
    elseif (category == 'def') then         str = Str('+{1}%', value)
    elseif (category == 'hp') then          str = Str('+{1}%', value)
    elseif (category == 'aspd') then        str = Str('+{1}%', value)
    elseif (category == 'cri_chance') then  str = Str('X{1}%', value)   -- ?? 애초에 %로 동작하기때문에 애매함
    elseif (category == 'cri_dmg') then     str = Str('X{1}%', value)   -- ??
    elseif (category == 'cri_avoid') then   str = Str('X{1}%', value)   -- ??
    elseif (category == 'hit_rate') then    str = Str('X{1}%', value)   -- ??
    elseif (category == 'avoid') then       str = Str('X{1}%', value)   -- ??
    else                                    error('category : ' .. category)
    end
    return str
end

-------------------------------------
-- function makeRuneOptionStr
-- @brief 룬의 옵션 문자열 생성 (주옵션 or 부옵션)
-------------------------------------
function TableRuneStatus:makeRuneOptionStr(l_mopt, type)
    local str = ''

    for i,v in ipairs(l_mopt) do
        local category = v['category']
        local value = comma_value(v['value'])

        if (str ~= '') then
            str = (str .. '\n')
        end

        if (type == nil) then
            str = str .. TableRuneStatus:getCategoryStr(category) .. ' ' .. TableRuneStatus:getStatusValueStr(category, value)
        elseif (type == 'category') then
            str = str .. TableRuneStatus:getCategoryStr(category)
        elseif (type == 'value') then
            str = str .. TableRuneStatus:getStatusValueStr(category, value)
        elseif (type == 'next_value') then
            str = str .. '▶ ' .. TableRuneStatus:getStatusValueStr(category, value)
        else
            error('type : ' .. type)
        end
    end

    return str
end

-------------------------------------
-- function makeRuneSetOptionStr
-- @brief
-------------------------------------
function TableRuneStatus:makeRuneSetOptionStr(t_rune_set)
    local name = t_rune_set['name']
    local str = Str('[{1}] 세트 효과', name)

    for category,value in pairs(t_rune_set['add_status']) do
        str = (str .. '\n') .. TableRuneStatus:getCategoryStr(category) .. ' ' .. TableRuneStatus:getStatusValueStr(category, value)
    end

    for category,value in pairs(t_rune_set['multiply_status']) do
        str = (str .. '\n') .. TableRuneStatus:getCategoryStr(category) .. ' ' .. TableRuneStatus:getStatusMultiplyValueStr(category, value)
    end

    return str
end