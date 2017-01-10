local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_AutoPlaySettingPopup
-------------------------------------
UI_AutoPlaySettingPopup = class(PARENT, {
    })

UI_AutoPlaySettingPopup.TAB_SKILL = 1
UI_AutoPlaySettingPopup.TAB_CONTINUOUS_BATTLE = 2

-------------------------------------
-- function init
-------------------------------------
function UI_AutoPlaySettingPopup:init(t_user_info)
    local vars = self:load('ready_auto_start.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AutoPlaySettingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AutoPlaySettingPopup:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_AutoPlaySettingPopup:initUI()
    local vars = self.vars

    self:addTab(UI_AutoPlaySettingPopup.TAB_SKILL, vars['skillBtn'], vars['skillMenu'])
    self:addTab(UI_AutoPlaySettingPopup.TAB_CONTINUOUS_BATTLE, vars['autoStartBtn'], vars['autoStartMenu'])
    self:setTab(UI_AutoPlaySettingPopup.TAB_CONTINUOUS_BATTLE)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AutoPlaySettingPopup:initButton(t_user_info)
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    vars['autoStartBtn1']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn2']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn3']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn4']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn5']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)

    vars['autoStartBtn1'] = UIC_CheckBox(vars['autoStartBtn1'].m_node, vars['autoStartSprite1'], true)
    vars['autoStartBtn2'] = UIC_CheckBox(vars['autoStartBtn2'].m_node, vars['autoStartSprite2'], false)
    vars['autoStartBtn3'] = UIC_CheckBox(vars['autoStartBtn3'].m_node, vars['autoStartSprite3'], false)
    vars['autoStartBtn4'] = UIC_CheckBox(vars['autoStartBtn4'].m_node, vars['autoStartSprite4'], false)
    vars['autoStartBtn5'] = UIC_CheckBox(vars['autoStartBtn5'].m_node, vars['autoStartSprite5'], false)

    local radio_button = UIC_RadioButton()
    vars['skillBtn1']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['skillBtn2']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    radio_button:addButton('1', vars['skillBtn1'], vars['skillSprite1'])
    radio_button:addButton('2', vars['skillBtn2'], vars['skillSprite2'])
    radio_button:setSelectedButton('1')

    local radio_button = UIC_RadioButton()
    vars['skillBtn3']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['skillBtn4']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    radio_button:addButton('3', vars['skillBtn3'], vars['skillSprite3'])
    radio_button:addButton('4', vars['skillBtn4'], vars['skillSprite4'])
    radio_button:setSelectedButton('3')

    local radio_button = UIC_RadioButton()
    vars['skillBtn5']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['skillBtn6']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['skillBtn7']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    radio_button:addButton('5', vars['skillBtn5'], vars['skillSprite5'])
    radio_button:addButton('6', vars['skillBtn6'], vars['skillSprite6'])
    radio_button:addButton('7', vars['skillBtn7'], vars['skillSprite7'])
    radio_button:setSelectedButton('5')

    vars['autoStartOnBtn'] = UIC_CheckBox(vars['autoStartOnBtn'].m_node, vars['autoStartOnSprite'], false)
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_AutoPlaySettingPopup:refresh(t_user_info)
    local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_AutoPlaySettingPopup)
