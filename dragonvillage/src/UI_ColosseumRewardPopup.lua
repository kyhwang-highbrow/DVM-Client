local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ColosseumRewardPopup
-------------------------------------
UI_ColosseumRewardPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRewardPopup:init()
    local vars = self:load('colosseum_reward_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ColosseumRewardPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ColosseumRewardPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumRewardPopup:initUI()
    self:initTab()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumRewardPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumRewardPopup:refresh()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ColosseumRewardPopup:initTab()
    local vars = self.vars
    self:addTab('rankReward', vars['rankRewardBtn'], vars['rankRewardNode'])
    self:addTab('firstReward', vars['firstRewardBtn'], vars['firstRewardNode'])

    self:setTab('rankReward')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ColosseumRewardPopup:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    if (not first) then
        return
    end

    if (tab == 'rankReward') then
        self:initRankReward()

    elseif (tab == 'firstReward') then
        self:initFirstReward()
    end
end

-------------------------------------
-- function initRankReward
-------------------------------------
function UI_ColosseumRewardPopup:initRankReward()
    local vars = self.vars

    local table_colosseum_reward = TableColosseumReward()

    for i,v in ipairs(table_colosseum_reward.m_lTierNumber) do
        local tier_name = v

        local ui = UI_ColosseumRewardListItem(tier_name)
        vars['rankRewardNode' .. i]:addChild(ui.root)

        ui.root:setScale(0)
        ui.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.ScaleTo:create(0.25, 1)))
    end
end

-------------------------------------
-- function initFirstReward
-------------------------------------
function UI_ColosseumRewardPopup:initFirstReward()
    local vars = self.vars

    local table_colosseum_reward = TableColosseumReward()

    for i,v in ipairs(table_colosseum_reward.m_lTierNumber) do
        local tier_name = v

        local ui = UI_ColosseumFirstRewardListItem(tier_name)
        vars['firstRewardNode' .. i]:addChild(ui.root)

        ui.root:setScale(0)
        ui.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.ScaleTo:create(0.25, 1)))
    end
end

--@CHECK
UI:checkCompileError(UI_ColosseumRewardPopup)
