local PARENT = UI

-------------------------------------
-- class UI_EventMatchCardResult
-------------------------------------
UI_EventMatchCardResult = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventMatchCardResult:init(data)
    local vars = self:load('event_match_card_result.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_EventMatchCardResult')

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
function UI_EventMatchCardResult:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventMatchCardResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventMatchCardResult:refresh()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_EventMatchCardResult:click_okBtn()
    UINavigator:goTo('event_match_card')
end

--@CHECK
UI:checkCompileError(UI_EventMatchCardResult)
