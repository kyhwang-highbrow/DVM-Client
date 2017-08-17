-------------------------------------
-- function init_accounteTab
-------------------------------------
function UI_Setting:init_accountTab()
    local vars = self.vars

    vars['copyBtn']:registerScriptTapHandler(function() self:click_copyBtn() end)

    vars['facebookBtn']:registerScriptTapHandler(function() self:click_facebookBtn() end)
    vars['gamecenterBtn']:registerScriptTapHandler(function() self:click_gamecenterBtn() end)
    vars['googleBtn']:registerScriptTapHandler(function() self:click_googleBtn() end)

    vars['clearBtn']:registerScriptTapHandler(function() self:click_clearBtn() end)
    vars['logoutBtn']:registerScriptTapHandler(function() self:click_logoutBtn() end)

    vars['gamecenterBtn']:setVisible(isIos())
    vars['googleBtn']:setVisible(isAndroid() or isWin32())

    self:updateInfo()
end

-------------------------------------
-- function click_copyBtn
-------------------------------------
function UI_Setting:click_copyBtn()
    local recovery_code = g_serverData:get('local', 'recovery_code')

    SDKManager:copyOntoClipBoard(tostring(recovery_code))
    UIManager:toastNotificationGreen(Str('복구코드를 복사하였습니다.'))
end

-------------------------------------
-- function click_gamecenterBtn
-------------------------------------
function UI_Setting:click_gamecenterBtn()
    if isWin32() then
        UIManager:toastNotificationRed(Str('Windows에서는 동작하지 않습니다.'))
        return
    end

    self.m_loadingUI:showLoading(Str('계정 연결 중...'))

    local old_platform_id = g_serverData:get('local', 'platform_id')

    PerpleSDK:linkWithGameCenter('http://dev.platform.perplelab.com/1003/user/customToken', function(ret, info)

        if ret == 'success' then

            cclog('Firebase GameCenter link was successful.')
            self:loginSuccess(info)

            -- 기존 구글 연결은 끊는다.
            if old_platform_id == 'google.com' then
                local app_ver = getAppVer()
                if app_ver == '0.2.2' then
                    PerpleSDK:googleLogout()
                else
                    PerpleSDK:googleLogout(1)
                end
                PerpleSDK:unlinkWithGoogle(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase unlink from Google was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Google failed.')
                    end
                end)
            -- 기존 페이스북 연결은 끊는다.
            elseif old_platform_id == 'facebook.com' then
                PerpleSDK:unlinkWithFacebook(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase unlink from Facebook was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Facebook failed.')
                    end
                end)
            else
                self.m_loadingUI:hideLoading()
            end

        elseif ret == 'already_in_use' then

            local ok_btn_cb = function()
                self.m_loadingUI:showLoading(Str('계정 전환 중...'))
                PerpleSDK:logout()
                PerpleSDK:loginWithGameCenter('http://dev.platform.perplelab.com/1003/user/customToken', function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase GameCenter link was successful.(already_in_use)')

                        self:loginSuccess(info)

                        if (old_platform_id == 'google.com') then
                            local app_ver = getAppVer()
                            if app_ver == '0.2.2' then
                                PerpleSDK:googleLogout()
                            else
                                PerpleSDK:googleLogout(1)
                            end
                        end

                        -- 앱 재시작
                        restart()

                    elseif ret == 'fail' then
                        local t_info = dkjson.decode(info)
                        local msg = t_info.msg
                        cclog('Firebase unknown error !!!- ' .. msg)
                    elseif ret == 'cancel' then
                        cclog('Firebase unknown error !!!')
                    end
                end)
            end

            local cancel_btn_cb = nil

            self.m_loadingUI:hideLoading()
            local msg = Str('이미 연결되어 있는 계정입니다.\n계정에 연결되어 있는 기존의 게임 데이터를 불러오시겠습니까?')
            local submsg = Str('현재의 게임데이터는 유실되므로 주의바랍니다.\n만약을 대비하여 복구코드를 메모해 두시기 바랍니다.')
            MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb, cancel_btn_cb)

        elseif ret == 'fail' then

            local t_info = dkjson.decode(info)
            local msg = t_info.msg
            cclog('Firebase GameCenter link failed - ' .. msg)

            self.m_loadingUI:hideLoading()
            MakeSimplePopup(POPUP_TYPE.OK, msg)

        elseif ret == 'cancel' then

            cclog('Firebase GameCenter link canceled.')
            self.m_loadingUI:hideLoading()

        end
    end)

end

