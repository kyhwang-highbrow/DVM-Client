local PARENT = UI

-------------------------------------
-- class UI_LoginPopup2
-------------------------------------
UI_LoginPopup2 = class(PARENT,{
        m_loadingUI = 'UI_TitleSceneLoading',                
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoginPopup2:init()
    local vars = self:load('login_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 없음
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_LoginPopup2')

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
function UI_LoginPopup2:initUI()
    local vars = self.vars

    vars['serverMenu']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LoginPopup2:initButton()
    local vars = self.vars
    
    vars['googleBtn']:registerScriptTapHandler(function() self:click_googleBtn() end)
	vars['facebookBtn']:registerScriptTapHandler(function() self:click_facebookBtn() end)
	vars['twitterBtn']:registerScriptTapHandler(function() self:click_twitterBtn() end)
    vars['gamecenterBtn']:registerScriptTapHandler(function() self:click_gamecenterBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

	self:alignButton()
end

-------------------------------------
-- function alignButton
-------------------------------------
function UI_LoginPopup2:alignButton()
	local vars = self.vars

	-- visible on/off
	--vars['googleBtn']:setVisible(true)
	--vars['facebookBtn']:setVisible(true)
	--vars['twitterBtn']:setVisible(true)
    vars['guestBtn']:setVisible(false)
	vars['gamecenterBtn']:setVisible(CppFunctions:isIos())

	-- visible로 구분하여 활성화된 버튼을 찾아 정렬
	local l_prefix_list = {'google', 'facebook', 'twitter', 'gamecenter'}
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
function UI_LoginPopup2:refresh()    
end

-------------------------------------
-- function click_gamecenterBtn
-------------------------------------
function UI_LoginPopup2:click_gamecenterBtn()
    if isWin32() then
        UIManager:toastNotificationRed(Str('Windows에서는 동작하지 않습니다.'))
        return
    end

    self.m_loadingUI:showLoading(Str('계정 연동 중...'))


    local old_uid = g_localData:get('local', 'uid')
    local game_center_uid = nil

    -- 순차적으로 호출될 함수
    -- 1. 게임센터 계정 정보 확인
    local func_gamecenter_login
    -- 2. gamecenter uid를 플랫폼 서버에 조회
    local func_check_gamecenter_uid_on_platform_server
    -- 2-1. gamecenter uid계정이 존재하지 않아서 연동하는 경우
    local func_new_account
    -- 2-2. gamecenter uid계정이 이미 존재하는 경우
    local func_existing_account
    -- 3. gamecenter uid로 파이어베이스 로그인
    local func_login_with_gamecenter


    -- 1. 게임센터 계정 정보 확인
    func_gamecenter_login = function()
        cclog('## func_gamecenter_login')
        PerpleSDK:gameCenterLogin(function(ret, info) -- info는 gamecenter의 playerId(fuid로 사용되기 때문에 uid라고 보면 됨)
            if (ret == 'success') then
                cclog('GameCenter login was successful.')
                self.m_loadingUI:hideLoading()
                game_center_uid = MakeGameServerUid(info)

                -- 다음 함수 호출
                func_check_gamecenter_uid_on_platform_server()

            elseif (ret == 'fail') then
                cclog('GameCenter login failed.')
			    UI_LoginPopup:loginFail(info)
                self.m_loadingUI:hideLoading()

            elseif (ret == 'cancel') then
                cclog('GameCenter login canceled.')
			    UI_LoginPopup:loginCancel()
                self.m_loadingUI:hideLoading()
            end
        end)
    end

    -- 2. gamecenter uid를 플랫폼 서버에 조회
    func_check_gamecenter_uid_on_platform_server = function()
        cclog('## func_check_gamecenter_uid_on_platform_server')
        local function result_cb(ret)
            -- ret의 데이터 예시
            --{
	        --    ['status']={
		    --        ['message']='success';
		    --        ['retcode']=0;
	        --    };
	        --    ['userInfo']={
		    --        ['uid']='G:1175721028';
		    --        ['create_date']='2019-06-19T08:11:11.000Z';
		    --        ['last_login_date']='2020-06-17T07:45:12.000Z';
		    --        ['push_token']='ei0KuKuedJk:APA91bHJ5UFyYQV5V5lhX6Z5zfMZ2r_r_Lgdj6ep_-eg7Qf5fGwIOqktn7fIh5oDKW3jhKyOHe5I3KiASmUKaKZPypHcBKyAPtRNcnU8o20-NLzq8UgShrezgWIfCSo6Ztur3bk5W2Gl';
		    --        ['os']=1;
		    --        ['rcode']='6fbee047-d675-4815-87da-f102566aeac8';
	        --    };
            --}

            -- 리턴값으로 기존 계정인지 신규 계정인지 확인
            local is_new_account = true
            if (ret['status'] and ret['status']['retcode'] == 0) then
                if (ret['userInfo'] and ret['userInfo']['uid']) then
                    is_new_account = false
                end
            end
            
            -- 신규 계정인지, 기존 계정인지
            if (is_new_account == true) then
                func_new_account() -- 다음 함수 호출
            else--if (is_new_account == false) then
                func_existing_account() -- 다음 함수 호출
            end
        end

        Network_platform_getUserByUid(game_center_uid, result_cb, result_cb) -- params : uid, success_cb, fail_cb)
    end

    -- 2-1. gamecenter uid계정이 존재하지 않아서 연동하는 경우
    func_new_account = function()
        cclog('## func_new_account')
        local function fail_cb(ret)
            local error_str = ''
            if ret['status'] and ret['status']['retcode'] then
                error_str = tostring(ret['status']['retcode'])
            end
            if ret['status'] and ret['status']['message'] then
                if (error_str ~= '') then
                    error_str = (error_str .. '-')
                end
                error_str = (error_str .. tostring(ret['status']['message']))
            end

            local msg = Str('계정 연동 과정에 오류가 발생하였습니다. (오류코드:{1})', error_str)
            MakeSimplePopup(POPUP_TYPE.OK, msg)
        end

        local function success_cb(ret)
            if ret['status'] and (ret['status']['retcode'] == 0) then
                -- 플랫폼 서버에서 이 정보를 업데이트 해서 사용하고있지 않다고 판단되어 호출하지 않는다. sgkim 20200617
                --Network_platform_updateId(game_center_uid, 'gamecenter', game_center_uid)

                -- 다음 함수 호출
                func_login_with_gamecenter(true) -- params : is_new_account
            else
                fail_cb(ret)
            end
        end

        Network_platform_changeByPlayerID(old_uid, game_center_uid, success_cb, fail_cb) -- old_uid, new_uid, success_cb, fail_cb)
    end

    -- 2-2. gamecenter uid계정이 이미 존재하는 경우
    func_existing_account = function()
        cclog('## func_existing_account')
        local msg = Str('이미 연결되어 있는 계정입니다.\n계정에 연결되어 있는 기존의 게임 데이터를 불러오시겠습니까?')
        local submsg = Str('현재의 게임데이터는 유실되므로 주의바랍니다.')

        local ok_btn_cb = function()
            -- 다음 함수 호출
            func_login_with_gamecenter(false) -- params : is_new_account
        end
        local cancel_btn_cb = nil

        MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb, cancel_btn_cb)
    end

    -- 3. gamecenter uid로 파이어베이스 로그인
    func_login_with_gamecenter = function(is_new_account)
        cclog('## func_existing_account. is_new_account : ' .. tostring(is_new_account))
        PerpleSDK:loginWithGameCenter(GetPlatformApiUrl() .. '/user/customToken', function(ret, info)
            if (ret == 'success') then
                cclog('Firebase GameCenter login was successful.')
                self:loginSuccess(info)

                -- 신규 계정인 경우 안내
                if (is_new_account == true) then
                    MakeSimplePopup(POPUP_TYPE.OK, Str('계정 연동에 성공하였습니다. 앱을 다시 시작합니다.'), function()
                        -- 앱 재시작
                        CppFunctions:restart()
                    end)
                else
                    -- 앱 재시작
                    CppFunctions:restart()
                end

            elseif (ret == 'fail') then
                cclog('Firebase GameCenter login failed.')
                UI_LoginPopup:loginFail(info)

            elseif (ret == 'cancel') then
                cclog('Firebase GameCenter login canceled.')
				UI_LoginPopup:loginCancel()
            end
        end)
    end

    -- 함수 시작
    func_gamecenter_login()
end

-------------------------------------
-- function click_facebookBtn
-------------------------------------
function UI_LoginPopup2:click_facebookBtn()
    if isWin32() then
        UIManager:toastNotificationRed(Str('Windows에서는 동작하지 않습니다.'))
        return
    end

    self.m_loadingUI:showLoading(Str('계정 연동 중...'))

    local old_platform_id = g_localData:get('local', 'platform_id')

    PerpleSDK:linkWithFacebook(function(ret, info)

        if ret == 'success' then

            cclog('Firebase Facebook link was successful.')
            self.m_loadingUI:hideLoading()

            self:loginSuccess(info)

            MakeSimplePopup(POPUP_TYPE.OK, Str('계정 연동에 성공하였습니다.'), function()
                -- 기존 구글 연결은 끊는다.
                if old_platform_id == 'google.com' then
                    PerpleSDK:googleLogout()
                    PerpleSDK:unlinkWithGoogle(function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase unlink from Google was successful.')
                        elseif ret == 'fail' then
                            cclog('Firebase unlink from Google failed.')
                        end
                    end)
				
				-- 기존 트위터 연결은 끊는다.
                elseif old_platform_id == 'twitter.com' then
                    PerpleSDK:unlinkWithTwitter(function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase unlink from Twitter was successful.')
                        elseif ret == 'fail' then
                            cclog('Firebase unlink from Twitter failed.')
                        end
                    end)

                -- 기존 게임센터 연결은 끊는다.
                elseif old_platform_id == 'gamecenter' then
                    PerpleSDK:unlinkWithGameCenter(function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase unlink from GameCenter was successful.')
                        elseif ret == 'fail' then
                            cclog('Firebase unlink from GameCenter failed.')
                        end
                    end)
                end
            end)


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
                            PerpleSDK:googleLogout()
                        end

                        -- 앱 재시작
                        CppFunctions:restart()

                    elseif ret == 'fail' then
						UI_LoginPopup:loginFail(info)
                    elseif ret == 'cancel' then
						UI_LoginPopup:loginCancel()
                    end
                end)
            end

            local cancel_btn_cb = nil

            self.m_loadingUI:hideLoading()
            local msg = Str('이미 연결되어 있는 계정입니다.\n계정에 연결되어 있는 기존의 게임 데이터를 불러오시겠습니까?')
            local submsg = Str('현재의 게임데이터는 유실되므로 주의바랍니다.')
            MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb, cancel_btn_cb)

        elseif ret == 'fail' then
            cclog('Firebase Facebook link failed')
			UI_LoginPopup:loginFail(info)
            self.m_loadingUI:hideLoading()
            
        elseif ret == 'cancel' then
            cclog('Firebase Facebook link canceled.')
			UI_LoginPopup:loginCancel()
            self.m_loadingUI:hideLoading()

        end
    end)

