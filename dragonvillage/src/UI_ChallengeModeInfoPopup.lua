local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ChallengeModeInfoPopup
-------------------------------------
UI_ChallengeModeInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeInfoPopup:init(default_tab)
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

    local curr_stage
    for i=1, 100 do
        local open_status = (g_challengeMode.m_lOpenInfo[i] or 0)
        if (1 <= open_status) then
            curr_stage = i
        end
    end
    

    local l_stage = g_challengeMode:getChallengeModeStagesInfo()

    -- 위쪽 순위
    if l_stage[1] then
        local ui = UI_ChallengeModeListItem(l_stage[1])
        ui.vars['lockSprite']:setVisible(true)
        vars['stageItem1']:addChild(ui.root)
    end

    -- 아래쪽 순위
    if l_stage[2] then
        local ui = UI_ChallengeModeListItem(l_stage[2])
        ui.vars['lockSprite']:setVisible(false)
        vars['stageItem2']:addChild(ui.root)
    end

    if (vars['scoreLabel']) then
        vars['scoreLabel']:setString(Str('{1}점',0))
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
    self:addTabAuto('difficulty', vars, vars['difficultyInfoMenu'])
    self:addTabAuto('reward', vars, vars['rewardInfoMenu'])
    
    self:setTab(default_tab)
end

-------------------------------------
-- function open
-- @brief 
-------------------------------------
function UI_ChallengeModeInfoPopup:open(tab)
    -- 하루동안 다시 보지 않기 체크
    local save_key = 'event_challenge_' .. tab
    local is_view = g_settingData:get('popup_only_once', save_key) or false
    if (not is_view) then
        g_settingData:applySettingData(true, 'popup_only_once', save_key)
        UI_ChallengeModeInfoPopup(tab)
        return true
    end

    return false
end

--@CHECK
UI:checkCompileError(UI_ChallengeModeInfoPopup)
