local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AttendanceSpecialListItem
-------------------------------------
UI_AttendanceSpecialListItem = class(PARENT, {
        m_tItemData = 'table',
        m_lMessage = '',
        m_messageIdx = '',
        m_messageTimer = '',
        m_lMessagePosY = '',
        m_effectTimer = '',
        
        m_eventId = '',
        m_hasCustomUI = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecialListItem:init(t_item_data, event_id)
    self.m_tItemData = t_item_data
    self.m_eventId = event_id
    self.m_hasCustomUI = false

    local ui_name 
    if (event_id == 'comeback') then
        ui_name = 'event_attendance_return.ui'
    else
        ui_name = 'event_attendance_special_item.ui'
    end

    -- 데이터에 ui파일명 들어가 있으면?
    if (self.m_tItemData and self.m_tItemData['ui'] and self.m_tItemData['ui'] ~= '') then 
        self.m_hasCustomUI = true
        ui_name = tostring(self.m_tItemData['ui']) 
    end

    local vars = self:load(ui_name)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceSpecialListItem:initUI()
    if (self.m_hasCustomUI) then
        self:initCustomUI()
    else
        self:initCommonUI()
    end
end

-------------------------------------
-- function initCommonUI
-------------------------------------
function UI_AttendanceSpecialListItem:initCommonUI()
    local vars = self.vars
    
    local t_step_list = self.m_tItemData['step_list']
    local today_step = self.m_tItemData['today_step']

    for i, v in ipairs(t_step_list) do
        local t_item_data = v
		
		local item_id = t_item_data['item_id']
		local item_cnt = t_item_data['value']
        
		-- 아이콘
		local item_icon = IconHelper:getItemIcon(item_id, nil)

        if (vars['itemNode'..i]) then vars['itemNode'..i]:addChild(item_icon) end
        if (vars['rewardNode'..i]) then vars['rewardNode'..i]:addChild(item_icon) end

		-- 이름
        local item_name = TableItem():getValue(item_id, 't_name')
		local name = UIHelper:makeItemNamePlainByParam(item_id, item_cnt)
        vars['quantityLabel'..i]:setString(name)

		-- 수령 표시
        if (i <= today_step) then
            vars['checkSprite'..i]:setVisible(true)
        end

		-- 아이템 설명
		if vars['dscLabel' .. i] then
			local desc = TableItem:getItemDesc(item_id)
			vars['dscLabel' .. i]:setString(desc)
		end
    end

    -- 남은 시간
    if vars['timeLabel'] then
        --vars['timeLabel']:setString(self:getRemainTimeStr())
    end
end

-------------------------------------
-- function initCustomUI
-------------------------------------
function UI_AttendanceSpecialListItem:initCustomUI()
    local vars = self.vars
    
    local t_step_list = self.m_tItemData['step_list']
    local today_step = self.m_tItemData['today_step']


    local isNewUser = self.m_eventId == 'newbie'
    local isComebackUser = self.m_eventId == 'comeback'

    -- 신규 or 복귀?
    if (vars['newUserSprite']) then
        vars['newUserSprite']:setVisible(isNewUser)
    end

    if (vars['returnSprite']) then
        vars['returnSprite']:setVisible(isComebackUser)
    end

    for i, v in ipairs(t_step_list) do
        local t_item_data = v
		
		local item_id = t_item_data['item_id']
		local item_cnt = t_item_data['value']
        
		-- 아이콘
		local item_icon = IconHelper:getItemIcon(item_id, nil)

        if (vars['itemNode'..i]) then vars['itemNode'..i]:addChild(item_icon) end
        if (vars['rewardNode'..i]) then vars['rewardNode'..i]:addChild(item_icon) end

        item_icon:setScale(0.9)


		-- 이름
        local item_name = TableItem():getValue(item_id, 't_name')
		local name = UIHelper:makeItemNamePlainByParam(item_id, item_cnt)

        if (vars['quantityLabel'..i]) then vars['quantityLabel'..i]:setString(name) end

		-- 수령 표시
        if (i <= today_step) then
            if (vars['checkSprite'..i]) then vars['checkSprite'..i]:setVisible(true) end
        end
    end
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceSpecialListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceSpecialListItem:refresh()
end

-------------------------------------
-- function getRemainTimeStr
-- 남은 시간
-------------------------------------
function UI_AttendanceSpecialListItem:getRemainTimeStr()
    local curr_time = Timer:getServerTime()
    local start_time = self.m_tItemData['start']
    start_time = start_time and (tonumber(start_time) / 1000) or 0

    local end_time = self.m_passInfoData[key]['end']
    end_time = end_time and (tonumber(end_time) / 1000) or 0

    local str = ''
    if (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true))

    else
        str = ''
    end

    return str
end
