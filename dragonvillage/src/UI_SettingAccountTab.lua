-------------------------------------
-- function init_accountTab
-------------------------------------
function UI_Setting:init_accountTab()
    local vars = self.vars

    vars['copyBtn']:registerScriptTapHandler(function() self:click_copyBtn() end)

    vars['googleBtn']:registerScriptTapHandler(function() LoginHelper:linkWithGoogle() end)
	vars['facebookBtn']:registerScriptTapHandler(function() LoginHelper:linkWithFacebook() end)
	vars['twitterBtn']:registerScriptTapHandler(function() LoginHelper:linkWithTwitter() end)
    vars['gamecenterBtn']:registerScriptTapHandler(function() self:click_gameCenter() end)
    vars['appleBtn']:registerScriptTapHandler(function() LoginHelper:linkWithApple() end)

    vars['clearBtn']:registerScriptTapHandler(function() LoginHelper:clearAccount() end)
    vars['logoutBtn']:registerScriptTapHandler(function() LoginHelper:logout() end)
    vars['serverBtn']:registerScriptTapHandler(function() self:click_serverBtn() end)
    vars['deleteBtn']:registerScriptTapHandler(function() self:click_deleteBtn() end)

    -- 테스트 모드에서만 로그아웃, 초기화 버튼을 노출한다
    if IS_TEST_MODE() then
        vars['clearBtn']:setVisible(true)
        vars['logoutBtn']:setVisible(true)
    else
        vars['clearBtn']:setVisible(false)
        vars['logoutBtn']:setVisible(false)
    end

    LoginHelper:setup(self.m_loadingUI, function(info) self:loginSuccess(info) end)

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
-- function click_deleteBtn
-------------------------------------
function UI_Setting:click_deleteBtn()
    local is_guest = g_localData:isGuestAccount()

    require('UI_AccountDeleteRequestPopup')
    UI_AccountDeleteRequestPopup(is_guest)
end

-------------------------------------
-- function click_gameCenter
-------------------------------------
function UI_Setting:click_gameCenter()
    local ok_btn_cb = function()
        LoginHelper:linkWithGameCenter()
    end

    -- 혹시 검수 반려 사항이 될 수도 있기 때문에 검수 모드일 때에는 경고 팝업 노출시키지 않음
    if (true == g_remoteConfig:hideCouponBtn()) or (true == LocalData.getInstance():isInAppReview()) then
        ok_btn_cb()
        return
    end

    local msg = 'Game Center'
    -- 현재 게임 센터 연동 시 다른 계정으로 전환을 막아놓음
    -- 기술적으로 불가능해 보이지 않지만 공수나 리스크를 고려해 아래와 같은 경고 문구 띄움
    -- 나중에는 전환이 가능하도록 지원을 고려해야 함(by kyhwang)
    local submsg = Str('게임센터 연동 시 다른 계정으로의 전환이 어렵습니다.\n그래도 연동을 진행하시겠습니까?')
    MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function loginSuccess
-------------------------------------
function UI_Setting:loginSuccess(info)
    local t_info = dkjson.decode(info)
    local fuid = t_info.fuid
    -- local push_token = t_info.pushToken
    local platform_id = t_info.providerId
    local account_info = t_info.name

    -- 고대의 탑 로컬 덱 리셋
    if (g_settingDeckData) then
        g_settingDeckData:resetAncientBestDeck()
    end

    if platform_id ~= 'gamecenter' then
        Network_platform_updateId(fuid, platform_id, account_info)
    end

    -- dirty -> lobby btn state
    GoogleHelper.setDirty(true)

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

    -- visible on/off
    LoginHelper:alignLinkButtons(vars, is_gamecenter)
    
    vars['codeMenu']:setVisible(is_guest)

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

	-- 서버 명 표기
	local server_name = g_localData:getServerName()
	vars['serverLabel']:setString( string.upper(server_name) )
end
