local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_AutoPlaySettingPopup
-------------------------------------
UI_AutoPlaySettingPopup = class(PARENT, {
        m_radioButton_dragonAtkSkill = 'UIC_RadioButton',
        m_radioButton_dragonHealSkill = 'UIC_RadioButton',
    })

UI_AutoPlaySettingPopup.TAB_SKILL = 1
UI_AutoPlaySettingPopup.TAB_CONTINUOUS_BATTLE = 2

-------------------------------------
-- function init
-------------------------------------
function UI_AutoPlaySettingPopup:init(t_user_info)
    local vars = self:load('battle_ready_auto_popup_new.ui')
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
    self.m_radioButton_dragonAtkSkill = radio_button
    vars['skillBtn1']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['skillBtn2']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    radio_button:addButton('at_cool', vars['skillBtn1'], vars['skillSprite1'])
    radio_button:addButton('at_event', vars['skillBtn2'], vars['skillSprite2'])

    local radio_button = UIC_RadioButton()
    self.m_radioButton_dragonHealSkill = radio_button
    vars['skillBtn3']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['skillBtn4']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    radio_button:addButton('at_cool', vars['skillBtn3'], vars['skillSprite3'])
    radio_button:addButton('at_event', vars['skillBtn4'], vars['skillSprite4'])    

    vars['autoStartOnBtn'] = UIC_CheckBox(vars['autoStartOnBtn'].m_node, vars['autoStartOnSprite'], false)
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_AutoPlaySettingPopup:refresh(t_user_info)
    local vars = self.vars

    vars['autoStartBtn1']:setChecked(g_autoPlaySetting:get('stop_condition_lose'))
    vars['autoStartBtn2']:setChecked(g_autoPlaySetting:get('stop_condition_dragon_lv_max'))
    vars['autoStartBtn3']:setChecked(g_autoPlaySetting:get('stop_condition_dragon_inventory_max'))
    vars['autoStartBtn4']:setChecked(g_autoPlaySetting:get('stop_condition_rune_inventory_max'))
    vars['autoStartBtn5']:setChecked(g_autoPlaySetting:get('stop_condition_find_rel_dungeon'))
    
    self.m_radioButton_dragonAtkSkill:setSelectedButton(g_autoPlaySetting:get('dragon_atk_skill'))
    self.m_radioButton_dragonHealSkill:setSelectedButton(g_autoPlaySetting:get('dragon_heal_skill'))

    vars['autoStartOnBtn']:setChecked(g_autoPlaySetting:isAutoPlay())
end

-------------------------------------
-- function close
-------------------------------------
function UI_AutoPlaySettingPopup:close()
    local vars = self.vars

    g_autoPlaySetting:set('stop_condition_lose', vars['autoStartBtn1']:isChecked())
    g_autoPlaySetting:set('stop_condition_dragon_lv_max', vars['autoStartBtn2']:isChecked())
    g_autoPlaySetting:set('stop_condition_dragon_inventory_max', vars['autoStartBtn3']:isChecked())
    g_autoPlaySetting:set('stop_condition_rune_inventory_max', vars['autoStartBtn4']:isChecked())
    g_autoPlaySetting:set('stop_condition_find_rel_dungeon', vars['autoStartBtn5']:isChecked())

    g_autoPlaySetting:set('dragon_atk_skill', self.m_radioButton_dragonAtkSkill.m_selectedButton)
    g_autoPlaySetting:set('dragon_heal_skill', self.m_radioButton_dragonHealSkill.m_selectedButton)

    g_autoPlaySetting:setAutoPlay(vars['autoStartOnBtn']:isChecked())

    PARENT.close(self)
end


--@CHECK
UI:checkCompileError(UI_AutoPlaySettingPopup)
