local PARENT = UI

-------------------------------------
-- class UI_SettingPopup
-------------------------------------
UI_SettingPopup = class(PARENT, {
        m_currTap = 'string',
        m_bRestart = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SettingPopup:init()
    local vars = self:load('setting_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SettingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:init_Dev()
    self:refresh()
end

-------------------------------------
-- function close
-------------------------------------
function UI_SettingPopup:close()
    if (self.m_bRestart == true) then
        local function ok_cb()
            restart()
        end
        MakeSimplePopup(POPUP_TYPE.OK, Str('변경사항 적용을 위해 게임을 재시작합니다.'), ok_cb)
        return    
    end
    
    PARENT.close(self)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SettingPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SettingPopup:initButton()
    local vars = self.vars

    -- 탭 버튼
    vars['infoTab']:registerScriptTapHandler(function() self:click_tap('info') end)
    vars['setTab']:registerScriptTapHandler(function() self:click_tap('set') end)
    vars['devTab']:registerScriptTapHandler(function() self:click_tap('dev') end)

    do -- 정보(info)
        vars['clearBtn']:registerScriptTapHandler(function() self:click_clearBtn() end)
    end

    do -- 설정(set)
        vars['lowResModeBtn']:registerScriptTapHandler(function() self:click_lowResModeBtn() end)
        vars['bgmBtn']:registerScriptTapHandler(function() self:click_bgmBtn() end)
        vars['sfxBtn']:registerScriptTapHandler(function() self:click_sfxBtn() end)
        vars['invenBtn']:registerScriptTapHandler(function() self:click_invenBtn() end)
    end

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SettingPopup:refresh()
    local vars = self.vars
    if (not self.m_currTap) then
         self.m_currTap = 'info'
    end

    vars['infoNode']:setVisible(false)
    vars['setNode']:setVisible(false)
    vars['devNode']:setVisible(false)
    vars[self.m_currTap .. 'Node']:setVisible(true)

    if (self.m_currTap == 'info') then
        self:refresh_infoTap()

    elseif (self.m_currTap == 'set') then
        self:refresh_setTap()

    elseif (self.m_currTap == 'dev') then
        self:refresh_devTap()

    end
end

-------------------------------------
-- function refresh_infoTap
-- @brief "정보" 탭
-------------------------------------
function UI_SettingPopup:refresh_infoTap()
    local vars = self.vars

    local uid = g_userData:get('uid')
    local nickname = g_userData:get('nickname') or g_serverData:get('local', 'idfa')
    local version_str = PatchData:getInstance():getAppVersionAndPatchIdxString()

    vars['userIdLabel']:setString(Str('유저 ID : ') .. uid)
    vars['userNameLabel']:setString(Str('닉네임 : ') .. nickname)
    vars['versionLabel']:setString(version_str)
end

-------------------------------------
-- function refresh_setTap
-- @brief "설정" 탭
-------------------------------------
function UI_SettingPopup:refresh_setTap()
    local vars = self.vars

    -- 저사양모드
    if g_serverData:get('local', 'lowResMode') then
        vars['lowResModeLabel']:setString('ON')
    else
        vars['lowResModeLabel']:setString('OFF')
    end

    -- 배경음
    if g_serverData:get('local', 'bgm') then
        vars['bgmLabel']:setString('ON')
    else
        vars['bgmLabel']:setString('OFF')
    end

    -- 효과음
    if g_serverData:get('local', 'sfx') then
        vars['sfxLabel']:setString('ON')
    else
        vars['sfxLabel']:setString('OFF')
    end
end

-------------------------------------
-- function click_tap
-------------------------------------
function UI_SettingPopup:click_tap(tap_type)
    self.m_currTap = tap_type
    self:refresh()
end

-------------------------------------
-- function click_lowResModeBtn
-------------------------------------
function UI_SettingPopup:click_lowResModeBtn()
    local value = g_serverData:get('local', 'lowResMode')
    g_serverData:applyServerData(not value, 'local', 'lowResMode')
    g_serverData:applySetting()
    self:refresh()
end

-------------------------------------
-- function click_bgmBtn
-------------------------------------
function UI_SettingPopup:click_bgmBtn()
    local value = g_serverData:get('local', 'bgm')
    g_serverData:applyServerData(not value, 'local', 'bgm')
    g_serverData:applySetting()
    self:refresh()
end

-------------------------------------
-- function click_sfxBtn
-------------------------------------
function UI_SettingPopup:click_sfxBtn()
    local value = g_serverData:get('local', 'sfx')
    g_serverData:applyServerData(not value, 'local', 'sfx')
    g_serverData:applySetting()
    self:refresh()
end

-------------------------------------
-- function click_invenBtn
-------------------------------------
function UI_SettingPopup:click_invenBtn()
    UI_InvenDevApiPopup()
end

-------------------------------------
-- function click_clearBtn
-------------------------------------
function UI_SettingPopup:click_clearBtn()
    local ask_popup
    local request
    local claer

    -- 1. 계정 초기화 여부를 물어보는 팝업
    ask_popup = function()
        local ok_btn_cb = function()
            request()
        end
    
        local cancel_btn_cb = nil

        local msg = Str('{@BLACK}' .. '계정을 초기화하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb, cancel_btn_cb)
    end

    -- 2. 네트워크 통신
    request = function()
        local uid = g_userData:get('uid')
        local success_cb = claer

        local ui_network = UI_Network()
        ui_network:setUrl('/manage/delete_user')
        ui_network:setParam('uid', uid)
        ui_network:setSuccessCB(success_cb)
        ui_network:setRevocable(true)
        ui_network:setMethod('GET')
        ui_network:setHmac(false)
        ui_network:request()
    end

    -- 3. 로컬 세이브 데이터 삭제 후 어플 재시작
    claer = function()
        ServerData:getInstance():clearServerDataFile()
        UserData:getInstance():clearServerDataFile()

        -- AppDelegate_Custom.cpp에 구현되어 있음
        restart()
    end
    
    ask_popup()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SettingPopup:click_closeBtn()
    self:close()
end

--@CHECK