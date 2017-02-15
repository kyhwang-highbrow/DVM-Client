local PARENT = UI

-------------------------------------
-- class UI_ExplorationResultPopup
-------------------------------------
UI_ExplorationResultPopup = class(PARENT,{
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ExplorationResultPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ExplorationResultPopup'
    self.m_bVisible = true or false
    self.m_titleStr = Str('탐험 보상') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationResultPopup:init()
    local vars = self:load('exploration_result.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ExplorationResultPopup')

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
function UI_ExplorationResultPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationResultPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationResultPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ExplorationResultPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ExplorationResultPopup)