-------------------------------------
-- function click_facebookBtn
-------------------------------------
function UI_Setting:click_facebookBtn()
    if isWin32() then
        UIManager:toastNotificationRed(Str('Windows에서는 동작하지 않습니다.'))
        return
    end

    self.m_loadingUI:showLoading(Str('계정 연결 중...'))

    local old_platform_id = g_serverData:get('local', 'platform_id')

    PerpleSDK:linkWithFacebook(function(ret, info)

        if ret == 'success' then

            cclog('Firebase Facebook link was successful.')
            self:loginSuccess(info)

            -- 기존 구글 연결은 끊는다.
            if old_platform_id == 'google.com' then
                local app_ver = getAppVer()
                if app_ver == '0.2.2' then
                    PerpleSDK:googleLogout()
                else
                    PerpleSDK:googleLogout(1)
                end
                PerpleSDK:unlinkWithGoogle(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase unlink from Google was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Google failed.')
                    end
                end)
            -- 기존 게임센터 연결은 끊는다.
            elseif old_platform_id == 'gamecenter' then
                PerpleSDK:unlinkWithGameCenter(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase unlink from GameCenter was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from GameCenter failed.')
                    end
                end)
            else
                self.m_loadingUI:hideLoading()
            end

        elseif ret == 'already_in_use' then

            local ok_btn_cb = function()
                self.m_loadingUI:showLoading(Str('계정 전환 중...'))
                PerpleSDK:logout()
                PerpleSDK:loginWithFacebook(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase Facebook link was successful.(already_in_use)')

                        self:loginSuccess(info)

                        if (old_platform_id == 'google.com') then
                            local app_ver = getAppVer()
                            if app_ver == '0.2.2' then
                                PerpleSDK:googleLogout()
                            else
                                PerpleSDK:googleLogout(1)
                            end
                        end

                        -- 앱 재시작
                        restart()

                    elseif ret == 'fail' then
                        local t_info = dkjson.decode(info)
                        local msg = t_info.msg
                        cclog('Firebase unknown error !!!- ' .. msg)
                    elseif ret == 'cancel' then
                        cclog('Firebase unknown error !!!')
                    end
                end)
            end

            local cancel_btn_cb = nil

            self.m_loadingUI:hideLoading()
            local msg = Str('이미 연결되어 있는 계정입니다.\n계정에 연결되어 있는 기존의 게임 데이터를 불러오시겠습니까?')
            local submsg = Str('현재의 게임데이터는 유실되므로 주의바랍니다.\n만약을 대비하여 복구코드를 메모해 두시기 바랍니다.')
            MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb, cancel_btn_cb)

        elseif ret == 'fail' then

            local t_info = dkjson.decode(info)
            local msg = t_info.msg
            cclog('Firebase Facebook link failed - ' .. msg)

            self.m_loadingUI:hideLoading()
            MakeSimplePopup(POPUP_TYPE.OK, msg)

        elseif ret == 'cancel' then

            cclog('Firebase Facebook link canceled.')
            self.m_loadingUI:hideLoading()

        end
    end)

end

-------------------------------------
-- function click_googleBtn
-------------------------------------
function UI_Setting:click_googleBtn()
    if isWin32() then
        UIManager:toastNotificationRed(Str('Windows에서는 동작하지 않습니다.'))
        return
    end

    self.m_loadingUI:showLoading(Str('계정 연결 중...'))

    local old_platform_id = g_serverData:get('local', 'platform_id')

    PerpleSDK:linkWithGoogle(function(ret, info)
        if ret == 'success' then

            cclog('Firebase Google link was successful.')
            self:loginSuccess(info)

            -- 기존 페이스북 연결은 끊는다.
            if old_platform_id == 'facebook.com' then
                PerpleSDK:unlinkWithFacebook(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase unlink from Facebook was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Facebook failed.')
                    end
                end)
            -- 기존 게임센터 연결은 끊는다.
            elseif old_platform_id == 'gamecenter' then
                PerpleSDK:unlinkWithGameCenter(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase unlink from GameCenter was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from GameCenter failed.')
                    end
                end)
            else
                self.m_loadingUI:hideLoading()
            end

            -- 구글 계정을 사용하지 않다가 최초 연동 시 업적을 한번 체크하여 클리어 하도록 한다.
            GoogleHelper.allAchievementCheck()

        elseif ret == 'already_in_use' then

            local ok_btn_cb = function()
                self.m_loadingUI:showLoading(Str('계정 전환 중...'))
                PerpleSDK:logout()
                PerpleSDK:loginWithGoogle(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase Google link was successful.(already_in_use)')

                        self:loginSuccess(info)

                        -- 앱 재시작
                        restart()

                    elseif ret == 'fail' then
                        local t_info = dkjson.decode(info)
                        local msg = t_info.msg
                        cclog('Firebase unknown error !!!- ' .. msg)
                    elseif ret == 'cancel' then
                        cclog('Firebase unknown error !!!')
                    end
                end)
            end
    
            local cancel_btn_cb = nil

            self.m_loadingUI:hideLoading()
            local msg = Str('이미 연결되어 있는 계정입니다.\n계정에 연결되어 있는 기존의 게임 데이터를 불러오시겠습니까?')
            local submsg = Str('현재의 게임데이터는 유실되므로 주의바랍니다.\n만약을 대비하여 복구코드를 메모해 두시기 바랍니다.')
            MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb, cancel_btn_cb)

        elseif ret == 'fail' then

            local t_info = dkjson.decode(info)
            local msg = t_info.msg
            cclog('Firebase Google link failed - ' .. msg)

            self.m_loadingUI:hideLoading()
            MakeSimplePopup(POPUP_TYPE.OK, msg)

        elseif ret == 'cancel' then

            cclog('Firebase Google link canceled.')
            self.m_loadingUI:hideLoading()

        end
    end)

