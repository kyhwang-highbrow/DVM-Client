-------------------------------------
-- function init_accounteTab
-------------------------------------
function UI_Setting:init_accountTab()
    local vars = self.vars

    vars['copyBtn']:registerScriptTapHandler(function() self:click_copyBtn() end)

    vars['facebookBtn']:registerScriptTapHandler(function() self:click_facebookBtn() end)
	vars['twitterBtn']:registerScriptTapHandler(function() self:click_twitterBtn() end)
    vars['gamecenterBtn']:registerScriptTapHandler(function() self:click_gamecenterBtn() end)
    vars['googleBtn']:registerScriptTapHandler(function() self:click_googleBtn() end)

    vars['clearBtn']:registerScriptTapHandler(function() self:click_clearBtn() end)
    vars['logoutBtn']:registerScriptTapHandler(function() self:click_logoutBtn() end)
    vars['serverBtn']:registerScriptTapHandler(function() self:click_serverBtn() end)

    -- 테스트 모드에서만 로그아웃, 초기화 버튼을 노출한다
    if IS_TEST_MODE() then
        vars['clearBtn']:setVisible(true)
        vars['logoutBtn']:setVisible(true)
    else
        vars['clearBtn']:setVisible(false)
        vars['logoutBtn']:setVisible(false)
    end

    self:updateInfo()
end

-------------------------------------
-- function click_copyBtn
-------------------------------------
function UI_Setting:click_copyBtn()
    local recovery_code = g_localData:get('local', 'recovery_code')

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
function UI_Setting:click_facebookBtn()
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
                    PerpleSDK:googleLogout(1)
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
                            PerpleSDK:googleLogout(1)
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
            cclog('Firebase Facebook link failed - ' .. msg)
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
function UI_Setting:click_googleBtn()
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
            cclog('Firebase Google link failed - ' .. msg)
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
function UI_Setting:click_twitterBtn()
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
                    PerpleSDK:googleLogout(1)
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
                            PerpleSDK:googleLogout(1)
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
            cclog('Firebase Twitter link failed - ' .. msg)
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
function UI_Setting:click_clearBtn()
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
function UI_Setting:click_logoutBtn()
    local ask_popup
    local clear

    -- 1. 계정 초기화 여부를 물어보는 팝업
    ask_popup = function()
        local ok_btn_cb = function()
            if isWin32() then
                clear()
            else
                PerpleSDK:logout()
                PerpleSDK:googleLogout(0)
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
function UI_Setting:click_serverBtn()
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
function UI_Setting:loginSuccess(info)
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

    if platform_id ~= 'gamecenter' then
        Network_platform_updateId(fuid, platform_id, account_info)
    end

    self:updateInfo()
end

-------------------------------------
-- function updateInfo
-------------------------------------
function UI_Setting:updateInfo()
	local vars = self.vars

	local platform_id = g_localData:get('local', 'platform_id') or 'firebase'
    local account_info = g_localData:get('local', 'account_info') or 'Guest'
    local recovery_code = g_localData:get('local', 'recovery_code')

	local is_guest = (platform_id == 'firebase')
	local is_gamecenter = (platform_id == 'gamecenter')

	-- 연동 안내 텍스트
	local desc = ''
    if is_gamecenter then
		desc = Str('현재 게임 데이터가 안전하게 보호되고 있습니다.\n(게임센터 로그인 상태에서는 다른 플랫품 계정으로 계정 전환을 하실 수 없습니다.)')
    elseif is_guest then
        desc = Str('계정 연동을 통해 게임 데이터를 안전하게 보호하세요.\n계정 연동은 이전에 계정 연동을 한 적이 없는 새로운 계정으로만 가능합니다.\n복구 코드는 게스트 상태의 게임 데이터 복구시 필요하며 복구 처리는 고객센터를 통해서만 가능하니 주의 바랍니다.')
    else
        if isIos() then
            desc = Str('현재 게임 데이터가 안전하게 보호되고 있습니다.\n\n다른 플랫폼 계정으로 계정 전환이 가능합니다.\n(이전에 계정 연동을 한 적이 없는 새로운 계정으로만 가능하며, 게임센터로의 전환은 불가능합니다.)')
        else
            desc = Str('현재 게임 데이터가 안전하게 보호되고 있습니다.\n\n다른 플랫폼 계정으로 계정 전환이 가능합니다.\n(이전에 계정 연동을 한 적이 없는 새로운 계정으로만 가능)')
        end
	end

    -- 버튼 visible on/off
	vars['codeMenu']:setVisible(is_guest)
    vars['gamecenterBtn']:setVisible(is_guest and CppFunctions:isIos())
    vars['googleBtn']:setVisible(not is_gamecenter)
    vars['facebookBtn']:setVisible(not is_gamecenter)
	vars['twitterBtn']:setVisible(not is_gamecenter)

	-- setString info
	vars['descLabel']:setString(desc)
    vars['accountLabel']:setString(account_info)
    vars['uidLabel']:setString(recovery_code)

    -- 계정 플랫폼 아이콘 표시
	do
		vars['loginNode']:removeAllChildren()
		if (not is_guest) then
			local platform = string.gsub(platform_id, '.com', '')
			local sprite = IconHelper:getIcon(string.format('res/ui/icons/login_%s.png', platform))
			vars['loginNode']:addChild(sprite)
		end
	end

	-- 버튼 위치 정렬 및 비활성화 처리
	do
		local l_prefix_list = {'google', 'facebook', 'twitter', 'gamecenter'}
		local l_active_btn_list = {}
		local btn, sprite = nil
		for _, prefix in ipairs(l_prefix_list) do
			btn = vars[prefix .. 'Btn']
			sprite = vars[prefix .. 'DisableSprite']

            -- 초기화
            sprite:setVisible(false)
            btn:setEnabled(true)
                    
			-- 비활성화 처리
			-- 게임센터는 전부 비활성화
			if (platform_id == 'gamecenter') then
				sprite:setVisible(true)
				btn:setEnabled(false)
			else
				-- 그외는 로그인한 플랫폼만 비활성화
				if (string.find(platform_id, prefix)) then
					sprite:setVisible(true)
					btn:setEnabled(false)
				end
			end

			-- 활성화 버튼
			if (btn:isVisible()) then
				table.insert(l_active_btn_list, btn)
			end
		end
		-- 버튼 정렬
		local l_pos_x = getSortPosList(280, #l_active_btn_list)
		for i, btn in ipairs(l_active_btn_list) do
			btn:setPositionX(l_pos_x[i])
		end
	end
	
	-- 서버 명 표기
	local server_name = g_localData:getServerName()
	vars['serverLabel']:setString( string.upper(server_name) )

    -- dirty -> lobby btn state
    GoogleHelper.setDirty(true)
end
