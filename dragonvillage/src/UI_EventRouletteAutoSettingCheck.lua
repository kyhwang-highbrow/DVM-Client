----------------------------------------------------------------------
-- @ksjang 2022.04.15
-- @brief UI_EventRouletteAutoSettingCheck 정의
----------------------------------------------------------------------

local PARENT = UI

----------------------------------------------------------------------
-- class UI_EventRouletteAutoSettingCheck
-- @brief 자동 돌림판 횟수 설정 한 번더 확인 하는 UI
----------------------------------------------------------------------
UI_EventRouletteAutoSettingCheck = class(PARENT, {
    m_autoCount = 'number',    -- 자동 돌림판 횟수
    m_rouletteCB = 'function', -- 자동 돌림판 시작 콜백
})

----------------------------------------------------------------------
-- function init
-- @param count 자동 돌림판 횟수
-- @param roulette_cb 자동 돌림판 시작을 위한 콜백, roulette_cb() <- 인자 없어요!
----------------------------------------------------------------------
function UI_EventRouletteAutoSettingCheck:init(count, roulette_cb)
    self.m_uiName = 'UI_EventRouletteAutoSettingCheck'
    self.m_autoCount = count
    self.m_rouletteCB = roulette_cb

    self:load('popup_02.ui')

    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRouletteAutoSettingCheck')

    self:initUI()
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_EventRouletteAutoSettingCheck:initUI()
    local vars = self.vars

    vars['subLabel']:setString(Str('선택한 횟수로 돌림판을 돌립니다.\n진행하시겠습니까?'))
    vars['mainLabel']:setString(Str('자동 돌림판 횟수 {1}', self.m_autoCount))
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_EventRouletteAutoSettingCheck:initButton()
    local vars = self.vars

    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRouletteAutoSettingCheck:refresh()
end

----------------------------------------------------------------------
-- function click_cancelBtn
----------------------------------------------------------------------
function UI_EventRouletteAutoSettingCheck:click_cancelBtn()
    self:close()
end

----------------------------------------------------------------------
-- function click_okBtn
----------------------------------------------------------------------
function UI_EventRouletteAutoSettingCheck:click_okBtn()
    if(self.m_rouletteCB) then
        self.m_rouletteCB()
    end

    self:close()
end

--@CHECK
UI:checkCompileError(UI_EventRouletteAutoSettingCheck)