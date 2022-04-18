----------------------------------------------------------------------
-- @ksjang 2022.04.15
-- @brief UI_EventRouletteAutoSetting 정의
----------------------------------------------------------------------

local PARENT = UI

-- 자동 돌림판 최소, 최대 횟수
local AUTO_MIN_COUNT = 0
local AUTO_MAX_COUNT = 100

----------------------------------------------------------------------
-- class UI_EventRouletteAutoSetting
-- @brief 자동 돌림판 횟수 설정 UI
----------------------------------------------------------------------
UI_EventRouletteAutoSetting = class(PARENT, {
    m_autoCount = 'number',    -- 자동 돌림판 횟수
    m_maxCount = 'number',     -- 최대로 돌릴 수 있는 수
    m_rouletteCB = 'function', -- 자동 돌림판 시작 콜백
})

----------------------------------------------------------------------
-- function init
-- @brief 
-- @param ticket_count 보유한 티켓 수
-- @param roulette_cb 자동 돌림판 시작을 위한 콜백, roulette_cb(횟수)
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:init(ticket_count, roulette_cb)
    self.m_uiName = 'UI_EventRouletteAutoSetting'
    self.m_autoCount = 0
    self.m_maxCount = ticket_count > AUTO_MAX_COUNT and AUTO_MAX_COUNT or ticket_count
    self.m_rouletteCB = roulette_cb

    self:load('event_roulette_setting_popup.ui')

    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRouletteAutoSetting')

    --self:initUI()
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:initUI()
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:initButton()
    local vars = self.vars

    -- 차례대로 횟수 증가, 감소, 횟수 100 추가, 취소, 자동 돌림판 시작 버튼
    vars['minusBtn']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['plusBtn']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['100Btn']:registerScriptTapHandler(function() self:click_100Btn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['grindAutoBtn']:registerScriptTapHandler(function() self:click_grindAutoBtn() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:refresh()
    self:refreshLabel()
end

----------------------------------------------------------------------
-- function refreshLabel
-- @brief 자동 돌림판 횟수 refresh
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:refreshLabel()
    local vars = self.vars
    vars['quantityLabel']:setString(tostring(self.m_autoCount))
end

----------------------------------------------------------------------
-- function addAutoCount
-- @brief 자동 돌림판 횟수 add 메서드
-- @param count 더할 횟수, 음수 가능
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:addAutoCount(count)
    self.m_autoCount = self.m_autoCount + count
    self.m_autoCount = math_clamp(self.m_autoCount, AUTO_MIN_COUNT, self.m_maxCount)
end

----------------------------------------------------------------------
-- function click_minusBtn
-- @brief 자동 돌림판 횟수 1회 감소 버튼 클릭
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:click_minusBtn()
    self:addAutoCount(-1)
    self:refresh()
end

----------------------------------------------------------------------
-- function click_plusBtn
-- @brief 자동 돌림판 횟수 1회 증가 버튼 클릭
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:click_plusBtn()
    self:addAutoCount(1)
    self:refresh()
end

----------------------------------------------------------------------
-- function click_100Btn
-- @brief 자동 돌림판 횟수 최대(100회) 설정 버튼 클릭
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:click_100Btn()
    self:addAutoCount(100)
    self:refresh()
end

----------------------------------------------------------------------
-- function click_cancelBtn
-- @brief 자동 돌림판 횟수 설정 UI 닫기 버튼 클릭
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:click_cancelBtn()
    self:close()
end

----------------------------------------------------------------------
-- function click_grindAutoBtn
-- @brief 자동 돌림판 시작 버튼 클릭
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:click_grindAutoBtn()
    if (self.m_autoCount > 0) then
        local cb = function() 
            if(self.m_rouletteCB) then
                self.m_rouletteCB(self.m_autoCount)
            end

            self:close()
        end

        UI_EventRouletteAutoSettingCheck(self.m_autoCount, cb)
    else
        -- 이미 토스트 팝업이 띄워져 있다면 추가 생성 안하는 쪽으로 수정 필요
        UI_ToastPopup(Str('티켓이 부족합니다.'))
    end
end

--@CHECK
UI:checkCompileError(UI_EventRouletteAutoSetting)