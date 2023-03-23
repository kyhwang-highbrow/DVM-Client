-------------------------------------
-- function init_gameTab
-------------------------------------
function UI_Setting:init_gameTab()
    local vars = self.vars

    -- 배경음
    self:init_bgmSetting()

    -- 효과음
    self:init_sfxSetting()

    -- 저사양 모드
    self:init_lowResModeSetting()

    -- 화면 흔들림
    self:init_shakeModeSetting()

    vars['languageBtn']:registerScriptTapHandler(function() self:click_languageBtn() end)

    -- 연출
    vars['directOnBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)
    vars['directOffBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)

    -- 채팅 on/off
    self:init_chatSetting()

    -- 푸시 on/off
    self:init_notification()

    -- 절전모드 설정
    self:init_sleepModeSetting()

    -- 시나리오 재생 설정
    self:init_scenarioPlayerSetting()

    -- 시나리오 다시보기
    vars['replayBtn']:registerScriptTapHandler(function() self:click_replayBtn() end)

	-- 언어
	self:init_language()
end

-------------------------------------
-- function init_bgmSetting
-- @brief 배경음 설정
-------------------------------------
function UI_Setting:init_bgmSetting()
    local vars = self.vars

    local radio_button = UIC_RadioButton()
    radio_button:addButton('on', vars['bgmOnBtn'])
    radio_button:addButton('off', vars['bgmOffBtn'])

    if g_settingData:get('bgm') then
        radio_button:setSelectedButton('on')
    else
        radio_button:setSelectedButton('off')
    end

    local function change_cb(selected)
        if (selected == 'on') then
            g_settingData:applySettingData(true, 'bgm')
        elseif (selected == 'off') then
            g_settingData:applySettingData(false, 'bgm')
        end
        g_settingData:applySetting()
    end

    radio_button:setChangeCB(change_cb)
end

-------------------------------------
-- function init_sfxSetting
-- @brief 효과음 설정
-------------------------------------
function UI_Setting:init_sfxSetting()
    local vars = self.vars

    local radio_button = UIC_RadioButton()
    radio_button:addButton('on', vars['effectOnBtn'])
    radio_button:addButton('off', vars['effectOffBtn'])

    if g_settingData:get('sfx') then
        radio_button:setSelectedButton('on')
    else
        radio_button:setSelectedButton('off')
    end

    local function change_cb(selected)
        if (selected == 'on') then
            g_settingData:applySettingData(true, 'sfx')
        elseif (selected == 'off') then
            g_settingData:applySettingData(false, 'sfx')
        end
        g_settingData:applySetting()
    end

    radio_button:setChangeCB(change_cb)
end

-------------------------------------
-- function init_lowResModeSetting
-- @brief 저사양 모드
-------------------------------------
function UI_Setting:init_lowResModeSetting()
    local vars = self.vars

    local radio_button = UIC_RadioButton()
    radio_button:addButton('on', vars['lowQualOnBtn'])
    radio_button:addButton('off', vars['lowQualOffBtn'])

    if g_settingData:get('lowResMode') then
        radio_button:setSelectedButton('on')
    else
        radio_button:setSelectedButton('off')
    end

    local function change_cb(selected)
        if (selected == 'on') then
            g_settingData:applySettingData(true, 'lowResMode')
        elseif (selected == 'off') then
            g_settingData:applySettingData(false, 'lowResMode')
        end
        g_settingData:applySetting()
    end

    radio_button:setChangeCB(change_cb)
end

-------------------------------------
-- function init_shakeModeSetting
-- @brief 화면 흔들림
-------------------------------------
function UI_Setting:init_shakeModeSetting()
    local vars = self.vars
    
    local radio_button = UIC_RadioButton()
    radio_button:addButton('on', vars['shakeOnBtn'])
    radio_button:addButton('off', vars['shakeOffBtn'])

    if g_settingData:get('shake_mode') then
        radio_button:setSelectedButton('on')
    else
        radio_button:setSelectedButton('off')
    end

    local function change_cb(selected)
        if (selected == 'on') then
            g_settingData:applySettingData(true, 'shake_mode')
        elseif (selected == 'off') then
            g_settingData:applySettingData(false, 'shake_mode')
        end
    end

    radio_button:setChangeCB(change_cb)

end
-------------------------------------
-- function init_chatSetting
-- @brief 채팅 on/off
-------------------------------------
function UI_Setting:init_chatSetting()
    local vars = self.vars

    local radio_button = UIC_RadioButton()
    radio_button:addButton('on', vars['chatOnBtn'])
    radio_button:addButton('off', vars['chatOffBtn'])

    if g_chatIgnoreList:isGlobalIgnore() then
        radio_button:setSelectedButton('off')
    else
        radio_button:setSelectedButton('on')
    end

    local function change_cb(selected)
        if (selected == 'on') then
            g_chatIgnoreList:setGlobalIgnore(false)
        elseif (selected == 'off') then
            g_chatIgnoreList:setGlobalIgnore(true)
        end
    end

    radio_button:setChangeCB(change_cb)
end

-------------------------------------
-- function init_notification
-- @brief 푸시 On/Off
-------------------------------------
function UI_Setting:init_notification()
    local vars = self.vars

    local radio_button = UIC_RadioButton()
    radio_button:addButton('on', vars['pushOnBtn'])
    radio_button:addButton('off', vars['pushOffBtn'])

    local push_all = g_settingData:getCloudSetting('push_all')
    if (push_all == true) then
        radio_button:setSelectedButton('on')
    else
        radio_button:setSelectedButton('off')
    end

    local function func_android_permission()
        SDKManager:checkAndroidPushPermission(function ()
        end)
    end

    local function change_cb(selected)
        local pushToken = g_localData:get('local', 'push_token')
        --local game_push = 1 -- 1(on) or 0(off)
        --if (selected == 'off') then
        --    game_push = 0
        --end
        local game_push = 1
        local push_all = true
        if (selected == 'off') then
            push_all = false
            game_push = 0
        end

        Network_platform_registerToken(game_push, pushToken)

        if push_all == true then
            g_settingData:request_setSetting(push_all, func_android_permission)
        else
            g_settingData:request_setSetting(push_all)
        end
        
        g_localData:applyLocalData(game_push, 'push_state')
    end

    radio_button:setChangeCB(change_cb)
end

-------------------------------------
-- function init_sleepModeSetting
-- @brief 절전모드 On/Off
-------------------------------------
function UI_Setting:init_sleepModeSetting()
    local vars = self.vars

    local radio_button = UIC_RadioButton()
    radio_button:addButton('on', vars['sleepOnBtn'])
    radio_button:addButton('off', vars['sleepOffBtn'])

    if g_settingData:isSleepMode() then
        radio_button:setSelectedButton('on')
    else
        radio_button:setSelectedButton('off')
    end

    local function change_cb(selected)
        if (selected == 'on') then
            g_settingData:setSleepMode(true)
        elseif (selected == 'off') then
            g_settingData:setSleepMode(false)
        end

        g_settingData:applySetting()
    end

    radio_button:setChangeCB(change_cb)
end

-------------------------------------
-- function init_scenarioPlayerSetting
-- @brief 시나리오 재생 설정
-------------------------------------
function UI_Setting:init_scenarioPlayerSetting()
    local vars = self.vars

    local uic_sort_list = MakeUICSortList_scenarioPlayerSetting(vars['scenarioBtn'], vars['scenarioLabel'], 'first')
    
    -- 초기 선택 덱 설정
    local setting = g_settingData:get('scenario_playback_rules')
    uic_sort_list:setSelectSortType(setting)

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        g_settingData:applySettingData(sort_type, 'scenario_playback_rules')
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)
end

-------------------------------------
-- function init_language
-- @brief 현재 언어
-------------------------------------
function UI_Setting:init_language()
	local lang = Translate:getGameLang()
	local lang_str = Translate:getLangStrTable()[lang]
	self.vars['languageLabel']:setString(lang_str)
end

-------------------------------------
-- function click_languageBtn
-- @brief
-------------------------------------
function UI_Setting:click_languageBtn()
	local function change_lang()
		--local is_use_loading = true
		--local scene = SceneLobby(is_use_loading)
		--scene:runScene()
        CppFunctionsClass:restart()
	end

    UI_SelectLanguagePopup(change_lang)
end

-------------------------------------
-- function click_replayBtn
-- @brief
-------------------------------------
function UI_Setting:click_replayBtn()
    UI_ScenarioReplay()
end