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

    do
        local banner_img = self.m_structAttendanceData:getBannerImg()
        if banner_img then
            vars['bannerNode']:addChild(banner_img)
        end
    end
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

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        co:waitTime(0.5)

        co:work()
        local today_item = step_list[today_step]
        local message = Str('{1}일 차 보너스', today_step)
        local ui = MakeSimpleRewarPopup(message, today_item['item_id'], today_item['value'])
        ui:setCloseCB(co.NEXT)
        if co:waitWork() then return end

        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_EventAttendance:onEnterTab()
    local vars = self.vars
end