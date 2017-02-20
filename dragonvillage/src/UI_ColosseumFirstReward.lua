local PARENT = UI

-------------------------------------
-- class UI_ColosseumFirstReward
-------------------------------------
UI_ColosseumFirstReward = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumFirstReward:init()
    local vars = self:load('colosseum_first_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ColosseumFirstReward')

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
function UI_ColosseumFirstReward:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumFirstReward:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumFirstReward:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    vars['tierLabel']:setString(Str('마스터 2'))
    vars['rewardLabel']:setString(Str('최초 승격 보상으로 자수정 {1}개가 지급되었습니다', 250))

    local tier_icon = ColosseumUserInfo:makeTierIcon('master_2', 'big')
    vars['tierNode']:addChild(tier_icon)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumFirstReward:refresh()
end

--@CHECK
UI:checkCompileError(UI_ColosseumFirstReward)
