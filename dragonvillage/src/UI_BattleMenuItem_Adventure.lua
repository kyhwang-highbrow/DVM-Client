local PARENT = UI_BattleMenuItem

-------------------------------------
-- class UI_BattleMenuItem_Adventure
-------------------------------------
UI_BattleMenuItem_Adventure = class(PARENT, {})

local THIS = UI_BattleMenuItem_Adventure

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem_Adventure:init(content_type)
    local vars = self:load('battle_menu_adventure_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end