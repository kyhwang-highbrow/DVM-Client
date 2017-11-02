local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ClanTabRank
-- @brief 클랜 랭킹 탭
-------------------------------------
UI_ClanTabRank = class(PARENT,{
        vars = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanTabRank:init(owner_ui)
    self.root = owner_ui.vars['rankMenu']
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ClanTabRank:onEnterTab(first)
    if first then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ClanTabRank:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanTabRank:initUI()
    local vars = self.vars
end