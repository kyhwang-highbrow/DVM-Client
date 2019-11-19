local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ArenaRewardInfoPopup
-------------------------------------
UI_ArenaRewardInfoPopup = class(PARENT,{
    })

UI_ArenaRewardInfoPopup.RANK = 'rankReward'
UI_ArenaRewardInfoPopup.MATCH = 'matchReward'
UI_ArenaRewardInfoPopup.CLAN = 'clanReward'

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaRewardInfoPopup:init()
    local ui_res = 'arena_reward_popup.ui'
    if (g_arenaData:removeClanData()) then
        ui_res = 'arena_reward_popup_new.ui'
    end
    local vars = self:load(ui_res)
    
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaRewardInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaRewardInfoPopup:initUI()
    local vars = self.vars
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaRewardInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaRewardInfoPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ArenaRewardInfoPopup:initTab()
    local vars = self.vars
    self:addTabAuto(UI_ArenaRewardInfoPopup.RANK, vars, vars['rankRewardNode'])
    self:addTabAuto(UI_ArenaRewardInfoPopup.MATCH, vars, vars['matchRewardNode'])
    self:addTabAuto(UI_ArenaRewardInfoPopup.CLAN, vars, vars['clanRewardNode'])

    self:setTab(UI_ArenaRewardInfoPopup.RANK)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ArenaRewardInfoPopup:onChangeTab(tab, first)
    -- 탭할때마다 액션 
    self:doActionReset()
    self:doAction(nil, false)  
end

--@CHECK
UI:checkCompileError(UI_ArenaRewardInfoPopup)
