local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanMarkListItem
-------------------------------------
UI_ClanMarkListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanMarkListItem:init()
    local vars = self:load('clan_mark_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanMarkListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanMarkListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanMarkListItem:refresh()
    local vars = self.vars
end