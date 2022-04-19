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
    m_pressBtn = 'UCI_Button', -- 누르고 있는 버튼
    m_pressTimer = 'number',   -- 누른 시간
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
    self.m_pressTimer = 0

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
    vars['minusBtn']:registerScriptTapHandler(function() self:click_countBtn(-1) end)
    vars['minusBtn']:registerScriptPressHandler(function() self:press_countBtn(false) end)

    vars['plusBtn']:registerScriptTapHandler(function() self:click_countBtn(1) end)
    vars['plusBtn']:registerScriptPressHandler(function() self:press_countBtn(true) end)

    vars['100Btn']:registerScriptTapHandler(function() self:click_countBtn(100) end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)

    vars['grindAutoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
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
    local autoCount = self.m_autoCount

    vars['quantityLabel']:setString(tostring(autoCount))
end

----------------------------------------------------------------------
-- function addAutoCount
-- @brief 자동 돌림판 횟수 add 메서드
-- @param count 더할 횟수, 음수 가능
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:addAutoCount(count)
    local autoCount = self.m_autoCount
    local maxCount = self.m_maxCount

    autoCount = autoCount + count

    if(autoCount > maxCount) then
        UIManager:toastNotificationRed(Str('이벤트 아이템이 부족합니다.'))
    end

    self.m_autoCount = math_clamp(autoCount, AUTO_MIN_COUNT, maxCount)
end

----------------------------------------------------------------------
-- function click_countBtn
-- @brief 자동 돌림판 횟수 증감 버튼 클릭
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:click_countBtn(amount)
    self:addAutoCount(amount)
    self:refresh()
end

----------------------------------------------------------------------
-- function click_autoBtn
-- @brief 자동 돌림판 시작 버튼 클릭
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:click_autoBtn()
    local autoCount = self.m_autoCount
    local rouletteCB = self.m_rouletteCB
    
    if (autoCount > 0) then
        local start_cb = function() 
            if(rouletteCB) then
                rouletteCB(autoCount)
            end

            self:close()
        end

        UI_EventRouletteAutoSettingCheck(autoCount, start_cb)
    else
        UIManager:toastNotificationRed(Str('이벤트 아이템이 부족합니다.'))
    end
end

----------------------------------------------------------------------
-- function press_countBtn
-- @brief 꾹 누르면 티켓 개수 변화 빠르게 적용
----------------------------------------------------------------------
function UI_EventRouletteAutoSetting:press_countBtn(is_plus)
	local vars = self.vars
    local amount = is_plus and 1 or -1

    self.m_pressBtn = is_plus and vars['plusBtn'] or vars['minusBtn']

	local function update_count(dt)

		if (not self.m_pressBtn:isSelected()) or (not self.m_pressBtn:isEnabled()) then
			self.m_pressTimer = 0
			self.m_pressBtn = nil
			self.root:unscheduleUpdate()
		end

		self.m_pressTimer = self.m_pressTimer + dt

		if (self.m_pressTimer > 0.03) then
			self:click_countBtn(amount)
			self.m_pressTimer = self.m_pressTimer - 0.03
		end
	end

	self.root:scheduleUpdateWithPriorityLua(function(dt) return update_count(dt) end, 1)
end

--@CHECK
UI:checkCompileError(UI_EventRouletteAutoSetting)