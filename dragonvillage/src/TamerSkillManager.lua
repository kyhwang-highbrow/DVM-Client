-------------------------------------
-- class TamerSkillManager
-------------------------------------
TamerSkillManager = class({
		m_charType = 'tamer',
		m_charTable = 'table',

		m_skill_list = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function TamerSkillManager:init(tamer_id)
    local table_tamer = TABLE:get('tamer')
    local t_tamer = table_tamer[tamer_id]

	self.m_charType = 'tamer'
	self.m_charTable = t_tamer
	self.m_skill_list = {}
	--self:setSkillSET()
end

-------------------------------------
-- function init
-------------------------------------
function TamerSkillManager:setSkillSET()
	local t_tamer = self.m_charTable
	local table_tamer_skill = TABLE:get('tamer_skill')

	local skill_id = nil
	local t_skill = nil 
	local idx = 1

	while true do
		skill_id = t_tamer['skill_' .. idx] 
		if (skill_id == 'x') then
			break
		end
		--cclog(skill_id)
		t_skill = table_tamer_skill[skill_id]
		if t_skill then
			table.insert(self.m_skill_list, t_skill)
		end
		idx = idx + 1
	end

	cclog(#self.m_skill_list)
end

-------------------------------------
-- function init
-------------------------------------
function TamerSkillManager:doSkill(skill_idx)
	local t_skill = self.m_skill_list[skill_idx]

	-- 1. target 설정
	local target_team = t_skill['taget_logic1']
	local target_stat = t_skill['taget_logic2']
	local target_specific = t_skill['taget_logic3']


	-- 2. do atcion



end