end

-------------------------------------
-- function click_googleBtn
-------------------------------------
function UI_LoginPopup2:click_googleBtn()
    if isWin32() then
        UIManager:toastNotificationRed(Str('Windows에서는 동작하지 않습니다.'))
        return
    end

    self.m_loadingUI:showLoading(Str('계정 연동 중...'))

    local old_platform_id = g_localData:get('local', 'platform_id')

    PerpleSDK:linkWithGoogle(function(ret, info)
        if ret == 'success' then

            cclog('Firebase Google link was successful.')
            self.m_loadingUI:hideLoading()

            self:loginSuccess(info)

            MakeSimplePopup(POPUP_TYPE.OK, Str('계정 연동에 성공하였습니다.'), function()
                -- 기존 페이스북 연결은 끊는다.
                if old_platform_id == 'facebook.com' then
                    PerpleSDK:unlinkWithFacebook(function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase unlink from Facebook was successful.')
                        elseif ret == 'fail' then
                            cclog('Firebase unlink from Facebook failed.')
                        end
                    end)
				
				-- 기존 트위터 연결은 끊는다.
                elseif old_platform_id == 'twitter.com' then
                    PerpleSDK:unlinkWithTwitter(function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase unlink from Twitter was successful.')
                        elseif ret == 'fail' then
                            cclog('Firebase unlink from Twitter failed.')
                        end
                    end)

                -- 기존 게임센터 연결은 끊는다.
                elseif old_platform_id == 'gamecenter' then
                    PerpleSDK:unlinkWithGameCenter(function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase unlink from GameCenter was successful.')
                        elseif ret == 'fail' then
                            cclog('Firebase unlink from GameCenter failed.')
                        end
                    end)
                end

                -- 구글 계정을 사용하지 않다가 최초 연동 시 업적을 한번 체크하여 클리어 하도록 한다.
                GoogleHelper.allAchievementCheck()

            end)

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
                        CppFunctions:restart()

                    elseif ret == 'fail' then
						UI_LoginPopup:loginFail(info)
                    elseif ret == 'cancel' then
						UI_LoginPopup:loginCancel()
                    end
                end)
            end
    
            local cancel_btn_cb = nil

            self.m_loadingUI:hideLoading()
            local msg = Str('이미 연결되어 있는 계정입니다.\n계정에 연결되어 있는 기존의 게임 데이터를 불러오시겠습니까?')
            local submsg = Str('현재의 게임데이터는 유실되므로 주의바랍니다.')
            MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb, cancel_btn_cb)

        elseif ret == 'fail' then
            cclog('Firebase Google link failed')
			UI_LoginPopup:loginFail(info)
            self.m_loadingUI:hideLoading()

        elseif ret == 'cancel' then
            cclog('Firebase Google link canceled.')
			UI_LoginPopup:loginCancel()
            self.m_loadingUI:hideLoading()

        end
    end)

