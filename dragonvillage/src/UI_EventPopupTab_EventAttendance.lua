local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_EventAttendance
-------------------------------------
UI_EventPopupTab_EventAttendance = class(PARENT,{
        m_structAttendanceData = 'StructAttendanceData',
        m_eventID = 'string',

        m_uiName = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_EventAttendance:init(event_id)
    self.m_structAttendanceData = g_attendanceData:getAttendanceData(event_id)

    self.m_uiName = 'event_attendance_special.ui'

    local vars = self:load(self.m_uiName)

    self.m_eventID = event_id
    self:initUI()

    -- 오늘 보상을 보여주는 팝업
	local ui = UI_BlockPopup()
	cca.reserveFunc(self.root, 0.5, function() 
		self:checkTodayRewardPopup() 
		ui:close()
	end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_EventAttendance:initUI()
    local node = self.vars['listNode']
    local data = self.m_structAttendanceData
    local event_id = self.m_eventID
    local list_ui = UI_AttendanceSpecialListItem(data, event_id)
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

	local t_item = step_list[today_step]
	local l_item_list = {
		{
			['item_id'] = t_item['item_id'],
			['count'] = t_item['value']
		}
	}
    local msg = struct_attendance_data:getDesc()
    local ok_btn_cb = nil
    UI_ObtainPopup(l_item_list, msg, ok_btn_cb)

    -- 로비 출석 D-day 표시를 위해 갱신 true
    g_attendanceData.m_bDirtyAttendanceInfo = true
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_EventAttendance:onEnterTab()
    local vars = self.vars
end