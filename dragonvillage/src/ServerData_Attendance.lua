-------------------------------------
-- class ServerData_Attendance
-------------------------------------
ServerData_Attendance = class({
        m_serverData = 'ServerData',
        m_bDirtyAttendanceInfo = 'boolean',

        -- 기본 출석 체크
        m_bNewAttendanceBasic = 'boolean',
        m_basicStepList = 'list',
        m_basicHelpText = 'string',
        m_basicDescText = 'string',
        m_basicGuideDragon = 'did',
        m_basicAddedItems = 'table',
        m_todayStep = 'number',

        -- 연속 출석 체크
        m_bNewAttendanceContinuous = 'boolean',
        m_continuousStepList = 'list',
        m_continuousTitleText = 'string',
        m_continuousHelpText = 'string',
        m_continuousAddedItems = 'table',
        m_continuousTodayStep = 'number',

        -- 특별 출석 체크
        m_bNewAttendanceSpecial = 'boolean',
        m_specialStepList = 'list',
        m_specialTitleText = 'string',
        m_specialHelpText = 'string',
        m_specialAddedItems = 'table',
        m_specialTodayStep = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Attendance:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtyAttendanceInfo = true
    self.m_bNewAttendanceBasic = false
    self.m_bNewAttendanceContinuous = false
    self.m_bNewAttendanceSpecial = false
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
        self.m_bDirtyAttendanceInfo = false

        -- 드래곤 생일 정보
        g_birthdayData:organize_birthdayTable(ret['birthday_table'])

        -- 오늘의 드래곤 생일 정보
        g_birthdayData:organize_todayBirthdayList(ret['birthday'])

        --[[
        local ret = TABLE:loadJsonTable('temp_attendance_info')

        -- 기본 출석 체크 보상 정보
        self.m_bNewAttendanceBasic = (not ret['attendance_basic']['received'])
        self.m_basicStepList = ret['attendance_basic']['step_list']
        self.m_basicHelpText = ret['attendance_basic']['help_text']
        self.m_basicDescText = ret['attendance_basic']['desc_text']
        self.m_basicGuideDragon = ret['attendance_basic']['guide_dragon']
        self.m_basicAddedItems = ret['attendance_basic']['added_items']
        self.m_todayStep = ret['attendance_basic']['today_step']

        -- 연속 출석 체크 보상
        self.m_bNewAttendanceContinuous = (not ret['attendance_continuous']['received'])
        self.m_continuousStepList = ret['attendance_continuous']['step_list']
        self.m_continuousTitleText = ret['attendance_continuous']['title_text']
        self.m_continuousHelpText = ret['attendance_continuous']['help_text']
        self.m_continuousAddedItems = ret['attendance_continuous']['added_items']
        self.m_continuousTodayStep = ret['attendance_continuous']['today_step']

        -- 특별 출석 체크 보상
        self.m_bNewAttendanceSpecial = (not ret['attendance_special']['received'])
        self.m_specialStepList = ret['attendance_special']['step_list']
        self.m_specialTitleText = ret['attendance_special']['title_text']
        self.m_specialHelpText = ret['attendance_special']['help_text']
        self.m_specialAddedItems = ret['attendance_special']['added_items']
        self.m_specialTodayStep = ret['attendance_special']['today_step']

        self.m_bNewAttendanceSpecial = true
        --]]

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/attendance/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end