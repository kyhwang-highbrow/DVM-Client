local PARENT = UI

-------------------------------------
-- class UI_ChallengeModeRankingPopup
-------------------------------------
UI_ChallengeModeRankingPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeRankingPopup:init()
    local vars = self:load('challenge_mode_ranking_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChallengeModeRankingPopup')

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
function UI_ChallengeModeRankingPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModeRankingPopup:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeModeRankingPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_ChallengeModeRankingPopup)
