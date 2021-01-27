local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_EventAttendanceSpecial
-- @brief 특수한 출석 이벤트를 위한 UI
-- @created mskim 2020.08.22
-------------------------------------
UI_EventPopupTab_EventAttendanceSpecial = class(PARENT,{
        m_structAttendanceData = 'StructAttendanceData',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_EventAttendanceSpecial:init(atd_id)
    local vars = self:load('event_attendance_special.ui')

    self.m_structAttendanceData = g_attendanceData:getAttendanceDataByAtdId(atd_id)

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
function UI_EventPopupTab_EventAttendanceSpecial:initUI()
    local node = self.vars['listNode']
    local struct_attendance_data = self.m_structAttendanceData -- StructAttendanceData
    local atd_id = struct_attendance_data['atd_id']

    local list_ui
    if (isExistValue(atd_id, 50011, 50015)) then
        require('UI_AttendanceSpecialListItem_3rdAnniv')
        list_ui = UI_AttendanceSpecialListItem_3rdAnniv(struct_attendance_data, atd_id)
    else
        require('UI_AttendanceSpecialListItem_Common')
        list_ui = UI_AttendanceSpecialListItem_Common(struct_attendance_data)
    end
    node:addChild(list_ui.root)
end

-------------------------------------
-- function checkTodayRewardPopup
-- @brief 오늘 획득한 보상 팝업
-------------------------------------
function UI_EventPopupTab_EventAttendanceSpecial:checkTodayRewardPopup()
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
function UI_EventPopupTab_EventAttendanceSpecial:onEnterTab()
    local vars = self.vars
end