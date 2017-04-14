-------------------------------------
-- class StageMissionMgr
-------------------------------------
StageMissionMgr = class({	
		m_logRecorder = 'LogRecorderWorld',
		m_lMissionList = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function StageMissionMgr:init(log_recorder, stage_id)
	-- 멤버 변수 초기화
	self.m_logRecorder = log_recorder
	self.m_lMissionList = {}

	-- 드롭테이블과 서버데이터에서 스테이지 미션 정보 받아옴
	self:init_missionList(stage_id)
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
			mission_value = tonumber(mission[2]) or mission[2], 
			mission_value2 = tonumber(mission[3]) or mission[3], 
			is_clear = stage_info['mission_' .. i]
		}
	end

	-- @LOG : 스테이지 클리어 횟수
	self.m_logRecorder:recordLog('clear_cnt', stage_info['clear_cnt'])
end

-------------------------------------
-- function checkMission
-------------------------------------
function StageMissionMgr:checkMission()
	for i, t_mission in pairs(self.m_lMissionList) do
		-- 이미 클리어한 미션은 체크하지 않는다.
		if (not t_mission['is_clear']) then
		
			local mission_key = t_mission['mission_key']
			local mission_value = t_mission['mission_value']
			local mission_value2 = t_mission['mission_value2']
			local achieve_data = self.m_logRecorder:getLog(mission_key)

			self:checkMissionCondition(t_mission, mission_key, mission_value, mission_value2, achieve_data)
		end
	end
end

-------------------------------------
-- function checkMissionCondition
-------------------------------------
function StageMissionMgr:checkMissionCondition(t_mission, mission_key, mission_value, mission_value2, achieve_data)
	if (not mission_key) then
		return
	end

	-- 목표치 보다 적어야 하는 미션
	if isExistValue(mission_key, 'lap_time', 'use_dragon_cnt', 'death_cnt') then
		if (achieve_data <= mission_value) then
			t_mission['is_clear'] = true
		end

	-- 값이 동일해야 하는 미션
	elseif isExistValue(mission_key, 'use_tamer', 'use_formation') then
		if (achieve_data == mission_value) then
			t_mission['is_clear'] = true
		end

	-- 값이 동일해야 하는 미션 (테이블)
	elseif isExistValue(mission_key, 'use_dragon') then
		if (achieve_data[mission_value]) then
			t_mission['is_clear'] = true
		end
			
	-- 값이 없어야 하는 미션 (테이블)
	elseif isExistValue(mission_key, 'not_use_role') then
		ccdump(achieve_data)
		if not (achieve_data[mission_value]) then
			t_mission['is_clear'] = true
		end

	-- value2를 사용하는 미션 (테이블)
	elseif isExistValue(mission_key, 'attribute_cnt', 'evolution_state') then
		if (achieve_data[mission_value]) then
			if (achieve_data[mission_value] >= mission_value2) then 
				t_mission['is_clear'] = true
			end
		end

	-- 별도의 처리가 필요한 미션 (막타체크)
	elseif string.find(mission_key, 'finish_') then
		mission_value = string.gsub(mission_key, 'finish_', '')
		if (achieve_data == mission_value) then
			t_mission['is_clear'] = true
		end

	-- 목표치 보다 많아야 하는 미션
	elseif isExistValue(mission_key, 'use_skill', 'use_fever', 'clear_cnt') then
		if (achieve_data >= mission_value) then
			t_mission['is_clear'] = true
		end

	-- 확인이 필요
	else
		error('정의 되지 않은 스테이지 클리어 미션 : ' .. mission_key)
	end
end

-------------------------------------
-- function getCompleteClearMission
-------------------------------------
function StageMissionMgr:getCompleteClearMission()
	self:checkMission()

	local t_ret = {}
	for i, t_mission in pairs(self.m_lMissionList) do
		t_ret['mission_' .. i] = t_mission['is_clear']
	end

	return t_ret
end