end

-------------------------------------
-- function click_clearBtn
-------------------------------------
function UI_Setting:click_clearBtn()
    local ask_popup
    local request
    local clear

    -- 1. 계정 초기화 여부를 물어보는 팝업
    ask_popup = function()
        local ok_btn_cb = function()
            if IS_PERPLELAB_EVENT_MODE() then
                OpenPerplelabEventPopup()
                return
            end
            request()
        end
    
        local cancel_btn_cb = nil

        local msg = Str('계정을 초기화하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb, cancel_btn_cb)
    end

    -- 2. 네트워크 통신
    request = function()
        local uid = g_userData:get('uid')
        local success_cb = clear

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
    clear = function()
        removeLocalFiles()

        -- AppDelegate_Custom.cpp에 구현되어 있음
        restart()
    end
    
    ask_popup()
end

-------------------------------------
-- function click_logoutBtn
-------------------------------------
function UI_Setting:click_logoutBtn()
    local ask_popup
    local clear

    -- 1. 계정 초기화 여부를 물어보는 팝업
    ask_popup = function()
        local ok_btn_cb = function()
            if IS_PERPLELAB_EVENT_MODE() then
                OpenPerplelabEventPopup()
                return
            end

            if isWin32() then
                clear()
            else
                PerpleSDK:logout()

                local app_ver = getAppVer()
                if app_ver == '0.2.2' then
                    PerpleSDK:googleLogout()
                else
                    PerpleSDK:googleLogout(0)
                end

                PerpleSDK:facebookLogout()

                clear()
            end

        end
    
        local cancel_btn_cb = nil

        local msg = Str('로그아웃하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb, cancel_btn_cb)
    end

    -- 2. 로컬 세이브 데이터 삭제 후 어플 재시작
    clear = function()
        removeLocalFiles()

        -- AppDelegate_Custom.cpp에 구현되어 있음
        restart()
    end

    ask_popup()
end

-------------------------------------
-- function loginSuccess
-------------------------------------
function UI_Setting:loginSuccess(info)
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

    self:updateInfo()
end

-------------------------------------
-- function loginFail
-------------------------------------
function UI_Setting:loginFail(info)
    local t_info = dkjson.decode(info)
    local code = t_info.code
    local subcode = t_info.subcode
    local msg = t_info.msg

    MakeSimplePopup(POPUP_TYPE.OK, msg)
end

-------------------------------------
-- function updateInfo
-------------------------------------
function UI_Setting:updateInfo()

    local platform_id = g_serverData:get('local', 'platform_id') or 'firebase'
    local account_info = g_serverData:get('local', 'account_info') or 'Guest'
    local recovery_code = g_serverData:get('local', 'recovery_code')

    -- 버튼 상태 업데이트
    self.vars['googleBtn']:setEnabled(platform_id ~= 'google.com')
    self.vars['googleDisableSprite']:setVisible(platform_id == 'google.com')
    self.vars['facebookBtn']:setEnabled(platform_id ~= 'facebook.com')
    self.vars['facebookDisableSprite']:setVisible(platform_id == 'facebook.com')
    self.vars['gamecenterBtn']:setEnabled(platform_id ~= 'gamecenter')
    self.vars['gamecenterDisableSprite']:setVisible(platform_id == 'gamecenter')

    self.vars['accountLabel']:setString(account_info)
    self.vars['uidLabel']:setString(recovery_code)

    -- 계정 플랫폼 아이콘 표시
    self.vars['loginNode']:removeAllChildren()
    local sprite = nil
    if platform_id == 'google.com' then
        sprite = cc.Sprite:create('res/ui/icons/login_google.png')
    elseif platform_id == 'facebook.com' then
        sprite = cc.Sprite:create('res/ui/icons/login_facebook.png')
    elseif platform_id == 'gamecenter' then
        sprite = cc.Sprite:create('res/ui/icons/login_gamecenter.png')
    end

    if sprite then
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        self.vars['loginNode']:addChild(sprite)
    end

    -- dirty -> lobby btn state
    GoogleHelper.setDirty(true)
end
