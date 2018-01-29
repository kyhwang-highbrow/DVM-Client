local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_PackageTabButton
-------------------------------------
UI_PackageTabButton = class(PARENT, {
        m_structEventPopupTab = 'StructEventPopupTab',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PackageTabButton:init(struct_event_popup_tab)
    self.m_structEventPopupTab = struct_event_popup_tab

    local vars = self:load('shop_package_list.ui')

    self:initUI()
    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PackageTabButton:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PackageTabButton:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PackageTabButton:refresh()
    local vars = self.vars
    local struct_event_popup_tab = self.m_structEventPopupTab
    local tab_btn_name = struct_event_popup_tab:getTabButtonName()
    vars['listLabel']:setString(tab_btn_name)
end