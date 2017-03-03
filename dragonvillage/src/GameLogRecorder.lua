-------------------------------------
-- class GameLogRecorder
-------------------------------------
GameLogRecorder = class({
		m_world = 'GameWorld',

		m_attrCnt = 'table<attr>',		-- {1} �Ӽ� �巡���� {2}�� �̻� ����Ͽ� Ŭ����
		m_evolutionCnt = 'table<rev>',	-- {1} ������ �巡���� {2}�� �̻� ����Ͽ� Ŭ����
		m_dragonCnt = 'num',			-- �巡���� {1} �� ���Ϸ� ����Ͽ� Ŭ����
		m_usedTamer = 'str',			-- {1} ���̸Ӹ� ����Ͽ� Ŭ����
		m_usedFormation = 'str',		-- {1} ������ ����Ͽ� Ŭ����
		m_usedDragon = 'table<did>',	-- {1} �巡���� ����Ͽ� Ŭ����
		m_usedRole = 'table<role>',		-- {1} ������ �巡���� ������� �ʰ� Ŭ����

		-- �̼� (����� �ʿ��� ��)
		m_clearCnt = 'num',			-- �������� Ŭ���� Ƚ��
		m_deathCnt = 'num',			-- ��� �巡�� {1}�� ������ ���¿��� Ŭ����
		m_useSkillCnt = 'num',		-- �巡���� ��ų�� {1}�� �̻� ���
		m_lapTime = 'num',			-- {1} �� ���� �������� Ŭ����
		m_feverCnt = 'num',			-- �ǹ��� {1}�� �̻� ���
		m_bossFinishAtk = 'str',	-- ������ {1} �������� óġ
     })

-------------------------------------
-- function init
-------------------------------------
function GameLogRecorder:init(world)
	self.m_world = world

	self.m_deathCnt = 0
	self.m_useSkillCnt = 0
	self.m_lapTime = 0
	self.m_feverCnt = 0
	self.m_bossFinishAtk = nil

	self:recordStaticAllLog()
end

-------------------------------------
-- function recordStaticAllLog
-------------------------------------
function GameLogRecorder:recordStaticAllLog()
	local world = self.m_world
	local l_dragon = world:getDragonList()


	-- ������ �巡���� ��
	self.m_dragonCnt = #l_dragon
	
	-- ����� ���̸� (����)
	self.m_usedTamer = g_userData:getTamerInfo()['type']
	
	-- ����� ����
	self.m_usedFormation = world.m_deckFormation

	-- �Ӽ� �� �巡�� ��
	self.m_attrCnt = {}
	
	-- ��ȭ �� �巡�� ��
	self.m_evolutionCnt = {}

	-- ����� �巡��id ����Ʈ
	self.m_usedDragon = {}

	-- ����� �巡�� ����
	self.m_usedRole = {}

	-- ���̺��� �ʿ��� ������ ����
	for i, dragon in pairs(l_dragon) do
		local attr = dragon.m_attribute
		self:applyDataInTable(self.m_attrCnt, attr)

		local evolution = dragon.m_tDragonInfo['evolution']
		self:applyDataInTable(self.m_evolutionCnt, evolution)

		local did = dragon.m_dragonID
		self:applyDataInTable(self.m_usedDragon, did)

		local role = dragon.m_tDragonInfo['role']
		self:applyDataInTable(self.m_usedRole, role)
	end
end

-------------------------------------
-- function getLog
-------------------------------------
function GameLogRecorder:applyDataInTable(table, key)
	if (not key) then return end

	if (table[key]) then
		table[key] = table[key] + 1
	else
		table[key] = 1
	end
end

-------------------------------------
-- function recordLog
-------------------------------------
function GameLogRecorder:recordLog(key, value)
	if (key == 'death_cnt') then
		self.m_deathCnt = self.m_deathCnt + value

	elseif (key == 'use_skill') then
		self.m_useSkillCnt = self.m_useSkillCnt + value

	elseif (key == 'use_fever') then
		self.m_feverCnt = self.m_feverCnt + value

	elseif (key == 'lap_time') then
		self.m_lapTime = value

	elseif (key == 'finish_atk') then
		self.m_bossFinishAtk = value
	
	elseif (key == 'clear_cnt') then
		-- @TODO Ŭ���� ī��Ʈ�� �̸� 1�� ���س��� �����Ѵ�
		self.m_clearCnt = value + 1

	elseif (key == 'attribute_cnt') then
		self.m_attrCnt = value

	elseif (key == 'evolution_state') then
		self.m_revolutionCnt = value

	elseif (key == 'use_dragon_cnt') then
		self.m_dragonCnt = value
		
	elseif (key == 'use_tamer') then
		self.m_usedTamer = value

	elseif (key == 'use_formation') then
		self.m_usedFormation = value
		
	elseif (key == 'use_dragon') then
		self.m_usedDragon = value

	elseif (key == 'not_use_role') then
		self.m_usedRole = value

	else
		error('���� ���� ���� Ű : ' .. key)
	end
end

-------------------------------------
-- function getLog
-------------------------------------
function GameLogRecorder:getLog(key)
	if (key == 'death_cnt') then
		return self.m_deathCnt

	elseif (key == 'use_skill') then
		return self.m_useSkillCnt

	elseif (key == 'use_fever') then
		return self.m_feverCnt

	elseif (key == 'lap_time') then
		return self.m_lapTime

	elseif (key == 'finish_atk') then
		return self.m_bossFinishAtk
	
	elseif (key == 'clear_cnt') then
		return self.m_clearCnt

	elseif (key == 'attribute_cnt') then
		return self.m_attrCnt

	elseif (key == 'evolution_state') then
		return self.m_evolutionCnt

	elseif (key == 'use_dragon_cnt') then
		return self.m_dragonCnt

	elseif (key == 'use_tamer') then
		return self.m_usedTamer

	elseif (key == 'use_formation') then
		return self.m_usedPosition

	elseif (key == 'use_dragon') then
		return self.m_usedDragon

	elseif (key == 'not_use_role') then
		return self.m_usedRole

	else
		return 0
	end
end