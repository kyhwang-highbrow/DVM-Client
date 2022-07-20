-------------------------------------
-- table LoginHelper
-------------------------------------
LoginHelper = {
    m_loadingUI = 'UI',
    m_successCb = 'function',
}

-------------------------------------
-- function setUpUI
-------------------------------------
function LoginHelper:setup(loading_ui, success_cb)
    self.m_loadingUI = loading_ui
    self.m_successCb = success_cb
end

-------------------------------------
-- function release
-------------------------------------
function LoginHelper:release()
    self.m_loadingUI = nil
    self.m_successCb = nil
end

--------------------------------------------------------------------------
-- function utility
--------------------------------------------------------------------------

-------------------------------------
-- function availableSignInWithApple
-------------------------------------
function LoginHelper:availableSignInWithApple()
    if (not CppFunctions:isIos()) then
        return false
    end

    if (getAppVerNum() < 1002005) then
        return false
    end

    return g_userData:getOSVersion() >= 13
end

-------------------------------------
-- function visibleButtons
-- @breif visible on/off
-------------------------------------
function LoginHelper:visibleButtons(vars, use_guest, use_gamecenter)
    -- gamecenter .. off all
    if (use_gamecenter) then
        vars['googleBtn']:setVisible(false)
	    vars['facebookBtn']:setVisible(false)
	    vars['twitterBtn']:setVisible(false)
	    vars['gamecenterBtn']:setVisible(false)
        vars['appleBtn']:setVisible(false)
        return
    end

    -- 일반적인 케이스
	vars['googleBtn']:setVisible(true)
	vars['facebookBtn']:setVisible(true)
	vars['twitterBtn']:setVisible(true)
	vars['gamecenterBtn']:setVisible(CppFunctions:isIos())
    vars['appleBtn']:setVisible(self:availableSignInWithApple())

    if (vars['guestBtn'] ~= nil) then
        vars['guestBtn']:setVisible(use_guest)
    end
end

