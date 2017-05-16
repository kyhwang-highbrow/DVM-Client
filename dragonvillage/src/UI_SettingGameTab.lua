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

    vars['languageBtn']:registerScriptTapHandler(function() self:click_languageBtn() end)

    -- 연출
    vars['directOnBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)
    vars['directOffBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)

    -- 시나리오 재생 설정
    self:init_scenarioPlayerSetting()
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

    if g_serverData:get('local', 'bgm') then
        radio_button:setSelectedButton('on')
    else
        radio_button:setSelectedButton('off')
    end

    local function change_cb(selected)
        if (selected == 'on') then
            g_serverData:applyServerData(true, 'local', 'bgm')
        elseif (selected == 'off') then
            g_serverData:applyServerData(false, 'local', 'bgm')
        end
        g_serverData:applySetting()
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

    if g_serverData:get('local', 'sfx') then
        radio_button:setSelectedButton('on')
    else
        radio_button:setSelectedButton('off')
    end

    local function change_cb(selected)
        if (selected == 'on') then
            g_serverData:applyServerData(true, 'local', 'sfx')
        elseif (selected == 'off') then
            g_serverData:applyServerData(false, 'local', 'sfx')
        end
        g_serverData:applySetting()
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

    if g_serverData:get('local', 'lowResMode') then
        radio_button:setSelectedButton('on')
    else
        radio_button:setSelectedButton('off')
    end

    local function change_cb(selected)
        if (selected == 'on') then
            g_serverData:applyServerData(true, 'local', 'lowResMode')
        elseif (selected == 'off') then
            g_serverData:applyServerData(false, 'local', 'lowResMode')
        end
        g_serverData:applySetting()
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
    local setting = g_localData:get('scenario_playback_rules')
    uic_sort_list:setSelectSortType(setting)

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        g_localData:applyLocalData(sort_type, 'scenario_playback_rules')
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)
end

-------------------------------------
-- function click_languageBtn
-- @brief
-------------------------------------
function UI_Setting:click_languageBtn()
    UIManager:toastNotificationRed(Str('"언어 설정"은 준비 중입니다.'))
end