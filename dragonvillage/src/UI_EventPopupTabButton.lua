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

    local struct_event_popup_tab = self.m_structEventPopupTab
    local type = struct_event_popup_tab.m_type
    local tab_btn_name = struct_event_popup_tab:getTabButtonName()
    tab_btn_name = self:labelForGoogleFeatured(tab_btn_name)
    vars['eventLabel']:setString(tab_btn_name)
end

-------------------------------------
-- function labelForGoogleFeatured
-- @brief UI_GoogleFeaturedContentChange를 상속받아 위치를 정리한다. (쓸모 없는 코드지만 이미 작업을 완료 하였으니 피처드 끝난 이후 커밋하여 코드를 깔끔하게 한다.)
-------------------------------------
function UI_EventPopupTabButton:labelForGoogleFeatured(tab_btn_name)
    return tab_btn_name
end