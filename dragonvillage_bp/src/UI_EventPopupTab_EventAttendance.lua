local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_EventAttendance
-------------------------------------
UI_EventPopupTab_EventAttendance = class(PARENT,{
        m_titleText = 'string',
        m_structAttendanceData = 'StructAttendanceData',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_EventAttendance:init(owner, struct_event_popup_tab)
    local vars = self:load('event_attendance_special.ui')
    self.m_structAttendanceData = struct_event_popup_tab.m_eventData
    self.m_titleText = self.m_structAttendanceData['title_text']

    self:initUI()

    self:checkTodayRewardPopup()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_EventAttendance:initUI()
    local node = self.vars['listNode']
    local data = self.m_structAttendanceData
    local list_ui = UI_AttendanceSpecialListItem(data)
    node:addChild(list_ui.root)
end

-------------------------------------
-- function checkTodayRewardPopup
-- @brief 오늘 획득한 보상 팝업
-------------------------------------
function UI_EventPopupTab_EventAttendance:checkTodayRewardPopup()
    local vars = self.vars

    local struct_attendance_data = self.m_structAttendanceData
    local step_list = struct_attendance_data['step_list']
    local today_step = struct_attendance_data['today_step']

    if (not struct_attendance_data:hasReward()) then
        return
    end
    struct_attendance_data:setReceived()

    local toast_msg = Str('{1}일 차 보상이 우편함으로 전송되었습니다.', today_step)
    UI_ToastPopup(toast_msg)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_EventAttendance:onEnterTab()
    local vars = self.vars
end