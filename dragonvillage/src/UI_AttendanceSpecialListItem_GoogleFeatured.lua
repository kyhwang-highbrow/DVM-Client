local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AttendanceSpecialListItem_GoogleFeatured
-------------------------------------
UI_AttendanceSpecialListItem_GoogleFeatured = class(PARENT, {
        m_structAttendanceData = 'table', -- StructAttendanceData
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecialListItem_GoogleFeatured:init(struct_attendance_data)
    self.m_structAttendanceData = struct_attendance_data

    local ui_res = struct_attendance_data:getUIRes() -- event_attendance_children.ui, event_attendance_1st_anniversary.ui
    local vars = self:load(ui_res)
    self:changeTitleSprite(vars)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function changeTitleSprite
-- @brief 구글 피쳐드 선정 기념. 구글 apk -> '구글 피처드 선정 기념 ~', 아니면 '피처드 선정 기념 ~'
-------------------------------------
function UI_AttendanceSpecialListItem_GoogleFeatured:changeTitleSprite(ui)
    if(ui['otherMarketSprite'] and ui['otherMarketSprite']) then
        ui['googleSprite']:setVisible(false)
        ui['otherMarketSprite']:setVisible(false)
        if (market ~= 'google') then
            ui['otherMarketSprite']:setVisible(true)
        else
            ui['googleSprite']:setVisible(true)
        end
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceSpecialListItem_GoogleFeatured:initUI()
    local vars = self.vars
    local struct_attendance_data = self.m_structAttendanceData
    local item_ui_res = struct_attendance_data:getItemUIRes() -- event_attendance_children_item.ui, event_attendance_1st_anniversary_item.ui


    --for i = 1,7 do
    for _,t_step_data in pairs(struct_attendance_data['step_list']) do
        local i = t_step_data['step']
        if (vars['rewardNode' .. i]) then
            local ui = UI_AttendanceSpecialListItem_GoogleFeaturedItem(item_ui_res, t_step_data)
            local cur_step = i
            ui:setTodayStep(struct_attendance_data['today_step'], cur_step)
            vars['rewardNode' .. i]:addChild(ui.root)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceSpecialListItem_GoogleFeatured:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceSpecialListItem_GoogleFeatured:refresh()
end




local PARENT = UI

-------------------------------------
-- class UI_AttendanceSpecialListItem_GoogleFeaturedItem
-------------------------------------
UI_AttendanceSpecialListItem_GoogleFeaturedItem = class(PARENT, {
        m_itemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecialListItem_GoogleFeaturedItem:init(item_ui_res, t_item_data)
    self.m_itemData = t_item_data

    local vars = self:load(item_ui_res) -- event_attendance_children_item.ui, event_attendance_1st_anniversary_item.ui

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceSpecialListItem_GoogleFeaturedItem:initUI()
    local vars = self.vars
    local t_item_data = self.m_itemData

    local item_id = t_item_data['item_id']
    local item_cnt = t_item_data['value']
    
    -- 아이콘
    local item_icon = IconHelper:getItemIcon(item_id, nil)
    vars['itemNode']:addChild(item_icon)
    
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

    -- 터치시 툴팁
    vars['clickBtn']:registerScriptTapHandler(function()
        local desc = TableItem:getToolTipDesc(item_id)
        local tool_tip = UI_Tooltip_Skill(70, -145, desc)
        tool_tip:autoPositioning(vars['clickBtn'])
    end)
end

-------------------------------------
-- function setTodayStep
-------------------------------------
function UI_AttendanceSpecialListItem_GoogleFeaturedItem:setTodayStep(today_step, cur_step)
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