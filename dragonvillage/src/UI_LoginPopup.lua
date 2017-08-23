local PARENT = UI

-------------------------------------
-- class UI_LoginPopup
-------------------------------------
UI_LoginPopup = class(PARENT,{
        m_loadingUI = 'UI_TitleSceneLoading',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoginPopup:init()
    local vars = self:load('login_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 없음
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LoginPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_loadingUI = UI_TitleSceneLoading()
    self.m_loadingUI:hideLoading()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoginPopup:initUI()
    local vars = self.vars
	--vars['facebookBtn'] -- Button
	--vars['gamecenterBtn'] -- Button
	--vars['googleBtn'] -- Button
	--vars['guestBtn'] -- Button
	--vars['closeBtn'] -- Button
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LoginPopup:initButton()
    local vars = self.vars
    self.vars['facebookBtn']:registerScriptTapHandler(function() self:click_facebookBtn() end)
    self.vars['gamecenterBtn']:registerScriptTapHandler(function() self:click_gamecenterBtn() end)
    self.vars['googleBtn']:registerScriptTapHandler(function() self:click_googleBtn() end)
    self.vars['guestBtn']:registerScriptTapHandler(function() self:click_guestBtn() end)

    self.vars['closeBtn']:setVisible(false)

    if isIos() then
        -- iOS
        self.vars['gamecenterBtn']:setVisible(true)
        self.vars['googleBtn']:setVisible(false)
    else
        -- Android, Win32
        self.vars['gamecenterBtn']:setVisible(false)
        self.vars['googleBtn']:setVisible(true)
    end

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoginPopup:refresh()
end

-------------------------------------
-- function click_exitBtn
-- @brief 종료
-------------------------------------
function UI_LoginPopup:click_exitBtn()
    local function yes_cb()
        closeApplication()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('종료하시겠습니까?'), yes_cb)
end

-------------------------------------
-- function click_facebookBtn
-------------------------------------
function UI_LoginPopup:click_facebookBtn()
    self.m_loadingUI:showLoading(Str('로그인 중...'))

    PerpleSDK:loginWithFacebook(function(ret, info)
        self.m_loadingUI:hideLoading()

        if ret == 'success' then
            cclog('Firebase Facebook login was successful.')
            self:loginSuccess(info)
            self:close()
        elseif ret == 'fail' then
            self:loginFail(info)
        elseif ret == 'cancel' then
        end
    end)

end

-------------------------------------
-- function click_gamecenterBtn
-------------------------------------
function UI_LoginPopup:click_gamecenterBtn()
    self.m_loadingUI:showLoading(Str('로그인 중...'))

    PerpleSDK:loginWithGameCenter(GetPlatformApiUrl() .. '/user/customToken', function(ret, info)
        self.m_loadingUI:hideLoading()

        if ret == 'success' then
            cclog('Firebase GameCenter login was successful.')
            self:loginSuccess(info)
            self:close()
        elseif ret == 'fail' then
            self:loginFail(info)
        elseif ret == 'cancel' then
        end
    end)

end

-------------------------------------
-- function click_googleBtn
-------------------------------------
function UI_LoginPopup:click_googleBtn()
    self.m_loadingUI:showLoading(Str('로그인 중...'))

    PerpleSDK:loginWithGoogle(function(ret, info)
        self.m_loadingUI:hideLoading()

        if ret == 'success' then
            cclog('Firebase Google login was successful.')
            self:loginSuccess(info)
            self:close()
        elseif ret == 'fail' then
            self:loginFail(info)
        elseif ret == 'cancel' then
        end
    end)

end

-------------------------------------
-- function click_guestBtn
-------------------------------------
function UI_LoginPopup:click_guestBtn()
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
-- function loginSuccess
-------------------------------------
function UI_LoginPopup:loginSuccess(info)
    local t_info = dkjson.decode(info)
    local fuid = t_info.fuid
    local push_token = t_info.pushToken
    local platform_id = t_info.providerId
    local account_info = t_info.name

    local app_ver = getAppVer()
    if app_ver == '0.2.2' then
        local idx = #t_info.providerData
        platform_id = t_info.providerData[idx].providerId
        account_info = 'Guest'
        if platform_id == 'google.com' then
            account_info = 'Google'
            if t_info.google then
                account_info = t_info.google.name or account_info
                end
        elseif platform_id == 'facebook.com' then
            account_info = 'Facebook'
            if t_info.facebook then
                account_info = t_info.facebook.name or account_info
            end
        end
    end

    cclog('fuid: ' .. tostring(fuid))
    cclog('push_token: ' .. tostring(push_token))
    cclog('platform_id:' .. tostring(platform_id))
    cclog('account_info:' .. tostring(account_info))

    g_serverData:applyServerData(fuid, 'local', 'uid')
    g_serverData:applyServerData(push_token, 'local', 'push_token')
    g_serverData:applyServerData(platform_id, 'local', 'platform_id')
    g_serverData:applyServerData(account_info, 'local', 'account_info')

    if platform_id == 'google.com' then
        g_serverData:applyServerData('on', 'local', 'googleplay_connected')
    else
        g_serverData:applyServerData('off', 'local', 'googleplay_connected')
    end

    -- 혹시 시스템 오류로 멀티연동이 된 경우 현재 로그인한 플랫폼 이외의 연결은 해제한다.
    UnlinkBrokenPlatform(t_info, platform_id)
end

-------------------------------------
-- function loginFail
-------------------------------------
function UI_LoginPopup:loginFail(info)
    local t_info = dkjson.decode(info)
    local code = t_info.code
    local subcode = t_info.subcode
    local msg = t_info.msg

    MakeSimplePopup(POPUP_TYPE.OK, msg)
end

--@CHECK
UI:checkCompileError(UI_LoginPopup)
