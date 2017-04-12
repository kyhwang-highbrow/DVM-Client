local PARENT = TableClass

-------------------------------------
-- class TableRuneSet
-------------------------------------
TableRuneSet = class(PARENT, {
    })

local THIS = TableRuneSet

-------------------------------------
-- function init
-------------------------------------
function TableRuneSet:init()
    self.m_tableName = 'table_rune_set'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function makeRuneSetData
-------------------------------------
function TableRuneSet:makeRuneSetData(color, grade)
    if (self == TableRuneSet) then
        self = TableRuneSet()
    end

    local apply_trim = true
    local l_key = self:getSemicolonSeparatedValues(color, 'key_grade' .. grade, apply_trim)
    local l_act = self:getSemicolonSeparatedValues(color, 'act_grade' .. grade, apply_trim)
    local l_value = self:getSemicolonSeparatedValues(color, 'value_grade' .. grade, apply_trim)

    local l_add_status = {}
    local l_multiplay_status = {}

    for i,v in ipairs(l_key) do
        local key = v
        local act = l_act[i]
        local value = l_value[i]

        local target_list
        if (act == 'add') then
            target_list = l_add_status
        elseif (act == 'multiply') then
            target_list = l_multiplay_status
        else
            error('act : ' .. act)
        end

        if (not target_list[key]) then
            target_list[key] = 0
        end

        target_list[key] = (target_list[key] + value)
    end

    local t_rune_set = {}
    t_rune_set['add_status'] = l_add_status
    t_rune_set['multiply_status'] = l_multiplay_status
    t_rune_set['name'] = Str(self:getValue(color, 't_name'))

    return t_rune_set
end

-------------------------------------
-- function makeRuneSetDescRichText
-------------------------------------
function TableRuneSet:makeRuneSetDescRichText(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(set_id)

    local name = Str(t_table['t_name'])
    local need_equip = t_table['need_equip']

    local option = t_table['key']
    local value = t_table['value']

    local text = '{@rune_set}' .. Str('{1} {2}세트', name, need_equip) .. '\n' .. TableOption:getOptionDesc(option, value)
    return text
end

-------------------------------------
-- function makeRuneSetEffectText
-------------------------------------
function TableRuneSet:makeRuneSetEffectText(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(set_id)

    local option = t_table['key']
    local value = t_table['value']

    local text = TableOption:getOptionDesc(option, value)

    return text
end

-------------------------------------
-- function runeSetAnalysis
-- 세트 효과 분석
-------------------------------------
function TableRuneSet:runeSetAnalysis(l_rid)
    if (self == THIS) then
        self = THIS()
    end

    local rune_set_analysis = {}

    for _,rid in pairs(l_rid) do
        local set_id = getDigit(rid, 100, 2)

        local t_set_data = rune_set_analysis[set_id]
        if (not t_set_data) then
            local need_equip = self:getValue(set_id, 'need_equip')
            t_set_data = {['set_id'] = set_id, ['need_equip'] = need_equip, ['count'] = 0, ['active'] = false}
            rune_set_analysis[set_id] = t_set_data
        end

        -- 장착 갯수 증가
        t_set_data['count'] = t_set_data['count'] + 1

        -- 필요한 갯수만큼 장착되었을 경우 활성화
        if (t_set_data['need_equip'] <= t_set_data['count']) then
            t_set_data['active'] = true
            t_set_data['active_cnt'] = math_floor(t_set_data['count'] / t_set_data['need_equip'])
        end
    end

    return rune_set_analysis
end

-------------------------------------
-- function getRuneSetName
-------------------------------------
function TableRuneSet:getRuneSetName(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local name = self:getValue(set_id, 't_name')

    return Str(name)
end

-------------------------------------
-- function getRuneSetColor
-------------------------------------
function TableRuneSet:getRuneSetColor(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local color = self:getValue(set_id, 'color')

    return color
end

-------------------------------------
-- function getRuneSetColorC3b
-------------------------------------
function TableRuneSet:getRuneSetColorC3b(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local set_color = self:getRuneSetColor(set_id)

    local c3b = cc.c3b(255, 255, 255)

    if (set_color == 'blue') then c3b = cc.c3b(0, 255, 255)
    elseif (set_color == 'purple') then c3b = cc.c3b(221, 177, 255)
    elseif (set_color == 'pink') then c3b = cc.c3b(253, 128, 255)
    elseif (set_color == 'red') then c3b = cc.c3b(255, 157, 157)
    elseif (set_color == 'bluegreen') then c3b = cc.c3b(106, 246, 205)
    elseif (set_color == 'green') then c3b = cc.c3b(201, 255, 157)
    elseif (set_color == 'orange') then c3b = cc.c3b(255, 190, 87)
    elseif (set_color == 'yellow') then c3b = cc.c3b(255, 253, 87)
    end

    return c3b
end

-------------------------------------
-- function getRuneSetStatus
--
-------------------------------------
function TableRuneSet:getRuneSetStatus(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(set_id)
    local key = t_table['key']

    local table_option = TableOption()

    local stat_type = table_option:getValue(key, 'status')
    local action = table_option:getValue(key, 'action')
    local value = t_table['value']

    return stat_type, action, value
end