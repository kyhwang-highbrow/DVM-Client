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
            t_set_data = {['need_equip'] = need_equip, ['count'] = 0, ['active'] = false}
            rune_set_analysis[set_id] = t_set_data
        end

        -- 장착 갯수 증가
        t_set_data['count'] = t_set_data['count'] + 1

        -- 필요한 갯수만큼 장착되었을 경우 활성화
        if (t_set_data['need_equip'] <= t_set_data['count']) then
            t_set_data['active'] = true
        end
    end

    return rune_set_analysis
end