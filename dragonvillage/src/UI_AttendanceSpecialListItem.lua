local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AttendanceSpecialListItem
-------------------------------------
UI_AttendanceSpecialListItem = class(PARENT, {
        m_tItemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecialListItem:init(t_item_data, event_id)
    self.m_tItemData = t_item_data

    local ui_name 
    if (event_id == 'comeback') then
        ui_name = 'event_attendance_return.ui'

    -- 1주년 스페셜 7일 출석 이벤트
    elseif (event_id == '1st_event') then
        ui_name =  'event_attendance_1st_anniversary.ui'

    else
        ui_name = 'event_attendance_special_item.ui'
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
    local vars = self.vars
    
    local t_step_list = self.m_tItemData['step_list']
    local today_step = self.m_tItemData['today_step']

    for i, v in ipairs(t_step_list) do
        local t_item_data = v
		
		local item_id = t_item_data['item_id']
		local item_cnt = t_item_data['value']
        
		-- 아이콘
		local item_icon = IconHelper:getItemIcon(item_id, nil)
        vars['itemNode'..i]:addChild(item_icon)

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