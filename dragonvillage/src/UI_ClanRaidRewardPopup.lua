local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaidRewardPopup
-------------------------------------
UI_ClanRaidRewardPopup = class(PARENT,{
    })

local CLAN_OFFSET_GAP = 20

local TAB_REWARD_FIGHT = 1 -- 한판 보상
local TAB_REWARD_CLEAR = 2 -- 클리어 보상
local TAB_REWARD_SEASON = 3 -- 시즌 보상

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidRewardPopup:init()
    local vars = self:load('clan_raid_reward.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_ClanRaidRewardPopup'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ClanRaidRewardPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initTab()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidRewardPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidRewardPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanRaidRewardPopup:initTab()
    local vars = self.vars

    self:addTabWithLabel(TAB_REWARD_FIGHT, vars['rewardTabBtn1'], vars['rewardTabLabel1'], vars['rewardNode1'])
    self:addTabWithLabel(TAB_REWARD_CLEAR, vars['rewardTabBtn2'], vars['rewardTabLabel2'], vars['rewardNode2'])
    self:addTabWithLabel(TAB_REWARD_SEASON, vars['rewardTabBtn3'], vars['rewardTabLabel3'], vars['rewardNode3'])
    self:setTab(TAB_REWARD_FIGHT)
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanRaidRewardPopup:onChangeTab(tab, first)
    -- 탭할때마다 액션 
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidRewardPopup:refresh()
    local vars = self.vars
    -- 종료 시간
    local status_text = g_clanRaidData:getClanRaidStatusText()
    vars['timeLabel']:setString(status_text)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ClanRaidRewardPopup:click_closeBtn()
    self:close()
end