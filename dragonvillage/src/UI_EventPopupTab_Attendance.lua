local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Attendance
-------------------------------------
UI_EventPopupTab_Attendance = class(PARENT,{
        m_titleText = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Attendance:init(owner)
    local vars = self:load('event_attendance_basic.ui')

    local struct_attendance_data = g_attendanceData:getBasicAttendance()

    local title_text = struct_attendance_data['title_text']
    local help_text = struct_attendance_data['help_text']
    local step_list = struct_attendance_data['step_list']
    local today_step = struct_attendance_data['today_step']

    self.m_titleText = Str(title_text)
    vars['descLabel']:setString(Str(help_text))
    vars['dayLabel']:setString(Str('{1}일차', today_step))

    -- 보상 리스트 출력
    for i,v in ipairs(step_list) do
        local step = v['step']
        local item_id = v['item_id']
        local ui = UI_AttendanceBasicListItem(v)
        vars['rewardNode' .. step]:addChild(ui.root)

        if (i <= today_step) then
            ui.vars['checkSprite']:setVisible(true)
        else
            ui.vars['checkSprite']:setVisible(false)
        end
        cca.uiReactionSlow(ui.root)
    end

    -- 오늘 보상을 보여주는 팝업
    self:checkTodayRewardPopup()
end

-------------------------------------
-- function checkTodayRewardPopup
-- @brief 오늘 획득한 보상 팝업
-------------------------------------
function UI_EventPopupTab_Attendance:checkTodayRewardPopup()
    local vars = self.vars

    local struct_attendance_data = g_attendanceData:getBasicAttendance()
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
        local message = Str('{1}일 차 출석 보너스', today_step)
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
function UI_EventPopupTab_Attendance:onEnterTab()
    local vars = self.vars
end
