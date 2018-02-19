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
    -- 로비 출석 D-day 표시를 위해 갱신 true
    self.m_bDirtyAttendanceInfo = true

	-- 이전 출석 정보에 아직 보상 수령 안된 상태라면 처리하지 않는다
	-- 이 상태에서 재접속하면 출석 보상 수령 연출이 안나오겠지만... 현재 구조에서는 어차피 불가능

	if (self.m_structAttendanceDataList) then
		if (self:hasAttendanceReward()) then
			if finish_cb then
				finish_cb(ret)
			end
			return
		end
	end

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
    if (self.m_structAttendanceDataList) then
        for i,v in pairs(self.m_structAttendanceDataList) do
		    if v:hasReward() then
			    return true
		    end
        end
    end
	
    return false
end

-------------------------------------
-- function getAttendanceData
-------------------------------------
function ServerData_Attendance:getAttendanceData(atdc_type)
    -- 2018.02.14 klee : attendance_type 이 아닌 category로 구분 (normal, newbie, comeback)
    if (self.m_structAttendanceDataList) then
        for i,v in pairs(self.m_structAttendanceDataList) do
            if (v.category == atdc_type) then
                return v
            end
        end
    end
    
    return nil
end

-------------------------------------
-- function getBasicAttendance
-------------------------------------
function ServerData_Attendance:getBasicAttendance()
    return self:getAttendanceData('normal')
end

-------------------------------------
-- function getAttendanceDataList
-------------------------------------
function ServerData_Attendance:getAttendanceDataList()
    return self.m_structAttendanceDataList
end

-------------------------------------
-- function getLegendaryDragonDay
-- @brief 전설의 알 획득 날짜
-------------------------------------
function ServerData_Attendance:getLegendaryDragonDay(atdc_type)
    local t_info = self:getAttendanceData(atdc_type)
    local legendary_egg_id = 703005
    local day
    if (t_info) then
        local step_list = t_info['step_list']
        for _, v in ipairs(step_list) do
            local item_id = v['item_id']
            if (item_id == legendary_egg_id) then
                day = v['step']
                break
            end
        end
    end
    return day
end
