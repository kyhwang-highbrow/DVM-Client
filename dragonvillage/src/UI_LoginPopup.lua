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
    g_currScene:pushBackKeyListener(self, function() self:close(true) end, 'UI_LoginPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_loadingUI = UI_TitleSceneLoading()
    self.m_loadingUI:hideLoading()

    --서버선택 팝업으로 최초에 보여주도록
    -- @sgkim 2019-05-28 타이틀 화면(UI_TitleScene:workCheckSelectedGameServer()) 에서 서버 선택을 하도록 변경 
    --self:click_changeServer()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoginPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LoginPopup:initButton()
    local vars = self.vars
    
    vars['googleBtn']:registerScriptTapHandler(function() self:click_googleBtn() end)
	vars['facebookBtn']:registerScriptTapHandler(function() self:click_facebookBtn() end)
	vars['twitterBtn']:registerScriptTapHandler(function() self:click_twitterBtn() end)
    vars['gamecenterBtn']:registerScriptTapHandler(function() self:click_gamecenterBtn() end)
    vars['guestBtn']:registerScriptTapHandler(function() self:click_guestBtn() end)
    vars['serverBtn']:registerScriptTapHandler(function() self:click_changeServer() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close(true) end)
	
    self:alignButton()
end

-------------------------------------
-- function alignButton
-------------------------------------
function UI_LoginPopup:alignButton()
	local vars = self.vars

	-- visible on/off
	--vars['googleBtn']:setVisible(true)
	--vars['facebookBtn']:setVisible(true)
	--vars['twitterBtn']:setVisible(true)
	vars['gamecenterBtn']:setVisible(CppFunctions:isIos())

	-- visible로 구분하여 활성화된 버튼을 찾아 정렬
	local l_prefix_list = {'google', 'facebook', 'twitter', 'gamecenter', 'guest'}
	local l_active_btn_list = {}
	local active_cnt = 0
	for _, prefix in ipairs(l_prefix_list) do
		if (vars[prefix .. 'Btn']:isVisible()) then
			active_cnt = active_cnt + 1
			table.insert(l_active_btn_list, vars[prefix .. 'Btn'])
		end
	end

	-- 3개 이하
	if (active_cnt <= 3) then
		for i, btn in ipairs(l_active_btn_list) do
			btn:setPosition(0, 110 - (70 * i))
		end
		
	-- 4개 이상
	else
		local odd, step = 0, 0
		for i, btn in ipairs(l_active_btn_list) do
			odd = (i % 2)
			step = math_floor((i - 1)/ 2)
			btn:setPosition((odd == 1) and -150 or 150, 40 - (70 * step))
		end

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
-- function close
-------------------------------------
function UI_LoginPopup:close(is_back_key)
    if self.closed then
        cclog('attempted to close twice')
        cclog(debug.traceback())
        return
    end
    self.closed = true
    self:onClose()

    UIManager:close(self)
    
    if self.m_closeCB then
        self.m_closeCB(is_back_key)
    end

    --[[
        -- 이전에는 뒤로가기 키 눌렀을 때, 이전 UI가 없어서 앱을 종료시켜줌
        -- @jhakim 190714 통합 로그인 창 생기면서 로그인하면 바로 다음 넘어가던가, 뒤로가기 키 누르면 UI창만 꺼주는 방향으로 수정
        local function yes_cb()
            closeApplication()
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('종료하시겠습니까?'), yes_cb)
    --]]
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
		    self:loginCancel()
        end
    end)

end

-------------------------------------
-- function click_twitterBtn
-------------------------------------
function UI_LoginPopup:click_twitterBtn()
    self.m_loadingUI:showLoading(Str('로그인 중...'))

    PerpleSDK:loginWithTwitter(function(ret, info)
        self.m_loadingUI:hideLoading()

        if ret == 'success' then
            cclog('Firebase Twitter login was successful.')
            self:loginSuccess(info)
            self:close()
        elseif ret == 'fail' then
            self:loginFail(info)
        elseif ret == 'cancel' then
			self:loginCancel()
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
			self:loginCancel()
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
			self:loginCancel()
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
    PerpleSdkManager:makeErrorPopup(info)
end

-------------------------------------
-- function loginCancel
-------------------------------------
function UI_LoginPopup:loginCancel()
    local msg = Str('로그인을 취소했습니다.')
    MakeSimplePopup(POPUP_TYPE.OK, msg)
end

--@CHECK
UI:checkCompileError(UI_LoginPopup)
