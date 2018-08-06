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

    local table_option = TableOption()

    local stat_type = table_option:getValue(option, 'status')
    local action = table_option:getValue(option, 'action')
    local game_mode = table_option:getValue(option, 'game_mode')
    
    local value = lv * t_table['add_value']
    return stat_type, action, value, game_mode
end