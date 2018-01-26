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
    vars['serverBtn']:registerScriptTapHandler(function() self:click_changeServer() end)

    self.vars['closeBtn']:setVisible(false)

    if isIos() then
        -- iOS
        self.vars['gamecenterBtn']:setVisible(true)

        local diff = 54
        local posXFacebookBtn = self.vars['facebookBtn']:getPositionX() - diff
        local posXGoogleBtn = self.vars['googleBtn']:getPositionX() - diff
        local posXgamecenterBtn = self.vars['gamecenterBtn']:getPositionX() + diff
        local posXguestBtn = self.vars['guestBtn']:getPositionX() + diff

        self.vars['facebookBtn']:setPositionX(posXFacebookBtn)
        self.vars['googleBtn']:setPositionX(posXGoogleBtn)
        self.vars['gamecenterBtn']:setPositionX(posXgamecenterBtn)
        self.vars['guestBtn']:setPositionX(posXguestBtn)
    else
        -- Android, Win32
        self.vars['gamecenterBtn']:setVisible(false)
    end

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoginPopup:refresh()    
    self:setServerName( ServerListData:getInstance():getSelectServer() )    
end

-------------------------------------
-- function setServerName
-------------------------------------
function UI_LoginPopup:setServerName(name)
    local vars = self.vars
    vars['serverLabel']:setString( string.upper( name ) )
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

    local function ok_cb()
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

    local msg = Str('게스트 계정으로 접속을 하면 게임 삭제,\n기기변동, 휴대폰 초기화시 계정 데이터도\n삭제됩니다.\n\n게스트 계정으로 로그인하시겠습니까?')
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
end

-------------------------------------
-- function click_changeServer()
-------------------------------------
function UI_LoginPopup:click_changeServer()
    local function onFinish( name )        
        ServerListData:getInstance():selectServer( name )
        self:setServerName( name )
    end
    UI_SelectServerPopup( onFinish )
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

    cclog('fuid: ' .. tostring(fuid))
    cclog('push_token: ' .. tostring(push_token))
    cclog('platform_id:' .. tostring(platform_id))
    cclog('account_info:' .. tostring(account_info))

    g_localData:applyLocalData(fuid, 'local', 'uid')
    g_localData:applyLocalData(push_token, 'local', 'push_token')
    g_localData:applyLocalData(platform_id, 'local', 'platform_id')
    g_localData:applyLocalData(account_info, 'local', 'account_info')

    if platform_id == 'google.com' then
        g_localData:applyLocalData('on', 'local', 'googleplay_connected')
    else
        g_localData:applyLocalData('off', 'local', 'googleplay_connected')
    end

    --선택 서버 저장
    g_localData:lockSaveData()
    g_localData:setServerName( ServerListData:getInstance():getSelectServer() )
    g_localData:unlockSaveData()


    --이쪽이면 os 로그인과 서버선택하며 들어가는것으로 naver channel을 추천으로 선택다시해준다.    
    NaverCafeManager:naverInitGlobalPlug(g_localData:getServerName(), g_localData:getLang())
    g_localData:setSavedNaverChannel( 1 )


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
