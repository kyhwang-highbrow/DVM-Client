local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Attendance
-------------------------------------
UI_EventPopupTab_Attendance = class(PARENT,{
		m_structAttendance = 'StructAttendanceData',
		m_tableView = 'UIC_TableView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Attendance:init(owner)
    local vars = self:load('event_attendance_basic_new.ui')

    self.m_structAttendance = g_attendanceData:getBasicAttendance()

	local struct_attendance_data = self.m_structAttendance
    local help_text = struct_attendance_data['help_text']
    local today_step = struct_attendance_data['today_step']
	local step_list = struct_attendance_data['step_list']

    vars['descLabel']:setString(Str(help_text))
    --vars['dayLabel']:setString(Str('{1}일차', today_step))

    -- 보상 리스트 출력
	local idx = 1
    for _, v in ipairs(step_list) do
		if (v['tag_hot'] == true) then
			local ui = self.makeHotRewardCell(v, today_step)
			vars['rewardNode' .. idx]:addChild(ui.root)
			idx = idx + 1
		end

		if (idx > 4) then
			break
		end
    end

	self:initTableView()

    -- 오늘 보상을 보여주는 팝업
    self:checkTodayRewardPopup()
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_EventPopupTab_Attendance:initTableView()
	local node = self.vars['listNode']
	local struct_attendance_data = self.m_structAttendance
	local t_item_list = struct_attendance_data['step_list']
	local today_step = struct_attendance_data['today_step']

		-- item ui에 보상 수령 함수 등록하는 콜백 함수
	local create_cb_func = function(ui, data)
		local step = data['step']
	    if (step < today_step) then
            ui.vars['checkSprite']:setVisible(true)

		elseif (step == today_step) then
			ui.vars['checkSprite']:setVisible(true)
			ui.vars['todayBgSprite']:setVisible(true)

        else
            ui.vars['checkSprite']:setVisible(false)
        end

        
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(120 + 5, 154)
    table_view:setCellUIClass(self.makeDayRewardCell, create_cb_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(t_item_list)
	self.m_tableView = table_view

	self.m_tableView:update(0)
	self.m_tableView:relocateContainerFromIndex(today_step, false)			
end

-------------------------------------
-- function checkTodayRewardPopup
-- @brief 오늘 획득한 보상 팝업
-------------------------------------
function UI_EventPopupTab_Attendance:checkTodayRewardPopup()
    local vars = self.vars

    local struct_attendance_data = self.m_structAttendance
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
function UI_EventPopupTab_Attendance:onEnterTab()
    local vars = self.vars
end

-------------------------------------
-- function makeHotRewardCell
-- @brief 태그 핫 보상 cell
-------------------------------------
function UI_EventPopupTab_Attendance.makeHotRewardCell(data, today)
	local ui = UI()
	local vars = ui:load('event_attendance_basic_item_01.ui')
			
	-- 아이템 세팅
	local item_id = data['item_id']
	do
		local t_sub_data = nil
		local item_icon = IconHelper:getItemIcon(item_id, t_sub_data)
		vars['itemNode']:addChild(item_icon)

		local item_name = TableItem:getItemName(item_id)
		vars['nameLabel']:setString(item_name)
	end

	vars['dscLabel']:setString('')

	local day = data['step']
	vars['dayLabel']:setString(Str('{1}일차', day))

	if (day <= today) then
        vars['checkSprite']:setVisible(true)
	elseif (math_floor(day/7) == math_floor(today/7)) then
		vars['ingSprite']:setVisible(true)
    else
		vars['checkSprite']:setVisible(false)
    end

    -- 터치시 툴팁
    vars['clickBtn']:registerScriptTapHandler(function()
        local desc = TableItem:getToolTipDesc(item_id)
        local tool_tip = UI_Tooltip_Skill(70, -145, desc)
        tool_tip:autoPositioning(vars['clickBtn'])
    end)

	cca.uiReactionSlow(ui.root)

	return ui
end

-------------------------------------
-- function makeDayRewardCell
-- @brief 태그 핫 보상 cell
-------------------------------------
function UI_EventPopupTab_Attendance.makeDayRewardCell(data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('event_attendance_basic_item_02.ui')

    local item_id = data['item_id']

    local t_sub_data = nil
    local item_icon = IconHelper:getItemIcon(item_id, t_sub_data)
    vars['itemNode']:addChild(item_icon)

    vars['dayLabel']:setString(Str('{1}일차', data['step']))
    vars['quantityLabel']:setString(comma_value(data['value']))
	vars['bgSprite']:setVisible(not data['tag_hot'])
    vars['specialBgSprite']:setVisible(data['tag_hot'])

	-- 터치시 툴팁
    vars['clickBtn']:registerScriptTapHandler(function()
        local desc = TableItem:getToolTipDesc(item_id)
        local tool_tip = UI_Tooltip_Skill(70, -145, desc)
        tool_tip:autoPositioning(vars['clickBtn'])
    end)

	return ui
end
