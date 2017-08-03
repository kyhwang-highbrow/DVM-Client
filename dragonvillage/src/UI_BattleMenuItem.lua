local PARENT = UI

-------------------------------------
-- class UI_BattleMenuItem
-------------------------------------
UI_BattleMenuItem = class(PARENT, {
     })

local THIS = UI_BattleMenuItem

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem:init()
    local vars = self:load('battle_menu_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenuItem:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BattleMenuItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BattleMenuItem:refresh()
end