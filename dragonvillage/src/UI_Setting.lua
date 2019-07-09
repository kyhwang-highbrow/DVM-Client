local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_Setting
-------------------------------------
UI_Setting = class(PARENT, {
        m_loadingUI = 'UI_TitleSceneLoading',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Setting:init()
	-- @mskim 해외 빌드 분기 처리
    local vars = self:load('setting_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Setting')

    -- @UI_ACTION
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_loadingUI = UI_TitleSceneLoading()
    self.m_loadingUI:hideLoading()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Setting:initUI()
    local vars = self.vars
    self:initTab()

    -- 테스트 모드 버튼
    if CppFunctionsClass:isTestMode() then
        vars['testModeBtn']:setVisible(true)
        local local_test_mode = g_settingData:get('test_mode')
        if (local_test_mode == nil) then
            local_test_mode = true
        end

        -- 활성 여부 출력
        if (local_test_mode == true) then
            vars['testModeLabel']:setString('테스트 모드 off')
        else
            vars['testModeLabel']:setString('테스트 모드 on')
        end
        
        -- 버튼 설정
        local function click()
            local function ok_cb()
                g_settingData:applySettingData(not local_test_mode, 'test_mode')
                CppFunctions:restart()
            end
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('설정을 변경하면 앱이 재시작됩니다.\n진행하시겠습니까?'), ok_cb)
        end
        vars['testModeBtn']:registerScriptTapHandler(click)
    else
        vars['testModeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Setting:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Setting:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Setting:click_closeBtn()
    self:close()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Setting:initTab()
    local vars = self.vars

    local tab_list = {}
    table.insert(tab_list, 'game')
    table.insert(tab_list, 'account')
    table.insert(tab_list, 'info')
    
    if (IS_TEST_MODE()) then
        table.insert(tab_list, 'dev')
        vars['devTabBtn']:setVisible(true)
    else
        vars['devTabBtn']:setVisible(false)
        vars['devMenu']:setVisible(false)
    end
    
    for i,v in ipairs(tab_list) do
        local key = v
        local menu = vars[v .. 'Menu']
        self:addTabAuto(key, vars, menu)
    end
    
    self:setTab('game')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Setting:onChangeTab(tab, first)
    if first then
        local func_name = 'init_' .. tab .. 'Tab'
        self[func_name](self)
    end
end


-------------------------------------
-- function checkGameLanguage
-- @brief 기기 언어와 게임 언어가 다르고
--        기기 언어가 지원하는 언어일 경우
--        언어 변경 안내
-------------------------------------
function UI_Setting:checkGameLanguage(close_cb)

    local language_verification_complete = g_settingData:get('language_verification_complete')
    if (language_verification_complete == true) then
        return
    end

    local game_lang = Translate:getGameLang()
    local device_lang = Translate:getDeviceLang()

    cclog('# game_lang : ' .. game_lang)
    cclog('# device_lang : ' .. device_lang)

    -- 언어가 같은 경우 skip
    if (game_lang == device_lang) then
        return
    end


    -- 기기 언어가 지원하지 않는 게임 언어일 경우 skip
    if (Translate:isSupportedLanguage(device_lang) == false) then
        return
    end    

    local make_info_popup
    local make_setting_popup

    -- 안내 팝업
    make_info_popup = function()
        local msg = Str('설정에서 게임 언어를 변경할 수 있습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, make_setting_popup)
    end

    -- [설정]-[게임]-[언어 선택]
    make_setting_popup = function()
        local ui = UI_Setting()
        ui:setTab('game')
        ui:click_languageBtn()
        ui:setCloseCB(close_cb)
        g_settingData:applySettingData(true, 'language_verification_complete')
    end

    make_info_popup()
    return true
end