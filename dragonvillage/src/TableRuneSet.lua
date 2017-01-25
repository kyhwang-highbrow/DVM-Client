local PARENT = TableClass

-------------------------------------
-- class TableRuneSet
-------------------------------------
TableRuneSet = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableRuneSet:init()
    self.m_tableName = 'rune_set'
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