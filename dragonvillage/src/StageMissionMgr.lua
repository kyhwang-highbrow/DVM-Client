-------------------------------------
-- class StageMissionMgr
-------------------------------------
StageMissionMgr = class({	
		m_logRecorder = 'GameLogRecorder',
		m_lMissionList = 'list',
		m_gameMode = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function StageMissionMgr:init(log_recorder, stage_id, game_mode)
	-- ��� ���� �ʱ�ȭ
	self.m_logRecorder = log_recorder
	self.m_lMissionList = {}
	self.m_gameMode = game_mode

	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		-- ������̺�� ���������Ϳ��� �������� �̼� ���� �޾ƿ�
		self:init_missionList(stage_id)

		-- �̼� üũ
		self:checkMission()
	end
end

-------------------------------------
-- function init_missionList
-------------------------------------
function StageMissionMgr:init_missionList(stage_id)
	local stage_info = g_adventureData:getStageInfo(stage_id)
	
	local l_mission = TableDrop():getStageMissionList(stage_id)

	for i, mission in pairs(l_mission) do
		self.m_lMissionList[i] = {
			mission_key = mission[1], 
			mission_value = tonumber(mission[2]), 
			mission_value2 = tonumber(mission[3]), 
			is_clear = stage_info['mission_' .. i]
		}
	end

	-- @LOG
	self.m_logRecorder:recordLog('clear_cnt', stage_info['clear_cnt'])
end

-------------------------------------
-- function checkMission
-------------------------------------
function StageMissionMgr:checkMission()
	for i, t_mission in pairs(self.m_lMissionList) do
		-- �̹� Ŭ������ �̼��� üũ���� �ʴ´�.
		if (not t_mission['is_clear']) then
		
			local mission_key = t_mission['mission_key']
			local mission_value = t_mission['mission_value']
			local mission_value2 = t_mission['mission_value2']
			local achieve_data = self.m_logRecorder:getLog(mission_key)

			self:missionTemp(t_mission, mission_key, mission_value, mission_value2, achieve_data)
		end
	end
end

-------------------------------------
-- function missionTemp
-------------------------------------
function StageMissionMgr:missionTemp(t_mission, mission_key, mission_value, mission_value2, achieve_data)
	-- ��ǥġ ���� ����� �ϴ� �̼�
	if isExistValue(mission_key, 'lap_time', 'use_dragon_cnt', 'death_cnt') then
		if (achieve_data < mission_value) then
			t_mission['is_clear'] = true
		end

	-- ���� �����ؾ� �ϴ� �̼�
	elseif isExistValue(mission_key, 'use_tamer', 'use_formation') then
		if (achieve_data == mission_value) then
			t_mission['is_clear'] = true
		end

	-- ���� �����ؾ� �ϴ� �̼� (���̺�)
	elseif isExistValue(mission_key, 'use_dragon') then
		if (achieve_data[mission_value]) then
			t_mission['is_clear'] = true
		end
			
	-- ���� ����� �ϴ� �̼� (���̺�)
	elseif isExistValue(mission_key, 'not_use_role') then
		if not (achieve_data[mission_value]) then
			t_mission['is_clear'] = true
		end

	-- value2�� ����ϴ� �̼� (���̺�)
	elseif isExistValue(mission_key, 'attribute_cnt', 'evolution_state') then
		if (achieve_data[mission_value]) then
			if (achieve_data[mission_value] > mission_value2) then 
				t_mission['is_clear'] = true
			end
		end

	-- ������ ó���� �ʿ��� �̼� (��Ÿüũ)
	elseif string.find(mission_key, 'finish_') then
		mission_value = string.gsub(mission_key, 'finish_', '')
		if (achieve_data == mission_value) then
			t_mission['is_clear'] = true
		end

	-- ��ǥġ ���� ���ƾ� �ϴ� �̼�
	elseif isExistValue(mission_key, 'use_skill', 'use_fever', 'clear_cnt') then
		if (achieve_data >= mission_value) then
			t_mission['is_clear'] = true
		end

	-- Ȯ���� �ʿ�
	else
		error('���� ���� ���� �������� Ŭ���� �̼� : ' .. mission_key)
	end
end

-------------------------------------
-- function getCompleteClearMission
-------------------------------------
function StageMissionMgr:getCompleteClearMission()
	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		self:checkMission()
	end

	local t_ret = {}
	for i, t_mission in pairs(self.m_lMissionList) do
		t_ret['mission_' .. i] = t_mission['is_clear']
	end

	return t_ret
end