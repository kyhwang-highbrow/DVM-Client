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
    local vars = self:load('attendance_special.ui')

    self.m_structAttendanceData = struct_event_popup_tab.m_userData
    vars['titleLabel'] = owner.vars['titleLabel']
    self.m_titleText = self.m_structAttendanceData['title_text']

    vars['titleLabel']:setString(Str(self.m_titleText))
    vars['descLabel']:setString('')
    vars['helpLabel']:setString(Str(self.m_structAttendanceData['help_text']))

    self:initTableView()

    self:initLastDayInfo()

    self:checkTodayRewardPopup()
end

-------------------------------------
-- function initLastDayInfo
-- @brief 마지막날 아이템 출력
-------------------------------------
function UI_EventPopupTab_EventAttendance:initLastDayInfo()
    local vars = self.vars

    local l_item_list = self.m_structAttendanceData['step_list']
    local last_item = l_item_list[#l_item_list]

    local last_day = last_item['step']
    local item_id = last_item['item_id']
    local count = last_item['value']

    -- 마지막날 아이템 아이콘 출력
    local item_icon = IconHelper:getItemIcon(item_id)
    item_icon:setDockPoint(cc.p(0.5, 0.5))
    item_icon:setAnchorPoint(cc.p(0.5, 0.5))
    vars['itemNode']:addChild(item_icon)

    -- 마지막날 표시
    vars['finalDayLabel']:setString(Str('{1}일 차', last_day))

    do -- 상품명, 갯수 출력
        local item_name = TableItem():getValue(item_id, 't_name')
        vars['quantityLabel']:setString(Str('{1} X{2}', item_name, comma_value(count)))
    end
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_EventPopupTab_EventAttendance:initTableView()
    local node = self.vars['listNode']
    --node:removeAllChildren()

    local l_item_list = self.m_structAttendanceData['step_list']
    local today_step = self.m_structAttendanceData['today_step']

    -- 생성 콜백
    local function create_func(ui, data)
        if (data['step'] <= today_step) then
            ui.vars['checkSprite']:setVisible(true)
        else
            ui.vars['checkSprite']:setVisible(false)
        end 

        if (data['step'] == today_step) then
            ui.vars['todaySprite']:setVisible(true)
        else
            ui.vars['todaySprite']:setVisible(false)
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(440, 108 + 10)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_AttendanceSpecialListItem, create_func)
    table_view:setItemList(l_item_list)
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
    vars['titleLabel']:setString(self.m_titleText)
end