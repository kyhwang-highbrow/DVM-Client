local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TableViewCellClass
-------------------------------------
UI_TableViewCellClass = class(PARENT, {
        m_tItemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TableViewCellClass:init(t_item_data)
    local vars = self:load('item_list.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TableViewCellClass:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TableViewCellClass:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TableViewCellClass:refresh()
end