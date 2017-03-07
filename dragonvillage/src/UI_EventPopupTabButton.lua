local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EventPopupTabButton
-------------------------------------
UI_EventPopupTabButton = class(PARENT, {
        m_structEventPopupTab = 'StructEventPopupTab',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTabButton:init(struct_event_popup_tab)
    self.m_structEventPopupTab = struct_event_popup_tab

    local vars = self:load('event_popup_list_item.ui')

    self:initUI()
    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTabButton:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTabButton:initButton()
    local vars = self.vars
    vars['listBtn']:registerScriptTapHandler(function() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTabButton:refresh()
    local vars = self.vars

    local struct_event_popup_tab = self.m_structEventPopupTab
    local type = struct_event_popup_tab.m_type

    if (type == 'birthday_calendar') then
        vars['eventLabel']:setString(Str('드래곤 생일'))

    elseif (type == 'attendance_basic') then
        vars['eventLabel']:setString(Str('출석'))

    elseif (type == 'attendance_event') then
        vars['eventLabel']:setString(Str('이벤트 출석'))

    end
end