end

-------------------------------------
-- function click_twitterBtn
-------------------------------------
function UI_LoginPopup2:click_twitterBtn()
    if isWin32() then
        UIManager:toastNotificationRed(Str('Windows에서는 동작하지 않습니다.'))
        return
    end

    self.m_loadingUI:showLoading(Str('계정 연동 중...'))

    local old_platform_id = g_localData:get('local', 'platform_id')

    PerpleSDK:linkWithTwitter(function(ret, info)

        if ret == 'success' then

            cclog('Firebase Twitter link was successful.')
            self.m_loadingUI:hideLoading()

            self:loginSuccess(info)

            MakeSimplePopup(POPUP_TYPE.OK, Str('계정 연동에 성공하였습니다.'), function()
                -- 기존 구글 연결은 끊는다.
                if old_platform_id == 'google.com' then
                    PerpleSDK:googleLogout()
                    PerpleSDK:unlinkWithGoogle(function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase unlink from Google was successful.')
                        elseif ret == 'fail' then
                            cclog('Firebase unlink from Google failed.')
                        end
                    end)
				
				-- 기존 페이스북 연결은 끊는다.
                elseif old_platform_id == 'facebook.com' then
                    PerpleSDK:unlinkWithFacebook(function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase unlink from Facebook was successful.')
                        elseif ret == 'fail' then
                            cclog('Firebase unlink from Facebook failed.')
                        end
                    end)

                -- 기존 게임센터 연결은 끊는다.
                elseif old_platform_id == 'gamecenter' then
                    PerpleSDK:unlinkWithGameCenter(function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase unlink from GameCenter was successful.')
                        elseif ret == 'fail' then
                            cclog('Firebase unlink from GameCenter failed.')
                        end
                    end)
                end
            end)


        elseif ret == 'already_in_use' then

            local ok_btn_cb = function()
                self.m_loadingUI:showLoading(Str('계정 전환 중...'))
                PerpleSDK:logout()
                PerpleSDK:loginWithTwitter(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase Twitter link was successful.(already_in_use)')

                        self:loginSuccess(info)

                        if (old_platform_id == 'google.com') then
                            PerpleSDK:googleLogout()
                        end

                        -- 앱 재시작
                        CppFunctions:restart()

                    elseif ret == 'fail' then
                        UI_LoginPopup:loginFail(info)
                    elseif ret == 'cancel' then
						UI_LoginPopup:loginCancel()
                    end
                end)
            end

            local cancel_btn_cb = nil

            self.m_loadingUI:hideLoading()
            local msg = Str('이미 연결되어 있는 계정입니다.\n계정에 연결되어 있는 기존의 게임 데이터를 불러오시겠습니까?')
            local submsg = Str('현재의 게임데이터는 유실되므로 주의바랍니다.')
            MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb, cancel_btn_cb)

        elseif ret == 'fail' then
            cclog('Firebase Twitter link failed')
			UI_LoginPopup:loginFail(info)
            self.m_loadingUI:hideLoading()

        elseif ret == 'cancel' then
            cclog('Firebase Twitter link canceled.')
			UI_LoginPopup:loginCancel()
            self.m_loadingUI:hideLoading()

        end
    end)

