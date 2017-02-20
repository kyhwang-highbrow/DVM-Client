local PARENT = UI

-------------------------------------
-- class UI_ColosseumRankingReward
-------------------------------------
UI_ColosseumRankingReward = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRankingReward:init()
    local vars = self:load('colosseum_ranking_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ColosseumRankingReward')

    self:initUI()
    self:initButton()
    self:refresh()

    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ColosseumRankingReward:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumRankingReward:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumRankingReward:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    vars['tierLabel']:setString(Str('마스터 2'))
    vars['rankingLabel']:setString(Str('68위'))
    vars['rewardLabel']:setString(Str('700개'))
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumRankingReward:refresh()
end

--@CHECK
UI:checkCompileError(UI_ColosseumRankingReward)
