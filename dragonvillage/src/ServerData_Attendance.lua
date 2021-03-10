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
            local step_list = v['step_list']
            local last_step = (step_list) and #step_list or 0

            -- 이벤트성 출석 보상은 전부 수령후 제외 시킴
            if (v['atd_type'] ~= 'basic') and (v['received']) and (v['today_step'] == last_step) then
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
-- function getAttendanceDataByAtdId
-------------------------------------
function ServerData_Attendance:getAttendanceDataByAtdId(atd_id)
    if (self.m_structAttendanceDataList) then
        for i,v in pairs(self.m_structAttendanceDataList) do
            if (v.atd_id == atd_id) then
                return v
            end
        end
    end
    
    return nil
end

-------------------------------------
-- function getAttendanceDataByAtdId
-- @param atd_id number table_attendance_event_list의 atd_id
-------------------------------------
function ServerData_Attendance:getAttendanceDataByAtdId(_atd_id)
    local atd_id = tonumber(_atd_id)

    if (self.m_structAttendanceDataList) then
        for i,v in pairs(self.m_structAttendanceDataList) do
            if (v.atd_id == atd_id) then
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
-- function getAttendanceDdayInfo
-------------------------------------
function ServerData_Attendance:getAttendanceDdayInfo()
    local tar_info, tar_day, tar_item_id

    -- 모든 출석 전설의 알 획득 날짜 체크
    tar_info, tar_day, tar_item_id = self:getLegendaryDragonDayInfo()

    -- 기본 출석 스페셜 보상 날짜 체크
    if (not tar_info) then
        tar_info, tar_day, tar_item_id = self:getSpecialDayInfo()
    end

    return tar_info, tar_day, tar_item_id
end

-------------------------------------
-- function getLegendaryDragonDayInfo
-- @brief 모든 출석에서 전설의 알 획득 날짜 D-day 표시
-------------------------------------
function ServerData_Attendance:getLegendaryDragonDayInfo()
    -- 출시기념, 신규, 복귀, 기본 출석순으로 D-day 체크
    local check_list = {'open_event', 'newbie', 'comeback', 'normal'}
    local legendary_egg_id = 703005

    local tar_info 
    local tar_day = 99
    local tar_item_id 
    local count_day = 7 -- 7일 전부터 count

    for _, category in ipairs(check_list) do
        local t_info = self:getAttendanceData(category)
        if (t_info) then
            local step_list = t_info['step_list']
            local today_step = t_info['today_step']
           
            for _, v in ipairs(step_list) do
                local step = v['step']
                local item_id = v['item_id']
                if (item_id == legendary_egg_id) then
                    local d_day =  step - today_step
                    if (d_day < tar_day) and (d_day >= 0 and d_day <= count_day) then 
                        tar_day = d_day
                        tar_info = t_info
                        tar_item_id = legendary_egg_id
                        break
                    end
                end
            end
        end
    end

    return tar_info, tar_day, tar_item_id
end

-------------------------------------
-- function getSpecialDayInfo
-- @brief 기본 출석인 경우 7, 14, 21, 28 D-day 표시
-------------------------------------
function ServerData_Attendance:getSpecialDayInfo()
    local tar_info 
    local tar_day = 99
    local tar_item_id

    local t_info = self:getAttendanceData('normal')
    if (t_info) then
        local step_list = t_info['step_list']
        local today_step = t_info['today_step']
           
        for _, v in ipairs(step_list) do
            local step = v['step']
            local item_id = v['item_id']

            if (step % 7 == 0) then
                local d_day =  step - today_step
                local count_day = (step > 21) and 7 or 2 -- 마지막 보상은 7일 카운트, 나머진 2일 카운트
                if (d_day < tar_day) and (d_day >= 0 and d_day <= count_day) then
                    tar_day = d_day
                    tar_info = t_info
                    tar_item_id = item_id
                    break
                end
            end
        end
    end
    
    return tar_info, tar_day, tar_item_id
end

-------------------------------------
-- function openEventPopup
-- @brief 출석 이벤트 팝업 오픈 
-------------------------------------
function ServerData_Attendance:openEventPopup(t_info)
    local category = t_info['category']
    local event_tab
      
    if (category == 'normal') then
        event_tab = 'attendance_basic'
    else
        event_tab = 'attendance_event'
    end

    g_eventData:openEventPopup(event_tab .. category)
end
