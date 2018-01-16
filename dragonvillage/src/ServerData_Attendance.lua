-------------------------------------
-- class ServerData_Attendance
-------------------------------------
ServerData_Attendance = class({
        m_serverData = 'ServerData',
        m_bDirtyAttendanceInfo = 'boolean',

        m_structAttendanceDataList = 'list[StructAttendanceData]',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Attendance:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtyAttendanceInfo = true
end

-------------------------------------
-- function ckechUpdateAttendanceInfo
-- @brief 출석체크 정보가 갱신되어야하는지 여부를 확인
-------------------------------------
function ServerData_Attendance:ckechUpdateAttendanceInfo()
    if self.m_bDirtyAttendanceInfo then
        return
    end

    -- 추후에 time stamp등을 확인해서 여부를 설정할 것
    -- self.m_bDirtyAttendanceInfo = true
end

-------------------------------------
-- function request_attendanceInfo
-------------------------------------
function ServerData_Attendance:request_attendanceInfo(finish_cb, fail_cb)
    -- 출석체크 정보가 갱신되어야하는지 여부를 확인
    self:ckechUpdateAttendanceInfo()

    -- 갱신할 필요가 없으면 즉시 리턴
    if (self.m_bDirtyAttendanceInfo == false) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)	
		g_serverData:networkCommonRespone_addedItems(ret)
		self:response_attendanceInfo(ret, finish_cb)
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/attendance/info')
    ui_network:setLoadingMsg(Str('출석 정보 받는 중...'))
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function response_attendanceInfo
-------------------------------------
function ServerData_Attendance:response_attendanceInfo(ret, finish_cb)
    self.m_bDirtyAttendanceInfo = false

	-- 출석 정보
	self.m_structAttendanceDataList = {}
    if ret['attendance_info'] then
        for i,v in ipairs(ret['attendance_info']) do
            -- 이벤트성 출석 보상은 전부 수령후 제외 시킴
            if (v['atd_type'] ~= 'basic') and (v['received']) and (v['today_step'] == 7) then
                -- nothing to do
            else
                table.insert(self.m_structAttendanceDataList, StructAttendanceData(v))
            end
        end
    end

    if finish_cb then
        finish_cb(ret)
    end
end

-------------------------------------
-- function hasAttendanceReward
-- @brief 풀팝업에서 사용
-------------------------------------
function ServerData_Attendance:hasAttendanceReward()
	for i,v in pairs(self.m_structAttendanceDataList) do
		if v:hasReward() then
			return true
		end
    end

    return false
end

-------------------------------------
-- function getAttendanceData
-------------------------------------
function ServerData_Attendance:getAttendanceData(atdc_type)
    for i,v in pairs(self.m_structAttendanceDataList) do
        if (v.attendance_type == atdc_type) then
            return v
        end
    end

    return nil
end

-------------------------------------
-- function getBasicAttendance
-------------------------------------
function ServerData_Attendance:getBasicAttendance()
    return self:getAttendanceData('basic')
end

-------------------------------------
-- function getAttendanceDataList
-------------------------------------
function ServerData_Attendance:getAttendanceDataList()
    return self.m_structAttendanceDataList
end