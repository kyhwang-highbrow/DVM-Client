local PARENT = TableClass

-------------------------------------
-- class TableMasterySkill
-------------------------------------
TableMasterySkill = class(PARENT, {
    })

local THIS = TableMasterySkill

-------------------------------------
-- function init
-------------------------------------
function TableMasterySkill:init()
    self.m_tableName = 'mastery_skill'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getName
-------------------------------------
function TableMasterySkill:getName(key)
	if (not key) or (key == '') then return end

    local t_mastery_skill = self:get(key)
    return t_mastery_skill['t_name']
end

-------------------------------------
-- function getRuneSetStatus
--
-------------------------------------
function TableMasterySkill:getMasterySkillStatus(mastery_id, lv)
    if (self == THIS) then
        self = THIS()
    end

    local lv = lv or 1
    local t_table = self:get(mastery_id)
    
    local option = t_table['option']
    local value = lv * t_table['add_value']
    local game_mode = t_table['mode']

    if (game_mode == '') then
        game_mode = nil
    end

    return option, value, game_mode
end

-------------------------------------
-- function makeMasterySkillID
--
-------------------------------------
function TableMasterySkill:makeMasterySkillID(dragon_rarity_str, dragon_role_str, mastery_skill_tier, mastery_skill_index)
    -- 110101
    -- 1xxxxx dragon_rarity
    --  1xxxx dragon_role
    --   01xx mastery_skill_tier
    --     01 mastery_skill_index

    local dragon_rarity = 0
    if (dragon_rarity_str == 'common') then
        dragon_rarity = 1
    elseif (dragon_rarity_str == 'rare') then
        dragon_rarity = 2
    elseif (dragon_rarity_str == 'hero') then
        dragon_rarity = 3
    elseif (dragon_rarity_str == 'legend') then
        dragon_rarity = 4
    end

    -- roleID
    local dragon_role = 0
    if (dragon_role_str == 'dealer') then
        dragon_role = 1
    elseif (dragon_role_str == 'tanker') then
        dragon_role = 2
    elseif (dragon_role_str == 'supporter') then
        dragon_role = 3
    elseif (dragon_role_str == 'healer') then
        dragon_role = 4
    end

    local mastery_skill_id = (100000 * dragon_rarity) + (10000 * dragon_role) + (100 * mastery_skill_tier) + (mastery_skill_index)
    return mastery_skill_id
end

-------------------------------------
-- function getMasterySkillName
--
-------------------------------------
function TableMasterySkill:getMasterySkillName(mastery_skill_id)
    if (self == THIS) then
        self = THIS()
    end

    local name = self:getValue(mastery_skill_id, 't_name')
    return Str(name)
end

-------------------------------------
-- function getMasterySkillOptionDesc
--
-------------------------------------
function TableMasterySkill:getMasterySkillOptionDesc(mastery_skill_id, mastery_skill_lv, is_rich)
    if (self == THIS) then
        self = THIS()
    end

    local option = self:getValue(mastery_skill_id, 'option')
    local value = self:getValue(mastery_skill_id, 'add_value') * mastery_skill_lv

    local desc = TableOption:getOptionDesc(option, value)

    if is_rich then
        desc = DragonSkillCore.getRichTemplateMod(desc)
    end

    return desc
end

-------------------------------------
-- function getMasterySkillStepDesc
--
-------------------------------------
function TableMasterySkill:getMasterySkillStepDesc(mastery_skill_id, mastery_skill_lv)
    if (self == THIS) then
        self = THIS()
    end

    local max_lv = self:getValue(mastery_skill_id, 'm_lv')
    local add_value = self:getValue(mastery_skill_id, 'add_value')
    local t_step_desc = self:getValue(mastery_skill_id, 't_step_desc') or ''
    t_step_desc = trim(t_step_desc) -- 좌/우 공백 제거
    local inner_str = ''
    local base_color = '{@GRAY}'

    if (max_lv == 1) then
        t_step_desc = string.gsub(t_step_desc, '%(', '')
        t_step_desc = string.gsub(t_step_desc, '%)', '')

        if (mastery_skill_lv == 1) then
            base_color = '{@SKILL_VALUE_MOD}'
        end
    end

    for i=1, max_lv do
        
        if (i > 1) then
            inner_str = inner_str .. ' / '
        end

        local num_str = comma_value(i * add_value)
        if (mastery_skill_lv == i) then
            num_str = '{@SKILL_VALUE_MOD}' .. num_str .. base_color
        end

        inner_str = inner_str .. num_str
    end

    return base_color .. Str(t_step_desc, inner_str)
end

-------------------------------------
-- function getMasterySkillStepDesc_single
-- @brief
-------------------------------------
function TableMasterySkill:getMasterySkillStepDesc_single(mastery_skill_id, mastery_skill_lv)
    if (self == THIS) then
        self = THIS()
    end

    local max_lv = self:getValue(mastery_skill_id, 'm_lv')
    local add_value = self:getValue(mastery_skill_id, 'add_value')
    local t_step_desc = self:getValue(mastery_skill_id, 't_step_desc') or ''
    t_step_desc = trim(t_step_desc) -- 좌/우 공백 제거

    t_step_desc = string.gsub(t_step_desc, '%(', '')
    t_step_desc = string.gsub(t_step_desc, '%)', '')

    local num_str = comma_value(mastery_skill_lv * add_value)
    return Str(t_step_desc, num_str)
end

-------------------------------------
-- function getMaxMasteryLV
--
-------------------------------------
function TableMasterySkill:getMaxMasteryLV(tier)
    if (tier <= 3) then
        return 3
    elseif (tier == 4) then
        return 1
    else
        error('tier : ' .. tier)
    end
end
