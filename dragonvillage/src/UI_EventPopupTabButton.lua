local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EventPopupTabButton
-------------------------------------
UI_EventPopupTabButton = class(PARENT, {
        m_tItemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTabButton:init(t_item_data)
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
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTabButton:refresh()
end