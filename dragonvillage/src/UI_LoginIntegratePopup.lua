local PARENT = UI

-------------------------------------
-- class UI_LoginIntegratePopup
-- @brief 타이틀 화면의 신규 유저 대상 내부 UI, 로그인, 게스트 플레이 (드래곤 만나러 가기), 서버 기능 지원
-------------------------------------
UI_LoginIntegratePopup = class(PARENT,{
        m_ownerUI = 'UI_TitleScene',
        m_loadingUI = 'UI_TitleSceneLoading',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoginIntegratePopup:init(owner_ui)
    -- uifile : title.ui
    self.m_ownerUI = owner_ui
    self.vars = owner_ui.vars

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_loadingUI = owner_ui.m_loadingUI
    self.m_loadingUI:hideLoading()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoginIntegratePopup:initUI()
    local vars = self.vars

    vars['newLoginMenu']:setVisible(true)
    vars['guestBtn']:setVisible(true)
    vars['loginBtn']:setVisible(true)
    vars['serverBtn']:setVisible(true)
end

-------------------------------------
-- function close
-------------------------------------
function UI_LoginIntegratePopup:close()
    local vars = self.vars

    vars['newLoginMenu']:setVisible(false)
    vars['guestBtn']:setVisible(false)
    vars['loginBtn']:setVisible(false)
    vars['serverBtn']:setVisible(false)

    if (self.m_closeCB) then
        self.m_closeCB()
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LoginIntegratePopup:initButton()
    local vars = self.vars
    
    vars['guestBtn']:registerScriptTapHandler(function() self:click_guestBtn() end)
    vars['loginBtn']:registerScriptTapHandler(function() self:click_loginBtn() end)
    vars['serverBtn']:registerScriptTapHandler(function() self:click_serverBtn() end)

    vars['testmodeBtn']:registerScriptTapHandler(function() self:click_testmodeBtn() end)
end

-------------------------------------
-- function click_guestBtn
-------------------------------------
function UI_LoginIntegratePopup:click_guestBtn()
   self.m_loadingUI:showLoading(Str('로그인 중...'))

   PerpleSDK:loginAnonymously(function(ret, info)
        self.m_loadingUI:hideLoading()
        if ret == 'success' then
            cclog('Firebase Guest login was successful.')
            self:loginSuccess(info)
            self:close()
        elseif ret == 'fail' then
            self:loginFail(info)
        end
    end)
end

-------------------------------------
-- function click_loginBtn
-------------------------------------
function UI_LoginIntegratePopup:click_loginBtn()
    local ui_login_popup = UI_LoginPopup(self.m_ownerUI)
    local cb_close = function(is_back_key)
        if (is_back_key) then
            self:refresh()
        else
            self:close()
        end
    end

    ui_login_popup:setCloseCB(cb_close)

end

-------------------------------------
-- function click_serverBtn
-------------------------------------
function UI_LoginIntegratePopup:click_serverBtn()
    local function onFinish(name)        
        ServerListData:getInstance():selectServer(name)
        self:refresh()
    end
    
    UI_SelectServerPopup(onFinish)
end

-------------------------------------
-- function setServerName
-------------------------------------
function UI_LoginIntegratePopup:setServerName(name)
    local vars = self.vars
    vars['serverLabel']:setString(string.upper(name))
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoginIntegratePopup:refresh()
    local vars = self.vars
    local target_server = ServerListData:getInstance():getSelectServer()
    self:setServerName(target_server)

    
    local is_new_server = (target_server == SERVER_NAME.EUROPE)
    self.vars['serverRewardMenu']:setVisible(is_new_server)

    if IS_TEST_MODE() then
        if (target_server == 'DEV') or (target_server == 'QA') then
            vars['testmodeBtn']:setVisible(true)
        else
            vars['testmodeBtn']:setVisible(false)
        end        
    end
end

-------------------------------------
-- function loginSuccess
-------------------------------------
function UI_LoginIntegratePopup:loginSuccess(info)
    local t_info = dkjson.decode(info)
    local fuid = t_info.fuid
    local push_token = t_info.pushToken
    local platform_id = t_info.providerId
    local account_info = t_info.name

    cclog('fuid: ' .. tostring(fuid))
    cclog('push_token: ' .. tostring(push_token))
    cclog('platform_id:' .. tostring(platform_id))
    cclog('account_info:' .. tostring(account_info))

    g_localData:applyLocalData(fuid, 'local', 'uid')
    g_localData:applyLocalData(push_token, 'local', 'push_token')
    g_localData:applyLocalData(platform_id, 'local', 'platform_id')
    g_localData:applyLocalData(account_info, 'local', 'account_info')

    if platform_id == 'google.com' then
		if (t_info['google'] and t_info['google']['playServicesConnected']) then
			g_localData:setGooglePlayConnected(true)
		end
    else
        g_localData:setGooglePlayConnected(false)
    end

    --선택 서버 저장
    g_localData:lockSaveData()
    g_localData:setServerName( ServerListData:getInstance():getSelectServer() )
    g_localData:unlockSaveData()

    -- 혹시 시스템 오류로 멀티연동이 된 경우 현재 로그인한 플랫폼 이외의 연결은 해제한다.
    UnlinkBrokenPlatform(t_info, platform_id)
end

-------------------------------------
-- function loginFail
-------------------------------------
function UI_LoginIntegratePopup:loginFail(info)
    PerpleSdkManager:makeErrorPopup(info)
end

-------------------------------------
-- function click_exitBtn
-- @brief 종료
-------------------------------------
function UI_LoginIntegratePopup:click_exitBtn()
    local function yes_cb()
        closeApplication()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('종료하시겠습니까?'), yes_cb)
end

-------------------------------------
-- function click_testmodeBtn
-------------------------------------
function UI_LoginIntegratePopup:click_testmodeBtn()
    local ui = UI_LoginPopupWithoutFirebase()
    ui:setCloseCB(function()
        self:close()
    end)
end

--@CHECK
UI:checkCompileError(UI_LoginIntegratePopup)