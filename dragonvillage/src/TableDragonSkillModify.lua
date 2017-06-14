local PARENT = TableClass

-------------------------------------
-- class TableDragonSkillModify
-------------------------------------
TableDragonSkillModify = class(PARENT, {
    })

local THIS = TableDragonSkillModify

-------------------------------------
-- function init
-------------------------------------
function TableDragonSkillModify:init()
    self.m_tableName = 'dragon_skill_modify'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getMaxLV
-------------------------------------
function TableDragonSkillModify:getMaxLV(skill_id)
    if (self == THIS) then
        self = THIS()
    end

	local t_one_skill = self:filterTable('sid', skill_id)
	local max_lv = table.count(t_one_skill)
	if (max_lv == 0) then
		max_lv = 1
	end
 
	return max_lv
end
