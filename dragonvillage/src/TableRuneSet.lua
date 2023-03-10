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
    local text = ''

    if (type(option) == 'number') then
        text = '{@rune_set}' .. Str('{1} {2}세트', name, need_equip) .. '\n' .. TableDragonSkill():getSkillDesc(option)
    else
        text = '{@rune_set}' .. Str('{1} {2}세트', name, need_equip) .. '\n' .. TableOption:getOptionDescWithSkillForm(option, value)
    end
    
    return text
end

-------------------------------------
-- function makeRuneSetNameRichTextWithoutNeed
-- @brief 세트 이름만 알고 싶을 때
-------------------------------------
function TableRuneSet:makeRuneSetNameRichTextWithoutNeed(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(set_id)

    local name = Str(t_table['t_name'])

    local tag = self:getRuneSetColorRichTag(set_id)
    local text = ''

    if (type(option) == 'number') then
        text = Str('{1}{2}', tag, name)
    else
        text = Str('{1}{2}', tag, name)
    end

    return text
end

-------------------------------------
-- function makeRuneSetNameRichText
-------------------------------------
function TableRuneSet:makeRuneSetNameRichText(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(set_id)

    local name = Str(t_table['t_name'])
    local need_equip = t_table['need_equip']

    local tag = self:getRuneSetColorRichTag(set_id)
    local text = ''

    if (type(option) == 'number') then
        text = Str('{1}{2}{@DESC} ({3}세트)', tag, name, need_equip)
    else
        text = Str('{1}{2}{@DESC} ({3}세트)', tag, name, need_equip)
    end

    return text
end

-------------------------------------
-- function makeRuneSetFullNameRichText
-------------------------------------
function TableRuneSet:makeRuneSetFullNameRichText(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(set_id)

    local name = Str(t_table['t_name'])
    local need_equip = t_table['need_equip']

    local option = t_table['key']
    local value = t_table['value']
    local tag = self:getRuneSetColorRichTag(set_id)
    local text = ''

    if (type(option) == 'number') then
        text = Str('{1}{2}{@DESC} ({3}세트): ', tag, name, need_equip)..TableDragonSkill():getSkillDesc(option)
    else
        text = Str('{1}{2}{@DESC} ({3}세트): ', tag, name, need_equip)..TableOption:getOptionDescWithSkillForm(option, value)  
    end

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
    local text = ''

    if (type(option) == 'number') then
        text = TableDragonSkill():getSkillDesc(option)
    else
        text = TableOption:getOptionDesc(option, value)
    end

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
        local set_id = TableRune:getRuneSetId(rid)

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
-- function getRuneSetNeedEquip
-------------------------------------
function TableRuneSet:getRuneSetNeedEquip(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local need_equip = self:getValue(set_id, 'need_equip')

    return need_equip
end

-------------------------------------
-- function getRuneSetColorC3b
-------------------------------------
function TableRuneSet:getRuneSetColorC3b(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local set_color = self:getRuneSetColor(set_id)
    local key = string.format('r_set_%s', set_color)
    return COLOR[key]
end

-------------------------------------
-- function getRuneSetColorRichTag
-------------------------------------
function TableRuneSet:getRuneSetColorRichTag(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local set_color = self:getRuneSetColor(set_id)
    return string.format('{@r_set_%s}',set_color)
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

    -- key값이 숫자인 경우면 스킬이기 때문에 스텟 정보는 없음
    if (type(key) == 'number') then
        return
    end 

    local table_option = TableOption()

    local stat_type = table_option:getValue(key, 'status')
    local action = table_option:getValue(key, 'action')
    local value = t_table['value']

    return stat_type, action, value
end

-------------------------------------
-- function getRuneSetVisualName
-------------------------------------
function TableRuneSet:getRuneSetVisualName(slot_id, set_id)
    if (self == THIS) then
        self = THIS()
    end

    local color = self:getValue(set_id, 'color')

    return string.format('%s_%02d', color, tonumber(slot_id))
end

-------------------------------------
-- function getRuneSetSkill
--
-------------------------------------
function TableRuneSet:getRuneSetSkill(set_id)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(set_id)
    local key = t_table['key']

    -- key값이 문자인 경우는 스텟 정보로 스킬 정보는 없음
    if (type(key) == 'string') then
        return
    end

    local skill_id = key
    return skill_id
end