local PARENT = UI

-------------------------------------
-- class UI_AttendanceBasicListItem
-------------------------------------
UI_AttendanceBasicListItem = class(PARENT, {
        m_tItemData = 'table',
    })

-------------------------------------
-- function init
-- @param item_data
-- {
--  "step":1,
--  "item_id":700001,
--  "value":1000,
--  "tag_hot":false
-- }
-------------------------------------
function UI_AttendanceBasicListItem:init(item_data)
    self.m_tItemData = item_data

    local vars = self:load('event_attendance_basic_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceBasicListItem:initUI()
    local vars = self.vars

    local t_item_data = self.m_tItemData
    
    local t_sub_data = nil
    local item_icon = IconHelper:getItemIcon(t_item_data['item_id'], t_sub_data)
    vars['itemNode']:addChild(item_icon)
    --checkSprite
    --itemNode

    vars['dayLabel']:setString(Str('{1}일 차', t_item_data['step']))
    vars['quantityLabel']:setString(comma_value(t_item_data['value']))
    vars['bgSprite']:setVisible(not t_item_data['tag_hot'])
    vars['specialBgSprite']:setVisible(t_item_data['tag_hot'])
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceBasicListItem:initButton()
    local vars = self.vars
    vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceBasicListItem:refresh()
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_AttendanceBasicListItem:click_clickBtn()
    local str = self:getToolTipDesc()
    local tool_tip = UI_Tooltip_Skill(0, 0, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['clickBtn'])
end

-------------------------------------
-- function getToolTipDesc
-------------------------------------
function UI_AttendanceBasicListItem:getToolTipDesc()
    local item_id = self.m_tItemData['item_id']

    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    local desc = ''

    -- 열매 description은 아이템
    if (t_item['type'] == 'fruit') then
        if (t_item['t_desc'] == 'x') then
            local full_type = t_item['full_type']
            local table_fruit = TABLE:get('fruit')
            local t_fruit = table_fruit[full_type]
            desc = t_fruit['t_desc']
        end
    else
        desc = t_item['t_desc']
    end

    local name = t_item['t_name']
    local str = '{@SKILL_NAME} ' .. Str(name) .. '\n {@DEFAULT}' .. Str(desc)
    return str
end