local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Attendance
-------------------------------------
UI_EventPopupTab_Attendance = class(PARENT,{
		m_structAttendance = 'StructAttendanceData',
		m_tableView = 'UIC_TableView',
		m_isCheckHot = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Attendance:init(owner)
    local vars = self:load('event_attendance_basic.ui')

    self.m_structAttendance = g_attendanceData:getBasicAttendance()
	self.m_isCheckHot = false

	local struct_attendance_data = self.m_structAttendance
    local today_step = struct_attendance_data['today_step']
	local step_list = struct_attendance_data['step_list']

    -- 보상 리스트 출력
	local idx = 1
    for _, v in ipairs(step_list) do
		if (v['tag_hot'] == true) then
			local ui = self:makeHotRewardCell(v, today_step)
			vars['rewardNode' .. idx]:addChild(ui.root)
			idx = idx + 1
		end

		-- 최대 4개까지 가능!
		if (idx > 4) then
			break
		end
    end

	self:initTableView()

    -- 오늘 보상을 보여주는 팝업
	cca.reserveFunc(self.root, 0.5, function() self:checkTodayRewardPopup() end)
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

	local t_item = step_list[today_step]
	local l_item_list = {
		{
			['item_id'] = t_item['item_id'],
			['count'] = t_item['value']
		}
	}
    local msg = Str('{1}일 차 보상이 우편함으로 전송되었습니다.', today_step)
    local ok_btn_cb = nil
    UI_ObtainPopup(l_item_list, msg, ok_btn_cb)
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
function UI_EventPopupTab_Attendance:makeHotRewardCell(data, today)
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

	-- @TODO 또 필요하면 전역함수로 빼자
	local hard_coding = ''
	if (item_id == 703005) then
		hard_coding = Str('{1}성 확정', 5)
	elseif (item_id == 703016) then
		hard_coding = Str('{1}성', '3~5')
	elseif (item_id == 703019) then
		hard_coding = Str('{1}성', '4~5')
	end
	vars['dscLabel']:setString(hard_coding)

	-- 일차
	local day = data['step']
	vars['dayLabel']:setString(Str('{1}일차', day))

	-- 날짜별 처리
	-- 다가오는 중
	if (not self.m_isCheckHot) and (day > today) then
		self.m_isCheckHot = true
		vars['ingSprite']:setVisible(true)
		vars['nextNode']:setVisible(true)
		vars['nextLabel']:setString(Str('획득까지 {1}일 남음', day - today))
		
		local action = cca.buttonShakeAction()
		vars['nextNode']:runAction(action)
		
	-- 이미 받음
	elseif (day <= today) then
        vars['checkSprite']:setVisible(true)

	-- 아직 멀었음
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
	local item_cnt = data['value']

	-- icon (ItemCard를 사용하지 않음)
    local t_sub_data = nil
    local item_icon = IconHelper:getItemIcon(item_id, t_sub_data)
    vars['itemNode']:addChild(item_icon)

	-- 일차	
	local day = Str('{1}일차', data['step'])
    vars['dayLabel']:setString(day)
    
	-- 이름
	local name = UIHelper:makeItemNamePlainByParam(item_id, item_cnt)
	vars['quantityLabel']:setString(name)

	-- 배경
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