-------------------------------------
-- function alignLoginButton
-------------------------------------
function LoginHelper:alignLoginButtons(vars, use_guest)
	-- visible on/off, login 시에는 gamecenter가 설정되는 경우는 없다.
	self:visibleButtons(vars, use_guest, false)

	-- visible로 구분하여 활성화된 버튼을 찾아 정렬
	local l_prefix_list = {'google', 'facebook', 'twitter', 'apple', 'guest', 'gamecenter'}
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
-- function alignButtons
-------------------------------------
function LoginHelper:alignLinkButtons(vars, use_gamecenter)
    -- visible on/off, link 시에는 게스트 계정 버튼이 사용될 일이 없다.
	self:visibleButtons(vars, false, use_gamecenter)

    local platform_id = g_localData:get('local', 'platform_id') or 'firebase'

    -- 버튼 위치 정렬 및 비활성화 처리
    local l_prefix_list = {'google', 'facebook', 'twitter', 'apple', 'gamecenter'}
    local l_active_btn_list = {}
    local btn, sprite = nil
    local active_cnt = 0

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
            active_cnt = active_cnt + 1
            table.insert(l_active_btn_list, btn)
        end
    end

    -- 4개 이하, 일렬로 정렬
    if (active_cnt <= 4) then
        -- 버튼 정렬
        local l_pos_x = getSortPosList(280, #l_active_btn_list)
        for i, btn in ipairs(l_active_btn_list) do
            btn:setPosition(l_pos_x[i], -150)
        end

    -- 5개, 2열로 정렬
    elseif (active_cnt == 5) then
        local l_pos = {
            cc.p(-270, -150),
            cc.p(0, -150),
            cc.p(270, -150),
            cc.p(-270, -220),
            cc.p(0, -220),
        }
        for i, btn in ipairs(l_active_btn_list) do
            btn:setPosition(l_pos[i])
        end
    end
end

--------------------------------------------------------------------------
-- function login
--------------------------------------------------------------------------

-------------------------------------
-- function loginWithGoogle
-------------------------------------
function LoginHelper:loginWithGoogle()
    self.m_loadingUI:showLoading(Str('로그인 중...'))

    PerpleSDK:loginWithGoogle(function(ret, info)
        if (self.m_loadingUI) then self.m_loadingUI:hideLoading() end

        if ret == 'success' then
            cclog('Firebase Google login was successful.')
            self:loginSuccess(info)
        elseif ret == 'fail' then
            self:loginFail(info)
        elseif ret == 'cancel' then
			self:loginCancel()
        end
    end)
end

-------------------------------------
-- function loginWithFacebook
-------------------------------------
function LoginHelper:loginWithFacebook()
    self.m_loadingUI:showLoading(Str('로그인 중...'))

    PerpleSDK:loginWithFacebook(function(ret, info)
        self.m_loadingUI:hideLoading()

        if ret == 'success' then
            cclog('Firebase Facebook login was successful.')
            self:loginSuccess(info)
        elseif ret == 'fail' then
            self:loginFail(info)
        elseif ret == 'cancel' then
		    self:loginCancel()
        end
    end)
end

-------------------------------------
-- function loginWithTwitter
-------------------------------------
function LoginHelper:loginWithTwitter()
    self.m_loadingUI:showLoading(Str('로그인 중...'))

    PerpleSDK:loginWithTwitter(function(ret, info)
        self.m_loadingUI:hideLoading()

        if ret == 'success' then
            cclog('Firebase Twitter login was successful.')
            self:loginSuccess(info)
        elseif ret == 'fail' then
            self:loginFail(info)
        elseif ret == 'cancel' then
			self:loginCancel()
        end
    end)
end

-------------------------------------
-- function loginWithApple
-------------------------------------
function LoginHelper:loginWithApple()
    self.m_loadingUI:showLoading(Str('로그인 중...'))

    PerpleSDK:loginWithApple(function(ret, info)
        ccdump(info)
        self.m_loadingUI:hideLoading()

        if ret == 'success' then
            cclog('Firebase Apple login was successful.')
            self:loginSuccess(info)
        elseif ret == 'fail' then
            self:loginFail(info)
        elseif ret == 'cancel' then
			self:loginCancel()
        end
    end)
end

-------------------------------------
-- function loginWithGameCenter
-------------------------------------
function LoginHelper:loginWithGameCenter()
    self.m_loadingUI:showLoading(Str('로그인 중...'))

    local is_first_call = true
    PerpleSDK:loginWithGameCenter(GetPlatformApiUrl() .. '/user/customToken', function(ret, info)
        if (is_first_call == false) then
            return
        end
        is_first_call = false

        self.m_loadingUI:hideLoading()

        if ret == 'success' then
            cclog('Firebase GameCenter login was successful.')
            self:loginSuccess(info)
        elseif ret == 'fail' then
            self:loginFail(info)
        elseif ret == 'cancel' then
			self:loginCancel()
        end
    end)
end

-------------------------------------
-- function loginAsGuest
-------------------------------------
function LoginHelper:loginAsGuest()
    local function ok_cb()
        self.m_loadingUI:showLoading(Str('로그인 중...'))

        PerpleSDK:loginAnonymously(function(ret, info)
            self.m_loadingUI:hideLoading()

            if ret == 'success' then
                cclog('Firebase Guest login was successful.')
                self:loginSuccess(info)
            elseif ret == 'fail' then
                self:loginFail(info)
            end
        end)
    end

    local msg = Str('게스트 계정으로 접속을 하면 게임 삭제,\n기기변동, 휴대폰 초기화시 계정 데이터도\n삭제됩니다.\n\n게스트 계정으로 로그인하시겠습니까?')
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
end

--------------------------------------------------------------------------
-- function link
--------------------------------------------------------------------------

-------------------------------------
-- function linkWithGoogle
-------------------------------------
function LoginHelper:linkWithGoogle()
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
                self:unlink(old_platform_id)

                -- 구글 계정을 사용하지 않다가 최초 연동 시 업적을 한번 체크하여 클리어 하도록 한다.
                GoogleHelper.allAchievementCheck()
            end)

        elseif ret == 'already_in_use' then

            local ok_btn_cb = function()
                self.m_loadingUI:showLoading(Str('계정 전환 중...'))
				PerpleSDK:logout()
                PerpleSDK:loginWithGoogle(function(ret, info)
                    if (self.m_loadingUI) then
                        self.m_loadingUI:hideLoading()
                    end

                    if ret == 'success' then
                        cclog('Firebase Google link was successful.(already_in_use)')

                        self:loginSuccess(info)

                        -- 앱 재시작
                        CppFunctions:restart()

                    elseif ret == 'fail' then
						self:loginFail(info)
                    elseif ret == 'cancel' then
						self:loginCancel()
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
			self:loginFail(info)
            self.m_loadingUI:hideLoading()

        elseif ret == 'cancel' then
            cclog('Firebase Google link canceled.')
			self:loginCancel()
            self.m_loadingUI:hideLoading()

        end
    end)

