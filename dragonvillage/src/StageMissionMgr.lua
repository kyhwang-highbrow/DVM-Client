-------------------------------------
-- class StageMissionMgr
-------------------------------------
StageMissionMgr = class({
		-- �̼� (����� �ʿ��� ��)
		m_clearCnt = 'num',			-- �������� Ŭ���� Ƚ��
		m_deathCnt = 'num',			-- ��� �巡�� {1}�� ������ ���¿��� Ŭ����
		m_useSkillCnt = 'num',		-- �巡���� ��ų�� {1}�� �̻� ���
		m_lapTime = 'num',			-- {1} �� ���� �������� Ŭ����
		m_feverCnt = 'num',			-- �ǹ��� {1}�� �̻� ���
		m_bossFinishAtk = 'str',		-- ������ {1} �������� óġ
		
		-- �̼� (�ΰ��� �߿� ����Ұ��� ����)
		m_attrCnt = 'num',			-- {1} �Ӽ� �巡���� {2}�� �̻� ����Ͽ� Ŭ����
		m_revolutionCnt = 'num',	-- {1} ������ �巡���� {2}�� �̻� ����Ͽ� Ŭ����
		m_dragonCnt = 'num',		-- �巡���� {1} �� ���Ϸ� ����Ͽ� Ŭ����
		m_UsedTamer = 'str',		-- {1} ���̸Ӹ� ����Ͽ� Ŭ����
		m_UsedPosition = 'str',		-- {1} ������ ����Ͽ� Ŭ����
		m_UsedDragon = 'str',		-- {1} �巡���� ����Ͽ� Ŭ����
		m_UsedRole = 'str',			-- {1} ������ �巡���� ������� �ʰ� Ŭ����

		m_dropTable = 'TableDrop',
     })

-------------------------------------
-- function init
-------------------------------------
function StageMissionMgr:init(stage_id)
	self.m_dropTable = TableDrop():get(stage_id)
	
	self.m_clearCnt = 0
	self.m_deathCnt = 0
	self.m_useSkillCnt = 0
	self.m_lapTime = 0
	self.m_feverCnt = 0
	self.m_bossFinishAtk = nil
end

-------------------------------------
-- function recordMission
-------------------------------------
function StageMissionMgr:recordMission(key, value)
	if (key == 'clear_cnt') then
		self.m_clearCnt = self.m_clearCnt + value

	elseif (key == 'death_cnt') then
		self.m_deathCnt = self.m_deathCnt + value

	elseif (key == 'use_skill') then
		self.m_useSkillCnt = self.m_useSkillCnt + value

	elseif (key == 'use_fever') then
		self.m_feverCnt = self.m_feverCnt + value

	elseif (key == 'lap_time') then
		self.m_lapTime = value

	elseif (key == 'finish_atk') then
		self.m_bossFinishAtk = value

	elseif (key == 'attribute_cnt') then
	elseif (key == 'revolution_state') then
	elseif (key == 'use_dragon_cnt') then
	elseif (key == 'use_tamer') then
	elseif (key == 'use_position') then
	elseif (key == 'use_dragon') then
	elseif (key == 'not_use_role') then
	
	else
		error('���� ���� ���� Ű : ' .. key)
	end
end

-------------------------------------
-- function checkWorldValue
-------------------------------------
function StageMissionMgr:checkWorldValue()
	local t_drop = self.m_dropTable
	
end

-------------------------------------
-- function init
-------------------------------------
function StageMissionMgr:getCompleteClearMission()
	local t_drop = self.m_dropTable

	local t_ret = {}
	t_ret['mission_1'] = 1
	t_ret['mission_2'] = 1
	t_ret['mission_3'] = 1

	return t_ret
end