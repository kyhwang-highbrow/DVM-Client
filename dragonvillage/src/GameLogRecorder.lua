-------------------------------------
-- class GameLogRecorder
-------------------------------------
GameLogRecorder = class({
		-- �̼� (����� �ʿ��� ��)
		m_clearCnt = 'num',			-- �������� Ŭ���� Ƚ��
		m_deathCnt = 'num',			-- ��� �巡�� {1}�� ������ ���¿��� Ŭ����
		m_useSkillCnt = 'num',		-- �巡���� ��ų�� {1}�� �̻� ���
		m_lapTime = 'num',			-- {1} �� ���� �������� Ŭ����
		m_feverCnt = 'num',			-- �ǹ��� {1}�� �̻� ���
		m_bossFinishAtk = 'str',		-- ������ {1} �������� óġ
     })

-------------------------------------
-- function init
-------------------------------------
function GameLogRecorder:init()
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
function GameLogRecorder:recordMission(key, value)
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
	
	else
		error('���� ���� ���� Ű : ' .. key)
	end
end

