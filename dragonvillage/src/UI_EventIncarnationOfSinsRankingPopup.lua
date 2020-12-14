local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventIncarnationOfSinsRankingPopup
-------------------------------------
UI_EventIncarnationOfSinsRankingPopup = class(PARENT,{
        
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:init()
    local vars = self:load('event_incarnation_of_sins_rank_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventIncarnationOfSinsRankingPopup')

    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:initTab()
    local vars = self.vars

    local all_rank_tab = UI_EventIncarnationOfSinsRankingTotalTab(self)
    local attr_rank_tab = UI_EventIncarnationOfSinsRankingAttributeTab(self)
    vars['indivisualTabMenu']:addChild(all_rank_tab.root)
    vars['indivisualTabMenu']:addChild(attr_rank_tab.root)
    
    self:addTabWithTabUIAndLabel('allRank', vars['allRankTabBtn'], vars['allRankTabLabel'], all_rank_tab) -- 종합 랭킹
    self:addTabWithTabUIAndLabel('attrRank', vars['attrRankTabBtn'], vars['attrRankTabLabel'], attr_rank_tab) -- 속성별 랭킹

    self:setTab('allRank')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:refresh()
    local vars = self.vars
end