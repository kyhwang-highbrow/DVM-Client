local PARENT = UI

-------------------------------------
-- class UI_TitleScene
-------------------------------------
UI_TitleScene = class(PARENT,{
        m_lWorkList = 'list',
        m_workIdx = 'number',
        m_loadingUI = 'UI_TitleSceneLoading',
        m_bNewUser = 'boolean',

        m_currWorkRetry = 'number',

		m_stopWatch = 'StopWatch',        
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TitleScene:init()
    local vars = self:load('title.ui')
    UIManager:open(self, UIManager.SCENE)

	self.m_stopWatch = Stopwatch() --G_STOPWATCH
	self.m_stopWatch:start()
	self.m_stopWatch:record('init titleScene')

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_TitleScene')

    self:initUI()
    self:initButton()
    self:refresh() 

	-- 사운드는 타이틀에서 사용하기 때문에 여기서 초기화
    SoundMgr:entry()

    -- 로컬 데이터 초기화
    SettingData:getInstance():applySetting()

    -- @brief work초기화 용도로 사용함
    self:setWorkList()
    self:doNextWork()

    -- 풀팝업 매니저 인스턴스 생성
    FullPopupManager:initInstance()

    --네이버 카페 글로벌 세팅(서버 선택이 필요해서 이쪽으로 옮깁니다.)
    self:initNaverPlug()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TitleScene:initUI()
    local vars = self.vars

    do -- spine으로 리소스 변경
        local animator = AnimatorHelper:getTitleAnimator()
        vars['animatorNode']:addChild(animator.m_node)
        vars['animator'] = animator
        animator:changeAni('02_scene_replace', true)
    end

    vars['messageLabel']:setVisible(false)
    vars['downloadLabel']:setVisible(false)
	vars['downloadGauge']:setVisible(false)

    do -- 앱버전과 패치 정보를 출력
        local patch_idx_str = PatchData:getInstance():getAppVersionAndPatchIdxString()
        vars['patchIdxLabel']:setString(patch_idx_str)
    end    

    self.m_loadingUI = UI_TitleSceneLoading()
    self.m_loadingUI:hideLoading()

    -- @UI_ACTION
    self:doActionReset()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TitleScene:initButton()
    self.vars['okButton']:registerScriptTapHandler(function() self:click_screenBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TitleScene:refresh()
end

-------------------------------------
-- function click_exitBtn
-- @brief 종료
-------------------------------------
function UI_TitleScene:click_exitBtn()
    if self.m_loadingUI:onLoading() then
        return
    end

    local function yes_cb()
        closeApplication()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('종료하시겠습니까?'), yes_cb)
end

-------------------------------------
-- function setTouchScreen
-- @brief '화면을 터치하세요' 문구 출력
-------------------------------------
function UI_TitleScene:setTouchScreen()
    local node = self.vars['messageLabel']

    node:setOpacity(255)

    local sequence = cc.Sequence:create(cc.FadeOut:create(1), cc.FadeIn:create(0.2))
    node:stopAllActions()
    node:runAction(cc.RepeatForever:create(sequence))

    node:setVisible(true)
    node:setString(Str('화면을 터치하세요.'))

	-- 로딩이 완료된 시점에서 사운드 교체
	self.vars['okButton']:setClickSoundName('ui_game_start')
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_TitleScene:click_screenBtn()
	local work_step = self.m_lWorkList[self.m_workIdx]
	if (not work_step) then
		return
	end

    local func_name = work_step .. '_click'
    if func_name and (self[func_name]) then
        self[func_name](self)
    end
end

-------------------------------------
-- function initChatClientSocket
-- @brief 채팅 클라이언트 소켓 초기화
-------------------------------------
function UI_TitleScene:initChatClientSocket()
    -- 김성구 로컬 서버
    --local ip = '192.168.1.105'
    --local port = '3927'

    local ip, port = GetChatServerUrl()
    local chat_client_socket = ChatClientSocket(ip, port)

    local t_data = self:makeUserDataForChatSocket()
    chat_client_socket:setUserInfo(t_data)

    -- 전역 변수로 설정
    g_chatClientSocket = chat_client_socket

    self:initLobbyManager(chat_client_socket)
    self:initChatManager(chat_client_socket)
end

-------------------------------------
-- function initChatClientSocket_Clan
-- @brief 채팅 클라이언트 소켓 초기화
-------------------------------------
function UI_TitleScene:initChatClientSocket_Clan()
    -- 김성구 로컬 서버
    --local ip = '192.168.1.105'
    --local port = '3927'

    local ip, port = GetClanChatServerUrl()
    local chat_client_socket = ChatClientSocket(ip, port)

    -- 채팅 소켓에서 사용되는 유저 정보 테이블 생성
    local t_data = self:makeUserDataForChatSocket()
    chat_client_socket:setUserInfo(t_data)

    do -- 클랜 로비 매니저 생성
        LobbyManager_Clan:initInstance()
        g_clanLobbyManager:setChatClientSocket(chat_client_socket)
        chat_client_socket:addRegularListener(g_clanLobbyManager)
    end

    do -- 클랜 채팅 매니저 생성
        ChatManagerClan:getInstance()
        g_clanChatManager:setChatClientSocket(chat_client_socket)
        chat_client_socket:addRegularListener(g_clanChatManager)
    end
end

-------------------------------------
-- function makeUserDataForChatSocket
-- @brief 채팅 소켓에서 사용되는 유저 정보 테이블 생성
-------------------------------------
function UI_TitleScene:makeUserDataForChatSocket()
    -- 유저 정보 입력
    local uid = g_localData:get('local', 'uid')
    local tamer_id = g_userData:get('tamer')
    local nickname = g_userData:get('nick')
    local lv = g_userData:get('lv')
    local tamer_title_id = g_userData:getTitleID()

    -- 리더 드래곤
    local leader_dragon = g_dragonsData:getLeaderDragon()
    local did = leader_dragon and tostring(leader_dragon['did']) or ''
    if (did ~= '') then
        did = did .. ';' .. leader_dragon['evolution']
    end

    local t_data = {}
    t_data['uid'] = tostring(uid)
    t_data['tamer'] = tostring(tamer_id)
    t_data['nickname'] = nickname
    t_data['did'] = did
    t_data['level'] = lv
    t_data['x'] = 0
    t_data['y'] = -150
    t_data['tamerTitleID'] = tamer_title_id
    t_data['json'] = {}

    do -- 클랜 정보
        local clan_struct = g_clanData:getClanStruct()
        if clan_struct then
            local t_clan = {}
            t_clan['name'] = clan_struct['name']
            t_clan['mark'] = clan_struct['mark']
            t_clan['id'] = clan_struct['id']
            t_data['json']['clan'] = t_clan
        end
    end

    do -- 테이머 코스츔 적용
        local struct_tamer_costume = g_tamerCostumeData:getCostumeDataWithTamerID(tamer_id)
        if (struct_tamer_costume:isDefaultCostume() == false) then
            local costume_id = struct_tamer_costume:getCid()
            t_data['tamer'] = t_data['tamer'] .. ';' .. tostring(costume_id)
        end
    end
    
    do -- 최초 랜덤 위치 지정
        local x, y = LobbyMapSpotMgr:makeRandomSpot()
        t_data['x'] = x
        t_data['y'] = y
    end

    return t_data
end

-------------------------------------
-- function initLobbyManager
-- @brief
-------------------------------------
function UI_TitleScene:initLobbyManager(chat_client_socket)
    LobbyManager:initInstance()
    g_lobbyManager:setChatClientSocket(chat_client_socket)

    if chat_client_socket then
        chat_client_socket:addRegularListener(g_lobbyManager)
    end
end

-------------------------------------
-- function initChatManager
-- @brief
-------------------------------------
function UI_TitleScene:initChatManager(chat_client_socket)
    ChatManager:getInstance()
    g_chatManager:setChatClientSocket(chat_client_socket)

    if chat_client_socket then
        chat_client_socket:addRegularListener(g_chatManager)
    end
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_TitleScene:setWorkList()
    self.m_workIdx = 0

    self.m_lWorkList = {}
    
    table.insert(self.m_lWorkList, 'workTitleAni')
    table.insert(self.m_lWorkList, 'workLoading')
    table.insert(self.m_lWorkList, 'workGetServerList')
    table.insert(self.m_lWorkList, 'workCheckUserID')    
    table.insert(self.m_lWorkList, 'workPlatformLogin')    
    table.insert(self.m_lWorkList, 'workGameLogin')
    table.insert(self.m_lWorkList, 'workGetDeck')
    table.insert(self.m_lWorkList, 'workGetServerInfo')
    table.insert(self.m_lWorkList, 'workBook')

    -- @perpelsdk
    if (isAndroid() or isIos()) then
        table.insert(self.m_lWorkList, 'workBillingSetup')        
        table.insert(self.m_lWorkList, 'workMarketInfoSetup')
    end

    table.insert(self.m_lWorkList, 'workSoundPreload')
    table.insert(self.m_lWorkList, 'workFinish')
    
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_TitleScene:doNextWork()
    self.m_currWorkRetry = 0
    self.m_workIdx = (self.m_workIdx + 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
		self.m_stopWatch:record(func_name .. '_start')
        cclog('\n')
        cclog('############################################################')
        cclog('# idx : ' .. self.m_workIdx .. ', func_name : ' .. func_name)
        cclog('############################################################')
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function doPreviousWork
-------------------------------------
function UI_TitleScene:doPreviousWork()
    self.m_workIdx = (self.m_workIdx - 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        cclog('\n')
        cclog('############################################################')
        cclog('# idx : ' .. self.m_workIdx .. ', func_name : ' .. func_name)
        cclog('############################################################')
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function retryCurrWork
-------------------------------------
function UI_TitleScene:retryCurrWork()
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        cclog('\n')
        cclog('############################################################')
        cclog('retry')
        cclog('# idx : ' .. self.m_workIdx .. ', func_name : ' .. func_name)
        cclog('############################################################')
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function workTitleAni
-- @brief 타이틀 연출 화면 (패치 종료 후 로그인 직전)
-------------------------------------
function UI_TitleScene:workTitleAni()
    -- @UI_ACTION
    self:doAction(nil, false)

    local vars = self.vars

    SoundMgr:playBGM('bgm_title')
    SoundMgr.m_bStopPreload = true

    local function ani_handler()
        vars['animator']:changeAni('04_title_idle', true)
        self:doNextWork()
    end

    vars['animator']:changeAni('03_title', false)
    vars['animator']:addAniHandler(ani_handler)
end

-------------------------------------
-- function workTitleAni_click
-- @brief 타이틀 연출 화면 클릭 (패치 종료 후 로그인 직전)
-------------------------------------
function UI_TitleScene:workTitleAni_click()
    local vars = self.vars
    vars['animator']:changeAni('04_title_idle', true)
    self:doNextWork()
end

-------------------------------------
-- function workLoading
-- @brief 로딩
-------------------------------------
function UI_TitleScene:workLoading()
    self.m_loadingUI:showLoading(Str('데이터 로딩 중...'))

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:yield()

        do -- TABLE:init의 기능을 여기서 수행
            local t_tale_info = TABLE:getTableInfo()
            local max_count = table.count(t_tale_info)
            local count = 0
            for k,v in pairs(t_tale_info) do
                count = (count + 1)
                -- self.m_loadingUI:showLoading(Str('로딩 중...') .. string.format(' %d/%d', count, max_count), false)
                co:yield()

                TABLE:loadCSVTable(v[1], k, v[2], v[3])
            end
            TableGradeInfo:initGlobal()
		end

	    ConstantData:getInstance()
        co:yield()

        ShaderCache:init()
        co:yield()

        TimeLib:initInstance()
        co:yield()

        ServerData:getInstance()
        co:yield()

        ChatIgnoreList:getInstance()
        co:yield()

        ScenarioViewingHistory:getInstance()
        co:yield()

        -- 다음 work로 이동
        self.m_loadingUI:hideLoading()
        self:doNextWork()
    end

    Coroutine(coroutine_function)
end
-------------------------------------
-- function workLoading_click
-------------------------------------
function UI_TitleScene:workLoading_click()
end

-------------------------------------
-- function workCheckUserID
-- @breif uid가 있는지 체크, UID가 없을 경우 난수 발생하여
--        uid로 사용
-------------------------------------
function UI_TitleScene:workCheckUserID()
    self.m_loadingUI:showLoading(Str('유저 계정 확인 중...'))

    SoundMgr.m_bStopPreload = false

    local target_server = CppFunctions:getTargetServer()
    if isWin32() then
        local uid = g_localData:get('local', 'uid')
        local server = g_localData:getServerName()
        if uid and server then
            self:doNextWork()
        else            
            self:makeRandomUid()
            self:selectWin32Server()
            self:doNextWork()
        end
        return
    end

    local function success_cb(info)
        local t_info = dkjson.decode(info)
        local fuid = t_info.fuid
        local push_token = t_info.pushToken
        local platform_id = t_info.providerId
        local account_info = t_info.name

        cclog('fuid: ' .. tostring(fuid))
        cclog('push_token: ' .. tostring(push_token))
        cclog('platform_id:' .. tostring(platform_id))
        cclog('account_info:' .. tostring(account_info))

        g_localData:lockSaveData()

        -- Firebase에서 발급하는 uid
        -- 게임 uid로 그대로 사용하면 됨
        g_localData:applyLocalData(fuid, 'local', 'uid')

        -- 푸시 발송을 위한 푸시토큰
        -- 로그인할 때마다 플랫폼 서버에 저장해야 함
        g_localData:applyLocalData(push_token, 'local', 'push_token')

        -- 현재 로그인된 계정의 플랫폼ID
        -- Google: 'google.com'
        -- Facebook: 'facebook.com'
		-- TWitter : 'twitter.com'
        -- Guest: 'firebase'
        g_localData:applyLocalData(platform_id, 'local', 'platform_id')

        -- 계정 정보(이름 or 이메일)
        g_localData:applyLocalData(account_info, 'local', 'account_info')

        g_localData:unlockSaveData()

        -- 혹시 시스템 오류로 멀티연동이 된 경우 현재 로그인한 플랫폼 이외의 연결은 해제한다.
        UnlinkBrokenPlatform(t_info, platform_id)

        if platform_id == 'google.com' then
            PerpleSDK:googleLogin(1, function(ret, info)
                g_localData:applyLocalData('on', 'local', 'googleplay_connected')
                self:doNextWork()
            end)
        else
            g_localData:applyLocalData('off', 'local', 'googleplay_connected')
            self:doNextWork()
        end
    end

    local function fail_cb()
        -- 자동로그인에 실패한 경우 로그인 팝업 출력
        local ui = UI_LoginPopup()
        local function close_cb()
            self:doNextWork()
        end
        ui:setCloseCB(close_cb)
    end

    -- iOS의 경우 앱을 재설치해도 autoLogin이 성공하므로
    -- 로컬데이터가 없는 경우를 재설치 경우로 보고,
    -- 이전 플랫폼 관련 로그인 세션을 모두 로그아웃하고 로그인 팝업 출력
    local needLogOut = false    
    if g_localData:getServerName() == nil then  --선택 서버 내용이 없어도.
        needLogOut = true
    elseif isIos() and (g_localData:get('local', 'platform_id') == nil) then        
        needLogOut = true
    end

    if needLogOut then
        self.m_loadingUI:hideLoading()

        PerpleSDK:logout()
        PerpleSDK:googleLogout(0)
        PerpleSDK:facebookLogout()
		PerpleSDK:twitterLogout()

        fail_cb()
        return
    end
        
    PerpleSDK:autoLogin(function(ret, info)
        self.m_loadingUI:hideLoading()
        if ret == 'success' then
            cclog('Firebase autoLogin was successful.')
            success_cb(info)
        elseif ret == 'fail' then
            cclog('Firebase autoLogin failed.')
            fail_cb()
        end
    end)

end

function UI_TitleScene:workCheckUserID_click()
end

-------------------------------------
-- function workGetServerList
-- @brief 플랫폼 서버에 서버리스트를 얻어 온다
-------------------------------------
function UI_TitleScene:workGetServerList()
    self.m_loadingUI:showLoading(Str('서버 목록을 받아오는 중...'))

    local success_cb = function(ret)
        self.m_loadingUI:hideLoading()
                
        if ret['state'] == 0 then            
            ServerListData:createWithData(ret)
            self:doNextWork()            
        else            
            self:makeFailPopup(nil, ret)
        end
    end

    local fail_cb = function(ret)
        self.m_loadingUI:hideLoading()
        self:makeFailPopup(nil, ret)
    end

    Network_platform_getServerList( success_cb, fail_cb )
end
function UI_TitleScene:workGetServerList_click()
end

-------------------------------------
-- function workPlatformLogin
-- @brief 플랫폼 서버에 복구 코드 요청
--        C/S 처리에 따라 이 과정에서 uid 가 변경될 수 있음
-------------------------------------
function UI_TitleScene:workPlatformLogin()
    self.m_loadingUI:showLoading(Str('플랫폼 서버에 로그인 중...'))

    local success_cb = function(ret)
        self.m_loadingUI:hideLoading()
        local t_status = ret['status']
        if (t_status['retcode'] == 0) then
            ccdump(ret)

            -- uid 저장
            g_localData:applyLocalData(ret['uid'], 'local', 'uid')

            -- 복구코드 저장            
            g_localData:applyLocalData(ret['rcode'], 'local', 'recovery_code')

            local terms = (ret['terms'] or 1)
            if (terms == 0) then
                -- 약관 동의 팝업
                local ui = UI_TermsPopup()
                local function close_cb()
                    local agree_terms = g_localData:get('local', 'agree_terms')
                    if (agree_terms == 0) then
                        -- 약관 동의 창에서 백키를 누르면 로그인 팝업 단계로 돌아간다.
                        -- 이때 바로 이전 단계로 돌아가면 autoLogin 이 성공하면서 로그인 팝업이 뜨지 않으므로
                        -- 로그아웃을 먼저 하고 돌아가야 함.
                        PerpleSDK:logout()
                        self:doPreviousWork()
                    else
                        self:doNextWork()
                    end
                end
                ui:setCloseCB(close_cb)
            else
                self:doNextWork()    
            end
        else
            --local msg = luadump(ret)
            self:makeFailPopup(nil, ret)
        end
    end

    local fail_cb = function(ret)
        self.m_loadingUI:hideLoading()
        self:makeFailPopup(nil, ret)
    end

    local rcode = g_localData:get('local', 'recovery_code')
    local os = 0 -- ( 0 : Android / 1 : iOS )
    if (isAndroid() == true) then
        os = 0
    elseif (isIos() == true) then
        os = 1
    end
    local pushToken = g_localData:get('local', 'push_token')
    local game_push = g_localData:get('push_state') or 1    -- 1(on) or 0(off)

    Network_platform_issueRcode(rcode, os, game_push, pushToken, success_cb, fail_cb)
end
function UI_TitleScene:workPlatformLogin_click()
end

-------------------------------------
-- function workPlatformNotiServer
-- @brief 플랫폼 서버에 선택한 서버를 알려준다.
-------------------------------------
function UI_TitleScene:workPlatformNotiServer()
    self.m_loadingUI:showLoading(Str('서버 선택을 저장 하는 중...'))

    local success_cb = function(ret)
        self.m_loadingUI:hideLoading()
        cclog( luadump( ret ) )        
        
        if ret['state'] == 0 then
            self:doNextWork()
        else            
            self:makeFailPopup(nil, ret)
        end
    end

    local fail_cb = function(ret)
        self.m_loadingUI:hideLoading()
        self:makeFailPopup(nil, ret)
    end

    Network_platform_electionServer( success_cb, fail_cb )
end

-------------------------------------
-- function workGameLogin
-- @brief 게임서버에 로그인
-------------------------------------
function UI_TitleScene:workGameLogin()
    self.m_loadingUI:showLoading(Str('게임 서버에 로그인 중...'))

    local uid = g_localData:get('local', 'uid')

    -- 네이버 카페에 uid 연동
    NaverCafeManager:naverCafeSyncGameUserId(uid)

    local success_cb = function(ret)
        do -- 사전 등록 닉네임 선점 정보 저장 (nil이면 비활성화)
            g_serverData:applyServerData(ret['preoccupancy_nick'], 'preoccupancy_nick')
        end

        -- 최초 로그인인 경우 계정 생성
        if ret['newuser'] then
            self.m_bNewUser = true
            g_startTamerData:setData(ret)
            self.m_loadingUI:hideLoading()
            self:setTouchScreen()
            return
        end

        g_serverData:lockSaveData()
        
		g_serverData:applyServerData(ret['user'], 'user')
        g_serverData:applyServerData(ret['tamers'], 'tamers')
        
		g_tamerData:reMappingTamerInfo(ret['tamers'])
		--g_questData:refreshQuestData(ret['quest_info'])

        -- 자신의 클랜이 있으면 저장
        g_clanData:setClanStruct(ret['clan'])
        g_clanData.m_bAttdRewardNoti = ret['clan_attd_reward']

		g_serverData:unlockSaveData()

        -- server_info 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        -- QA 계정 통계비활성화
        if (ret['qa'] ~= nil) and (ret['qa'] == true) then
            Analytics:setEnable(false)
        end

        -- 일일 데이터 초기화 (풀팝업, 로비 도우미 본 기록 등)
        if (ret['first_login']) then
			g_settingData:clearDataListDaily()
		end
        
        self:doNextWork()
    end

    local fail_cb = function(ret)
        self:makeFailPopup(nil, ret)
    end

    -- 디바이스 정보를 받음
    local function cb_func(ret, info)

        -- ret의 값에 상관없이 로그인 진행
        local device_info_json = json_decode(info) or {}
        Network_login(uid, nickname, device_info_json, success_cb, fail_cb)
    end

    SDKManager:deviceInfo(cb_func)
end

-------------------------------------
-- function workGameLogin_click
-- @brief 신규계정 생성시에만 클릭 가능함
-------------------------------------
function UI_TitleScene:workGameLogin_click()
    if self.m_bNewUser then
        self:createAccount()
    end
end

-------------------------------------
-- function workGetDeck
-- @brief
-------------------------------------
function UI_TitleScene:workGetDeck()
    self.m_loadingUI:showLoading(Str('덱 정보 요청 중...'))

    local uid = g_localData:get('local', 'uid')

    local success_cb = function(ret)
        g_serverData:applyServerData(ret['deck'], 'deck')
        
        self:doNextWork()
    end

    local fail_cb = function(ret)
        self:makeFailPopup(nil, ret)
    end

    Network_get_deck(uid, success_cb, fail_cb)
end
function UI_TitleScene:workGetDeck_click()
end

-------------------------------------
-- function workGetServerInfo
-- @brief
-------------------------------------
function UI_TitleScene:workGetServerInfo()
    local function coroutine_function(dt)
        local co = CoroutineHelper()

        local fail_cb = function(ret)
            self:retryCurrWork3Times(nil, ret)
        end

        -- (테이블 정보를 받는 중)
        co:work()
        self.m_loadingUI:showLoading(Str('지도를 챙기는 중...'))
        local ui_network = g_serverData:request_serverTables(co.NEXT, fail_cb)
        if ui_network then
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 룬 정보 받기
        co:work()
        self.m_loadingUI:showLoading(Str('룬을 챙기는 중...'))
        local ui_network = g_runesData:request_runesInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 드래곤 정보 받기
        co:work()
        self.m_loadingUI:showLoading(Str('드래곤들을 부르는 중...'))
        local ui_network = g_dragonsData:request_dragonsInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

		-- 스테이지 리스트 받기
        co:work()
        self.m_loadingUI:showLoading(Str('지난 흔적을 찾는 중...'))
        local ui_network = g_adventureData:request_adventureInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        --[[
        -- 탐험 정보 받기
        co:work()
        self.m_loadingUI:showLoading(Str('탐험지역을 탐색 중...'))
        local ui_network = g_explorationData:request_explorationInfo(co.NEXT)
        ui_network:setRevocable(false)
        ui_network:setFailCB(fail_cb)
        ui_network:hideLoading()
        if co:waitWork() then return end
        --]]

        -- 부화소 정보 받기
        co:work()
        self.m_loadingUI:showLoading(Str('알 부화를 준비 중...'))
        local ui_network = g_hatcheryData:request_hatcheryInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

		-- 핫 타임
        co:work()
        self.m_loadingUI:showLoading(Str('핫타임 정보 요청 중...'))
        local ui_network = g_hotTimeData:request_hottime(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

		-- 드빌 전용관 정보
		if (g_localData:isShowHighbrowShop()) then
			co:work()
			self.m_loadingUI:showLoading(Str('이전 추억을 되살리는 중...'))
			local ui_network = g_highbrowData:request_getHbProductList(co.NEXT, fail_cb)
			if ui_network then
				ui_network:setRevocable(false)
				ui_network:setFailCB(fail_cb)
				ui_network:hideLoading()
			end
			if co:waitWork() then return end
		end

        -- 접속시간 이벤트
        co:work()
        self.m_loadingUI:showLoading(Str('접속시간 정보 요청 중...'))
        local ui_network = g_accessTimeData:request_accessTime(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 네스트 던전 정보
        co:work()
        self.m_loadingUI:showLoading(Str('던전 정보를 확인 중...'))
        local ui_network = g_nestDungeonData:requestNestDungeonInfo(co.NEXT)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 튜토리얼
        co:work()
        self.m_loadingUI:showLoading(Str('튜토리얼 정보를 가져오는 중...'))
        local ui_network = g_tutorialData:request_tutorialInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 마스터의 길
        co:work()
        self.m_loadingUI:showLoading(Str('마스터의 길을 닦는 중...'))
        local ui_network = g_masterRoadData:request_roadInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 드래곤 성장일지
        co:work()
        self.m_loadingUI:showLoading(Str('네트워크 통신 중...'))
        local ui_network = g_dragonDiaryData:request_diaryInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 상점 정보 
        -- # 먼저 sku를 받아온 후 perplesdk 호출하여 해당 sku에 대한 마켓 정보 받아옴
        -- # 마켓 정보는 타이틀씬에서만 처리
        co:work()
        self.m_loadingUI:showLoading(Str('네트워크 통신 중...'))
        local ui_network = g_shopDataNew:request_shopInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 레벨업 패키지
        co:work()
        self.m_loadingUI:showLoading(Str('가방을 챙기는 중...'))
        local ui_network = g_levelUpPackageData:request_lvuppackInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 레벨업 패키지
        co:work()
        self.m_loadingUI:showLoading(Str('가방을 챙기는 중...'))
        local ui_network = g_adventureClearPackageData:request_adventureClearInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:setFailCB(fail_cb)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

		-- @ daily mission
		co:work()
        self.m_loadingUI:showLoading(Str('오늘의 미션 확인 중...'))
        local ui_network = g_dailyMissionData:request_dailyMissionInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

		-- @ capsule box
		co:work()
        self.m_loadingUI:showLoading(Str('캡슐 뽑기 채워넣는 중...'))
        local ui_network = g_capsuleBoxData:request_capsuleBoxInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:setRevocable(false)
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        do -- 콜로세움 덱 정보 받기 (추후 통합 API 제작할 것!) sgkim
            co:work()
            self.m_loadingUI:showLoading(Str('간식을 챙기는 중...'))
            local ui_network = g_colosseumData:request_playerColosseumDeck('atk', co.NEXT, fail_cb)
            ui_network:hideLoading()
            if co:waitWork() then return end

            co:work()
            self.m_loadingUI:showLoading(Str('신발을 신는 중...'))
            local ui_network = g_colosseumData:request_playerColosseumDeck('def', co.NEXT, fail_cb)
            if ui_network then
                ui_network:hideLoading()
            end
            if co:waitWork() then return end

            -- 콜로세움 정보 받아옴
            co:work()
            self.m_loadingUI:showLoading(Str('신발을 신는 중...'))
            local ui_network = g_colosseumData:request_colosseumInfo(co.NEXT, fail_cb)
            if ui_network then
                ui_network:hideLoading()
            end
            if co:waitWork() then return end
        end

        -- 고대의 탑 정보 받아옴
        co:work()
        self.m_loadingUI:showLoading(Str('신발을 신는 중...'))
        local ui_network = g_ancientTowerData:request_ancientTowerInfo(nil, co.NEXT, fail_cb)
        if ui_network then
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        co:close()

        -- 다음 work로 이동
        self:doNextWork()
    end

    Coroutine(coroutine_function)
end
function UI_TitleScene:workGetServerInfo_click()
end

-------------------------------------
-- function workBook
-- @brief
-------------------------------------
function UI_TitleScene:workBook()
    self.m_loadingUI:showLoading(Str('도감 정보 받는 중...'))

    local success_cb = function(ret)
        self:doNextWork()
    end

    local fail_cb = function(ret)
        self:makeFailPopup(nil, ret)
        return true
    end

    local ui_network = g_bookData:request_bookInfo(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setLoadingMsg('')
    ui_network:hideLoading()
end
function UI_TitleScene:workBook_click()
end

-------------------------------------
-- function workBillingSetup
-- @brief Billing 초기화
-------------------------------------
function UI_TitleScene:workBillingSetup()
    self.m_loadingUI:showLoading(Str('결제 정보 초기화...'))

    local l_payload = {}
    local function call_back(ret, info)
        cclog('# UI_TitleScene:workBillingSetup() result : ' .. tostring(ret))
        if (ret == 'purchase') then
            cclog('#### billingSetup success - info : ')
            ccdump(info)

            --[[
            -- info : [{"orderId":"@orderId","payload":"@payload"},...]
            local info_json = dkjson.decode(info)
            if (info_json and type(info_json) == 'table' and 0 < #info_json) then
                local l_payload = info_json

                local function finish_cb()
                    self:doNextWork()
                end

                StructProduct:handlingMissingPayments(l_payload, nil, finish_cb)
            else
                self:doNextWork()
            end
            --]]

            local function finish_cb()
                self:doNextWork()
            end

            local info_json = dkjson.decode(info)
            if info == '' or info_json == nil then
                StructProduct:handlingMissingPayments(l_payload, nil, finish_cb)
            else
                if #info_json == table.count(info_json) then
                    -- info : [{"orderId":"@orderId","payload":"@payload"},...]
                    StructProduct:handlingMissingPayments(info_json, nil, finish_cb)
                else
                    -- info : {"orderId":"@orderId"}
                    table.insert(l_payload, info_json)
                end
            end
            
        elseif (ret == 'fail') then
            cclog('#### billingSetup failed - info : ')
            ccdump(info)
            --local info_json = dkjson.decode(info)

            -- 결제 시스템 초기화에 실패하더라도 게임 진입을 허용
            local function finish_cb()
                self:doNextWork()
            end

            -- 인포에서 넘어온 msg는 무시
            -- local desc = Str(info_json.msg)
            local msg = Str('결제 시스템 초기화에 실패하였습니다.')
            local submsg = Str('(결제 시도 시 결제에 실패할 경우 재접속 후 다시 시도해주세요)')
            MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg, finish_cb)
        else
            self:doNextWork()
        end
    end

    -- 영수증 검증 API 주소
    local url = GetPlatformApiUrl() .. '/payment/receiptValidation/'
    PerpleSDK:billingSetup(url, call_back)
end
function UI_TitleScene:workBillingSetup_click()
end

-------------------------------------
-- function workMarketInfoSetup
-- @brief 마켓 정보 초기화
-------------------------------------
function UI_TitleScene:workMarketInfoSetup()
    self.m_loadingUI:showLoading(Str('네트워크 통신 중...'))

    local function call_back(ret, info)
        if (ret == 'success') then
            local tRet = json_decode(info)
            g_shopDataNew:setMarketPrice(tRet)

        elseif (ret == 'fail') then
            cclog('#### billingItemInfo failed - info : ')
            ccdump(info)
            
            local msg = Str('결제 아이템 정보를 가져오는데 실패했습니다.')
        end

        self:doNextWork()
    end

    local skuList = g_shopDataNew:getSkuList()
    if skuList == nil then
        self:doNextWork()
        return
    end

    PerpleSDK:billingGetItemList(skuList, call_back)
end
function UI_TitleScene:workMarketInfoSetup_click()
end

-------------------------------------
-- function workSoundPreload
-- @brief 사운드 프리로드
-------------------------------------
function UI_TitleScene:workSoundPreload()
    self:initChatClientSocket()
    self:initChatClientSocket_Clan()
    --ChatManager:getInstance()

    if SoundMgr:isPreloadFinish() then
        self:doNextWork()
    else
        SoundMgr.m_cbPreloadFinish = function()
            self:doNextWork()
        end
    end
end
function UI_TitleScene:workSoundPreload_click()
end

-------------------------------------
-- function workFinish
-- @brief 로그인 완료 Scene 전환
-------------------------------------
function UI_TitleScene:workFinish()
    -- 로딩창 숨김
    self.m_loadingUI:hideLoading()

    -- 신규 유저 바로 진입 가능하게 변경
    if self.m_bNewUser then
        self:workFinish_click()
    else
    -- 화면을 터치하세요. 출력
        self:setTouchScreen()
    end

	self.m_stopWatch:stop()
    self.m_stopWatch:print()
end

function UI_TitleScene:workFinish_click()
    -- 모든 작업이 끝난 경우 로비로 전환
    local lobby_func
    local check_intro_func
    
    -- @analytics
    Analytics:userInfo()
    Analytics:setAppDataVersion()

    -- 계정 생성시에는 lobby_func 타지 않으므로 여기서 title_to_lobby 저장 
    g_fullPopupManager:setTitleToLobby(true)

    -- 로비 진입
    lobby_func = function() 
        -- 시작이 두번 되지 않도록 하기 위함
        UI_BlockPopup()

        local is_use_loading = true
        local scene = SceneLobby(is_use_loading)
        scene:runScene()
    end
	
    -- 인트로 시나리오 체크
    check_intro_func = function()
        g_scenarioViewingHistory:checkIntroScenario(lobby_func)
    end

    -- 인트로 시나리오 로비씬 진입전 체크로 수정 - 신규유저일때만
    if (self.m_bNewUser) then
        check_intro_func()
    else
        lobby_func()
    end
end

-------------------------------------
-- function selectWindowServer
-------------------------------------
function UI_TitleScene:selectWin32Server()
    local server = CppFunctionsClass:getTargetServer()
    g_localData:lockSaveData()
    ServerListData:getInstance():selectServer( server )
    g_localData:setServerName( server )
    g_localData:unlockSaveData()
end

-------------------------------------
-- function makeRandomUid
-------------------------------------
function UI_TitleScene:makeRandomUid()
    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local uuid = string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end) 

    g_localData:applyLocalData(uuid, 'local', 'uid')

    if isWin32() then
        g_localData:applyLocalData('', 'local', 'push_token')
        g_localData:applyLocalData('firebase', 'local', 'platform_id')
        g_localData:applyLocalData('Guest', 'local', 'account_info')
    end

end

-------------------------------------
-- function createAccount
-- @brief 신규 계정일 경우 계정 생성
-------------------------------------
function UI_TitleScene:createAccount()
    local prologue_func     -- 프롤로그 재생
    local tamer_sel_func    -- 테이머 선택
    local login_func        -- 계정 생성후 재로그인

    prologue_func = function()
        -- @analytics
        Analytics:firstTimeExperience('Prologue_Start')

        local scenario_name = 'scenario_prologue'
        local prologue = UI_ScenarioPlayer(scenario_name)
        prologue:setCloseCB(tamer_sel_func)
        prologue:next()
    end

    tamer_sel_func = function()
        -- @analytics
        Analytics:firstTimeExperience('Prologue_Finish')

		-- 스타팅 드래곤 선택 -> 닉네임 입력 : 콜백 계속 전달하여 닉네임 입력후 실행
        UI_SelectStartingDragon(login_func)
    end

    login_func = function()
        self.m_bNewUser = true
        self.m_loadingUI:showLoading()
		self.vars['messageLabel']:setVisible(false)
        self:retryCurrWork()
    end
    
    prologue_func()
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function retryCurrWork3Times
-- @brief
-------------------------------------
function UI_TitleScene:retryCurrWork3Times(msg, ret)
    self.m_currWorkRetry = (self.m_currWorkRetry + 1)

    if (self.m_currWorkRetry <= 3) then
        self:retryCurrWork()
    else
        self.m_currWorkRetry = 0
        self:makeFailPopup(msg, ret)
    end
end

-------------------------------------
-- function makeFailPopup
-- @brief
-------------------------------------
function UI_TitleScene:makeFailPopup(msg, ret)
    local function ok_btn_cb()
        self.m_loadingUI:showLoading()
        self:retryCurrWork()
    end

    local msg = msg or Str('오류가 발생하였습니다.\n다시 시도하시겠습니까?')

    if ret then
        local add_msg = '(status : ' .. tostring(ret['status']) .. ', message : ' .. tostring(ret['message']) .. ')'
        msg =  msg .. '\n\n' .. add_msg
    end

    self.m_loadingUI:hideLoading()
    MakeSimplePopup(POPUP_TYPE.OK, msg, ok_btn_cb)
end

-------------------------------------
-- function initNaverPlug
-- @brief
-------------------------------------
function UI_TitleScene:initNaverPlug()
    --글로벌 플러그 초기화
    NaverCafeManager:naverInitGlobalPlug(g_localData:getServerName(), g_localData:getLang(), g_localData:getSavedNaverChannel())

    -- 카페 위젯 노출 시작
    NaverCafeManager:naverCafeStartWidget()
    NaverCafeManager:naverCafeShowWidgetWhenUnloadSdk(1) -- @isShowWidget : 1(SDK unload 시 카페 위젯 보여주기) or 0(안 보여주기)

	--네이버 카페 콜백 연동
    NaverCafeManager:naverCafeSetCallback()
end

--@CHECK
UI:checkCompileError(UI_TitleScene)
