local PARENT = class(UI, ITabUI:getCloneTable(), IEventDispatcher:getCloneTable())

-------------------------------------
-- class UI_AutoPlaySettingPopup
-------------------------------------
UI_AutoPlaySettingPopup = class(PARENT, {
		m_gameMode = '',
    })

UI_AutoPlaySettingPopup.TAB_SKILL = 1
UI_AutoPlaySettingPopup.TAB_CONTINUOUS_BATTLE = 2

-------------------------------------
-- function init
-------------------------------------
function UI_AutoPlaySettingPopup:init(game_mode)
    local vars = self:load('battle_ready_auto_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AutoPlaySettingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

	self.m_gameMode = game_mode

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_autoStartOnBtn
-------------------------------------
function UI_AutoPlaySettingPopup:click_autoStartOnBtn()
    local vars = self.vars
    if (vars['autoStartOnBtn']:isChecked()) then
        self:close()
    end
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

	-- 고대의탑 분기처리
	if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
		vars['autoMenu4']:setVisible(true)
		vars['autoMenu5']:setVisible(false)
		vars['autoMenu3']:setVisible(false)

    -- 콜로세움 분기처리
	elseif (self.m_gameMode == GAME_MODE_ARENA) then
        vars['autoMenu2']:setVisible(false)
		vars['autoMenu4']:setVisible(false)
		vars['autoMenu5']:setVisible(false)
        vars['autoMenu6']:setVisible(true)
		vars['autoMenu3']:setVisible(false)

	else
		vars['autoMenu4']:setVisible(false)
		vars['autoMenu5']:setVisible(true)

		-- 쫄작(farming) 기능
		vars['autoMenu3']:setVisible(self.m_gameMode == GAME_MODE_ADVENTURE)

	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AutoPlaySettingPopup:initButton(t_user_info)
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

	-- common
    vars['autoStartBtn1']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn2']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn1'] = UIC_CheckBox(vars['autoStartBtn1'].m_node, vars['autoStartSprite1'], true)
    vars['autoStartBtn2'] = UIC_CheckBox(vars['autoStartBtn2'].m_node, vars['autoStartSprite2'], false)
    
	-- tower
    vars['autoStartBtn4']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn5']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn4'] = UIC_CheckBox(vars['autoStartBtn4'].m_node, vars['autoStartSprite4'], false)
    vars['autoStartBtn5'] = UIC_CheckBox(vars['autoStartBtn5'].m_node, vars['autoStartSprite5'], false)  

	-- farming
	vars['autoStartBtn3']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
	vars['autoStartBtn3'] = UIC_CheckBox(vars['autoStartBtn3'].m_node, vars['autoStartSprite3'], false)

	-- main
    vars['autoStartOnBtn'] = UIC_CheckBox(vars['autoStartOnBtn'].m_node, vars['autoStartOnSprite'], false)
    vars['autoStartOnBtn']:registerScriptTapHandler(function() self:click_autoStartOnBtn() end)
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_AutoPlaySettingPopup:refresh(t_user_info)
    local vars = self.vars

	-- common
    vars['autoStartBtn1']:setChecked(g_autoPlaySetting:get('stop_condition_lose'))
    vars['autoStartBtn2']:setChecked(g_autoPlaySetting:get('stop_condition_dragon_lv_max'))

	-- tower
    vars['autoStartBtn4']:setChecked(g_autoPlaySetting:get('tower_next_floor'))
    vars['autoStartBtn5']:setChecked(g_autoPlaySetting:get('stop_condition_find_rel_dungeon'))
	
	-- farming
	vars['autoStartBtn3']:setChecked(g_autoPlaySetting:get('dragon_farming_mode'))
	 
    vars['autoStartOnBtn']:setChecked(g_autoPlaySetting:isAutoPlay())
end

-------------------------------------
-- function close
-------------------------------------
function UI_AutoPlaySettingPopup:close()
    local vars = self.vars

	-- common
    g_autoPlaySetting:set('stop_condition_lose', vars['autoStartBtn1']:isChecked())
    g_autoPlaySetting:set('stop_condition_dragon_lv_max', vars['autoStartBtn2']:isChecked())
    
	-- tower
    g_autoPlaySetting:set('tower_next_floor', vars['autoStartBtn4']:isChecked())
    g_autoPlaySetting:set('stop_condition_find_rel_dungeon', vars['autoStartBtn5']:isChecked())

	-- farming
	g_autoPlaySetting:set('dragon_farming_mode', vars['autoStartBtn3']:isChecked())
    
	g_autoPlaySetting:setAutoPlay(vars['autoStartOnBtn']:isChecked())

	if (g_gameScene) then
		g_gameScene:getGameWorld():dispatch('farming_changed')
	end
	
    PARENT.close(self)
end


--@CHECK
UI:checkCompileError(UI_AutoPlaySettingPopup)
