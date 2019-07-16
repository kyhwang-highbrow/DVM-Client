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

    local old_fuid = g_localData:get('local', 'uid')

    PerpleSDK:gameCenterLogin(function(ret, info)

        if ret == 'success' then
            cclog('GameCenter login was successful.')
            self.m_loadingUI:hideLoading()

            local fuid = info

            -- fuid를 플랫폼 서버에 조회 신규/기존 판단
            local result_cb = function(ret)
                ccdump(ret)

                local function ok_btn_cb()
                    PerpleSDK:loginWithGameCenter(GetPlatformApiUrl() .. '/user/customToken', function(ret, info)
                        if ret == 'success' then
                            cclog('Firebase GameCenter login was successful.')

                            self:loginSuccess(info)

                            MakeSimplePopup(POPUP_TYPE.OK, Str('계정 연동에 성공하였습니다. 앱을 다시 시작합니다.'), function()
                                -- 앱 재시작
                                CppFunctions:restart()
                            end)

                        elseif ret == 'fail' then
                            cclog('Firebase GameCenter login failed.')
                            UI_LoginPopup:loginFail(info)

                        elseif ret == 'cancel' then
                            cclog('Firebase GameCenter login canceled.')
							UI_LoginPopup:loginCancel()
                            -- no nothing
                        end
                    end)
                end

                local cancel_btn_cb = nil

                local checkUserUid = ret['userInfo'] and ret['userInfo']['fuid']

                if checkUserUid == nil then
                    -- 신규 유저
                    local function success_cb()
                        ok_btn_cb();
                    end

                    local function fail_cb(ret)
                        local msg = Str('계정 연동 과정에 오류가 발생하였습니다. (오류코드:{1})', ret['status'])
                        MakeSimplePopup(POPUP_TYPE.OK, msg)
                    end

                    Network_platform_updateId(fuid, 'gamecenter', old_fuid, success_cb, fail_cb)
                else
                    -- 기존 유저
                    local msg = Str('이미 연결되어 있는 계정입니다.\n계정에 연결되어 있는 기존의 게임 데이터를 불러오시겠습니까?')
                    local submsg = Str('현재의 게임데이터는 유실되므로 주의바랍니다.')
                    MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb, cancel_btn_cb)
                end
            end

            Network_platform_getUserByUid(fuid, result_cb, result_cb)

        elseif ret == 'fail' then
            cclog('GameCenter login failed.')
			UI_LoginPopup:loginFail(info)
            self.m_loadingUI:hideLoading()

        elseif ret == 'cancel' then
            cclog('GameCenter login canceled.')
			UI_LoginPopup:loginCancel()
            self.m_loadingUI:hideLoading()
        end
    end)
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

    self:updateInfo()
end

--@CHECK
UI:checkCompileError(UI_LoginPopup2)
