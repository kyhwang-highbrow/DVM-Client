local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventIncarnationOfSinsRankingTotalTab
-------------------------------------
UI_EventIncarnationOfSinsRankingTotalTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:init(owner_ui)
    local vars = self:load('event_incarnation_of_sins_rank_popup_all.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
        self:initButton()
    end

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:refresh()
    local vars = self.vars
end