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

    local vars = self:load('event_item.ui')

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
    
    g_eventData:setEventTabNoti(self.m_structEventPopupTab)

    local struct_event_popup_tab = self.m_structEventPopupTab
    local type = struct_event_popup_tab.m_type
    local tab_btn_name = struct_event_popup_tab:getTabButtonName()

    if vars['eventLabel'] then
        vars['eventLabel']:setString(tab_btn_name)
    end

    if vars['notiSprite'] then
        vars['notiSprite']:setVisible(self.m_structEventPopupTab.m_hasNoti)
    end
end

-------------------------------------
-- function refreshNoti
-------------------------------------
function UI_EventPopupTabButton:refreshNoti()
    local vars = self.vars
    local is_noti_on = self.m_structEventPopupTab:isNotiVisible()

    if vars['notiSprite'] then
        vars['notiSprite']:setVisible(is_noti_on)
    end
end