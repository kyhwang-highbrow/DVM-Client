-------------------------------------
-- class ServerData_DailyMission
-------------------------------------
ServerData_DailyMission = class({
        m_serverData = 'ServerData',
		m_mMissionMap = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DailyMission:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function applyMissionMap
-------------------------------------
function ServerData_DailyMission:applyMissionMap(l_mission_list)
	self.m_mMissionMap = {}
	for i, t_mission in ipairs(l_mission_list) do
		local key = t_mission['mission_key']
		self.m_mMissionMap[key] = StructDailyMission(t_mission)
	end
end

-------------------------------------
-- function hasAvailableReward
-------------------------------------
function ServerData_DailyMission:hasAvailableReward(mission_key)
    local struct = self:getMissionStruct(mission_key)

    if (not struct) then
        return false
    end

    return struct:hasAvailableReward()
end

-------------------------------------
-- function getMissionStruct
-------------------------------------
function ServerData_DailyMission:getMissionStruct(mission_key)
	if (not self.m_mMissionMap) then
		return
	end

	return self.m_mMissionMap[mission_key]
end

-------------------------------------
-- function getMissionDone
-------------------------------------
function ServerData_DailyMission:getMissionDone(mission_key)
	if (not self.m_mMissionMap) then
		return
	end
	local struct = self.m_mMissionMap[mission_key]
	if (not struct) then
		return
	end

	return (struct['status'] == 'done')
end



-------------------------------------
-- function request_dailyMissionInfo
-------------------------------------
function ServerData_DailyMission:request_dailyMissionInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
		if (ret['mission']) then
			self:applyMissionMap(ret['mission'])
		end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/daily_mission/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_dailyMissionReward
-------------------------------------
function ServerData_DailyMission:request_dailyMissionReward(mission_key, day, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
		if (ret['mission']) then
			self:applyMissionMap(ret['mission'])
		end
		if (ret['new_mail']) then
			local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
			UI_ToastPopup(toast_msg)
		end
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/daily_mission/reward')
    ui_network:setParam('uid', uid)
	ui_network:setParam('mission', mission_key)
	ui_network:setParam('day', day)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end