end

-------------------------------------
-- function linkWithFacebook
-------------------------------------
function LoginHelper:linkWithFacebook()
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
                self:unlink(old_platform_id)
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
						self:loginFail(info)
                    elseif ret == 'cancel' then
						self:loginCancel()
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
            
            local error_info = dkjson.decode(info)
            if error_info then
                -- 2개 이상의 페이스북 계정 사용으로 인해 현재 로그인하려는 계정과 기존 엑세스 토큰이 다른 경우
                if (error_info['code'] == '-1302') then 
                    PerpleSDK:facebookLogout()
                    -- 처음부터 연동하는 프로세스를 다시 타야 하기 때문에 재귀로 돌림
                    self:linkWithFacebook()
                    --[[
                    PerpleSDK:loginWithFacebook(function(ret, info) 
                        self.m_loadingUI:hideLoading()

                        if (ret == 'success') then
                            self:loginSuccess(info)

                            -- 앱 재시작
                            CppFunctions:restart()
                        elseif ret == 'fail' then
                            self:loginFail()
                        elseif ret == 'cancel' then
                            self:loginCancel()
                        end
                    end)   ]]
                    
                    return
                end
            end

			self:loginFail(info)
            self.m_loadingUI:hideLoading()
            
        elseif ret == 'cancel' then
            cclog('Firebase Facebook link canceled.')
			self:loginCancel()
            self.m_loadingUI:hideLoading()

        end
    end)
end

-------------------------------------
-- function linkWithTwitter
-------------------------------------
function LoginHelper:linkWithTwitter()
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
                self:unlink(old_platform_id)
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
                        self:loginFail(info)
                    elseif ret == 'cancel' then
						self:loginCancel()
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
			self:loginFail(info)
            self.m_loadingUI:hideLoading()

        elseif ret == 'cancel' then
            cclog('Firebase Twitter link canceled.')
			self:loginCancel()
            self.m_loadingUI:hideLoading()

        end
    end)

end

