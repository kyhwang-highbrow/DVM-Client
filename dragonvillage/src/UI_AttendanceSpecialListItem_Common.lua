local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AttendanceSpecialListItem_Common
-------------------------------------
UI_AttendanceSpecialListItem_Common = class(PARENT, {
        m_structAttendanceData = 'table', -- StructAttendanceData
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecialListItem_Common:init(struct_attendance_data)
    self.m_structAttendanceData = struct_attendance_data
    local ui_res = struct_attendance_data:getUIRes() -- event_attendance_children.ui, event_attendance_1st_anniversary.ui

    local vars = self:load(ui_res)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceSpecialListItem_Common:initUI()
    local vars = self.vars
    local struct_attendance_data = self.m_structAttendanceData
    local item_ui_res = struct_attendance_data:getItemUIRes() -- event_attendance_children_item.ui, event_attendance_1st_anniversary_item.ui

    --for i = 1,7 do
    for _,t_step_data in pairs(struct_attendance_data['step_list']) do
        local i = t_step_data['step']
        if (vars['rewardNode' .. i]) then
            local ui = UI_AttendanceSpecialListItem_CommonItem(item_ui_res, t_step_data)
            local cur_step = i
            ui:setTodayStep(struct_attendance_data['today_step'], cur_step)
            vars['rewardNode' .. i]:addChild(ui.root)
        end
    end

    

    -- new new 신규 복귀 출석체크
    if (self.m_structAttendanceData and self.m_structAttendanceData.atd_id) then
        local atd_id = self.m_structAttendanceData.atd_id

        if (atd_id == 50023) then
            -- 복귀
            local msg = Str('복귀 유저 출석체크 이벤트')
            if (vars['titleLabel']) then vars['titleLabel']:setString(msg) end

        elseif (atd_id == 50024) then
            -- 신규
            local msg = Str('스페셜 출석체크 이벤트')
            if (vars['titleLabel']) then vars['titleLabel']:setString(msg) end

        else
            if (vars['titleLabel']) then vars['titleLabel']:setString('') end

        end
    end

    self:setTimeLabel()
    self:changeTitleSprite()
end

-------------------------------------
-- function setTimeLabel
-- @brief timeLabel 이 있으면 세팅해주자
-------------------------------------
function UI_AttendanceSpecialListItem_Common:setTimeLabel()
    local timeLabel = self.vars['timeLabel']
    if (not timeLabel) then return end

    local time_str = ''
    local eventInfo = nil

    if (self.m_structAttendanceData) then
        eventInfo = g_eventData:getEventInByEventId(self.m_structAttendanceData.atd_id)
    end

    if (eventInfo) then
        local end_time = eventInfo['end_date_timestamp'] / 1000
        local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()

        local time = end_time - curr_time

        time_str = Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
    end
    
    timeLabel:setString(time_str)
end


-------------------------------------
-- function changeTitleSprite
-- @brief 구글 피쳐드 선정 기념. 구글 apk -> '구글 피처드 선정 기념 ~', 아니면 '피처드 선정 기념 ~'
-- @brief UI_GoogleFeaturedContentChange를 상속받아 함수의 중복을 없앤다. (쓸모 없는 코드지만 이미 작업을 완료 하였으니 피처드 끝난 이후 커밋하여 코드를 깔끔하게 한다.)
-------------------------------------
function UI_AttendanceSpecialListItem_Common:changeTitleSprite()
    local ui = self.vars
    if (not ui) then return end
    if (ui['googleSprite'] and ui['otherMarketSprite']) then
        local market, os = GetMarketAndOS()
        ui['googleSprite']:setVisible(false)
        ui['otherMarketSprite']:setVisible(false)
        if (market == 'google') then
            ui['googleSprite']:setVisible(true)
        else
            ui['otherMarketSprite']:setVisible(true)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceSpecialListItem_Common:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceSpecialListItem_Common:refresh()
end




local PARENT = UI

-------------------------------------
-- class UI_AttendanceSpecialListItem_CommonItem
-------------------------------------
UI_AttendanceSpecialListItem_CommonItem = class(PARENT, {
        m_itemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecialListItem_CommonItem:init(item_ui_res, t_item_data)
    self.m_itemData = t_item_data

    local vars = self:load(item_ui_res) -- event_attendance_children_item.ui, event_attendance_1st_anniversary_item.ui

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceSpecialListItem_CommonItem:initUI()
    local vars = self.vars
    local t_item_data = self.m_itemData

    local item_id = t_item_data['item_id']
    local item_cnt = t_item_data['value']
    
    -- 아이콘
    -- local item_icon = IconHelper:getItemIcon(item_id, nil)
    local item_icon = UI_ItemCard(item_id, nil, t_item_data)
    vars['itemNode']:addChild(item_icon.root)
    
    -- 이름
    local item_name = TableItem():getValue(item_id, 't_name')
    local name = UIHelper:makeItemNamePlainByParam(item_id, item_cnt)
    vars['quantityLabel']:setString(name)
    
    -- 아이템 설명
    if vars['dscLabel'] then
    	local desc = TableItem:getItemDesc(item_id)
    	vars['dscLabel']:setString(desc)
    end

    vars['dayLabel']:setString(Str('{1}일 차', t_item_data['step']))
end

-------------------------------------
-- function setTodayStep
-------------------------------------
function UI_AttendanceSpecialListItem_CommonItem:setTodayStep(today_step, cur_step)
    local vars = self.vars

    if (not today_step) then
        return
    end

    if (today_step == '') then
        return
    end

    -- 수령 표시
    if (cur_step <= tonumber(today_step)) then
        vars['checkSprite']:setVisible(true)
    end
end
