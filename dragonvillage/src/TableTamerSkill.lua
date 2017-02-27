local PARENT = TableClass

-------------------------------------
-- class TableTamerSkill
-------------------------------------
TableTamerSkill = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableTamerSkill:init()
    self.m_tableName = 'tamer_skill_new'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getTamerSkill
-------------------------------------
function TableTamerSkill:getTamerSkill(skill_id)
	local t_skill = self:get(skill_id)
	
	-- ��ų ��ü�� ���� ���� nil ��ȯ
	if not (t_skill) then 
		return nil
	end
	
	-- �нú�� ��ų ������ 1�̴�.
	if (t_skill['chance_type'] == 'passive') then
		return t_skill

	-- �нú갡 �ƴ� ���
	else
		-- ���� ������ ���� ��ų�� ���� ���
		local skill_level = self:getSkillLevel()
		local adj_skill_id = skill_id + skill_level
		t_skill = self:get(adj_skill_id)
		return t_skill
	end
end

-------------------------------------
-- function getSkillLevel
-- @brief ���� ������ ���� ��ų�� ���� ���
-------------------------------------
function TableTamerSkill:getSkillLevel()
	local user_lv = g_userData:get('lv')
	
	local skill_lv = 0
	for i, std_lv in ipairs(TAMER_SKILL_FLOW) do
		if (std_lv > user_lv) then
			skill_lv = i - 1
			break
		end
	end	

	return skill_lv
end
