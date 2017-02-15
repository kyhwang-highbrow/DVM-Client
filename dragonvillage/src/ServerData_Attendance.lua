-------------------------------------
-- class ServerData_Attendance
-------------------------------------
ServerData_Attendance = class({
        m_serverData = 'ServerData',
        m_bDirtyAttendanceInfo = 'boolean',

        -- �Ϲ� �⼮üũ
        m_bNewAttendanceBasic = 'boolean',
        m_basicStepList = 'list',
        m_basicHelpText = 'string',
        m_basicDescText = 'string',
        m_basicGuideDragon = 'did',
        m_basicAddedItems = 'table',
        m_todayStep = 'number',

        -- ���� �⼮üũ
        m_bNewAttendanceContinuous = 'boolean',
        m_continuousStepList = 'list',
        m_continuousTitleText = 'string',
        m_continuousHelpText = 'string',
        m_continuousAddedItems = 'table',
        m_continuousTodayStep = 'number',

        -- Ư�� �⼮üũ
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
-- @brief �⼮������ ���ŵǾ�� �ϴ��� üũ
-------------------------------------
function ServerData_Attendance:ckechUpdateAttendanceInfo()
    if self.m_bDirtyAttendanceInfo then
        return
    end

    -- ��ȿ�ð� �� üũ�ؼ� m_bDirtyAttendanceInfo ������ ��
    -- self.m_bDirtyAttendanceInfo = true
end

-------------------------------------
-- function request_attendanceInfo
-------------------------------------
function ServerData_Attendance:request_attendanceInfo(finish_cb)
    -- �⼮������ ���ŵǾ�� �ϴ��� üũ
    self:ckechUpdateAttendanceInfo()

    -- ���ŵ� �ʿ䰡 ������ ����
    if (self.m_bDirtyAttendanceInfo == false) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- �Ķ����
    local uid = g_userData:get('uid')

    -- �ݹ� �Լ�
    local function success_cb(ret)
        self.m_bDirtyAttendanceInfo = false

        local ret = TABLE:loadJsonTable('temp_attendance_info')

        -- �Ϲ� �⼮ ���ʽ�
        self.m_bNewAttendanceBasic = (not ret['attendance_basic']['received'])
        self.m_basicStepList = ret['attendance_basic']['step_list']
        self.m_basicHelpText = ret['attendance_basic']['help_text']
        self.m_basicDescText = ret['attendance_basic']['desc_text']
        self.m_basicGuideDragon = ret['attendance_basic']['guide_dragon']
        self.m_basicAddedItems = ret['attendance_basic']['added_items']
        self.m_todayStep = ret['attendance_basic']['today_step']

        -- ���� �⼮ ���ʽ�
        self.m_bNewAttendanceContinuous = (not ret['attendance_continuous']['received'])
        self.m_continuousStepList = ret['attendance_continuous']['step_list']
        self.m_continuousTitleText = ret['attendance_continuous']['title_text']
        self.m_continuousHelpText = ret['attendance_continuous']['help_text']
        self.m_continuousAddedItems = ret['attendance_continuous']['added_items']
        self.m_continuousTodayStep = ret['attendance_continuous']['today_step']

        -- Ư�� �⼮ ���ʽ�
        self.m_bNewAttendanceSpecial = (not ret['attendance_special']['received'])
        self.m_specialStepList = ret['attendance_special']['step_list']
        self.m_specialTitleText = ret['attendance_special']['title_text']
        self.m_specialHelpText = ret['attendance_special']['help_text']
        self.m_specialAddedItems = ret['attendance_special']['added_items']
        self.m_specialTodayStep = ret['attendance_special']['today_step']

        self.m_bNewAttendanceSpecial = true

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- ��Ʈ��ũ ��� UI ����
    local ui_network = UI_Network()
    ui_network:setUrl('/get_patch_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('app_ver', '0.0.0')
    ui_network:setMethod('GET') -- ��ġ ������ �ӽ� ����ϱ����� �߰�
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end