-------------------------------------
-- function linkWithApple
-------------------------------------
function LoginHelper:linkWithApple()
    if isWin32() then
        UIManager:toastNotificationRed(Str('Windows에서는 동작하지 않습니다.'))
        return
    end

    self.m_loadingUI:showLoading(Str('계정 연동 중...'))

    local old_platform_id = g_localData:get('local', 'platform_id')

    PerpleSDK:linkWithApple(function(ret, info)

        if ret == 'success' then

            cclog('Firebase Apple link was successful.')
            self.m_loadingUI:hideLoading()

            self:loginSuccess(info)

            MakeSimplePopup(POPUP_TYPE.OK, Str('계정 연동에 성공하였습니다.'), function()
                self:unlink(old_platform_id)
            end)

        elseif ret == 'already_in_use' then

            local ok_btn_cb = function()
                self.m_loadingUI:showLoading(Str('계정 전환 중...'))
                PerpleSDK:logout()
                PerpleSDK:loginWithApple(function(ret, info)
                    self.m_loadingUI:hideLoading()
                    if ret == 'success' then
                        cclog('Firebase Apple link was successful.(already_in_use)')

                        self:loginSuccess(info)

                        -- 앱 재시작
                        CppFunctions:restart()

                    elseif ret == 'fail' then
                        self:loginFail(info)
                    elseif ret == 'cancel' then
						self:loginCancel()
                    end
                end)
            end

            local cancel_btn_cb = nil

            self.m_loadingUI:hideLoading()
            local msg = Str('이미 연결되어 있는 계정입니다.\n계정에 연결되어 있는 기존의 게임 데이터를 불러오시겠습니까?')
            local submsg = Str('현재의 게임데이터는 유실되므로 주의바랍니다.')
            MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb, cancel_btn_cb)

        elseif ret == 'fail' then
			self:loginFail(info)
            self.m_loadingUI:hideLoading()

        elseif ret == 'cancel' then
			self:loginCancel()
            self.m_loadingUI:hideLoading()

        end
    end)
end

-------------------------------------
-- function linkWithGameCenter
-------------------------------------
function LoginHelper:linkWithGameCenter()
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
			    self:loginFail(info)
                self.m_loadingUI:hideLoading()

            elseif (ret == 'cancel') then
                cclog('GameCenter login canceled.')
			    self:loginCancel()
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
                self:loginFail(info)

            elseif (ret == 'cancel') then
                cclog('Firebase GameCenter login canceled.')
				self:loginCancel()
            end
        end)
    end

    -- 함수 시작
    func_gamecenter_login()
end

-------------------------------------
-- function unlink
-- @brief 로그아웃
-------------------------------------
function LoginHelper:unlink(old_platform_id)
    -- google
    if old_platform_id == 'google.com' then
        PerpleSDK:googleLogout()
        PerpleSDK:unlinkWithGoogle(function(ret, info)
            if ret == 'success' then
                cclog('Firebase unlink from Google was successful.')
            elseif ret == 'fail' then
                cclog('Firebase unlink from Google failed.')
            end
        end)
				
    -- facebook
    elseif old_platform_id == 'facebook.com' then
        PerpleSDK:unlinkWithFacebook(function(ret, info)
            if ret == 'success' then
                cclog('Firebase unlink from Facebook was successful.')
            elseif ret == 'fail' then
                cclog('Firebase unlink from Facebook failed.')
            end
        end)

    -- twitter
    elseif old_platform_id == 'twitter.com' then
        PerpleSDK:unlinkWithTwitter(function(ret, info)
            if ret == 'success' then
                cclog('Firebase unlink from Twitter was successful.')
            elseif ret == 'fail' then
                cclog('Firebase unlink from Twitter failed.')
            end
        end)

    -- apple
    elseif old_platform_id == 'apple.com' then
        PerpleSDK:unlinkWithApple(function(ret, info)
            if ret == 'success' then
                cclog('Firebase unlink from Apple was successful.')
            elseif ret == 'fail' then
                cclog('Firebase unlink from Apple failed.')
            end
        end)

    -- gamecenter
    elseif old_platform_id == 'gamecenter' then
        PerpleSDK:unlinkWithGameCenter(function(ret, info)
            if ret == 'success' then
                cclog('Firebase unlink from GameCenter was successful.')
            elseif ret == 'fail' then
                cclog('Firebase unlink from GameCenter failed.')
            end
        end)
    end
end

