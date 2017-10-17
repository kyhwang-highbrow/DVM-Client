local PARENT = TableClass

-------------------------------------
-- class TableDragonSkillModify
-------------------------------------
TableDragonSkillModify = class(PARENT, {
    })

local THIS = TableDragonSkillModify

-- skill max lv을 앱이 동작하는 동안 테이블로 들고있도록 함 (TableDragonSkillModify 최초 생성시 같이 만듬)
local t_skill_max_lv = nil

-------------------------------------
-- function init
-------------------------------------
function TableDragonSkillModify:init()
    self.m_tableName = 'dragon_skill_modify'
    self.m_orgTable = TABLE:get(self.m_tableName)

	if (not t_skill_max_lv) then
		self:init_skillMaxLV()
	end
end

-------------------------------------
-- function init_skillMaxLV
-------------------------------------
function TableDragonSkillModify:init_skillMaxLV()
	t_skill_max_lv = {}
	local skill_id
	for i, v in pairs(self.m_orgTable) do
		skill_id = v['sid']
		if (not t_skill_max_lv[skill_id]) then
			t_skill_max_lv[skill_id] = 0
		end

		t_skill_max_lv[skill_id] = t_skill_max_lv[skill_id] + 1 
	end
end

-------------------------------------
-- function getMaxLV
-------------------------------------
function TableDragonSkillModify:getMaxLV(skill_id)
    if (self == THIS) then
        self = THIS()
    end

	return t_skill_max_lv[skill_id] or 1
end
