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
function UI_AttendanceSpecialListItem:init(t_item_data)
    self.m_tItemData = t_item_data

    local vars = self:load('event_attendance_special_item.ui')

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
        local t_sub_data = nil
        local item_icon = IconHelper:getItemIcon(t_item_data['item_id'], t_sub_data)
        vars['itemNode'..i]:addChild(item_icon)

        local item_name = TableItem():getValue(t_item_data['item_id'], 't_name')
        vars['quantityLabel'..i]:setString(Str('{1}\n{2}개', item_name, comma_value(t_item_data['value'])))

        if (i <= today_step) then
            vars['checkSprite'..i]:setVisible(true)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceSpecialListItem:initButton()
    local vars = self.vars
    if vars['clickBtn'] then
        vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceSpecialListItem:refresh()
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_AttendanceSpecialListItem:click_clickBtn()
    local str = self:getToolTipDesc()
    local tool_tip = UI_Tooltip_Skill(0, 0, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['clickBtn'])
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_AttendanceSpecialListItem:getToolTipDesc()
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
    local str = '{@SKILL_NAME} ' .. name .. '\n {@DEFAULT}' .. desc
    return str
end