end

-------------------------------------
-- function click_clearBtn
-------------------------------------
function UI_LoginPopup2:click_clearBtn()
    local ask_popup
    local request
    local clear

    -- 1. 계정 초기화 여부를 물어보는 팝업
    ask_popup = function()
        local ok_btn_cb = function()
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
        ui_network:request()
    end

    -- 3. 로컬 세이브 데이터 삭제 후 어플 재시작
    clear = function()
        removeLocalFiles()

        -- AppDelegate_Custom.cpp에 구현되어 있음
        CppFunctions:restart()
    end
    
    ask_popup()
end

-------------------------------------
-- function click_logoutBtn
-------------------------------------
function UI_LoginPopup2:click_logoutBtn()
    local ask_popup
    local clear

    -- 1. 계정 초기화 여부를 물어보는 팝업
    ask_popup = function()
        local ok_btn_cb = function()
            if isWin32() then
                clear()
            else
                PerpleSDK:logout()
                PerpleSDK:googleLogout()
                PerpleSDK:facebookLogout()
				PerpleSDK:twitterLogout()

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
        CppFunctions:restart()
    end

    ask_popup()
end

-------------------------------------
-- function click_serverBtn
-------------------------------------
function UI_LoginPopup2:click_serverBtn()
    local function onChangeServer( serverName )
        local oldServer = ServerListData:getInstance():getSelectServer()
        if oldServer == serverName then
            return
        end

        local function ok_cb()
			-- 선택한 서버 저장
            ServerListData:getInstance():selectServer( serverName )
            g_localData:lockSaveData()        
            g_localData:setServerName( serverName )
            g_localData:unlockSaveData()

			-- 설정, 채팅, 시나리오 로컬 파일 삭제
		    SettingData:getInstance():clearSettingDataFile()
            LobbyGuideData:getInstance():clearLobbyGuideDataFile()
            LobbyPopupData:getInstance():clearLobbyPopupDataFile()
			ChatIgnoreList:clearChatIgnoreListFile()
			ScenarioViewingHistory:clearScenarioViewingHistoryFile()

			-- 신규 룬, 드래곤 로컬 파일 삭제
			g_highlightData:clearNewOidMapFile()

			-- 재시작
            CppFunctions:restart()
        end

        MakeSimplePopup(POPUP_TYPE.OK, Str('앱을 재시작합니다.'), ok_cb)
    end

    UI_SelectServerPopup(onChangeServer)
end

-------------------------------------
-- function loginSuccess
-------------------------------------
function UI_LoginPopup2:loginSuccess(info)
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

    --[[
    -- settingData에 있는 이전 기록 삭제
    if (g_settingData) then
        g_settingData:resetSettingData()
    end
    --]]

    if (g_settingDeckData) then
        g_settingDeckData:resetAncientBestDeck()
    end

    if platform_id == 'google.com' then
		if (t_info['google'] and t_info['google']['playServicesConnected']) then
			g_localData:setGooglePlayConnected(true)
		end
    else
        g_localData:setGooglePlayConnected(false)
    end

    if platform_id ~= 'gamecenter' then
        Network_platform_updateId(fuid, platform_id, account_info)
    end

    -- dirty -> lobby btn state
    GoogleHelper.setDirty(true)
end

--@CHECK
UI:checkCompileError(UI_LoginPopup2)
