local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ClanGuestTabRank
-- @brief 드래곤 조합
-------------------------------------
UI_ClanGuestTabRank = class(PARENT,{
        vars = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanGuestTabRank:init(owner_ui)
    self.root = owner_ui.vars['rankMenu']
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ClanGuestTabRank:onEnterTab(first)
    if first then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ClanGuestTabRank:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanGuestTabRank:initUI()
    local vars = self.vars
end