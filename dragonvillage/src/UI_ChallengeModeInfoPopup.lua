local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ChallengeModeInfoPopup
-------------------------------------
UI_ChallengeModeInfoPopup = class(PARENT,{
        m_dailySkipKey = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeInfoPopup:init(default_tab, save_key)
    self.m_dailySkipKey = save_key
    local vars = self:load('challenge_mode_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChallengeModeInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
    self:initTab(default_tab)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeModeInfoPopup:initUI()
    local vars = self.vars

    -- 하루동안 다시 보지 않기
    if self.m_dailySkipKey then
        vars['checkBtn']:setVisible(true)
        vars['checkLabel']:setVisible(true)
    else
        vars['checkBtn']:setVisible(false)
        vars['checkLabel']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModeInfoPopup:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeModeInfoPopup:refresh()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ChallengeModeInfoPopup:initTab(default_tab)
    local default_tab = (default_tab or 'bg')

    local vars = self.vars
    self:addTabAuto('bg', vars, vars['bgInfoMenu'])
    self:addTabAuto('lock', vars, vars['lockInfoMenu'])
    self:addTabAuto('score', vars, vars['scoreInfoMenu'])
    self:addTabAuto('wing', vars, vars['wingInfoMenu'])
    self:addTabAuto('reward', vars, vars['rewardInfoMenu'])
    self:setTab(default_tab)
end

-------------------------------------
-- function click_checkBtn
-------------------------------------
function UI_ChallengeModeInfoPopup:click_checkBtn()
    local vars = self.vars
    vars['checkSprite']:setVisible(true)

    -- 다시보지않기
    g_settingData:applySettingData(true, 'event_full_popup', self.m_dailySkipKey)

    self:close()
end

-------------------------------------
-- function open
-- @brief 
-------------------------------------
function UI_ChallengeModeInfoPopup:open(tab)
    -- 하루동안 다시 보지 않기 체크
    local save_key = 'event_challenge_' .. tab
    local is_view = g_settingData:get('event_full_popup', save_key) or false
    if (not is_view) then
        UI_ChallengeModeInfoPopup(tab, save_key)
        return true
    end

    return false
end

--@CHECK
UI:checkCompileError(UI_ChallengeModeInfoPopup)
