-------------------------------------
-- class StageMissionMgr
-------------------------------------
StageMissionMgr = class({	
		m_logRecorder = 'GameLogRecorder',
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
	do
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

	-- 미션 체크
	self:checkMission()
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

			-- 목표치 보다 적어야 하는 미션
			if isExistValue(mission_key, 'lab_time', 'use_dragon_cnt', 'death_cnt') then
				if (achieve_data < mission_value) then
					t_mission['is_clear'] = true
				end

			-- 값이 동일해야 하는 미션
			elseif isExistValue(mission_key, 'use_tamer', 'use_formation', 'finish_atk') then
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
				if not (achieve_data[mission_value]) then
					t_mission['is_clear'] = true
				end

			-- value2를 사용하는 미션 (테이블)
			elseif isExistValue(mission_key, 'attribute_cnt', 'evolution_state') then
				if (achieve_data[mission_value]) then
					if (achieve_data[mission_value] > mission_value2) then 
						t_mission['is_clear'] = true
					end
				end

			else
				if (achieve_data >= mission_value) then
					t_mission['is_clear'] = true
				end
			end
		end
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