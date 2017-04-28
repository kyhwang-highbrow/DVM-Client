local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_CollectionStoryPopup
-------------------------------------
UI_CollectionStoryPopup = class(PARENT, {
        m_mTabUI = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionStoryPopup:init(t_item_data)
    local vars = self:load('collection_story_popup.ui')

    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_CollectionStoryPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionStoryPopup:initUI()
    local vars = self.vars
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionStoryPopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionStoryPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_CollectionStoryPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_CollectionStoryPopup:initTab()
    self.m_mTabUI = {}
    self.m_mTabUI['applyTeam'] = UI_CollectionStoryPopup_ApplyTeamTab(self)
    self.m_mTabUI['dragonTeam'] = UI_CollectionStoryPopup_DragonTeamTab(self)
    self.m_mTabUI['allTeam'] = UI_CollectionStoryPopup_AllTeamTab(self)

    local vars = self.vars
    self:addTab('applyTeam', vars['applyTeamBtn'], vars['applyTeamMenu'])
    self:addTab('dragonTeam', vars['dragonTeamBtn'], vars['dragonTeamMenu'])
    self:addTab('allTeam', vars['allTeamBtn'], vars['allTeamMenu'])
    self:setTab('dragonTeam')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_CollectionStoryPopup:onChangeTab(tab, first)
    if self.m_mTabUI[tab] then
        self.m_mTabUI[tab]:onEnterTab(first)
    end
end