-------------------------------------
-- function logout
-- @brief 로그아웃
-------------------------------------
function LoginHelper:logout()
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
-- function requestDeleteAccount
-- @brief 계정 삭제 (7일 후 삭제 진행)
-------------------------------------
function LoginHelper:requestDeleteAccount()
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if (isWin32() == false) then
            PerpleSDK:logout()
            PerpleSDK:googleLogout()
            PerpleSDK:facebookLogout()
            PerpleSDK:twitterLogout()
        end

        -- 로컬 세이브 데이터 삭제
        removeLocalFiles()

        MakeSimplePopup(POPUP_TYPE.OK, Str('계정 삭제 요청이 완료되었습니다.'), function() 
            -- 어플 재시작
            CppFunctions:restart()
        end)
    end

    local function fail_cb(ret)
        local status = ret['status'] or 0

        local main_msg = Str('오류가 발생했습니다.') .. '\n' .. Str('오류코드와 함께 고객센터로 문의해주시기를 바랍니다.')
        local sub_msg = Str('에러코드 : {1}', status)

        MakeSimplePopup2(POPUP_TYPE.OK, main_msg, sub_msg)
    end

    local ui_network = UI_Network()
    ui_network:setUrl( '/users/delete_user_account_request')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function requestCancelDeleteAccount
-- @brief 계정 삭제 7일 내에 계정 삭제 취소
-------------------------------------
function LoginHelper:requestCancelDeleteAccount(uid, success_cb, fail_cb, response_status_cb)
    local ui_network = UI_Network()
    ui_network:setUrl( '/users/delete_user_account_request_cancel')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end



-------------------------------------
-- function deleteAccount
-- @brief 계정 삭제 (바로 - 개발서버, QA서버용)
-------------------------------------
function LoginHelper:deleteAccount()
    -- 클랜 확인 (클랜 가입 상태인 경우 계정 삭제 불가)
    local is_clan_guest = g_clanData:isClanGuest()
    if (is_clan_guest == false) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('클랜 탈퇴 후 이용이 가능합니다.'))
        return
    end

    local ok_callback = function()
        local uid = g_userData:get('uid')
        local success_cb = function()
            if (isWin32() == false) then
                PerpleSDK:logout()
                PerpleSDK:googleLogout()
                PerpleSDK:facebookLogout()
				PerpleSDK:twitterLogout()
            end

            removeLocalFiles()

            -- AppDelegate_Custom.cpp에 구현되어 있음
            CppFunctions:restart()
        end

        local ui_network = UI_Network()
        ui_network:setUrl( '/users/delete_user_account')
        ui_network:setParam('uid', uid)
        ui_network:setSuccessCB(success_cb)
        ui_network:setRevocable(true)
        ui_network:setMethod('POST')
        ui_network:request()
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('정말 계정을 삭제하시겠습니까?'), ok_callback)
end

-------------------------------------
-- function clearAccount
-- @brief 계정 초기화 .. 개발용
-------------------------------------
function LoginHelper:clearAccount()
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

--------------------------------------------------------------------------
-- function postprocess
--------------------------------------------------------------------------

-------------------------------------
-- function loginSuccess
-------------------------------------
function LoginHelper:loginSuccess(info)
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

    if platform_id == 'google.com' then
		if (t_info['google'] and t_info['google']['playServicesConnected']) then
			g_localData:setGooglePlayConnected(true)
		end
    else
        g_localData:setGooglePlayConnected(false)
    end

    -- 케이스 별 콜백 처리
    if (self.m_successCb ~= nil) then
        self.m_successCb(info)
    end
end

-------------------------------------
-- function loginFail
-------------------------------------
function LoginHelper:loginFail(info)
    PerpleSdkManager:makeErrorPopup(info)
end

-------------------------------------
-- function loginCancel
-------------------------------------
function LoginHelper:loginCancel()
    local msg = Str('로그인을 취소했습니다.')
    MakeSimplePopup(POPUP_TYPE.OK, msg)
end
