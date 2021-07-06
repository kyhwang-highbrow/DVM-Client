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
    vars['eventLabel']:setString(tab_btn_name)

    
    -- 이벤트 탭 노티피케이션 (ServerData_Event:setEventTabNoti 참고)
    vars['notiSprite']:setVisible(struct_event_popup_tab.m_hasNoti)
    

    --vars['notiSprite']
end