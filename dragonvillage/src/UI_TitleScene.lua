local PARENT = UI

-------------------------------------
-- class UI_TitleScene
-------------------------------------
UI_TitleScene = class(PARENT,{
        m_lWorkList = 'list',
        m_workIdx = 'number',
        m_loadingUI = 'UI_TitleSceneLoading',
        
        m_currWorkRetry = 'number',

		m_stopWatch = 'StopWatch',        
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TitleScene:init()
    local vars = self:load('title.ui')
    UIManager:open(self, UIManager.SCENE)
    self.m_uiName = 'UI_TitleScene'


	self.m_stopWatch = Stopwatch() --G_STOPWATCH
	self.m_stopWatch:start()
	self.m_stopWatch:record('start')

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

    do -- copyright
        local date = os.date('*t')
        local year = 2022
        if (date and date.year) then
            year = date.year
        end
        local str = Str('ⓒ {1}. highbrow Inc. all rights reserved.', year)
        vars['copylightImage']:setString(str)
    end

    -- 앱버전과 패치 정보, 게임 서버를 출력
    self:refresh_appVersionString()

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
-- function refresh_appVersionString
-- @brief 앱버전과 패치 정보, 게임 서버를 출력
-------------------------------------
function UI_TitleScene:refresh_appVersionString()
    local vars = self.vars
    local patch_idx_str = PatchData:getInstance():getAppVersionAndPatchIdxString()
    vars['patchIdxLabel']:setString(patch_idx_str)
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

    -- 전역 변수로 설정
    g_clanChatClientSocket = chat_client_socket

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
        -- 외형 변환 존재하는 경우에 추가 
        local transform = leader_dragon['transform'] 
        if (transform) then
            did = did .. ';' .. transform
        end
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

    do
        t_data['json']['last_arena_tier'] = g_arenaNewData.m_playerUserInfo.m_lastTier
    end

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
-- function isSkipGetMarketInfo
-- @brief 마켓(sku) 정보 받아오기 생략 여부
-------------------------------------
function UI_TitleScene:isSkipGetMarketInfo()
    -- 1.2.0버전
    if (getAppVer() ~= '1.2.0') then
        return false
    end
            
    -- ios일 경우
    if (isIos() ~= true) then
        return false
    end

    -- systemVersion의 값이 있을 경우 (ios 버전을 알기 위함)
    local system_version = g_userData:getDeviceInfoByKey('systemVersion')
    if (type(system_version) ~= 'string') then
        return false
    end

    -- major버전을 얻어옴
    cclog('systemVersion : ' .. system_version)
    local l_version = pl.stringx.split(system_version, '.')
    local major_version = tonumber(l_version[1])
    if (major_version == nil) then
        return false
    end

    -- ios 13이상인 경우
    cclog('major_version : ' .. major_version)
    if (major_version < 13) then
        return false
    end

    return true
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_TitleScene:setWorkList()
    self.m_workIdx = 0

    self.m_lWorkList = {}
    
    table.insert(self.m_lWorkList, 'workTitleAni') -- @jhakim 190709 (오래걸리는)타이틀 애니메이션 제거
    table.insert(self.m_lWorkList, 'workLoading')
    table.insert(self.m_lWorkList, 'workGetServerList')
    --table.insert(self.m_lWorkList, 'workCheckSelectedGameServer') -- 유저가 선택(or 추천)한 게임 서버 확인
    table.insert(self.m_lWorkList, 'workCheckUserID')
    table.insert(self.m_lWorkList, 'workPlatformLogin') 
    table.insert(self.m_lWorkList, 'workCheckDeletedUserID')
    table.insert(self.m_lWorkList, 'workPlatformLogin')
    table.insert(self.m_lWorkList, 'workGameLogin')
    table.insert(self.m_lWorkList, 'workAgreeTerms')
    table.insert(self.m_lWorkList, 'workGetServerInfo')

    -- @perpelsdk
    if (isAndroid() or isIos()) then        
        local is_new_billing_setup_process = false

        -- @mskim 2020.11.18, 1.2.7 앱 업데이트 분기 처리
        -- LIVE 1.2.7, QA 0.7.8, DEV 0.7.7 이상은 새로운 미지급 결제 처리 로직을 사용하도록 한다.
        if (IS_LIVE_SERVER() and getAppVerNum() >= 1002007) 
            or (IS_QA_SERVER() and getAppVerNum() >= 7008)
            or (CppFunctions:getTargetServer() == 'DEV' and getAppVerNum() >= 7007) then

            is_new_billing_setup_process = true
        end

        local is_billing_3 = false
        -- @ochoi 2021.09.23, 1.3.0 앱 업데이트 분기 처리
        -- LIVE 1.3.0, QA 0.7.8, DEV 0.7.9 이상은 새로운 결제 처리 로직을 사용하도록 한다.
        if (CppFunctionsClass:isAndroid() == true and getAppVerNum() >= 1003000)
            or (IS_QA_SERVER() and getAppVerNum() >= 7009)
            or (CppFunctions:getTargetServer() == 'DEV' and getAppVerNum() >= 7009) then

            is_billing_3 = true
        end


        -- market : Onestore or Google
        if (PerpleSdkManager:onestoreIsAvailable()) then
            if (is_new_billing_setup_process == true) then
                table.insert(self.m_lWorkList, 'workBillingSetupWithoutRestore') -- perple sdk                    
            else
                table.insert(self.m_lWorkList, 'workBillingSetup') -- perple sdk
            end
            table.insert(self.m_lWorkList, 'workBillingSetupForOnestore') -- perple sdk
            table.insert(self.m_lWorkList, 'workGetMarketInfoForOnestore') -- perple sdk
        else
            if (is_billing_3 == true) then
                table.insert(self.m_lWorkList, 'workNewBillingSetup') -- 인앱결제 초기화
                table.insert(self.m_lWorkList, 'workNewBillingGetItemList') -- 인앱결제 상품 정보 획득 (sku를 통해 현지화된 가격 등을 획득)
                table.insert(self.m_lWorkList, 'workGetMarketInfo_Monthly') -- perple sdk
                table.insert(self.m_lWorkList, 'workNewBillingGetIncompletePurchaseList') -- 완료되지 않은 결제건 조회
                table.insert(self.m_lWorkList, 'workNewBillingHandleIncompletePurchaseList') -- 완료되지 않은 결제건 처리
            elseif (is_new_billing_setup_process == true) then
                table.insert(self.m_lWorkList, 'workBillingSetupWithoutRestore') -- perple sdk                    
                table.insert(self.m_lWorkList, 'workBillingRestorePurchase') -- perple sdk
                table.insert(self.m_lWorkList, 'workGetMarketInfo') -- perple sdk
                table.insert(self.m_lWorkList, 'workGetMarketInfo_Monthly') -- perple sdk
            else
                table.insert(self.m_lWorkList, 'workBillingSetup') -- perple sdk
                table.insert(self.m_lWorkList, 'workGetMarketInfo') -- perple sdk
                table.insert(self.m_lWorkList, 'workGetMarketInfo_Monthly') -- perple sdk
            end
        end

        table.insert(self.m_lWorkList, 'workNetworkUserInfo') -- crash log에 정보 저장
        table.insert(self.m_lWorkList, 'workAdManagerInitialize') -- 광고 모듈 초기화
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
        local pre_func_name = self.m_lWorkList[self.m_workIdx - 1]
        if (pre_func_name) then
            self.m_stopWatch:record(pre_func_name)
        end

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
    -- @analytics
    Analytics:firstTimeExperience('Title_TitleAni')

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
    -- @analytics
    Analytics:firstTimeExperience('Title_Loading')

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

        LobbyChangeMgr:getInstance()
        co:yield()

        UserStatusAnalyser:init()
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
    -- @analytics
    Analytics:firstTimeExperience('Title_CheckUserID')

    self.m_loadingUI:showLoading(Str('유저 계정 확인 중...'))

    SoundMgr.m_bStopPreload = false

    -- user 기기 정보 확인
    local function cb(ret, info)
        local device_info_json = json_decode(info) or {}
        g_userData:setDeviceInfoTable(device_info_json)
    end
    SDKManager:deviceInfo(cb)

    -- Firebase Authentication으로 로그인 처리가 불가능지 여부
    local not_available_firebase = false

    -- 윈도우에서는 firebase 사용 불가
    if (isWin32()) then
        not_available_firebase = true
    end

    -- 테스트 모드에서는 firebase 사용 불가
    if (IS_TEST_MODE()) then
        not_available_firebase = true
    end

    -- 카페 바자르 빌드에서는 이란 제재로 firebase 서비스 불가
    if (CppFunctions:isCafeBazaarBuild() == true) then
        not_available_firebase = true
        return self:workCheckUserID_CafeBazaarBuild()
    end

    -- Firebase Authentication으로 로그인 처리가 불가능할 경우
    if (not_available_firebase == true) then
        local uid = g_localData:get('local', 'uid')
        if uid then
            self:doNextWork()
        else
            self.m_loadingUI:hideLoading()
            local ui = UI_LoginPopupWithoutFirebase()
            local function close_cb()
                self:doNextWork()
            end
            ui:setCloseCB(close_cb)
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
            PerpleSDK:googleSilentLogin(function(ret, info)
                self:doNextWork()
            end)
        else
            g_localData:setGooglePlayConnected(false)
            self:doNextWork()
        end
    end

    local function fail_cb()
        -- 자동로그인에 실패한 경우 로그인 팝업 출력
        --local ui = UI_LoginPopup()
        local ui = UI_LoginIntegratePopup(self)
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
        PerpleSDK:googleLogout()
        PerpleSDK:facebookLogout()
		PerpleSDK:twitterLogout()
        PerpleSDK:appleLogout()


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

-------------------------------------
-- function workCheckDeletedUserID
-- @breif 계정 탈퇴된 uid인지 체크 후 삭제된 uid라면 서버에서 전달받은 uid로 변경
-------------------------------------
function UI_TitleScene:workCheckDeletedUserID()
    local function success_cb(ret)
        self:doNextWork()
    end

    local function fail_cb(ret)
        self:retryCurrWork3Times(nil, ret)
    end

    g_userData:request_checkDeletedUserID(success_cb, fail_cb)
end

-------------------------------------
-- function workCheckDeletedUserID_click
-------------------------------------
function UI_TitleScene:workCheckDeletedUserID_click()
end


-------------------------------------
-- function workCheckUserID_CafeBazaarBuild
-- @breif 이란 빌드 전용
-------------------------------------
function UI_TitleScene:workCheckUserID_CafeBazaarBuild()
    cclog('workCheckUserID_CafeBazaarBuild()')

    local uid = g_localData:get('local', 'uid')
    if uid then
        self:doNextWork()
    else
        require('UI_IranLoginPopup')
        local ui = UI_IranLoginPopup()
        local function close_cb()
            self:doNextWork()
        end
        ui:setCloseCB(close_cb)
    end

end

function UI_TitleScene:workCheckUserID_click()
end

-------------------------------------
-- function workGetServerList
-- @brief 플랫폼 서버에 서버리스트를 얻어 온다
-------------------------------------
function UI_TitleScene:workGetServerList()
    -- @analytics
    Analytics:firstTimeExperience('Title_GetServerList')

    self.m_loadingUI:showLoading(Str('서버 목록을 받아오는 중...'))

    local success_cb = function(ret)
        self.m_loadingUI:hideLoading()
                
        if ret['state'] == 0 then            
            ServerListData:createWithData(ret)
            
            -- 앱버전과 패치 정보, 게임 서버를 출력
            self:refresh_appVersionString()

            self:doNextWork()            
        else            
            self:retryCurrWork3Times(nil, ret)
        end
    end

    local fail_cb = function(ret)
        self.m_loadingUI:hideLoading()
        self:retryCurrWork3Times(nil, ret)
    end

    Network_platform_getServerList( success_cb, fail_cb )
end
function UI_TitleScene:workGetServerList_click()
end

-------------------------------------
-- function workCheckSelectedGameServer
-- @brief 유저가 선택(or 추천)한 게임 서버 확인
-------------------------------------
function UI_TitleScene:workCheckSelectedGameServer()
    -- @analytics
    Analytics:firstTimeExperience('Title_CheckSelectedGameServer')

    -- 1. 서버 선택이 필요한지 여부
    local need_select_server = false
    
    -- 1-1. 선택된 게임 서버가 없을 경우
    --      기본적으로 ServerListData의 initWithData에서 추천 서버를 선택하기 때문에 이럴 경우는 없어야 한다.
    local server_name = g_localData:getServerName()
    if (not server_name) then
        need_select_server = true
    end

    -- 1-2. 유저 ID가 설정되지 않았을 경우 (최초 실행)
    local uid = g_localData:get('local', 'uid')
    if (not uid) then
        need_select_server = true
    end

    -- 2. 서버 선택 과정이 필요 없는 경우 다음 step으로
    if (not need_select_server) then
        self:doNextWork()
        return
    end

    -- 3. 서버 선택이 필요한 경우 팝업
    local open_select_server_popup
    local close_cb
    local popup_ui

    -- 3-1. 서버 선택 팝업 오픈
    open_select_server_popup = function()
        popup_ui = UI_SelectServerPopup(nil) -- param : finish_cb
        popup_ui:setCloseCB(close_cb)
    end

    -- 3-2. 서버 선택 종료
    close_cb = function()
        local server_name = popup_ui:getSelectedServerName()
        ServerListData:getInstance():selectServer(server_name)

        -- 앱버전과 패치 정보, 게임 서버를 출력
        self:refresh_appVersionString()

        self:doNextWork()
    end

    open_select_server_popup()
end
function UI_TitleScene:workCheckSelectedGameServer_click()
end


-------------------------------------
-- function workPlatformLogin
-- @brief 플랫폼 서버에 복구 코드 요청
--        C/S 처리에 따라 이 과정에서 uid 가 변경될 수 있음
-------------------------------------
function UI_TitleScene:workPlatformLogin()
    -- @analytics
    Analytics:firstTimeExperience('Title_PlatformLogin')

    self.m_loadingUI:showLoading(Str('플랫폼 서버에 로그인 중...'))

    local success_cb = function(ret)
        self.m_loadingUI:hideLoading()
        local t_status = ret['status']
        if (t_status['retcode'] == 0) then
            -- uid 저장
            g_localData:applyLocalData(ret['uid'], 'local', 'uid')

            -- 복구코드 저장            
            g_localData:applyLocalData(ret['rcode'], 'local', 'recovery_code')
            
            self:doNextWork()    
        else
            --local msg = luadump(ret)
            self:retryCurrWork3Times(nil, ret)
        end
    end

    local fail_cb = function(ret)
        self.m_loadingUI:hideLoading()
        self:retryCurrWork3Times(nil, ret)
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
-- function workAgreeTerms
-- @brief .
-------------------------------------
function UI_TitleScene:workAgreeTerms()
    self.m_loadingUI:showLoading(Str('약관 동의 확인 중...'))
    
    local function success_cb(is_needed_agree)
        self.m_loadingUI:hideLoading()
        
        if (is_needed_agree == true) then
            local function close_cb()
                if (g_localData:get('local', 'agree_terms') == 0) then
                    -- 약관 동의 창에서 백키를 누르면 로그인 팝업 단계로 돌아간다.
                    -- 이때 바로 이전 단계로 돌아가면 autoLogin 이 성공하면서 로그인 팝업이 뜨지 않으므로
                    -- 로그아웃을 먼저 하고 돌아가야 함.
                    PerpleSDK:logout()
                    self:doPreviousWork()
                else
                    self.m_loadingUI:showLoading()

                    local function agree_success_cb()
                        self.m_loadingUI:hideLoading()
                        self:doNextWork()
                    end

                    -- 실패하더라도 게임 진행되도록
                    g_userData:request_termsAgree(agree_success_cb, agree_success_cb)
                end
            end

            local ui = UI_TermsPopup()
            ui:setCloseCB(close_cb)
        else
            self.m_loadingUI:hideLoading()
            self:doNextWork()  
        end
    end

    local function fail_cb(ret)     
        self.m_loadingUI:hideLoading()   
        -- 실패하더라도 게임 진행되도록
        self:doNextWork()  
    end

    g_userData:request_termsInfo(success_cb, fail_cb)
end

function UI_TitleScene:workAgreeTerms_click()

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
            self:retryCurrWork3Times(nil, ret)
        end
    end

    local fail_cb = function(ret)
        self.m_loadingUI:hideLoading()
        self:retryCurrWork3Times(nil, ret)
    end

    Network_platform_electionServer( success_cb, fail_cb )
end

-------------------------------------
-- function workGameLogin
-- @brief 게임서버에 로그인
-------------------------------------
function UI_TitleScene:workGameLogin()
    -- @analytics
    Analytics:firstTimeExperience('Title_GameLogin')

    self.m_loadingUI:showLoading(Str('게임 서버에 로그인 중...'))
    
    local get_device_info       -- 기기 정보
    local get_advertising_id    -- 광고 식별자 ADID, IDFA
    local login                 -- 로그인
    local login_new_user        -- 로그인 신규 유저
    local login_existing_user   -- 로그인 기존 유저

    -- 기기 정보
    get_device_info = function()
        -- @analytics
        Analytics:firstTimeExperience('Title_GameLogin_getDeviceInfo')

        local function cb(ret, info)
            -- ret의 값에 상관없이 로그인 진행
            local device_info_json = json_decode(info) or {}
            g_userData:setDeviceInfoTable(device_info_json)

            -- next
            get_advertising_id(device_info_json)
        end

        SDKManager:deviceInfo(cb)
    end

    -- 광고 식별자 (adid, idfa)
    get_advertising_id = function(device_info_json)
        local function cb_func(ret, advertising_id)
            cclog('# advertising_id ' .. tostring(advertising_id))

            -- next
            login(device_info_json, advertising_id)
        end
        SDKManager:getAdvertisingID(cb_func)
    end

    -- 로그인
    login = function(device_info_json, advertising_id)
        -- @analytics
        Analytics:firstTimeExperience('Title_GameLogin_login')

        local success_cb = function(ret)
            -- 계정 탈퇴 보류 기간 (7일)
            if (ret['status'] == -4101) and (ret['uid'] ~= nil) then
                self.m_loadingUI:hideLoading()

                local uid = ret['uid']
                
                require('UI_AccountDeleteWaitPopup')
                local delete_timestamp = ret['delete_time']
                UI_AccountDeleteWaitPopup(uid, delete_timestamp)
                return
            end

            -- 원격 설정 초기화
            if (ret['remote_config']) then
                --cclog('# 원격 설정(remote config)')
                g_remoteConfig:applyRemoteConfig(ret['remote_config'])
            end

            -- 게임 서버에서 관리하는 설정값 초기화
            if (ret['user'] and ret['user']['settings']) then
                g_settingData:applyCloudSettings(ret['user']['settings'])
            end

            -- next
            if ret['newuser'] then
                -- 신규 유저의 경우에만 remote config값에 따라 시나리오 재생 생략 여부를 위해 설정값을 조정한다.
                -- scenario_playback_rules설정은 'first', 'always', 'off' 세가지 상태가 있으며, 기본값은 'first'이다.
                local skip_scenario_playback = g_remoteConfig:isSkipScenarioPlayback()
                if (skip_scenario_playback == true) then
                    g_settingData:applySettingData('off', 'scenario_playback_rules')
                end

                login_new_user(ret)
            else
                login_existing_user(ret)
            end
        end

        local fail_cb = function(ret)
            self:retryCurrWork3Times(nil, ret)
        end

        local uid = g_localData:get('local', 'uid')
        local nickname = nil -- @sgkim 2019-06-11 서버에서 사용하지 않는 값 확인
        Network_login(uid, nickname, device_info_json, advertising_id, success_cb, fail_cb)
    end

    -- 로그인 신규 유저
    login_new_user = function(ret)
        -- @analytics
        Analytics:firstTimeExperience('Title_GameLogin_loginNewUser')

        g_startTamerData:setData(ret)
        self.createAccount()
    end

    -- 로그인 기존 유저
    login_existing_user = function(ret)
        g_serverData:lockSaveData()
        
		-- user
		g_serverData:applyServerData(ret['user'], 'user')
        
		-- tamer
		g_serverData:applyServerData(ret['tamers'], 'tamers')
		g_tamerData:reMappingTamerInfo(ret['tamers'])

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
        
        -- @crashyltics setUid
        if (ret['user']) then
            PerpleSdkManager.getCrashlytics():setUid(ret['user']['uid'])
        end
        
        self:doNextWork()
    end

    get_device_info()
end
-------------------------------------
-- function workGameLogin_click
-------------------------------------
function UI_TitleScene:workGameLogin_click()
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

		-- 스테이지 리스트 받기 (users/title에서 정보 안줌 hotfix 후에 정리)
        co:work()
        self.m_loadingUI:showLoading(Str('지난 흔적을 찾는 중...'))
        local ui_network = g_nestDungeonData:requestNestDungeonInfo(co.NEXT, fail_cb)
        if ui_network then
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

        -- 우편 받기
        co:work()
        self.m_loadingUI:showLoading(Str('지난 흔적을 찾는 중...') .. '(2)')
        local ui_network = g_mailData:request_mailList(co.NEXT, fail_cb)
        if ui_network then
            ui_network:hideLoading()
        end
        if co:waitWork() then return end


        -- 코스튬 정보 받기
        co:work()
        self.m_loadingUI:showLoading(Str('지난 흔적을 찾는 중...') .. '(3)')
        local ui_network =  g_tamerCostumeData:request_costumeInfo(co.NEXT, false, fail_cb)
        if ui_network then
            ui_network:hideLoading()
        end
        if co:waitWork() then return end

		-- /users/title : title 통합 api
		co:work()
		self.m_loadingUI:showLoading(Str('던전 정보를 확인 중...'))
        do
			-- param
			local uid = g_userData:get('uid')
			local time = g_accessTimeData:getTime()
			local combat_power = g_dragonsData:getBestCombatPower()
			-- ui_network
			local ui_network = UI_Network()
			ui_network:setUrl('/users/title')
            ui_network:setParam('uid', uid)
			ui_network:setRevocable(true)
            ui_network:setSuccessCB(function(ret)
				
                -- server_info 정보를 갱신
                g_serverData:networkCommonRespone(ret)

                if (ret['last_arena_tier']) then
                    cclog('# 현재 티어 정보')
                    g_arenaNewData:applyLastTierInfo_Title(ret['last_arena_tier'])
                end

				 -- 클랜 정보 (클랜 로비가 들어가면서 추가)
                if (ret['clan']) then
                    cclog('# 클랜 정보')
                    g_clanData:applyClanInfo_Title(ret)
                end

                -- contents 관련  
                if (ret['stage_list']) then
                    cclog('# 모험 스테이지 리스트')
                    g_adventureData:response_adventureInfo(ret['stage_list'])

                    cclog('# 네스트 던전 리스트')
                    local game_list = ret['stage_list']['stage_list']
                    g_nestDungeonData:applyNestDungeonStageListWithCheckID(game_list)
                end

                if (ret['accesstime_info']) then
                    cclog('# 접속 시간 정보')
                    g_accessTimeData:response_accessTime(ret['accesstime_info'])
                end

                if (ret['tutorial_info']) then
                    cclog('# 튜토리얼 정보')
                    g_tutorialData:response_tutorialInfo(ret['tutorial_info'])
                end

                if (ret['masterroad_info']) then
                    cclog('# 마스터의 길 정보')
                    g_masterRoadData:applyInfo(ret['masterroad_info'])
                end

                if (ret['dragondiary_info']) then
                    cclog('# 드래곤의 길 정보')
                    g_dragonDiaryData:applyInfo(ret['dragondiary_info'])

                    -- 드래곤 성장일지 제거 이후 생성 계정인지 정보를 서버에서 받
                    if (ret['close_diary']) then
                        local is_close_diary = ret['close_diary']
                        g_dragonDiaryData:applyIsAfterCloseDiaryUser(is_close_diary)
                    end
                end

                if (ret['book_info']) then
                    cclog('# 도감 정보')
                    g_bookData:response_bookInfo(ret['book_info'])
                end

                if (ret['deck_info']) then
                    cclog('# 각 모드 덱')
                    g_deckData:response_deckInfo(ret['deck_info'])
                end

                if (ret['pvp_deck_info']) then
                    cclog('# 각 모드 덱')
                    g_deckData:response_deckPvpInfo(ret['pvp_deck_info'])
                end

                if (ret['pvpdeck_info']) then
                    cclog('# 콜로세움 공격덱 방어덱')
                    g_colosseumData:response_playerColosseumDeck(ret['pvpdeck_info'])
                end

                if (ret['arenadeck_info']) then
                    cclog('# 콜로세움(신규) 공격덱 방어덱')
                    g_arenaData:response_playerArenaDeck(ret['arenadeck_info'])
                end

                if (ret['arenanew_deck_a_info']) then
                    cclog('# 콜로세움 2021 공격덱')
                    g_arenaNewData:response_playerArenaDeck(ret['arenanew_deck_a_info'])
                end

                if (ret['arenanew_deck_d_info']) then
                    cclog('# 콜로세움 2021 방어덱')
                    g_arenaNewData:response_playerArenaDeck(ret['arenanew_deck_d_info'])
                end

                if (ret['season_info']) then
                    cclog('# 시즌 정보')
                    g_seasonData:applyInfo(ret['season_info'])
                end

                if (ret['adv_info']) then
                    cclog('# 광고 시청 정보')
                    g_advertisingData:response_dailyAdInfo(ret['adv_info'])
                end

                -- shop 관련
                if (ret['shop_list']) then
                    cclog('# 상점 리스트')
                    g_shopDataNew:response_shopInfo(ret['shop_list'])
                end

                -- 레벨업 패키지
                if (ret['lvuppack_info']) then
                    cclog('# 레벨업 패키지 정보')
                    g_levelUpPackageDataOld:response_lvuppackInfoByTitle(ret['lvuppack_info'])

                    
                    for key, data in pairs(ret['lvuppack_info']) do
                        g_levelUpPackageData:response_info(key, data)
                    end
                end

                -- 모험 돌파 패키지
                if (ret['stagepack_info']) then
                    cclog('# 모험 패키지 정보')

                    for key, data in pairs(ret['stagepack_info']) do
                        g_adventureBreakthroughPackageData:response_info(key, data)
                    end
                end

                -- 모험 돌파 패키지 1
                if (ret['stagepack_info'] and ret['stagepack_info']['90057']) then
                    cclog('# 모험 패키지 정보')
                    g_adventureClearPackageData01:response_adventureClearInfo(ret['stagepack_info']['90057'])
                end

                -- 모험 돌파 패키지 2
                if (ret['stagepack_info'] and ret['stagepack_info']['110281']) then
                    cclog('# 모험 패키지 정보')
                    g_adventureClearPackageData02:response_adventureClearInfo(ret['stagepack_info']['110281'])
                end

                -- 모험 돌파 패키지 3 2020.08.24
                if (ret['stagepack_info'] and ret['stagepack_info']['110282']) then
                    cclog('# 모험 패키지 정보')
                    g_adventureClearPackageData03:response_adventureClearInfo(ret['stagepack_info']['110282'])
                end

                if (ret['dmgate_stage_pack_info']) then
                    cclog('# 차원문 패키지 정보')
                    for k, v in pairs(ret['dmgate_stage_pack_info']) do
                        g_dmgatePackageData:response_info(v, k)
                    end
                end

                -- 시험의 탑 정복 선물 패키지 2020.11.25
                if (ret['attr_tower_pack_info']) then
                    cclog('# 시험의 탑 정복 선물 패키지 정보')
                    g_attrTowerPackageData:response_attrTowerPackInfo(ret['attr_tower_pack_info'])
                end

                if (ret['capsulebox_info']) then
                    cclog('# 캡슐 뽑기 정보')
                    g_capsuleBoxData:response_capsuleBoxInfo(ret['capsulebox_info'])
                end

				if (ret['clan_attd_reward']) then
					cclog('# 클랜 출석 정보')
					g_clanData.m_bAttdRewardNoti = ret['clan_attd_reward']
				end

				if (ret['comeback_reward']) then
					cclog('# 1주년 스페셜 복귀 유저 이벤트 정보')
					-- g_eventData:setComebackUser_1st(ret['comeback_reward'])
					g_eventData:setEventUserReward(ret['comeback_reward'])
				end

                if (ret['comeback_user_state']) then
					cclog('# 1주년 스페셜 복귀 유저 정보')
					g_eventData:setComebackUserState(ret['comeback_user_state'])
				end

                if (ret['remote_config']) then
                    cclog('# 원격 설정(remote config)')
                    g_remoteConfig:applyRemoteConfig(ret['remote_config'])
                end

                do 
                    cclog('# 핫타임 설정(fevertime)')
                    g_fevertimeData:applyFevertimeAtTitleAPI(ret)
                end

                cclog('# 레이드 정보')
                g_leagueRaidData:applyServerData(ret)

                cclog('# 보급소(정액제)(supply_list)')
                g_supply:applySupplyList_fromRet(ret)

                cclog('# 자동 줍기으로 획득한 누적 아이템 수량 갱신')
                g_subscriptionData:response_ingameDropInfo(ret)


                cclog('# 드랍 아이템 일일획득량 정보 갱신')
                g_userData:response_ingameDropInfo(ret)

                cclog('# Highbrow VIP 정보 갱신')
                g_userData:response_vipInfo(ret)
                g_highbrowVipData:response_info(ret)

                cclog('# 초보자 선물(신규 유저 전용 상점)')
                g_newcomerShop:applyNewcomderShopEndInfo_fromRet(ret)

                cclog('# 소환 천장 남은 횟수 정보 갱신')
                g_hatcheryData:applyPickupCeilingInfo(ret)

                cclog('# 드래곤 획득 패키지 정보 갱신')
                g_getDragonPackage:applyPackageList(ret, true)

                co.NEXT()
			end)
			ui_network:setFailCB(fail_cb)
			ui_network:hideLoading()
			ui_network:request()
        end
        if co:waitWork() then return end

        -- 차원문 /dmgate/info API
        do
            co:work('# 차원문 정보 받는 중')
            g_dmgateData:request_dmgateInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end


        co:close()

        -- 다음 work로 이동
        self:doNextWork()
    end

    Coroutine(coroutine_function)
end
function UI_TitleScene:workGetServerInfo_click()
end


-------------------------------------
-- function workAdManagerInitialize
-- @brief 광고 모듈 초기화
-------------------------------------
function UI_TitleScene:workAdManagerInitialize()
    -- 로딩 UI On
    self.m_loadingUI:showLoading()

    AdManager:getInstance():adManagerInitialize(function()
        -- -- 광고 재생 생략 여부
        -- local skip_ad_play = g_remoteConfig:getRemoteConfig('skip_ad_play')
        -- local skip_ad_aos_7_later = g_remoteConfig:getRemoteConfig('skip_ad_aos_7_later')
        -- local skip_facebook_ad_play = g_remoteConfig:getRemoteConfig('skip_facebook_ad_play')

        -- AdSDKSelector:initAdSDKSelector(skip_ad_play, skip_ad_aos_7_later, skip_facebook_ad_play)
        -- 로딩 UI Off
        self.m_loadingUI:hideLoading()

        self.m_worker:doNextWork()
    end)
end
function UI_TitleScene:workAdManagerInitialize_click()
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
            -- local info_json = dkjson.decode(info)

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
    local saveTransactionIdUrl = GetPlatformApiUrl() .. '/payment/saveTransaction'

    -- 카페 바자르 빌드에서만 동작
    if (CppFunctions:isCafeBazaarBuild() == true) then
        url = GetPlatformApiUrl() .. '/payment/receiptValidationForCafeBazaar/'
    end

    PerpleSDK:billingSetup(url, saveTransactionIdUrl, call_back)

    -- Xsolla 데이터 검증용 API 주소
    if (PerpleSdkManager:xsollaIsAvailable()) then
        PerpleSDK:xsollaSetPaymentInfoUrl(url)
    end
end

-------------------------------------
-- function workBillingSetupWithoutRestore
-- @brief Billing 초기화
-------------------------------------
function UI_TitleScene:workBillingSetupWithoutRestore()
    self.m_loadingUI:showLoading(Str('결제 정보 초기화...'))

    local l_payload = {}
    local function call_back(ret, info)
        cclog('# UI_TitleScene:workBillingSetupWithoutRestore() result : ' .. tostring(ret))
        if (ret == 'success') then
            cclog('#### billingSetup success - info : ')
            ccdump(info)
            self:doNextWork()

        elseif (ret == 'fail') then
            cclog('#### billingSetup failed - info : ')
            ccdump(info)
            -- local info_json = dkjson.decode(info)

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
    local url_receipt_validation = GetPlatformApiUrl() .. '/payment/receiptValidation/'
    local url_save_transaction = GetPlatformApiUrl() .. '/payment/saveTransaction'

    -- 카페 바자르 빌드에서만 동작
    if (CppFunctions:isCafeBazaarBuild() == true) then
        url_receipt_validation = GetPlatformApiUrl() .. '/payment/receiptValidationForCafeBazaar/'
    end

    PerpleSDK:billingSetup(url_receipt_validation, url_save_transaction, call_back)

    -- Xsolla 데이터 검증용 API 주소
    if (PerpleSdkManager:xsollaIsAvailable()) then
        PerpleSDK:xsollaSetPaymentInfoUrl(url_receipt_validation)
    end
end

function UI_TitleScene:workBillingSetup_click()
end

-------------------------------------
-- function workBillingRestorePurchase
-- @brief Billing 구매 복원
-------------------------------------
function UI_TitleScene:workBillingRestorePurchase()
    local function finish_cb()
        self:doNextWork()
    end

    local function call_back(ret, info)
        cclog('# UI_TitleScene:workBillingRestorePurchase() result : ' .. tostring(ret))
        if (ret == 'success') then
            cclog('#### billingRestorePurchase success - info : ')
            ccdump(info)

            local info_json = dkjson.decode(info)
            if info == '' or info_json == nil then
                self:doNextWork()
            else
                -- jsonArray 인지 판별
                if #info_json == table.count(info_json) then
                    -- info : [{"orderId":"@orderId","payload":"@payload"},...]
                    StructProduct:handlingMissingPayments(info_json, nil, finish_cb)
                end
            end
            
        elseif (ret == 'fail') then
            cclog('#### getIncompletePurchaseList failed - info : ')
            ccdump(info)

            local info_json = dkjson.decode(info)
            local msg = Str(info_json.msg)
            MakeSimplePopup(POPUP_TYPE.OK, msg, finish_cb)
        else
            self:doNextWork()
        end
    end

    PerpleSDK:billingGetIncompletePurchaseList(call_back)
end
function UI_TitleScene:workBillingRestorePurchase_click()
end

-------------------------------------
-- function workGetMarketInfo
-- @brief 마켓 정보 초기화
-------------------------------------
function UI_TitleScene:workGetMarketInfo()
    self.m_loadingUI:showLoading(Str('네트워크 통신 중...'))

    if self:isSkipGetMarketInfo() then
        self:doNextWork()
        return
    end

    local function call_back(ret, info)
        -- KR
        --{"productId":"dvm_cash_10k","type":"inapp","title":"11,000원 캐시 상품 (드래곤빌리지 M : 전투형 RPG)","name":"11,000원 캐시 상품","description":"11,000원 캐시 상품입니다.","price":"₩11,000","price_amount_micros":11000000000,"price_currency_code":"KRW","skuDetailsToken":"AEuhp4JvaIxqIyTUvGyXyjdJvwO-zqNtX-sbsChJSTKKVmV_F-k5wjqKuzKEwMDwxStV"}
        -- US
        --{"productId":"dvm_cash_10k","type":"inapp","title":"11,000원 캐시 상품 (드래곤빌리지 M : 전투형 RPG)","name":"11,000원 캐시 상품","description":"11,000원 캐시 상품입니다.","price":"US$9.49","price_amount_micros":9490000,"price_currency_code":"USD","skuDetailsToken":"AEuhp4LA1XLn-ExxfnaQKkI0ORWPAMIc-1bhr_oMV_jd4AFXzOMqXi-t_Vlu2n2UhT85"}
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


-------------------------------------
-- function workBillingSetupForOnestore
-- @brief 마켓 정보 초기화
--        이 함수는 원스토어 빌드일 경우에만 호출된다.
-------------------------------------
function UI_TitleScene:workBillingSetupForOnestore()
    self.m_loadingUI:showLoading(Str('결제 정보 초기화...'))

    -- 원스토어(ONEstore) 결제 시 사용될 uid 설정
    if PerpleSDK.onestoreSetUid then
        local uid = g_localData:get('local', 'uid')
        cclog('# UI_TitleScene:workBillingSetupForOnestore() PerpleSDK.onestoreSetUid : ' .. uid)
        PerpleSDK:onestoreSetUid(uid)
    end

    -- 결제 진행 후 consume되지 않은 결제건 조회
    if PerpleSDK.onestoreRequestPurchases then
        local function finish_cb()
            cclog('## PaymentHelper.handlingMissingPayments_onestore 종료!!!')
            self:doNextWork()
        end

        local function callback(ret, info)
            cclog('## PerpleSDK:onestoreRequestPurchases() callback!!')
            cclog('## ret : ' .. tostring(ret))
            cclog('## info : ' .. tostring(info))

            local info_json = dkjson.decode(info) or {}
            local l_payload = table.MapToList(info_json)

            -- 페이로드로 누락된 지급 처리
            PaymentHelper.handlingMissingPayments_onestore(l_payload, nil, finish_cb)
        end

        cclog('## PerpleSDK:onestoreRequestPurchases() call!!')
        PerpleSDK:onestoreRequestPurchases(callback)

        return
    end

    self:doNextWork()
end

function UI_TitleScene:workBillingSetupForOnestore_click()
end

-------------------------------------
-- function workGetMarketInfoForOnestore
-- @brief 마켓 정보 초기화
-------------------------------------
function UI_TitleScene:workGetMarketInfoForOnestore()
    self.m_loadingUI:showLoading(Str('네트워크 통신 중...'))

    if self:isSkipGetMarketInfo() then
        self:doNextWork()
        return
    end

    local function call_back(ret, info)
		if (ret == 'success') then
         	local tRet = json_decode(info)
		 	g_shopDataNew:setMarketPriceForOnestore(tRet)
		else		
			cclog('#### billingItemInfo failed - info : ')
    	end
		self:doNextWork()
	end

    local skuList = g_shopDataNew:getSkuList()
    if skuList == nil then
        self:doNextWork()
        return
    end

    PerpleSDK:billingGetItemListForOnestore(skuList, call_back)
end

function UI_TitleScene:workGetMarketInfo_click()
end

-------------------------------------
-- function workGetMarketInfo_Monthly
-- @brief 마켓 정보 초기화 - 월정액 상품
-------------------------------------
function UI_TitleScene:workGetMarketInfo_Monthly()
    self.m_loadingUI:showLoading(Str('네트워크 통신 중...'))

    if self:isSkipGetMarketInfo() then
        self:doNextWork()
        return
    end

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

    local skuList = g_shopDataNew:getSkuList_Monthly()
    if skuList == nil then
        self:doNextWork()
        return
    end

    PerpleSDK:billingGetItemList(skuList, call_back)
end
function UI_TitleScene:workGetMarketInfo_Monthly_click()
end

-------------------------------------
-- function workNetworkUserInfo
-- @brief 기본 유저 정보 통신
-------------------------------------
function UI_TitleScene:workNetworkUserInfo()
    self.m_loadingUI:showLoading(Str('네트워크 통신 중...'))

	local function success_cb()
		self:doNextWork()
	end
	g_errorTracker:sendUserInfoLog(success_cb)
end
function UI_TitleScene:workNetworkUserInfo_click()
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

    -- 화면을 터치하세요. 출력
    --self:setTouchScreen() -- @jhakim 190709 화면 터치 단계 제거
    function cb_touch()
        self:click_screenBtn()
    end

    self.m_stopWatch:record('finish')
	self.m_stopWatch:stop()
    self.m_stopWatch:print()
    self.m_stopWatch = nil

    -- 절전모드 설정
    SetSleepMode_After(self.root)

    -- 언어 설정 팝업이 뜬다면 해당 UI 닫을 때 게임 실행, 언어 설정 팝업이 뜨지 않는다면 바로 게임 실행
    local is_popup = UI_Setting:checkGameLanguage(cb_touch)
    if (not is_popup) then
        cb_touch()
    end
end
function UI_TitleScene:workFinish_click()
    -- @analytics
    Analytics:userInfo()
    Analytics:setAppDataVersion()

    -- 계정 생성시에는 lobby_func 타지 않으므로 여기서 title_to_lobby 저장 
    g_fullPopupManager:setTitleToLobby(true)

    UI_BlockPopup()

    local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
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

    --if ret then
        --local add_msg = '(status : ' .. tostring(ret['status']) .. ', message : ' .. tostring(ret['message']) .. ')'
        --msg =  msg .. '\n\n' .. add_msg
    --end

    self.m_loadingUI:hideLoading()
    MakeSimplePopup(POPUP_TYPE.OK, msg, ok_btn_cb)
end

-------------------------------------
-- function createAccount
-- @non-self
-- @brief 신규 계정일 경우 계정 생성
-------------------------------------
function UI_TitleScene.createAccount()
    local prologue_func     -- 프롤로그 재생
	local play_intro_start	-- 인트로 시작 시나리오
    local play_intro_fight	-- 인트로 전투
	local play_intro_end	-- 인트로 종료 시나리오
    local tamer_sel_func    -- 테이머 선택
    local comeback_title_fucn   -- 타이틀로 돌아와 로그인 실행

	-- 프롤로그    
    prologue_func = function()
        -- @analytics
        Analytics:firstTimeExperience('Prologue_Start')

        if (g_settingData:get('scenario_playback_rules') == 'off') then
            play_intro_start()
        else
            local ui = UI_ScenarioPlayer('scenario_prologue')
            ui:setCloseCB(play_intro_start)
            ui:next()
        end
    end

	-- 인트로 시작 시나리오
	play_intro_start = function()
        -- @analytics
        Analytics:firstTimeExperience('Tutorial_Intro_Start')

        if (g_settingData:get('scenario_playback_rules') == 'off') then
            play_intro_fight()
        else
            local ui = UI_ScenarioPlayer('scenario_intro_start_goni')
            ui:setCloseCB(play_intro_fight)
            ui:next()
        end
    end

	-- 인트로 전투
    play_intro_fight = function()
        local scene = SceneGameIntro()
		scene:setNextCB(play_intro_end)
        scene:runScene()
    end

	-- 인트로 종료 시나리오
	play_intro_end = function()
        if (g_settingData:get('scenario_playback_rules') == 'off') then
            tamer_sel_func()
        else
            local ui = UI_ScenarioPlayer('scenario_intro_finish')
            ui:setCloseCB(tamer_sel_func)
            ui:next()
        end
    end

	-- 계정 생성
    tamer_sel_func = function()
        -- @analytics
        Analytics:firstTimeExperience('Prologue_Finish')

		-- 스타팅 드래곤 선택 -> 닉네임 입력 : 콜백 계속 전달하여 닉네임 입력후 실행
        UI_SelectStartingDragon(comeback_title_fucn)
    end
    
	-- 타이틀을 다시 불러와 시작
    comeback_title_fucn = function()
		local scene = SceneTitle()
        scene:runScene()
    end
	
    prologue_func()
end









------------------------ Google 결제 3.0 ---------------------------


-------------------------------------
-- function workNewBillingSetup
-- @brief API(결제) 초기화
-------------------------------------
function UI_TitleScene:workNewBillingSetup()
    -- 로딩 UI On
    self.m_loadingUI:showLoading()

    local is_done = false -- 함수가 두번 호출되지 않도록 처리
    local function success_cb(info)

        -- 함수가 두번 호출되지 않도록 처리
        if (is_done == true) then
            return
        end
        is_done = true

        -- 로딩 UI Off
        self.m_loadingUI:hideLoading()

        -- 다음 work로 이동
        self:doNextWork()
    end

    local function fail_cb(info)

        -- 함수가 두번 호출되지 않도록 처리
        if (is_done == true) then
            return
        end
        is_done = true

        -- 로딩 UI Off
        self.m_loadingUI:hideLoading()

        -- 결제 시스템 초기화에 실패하더라도 게임 진입을 허용
        local function ok_cb()
            -- 다음 work로 이동
            self:doNextWork()
        end

        -- 인포에서 넘어온 msg는 무시
        -- local desc = Str(info_json.msg)
        local msg = Str('결제 시스템 초기화에 실패하였습니다.')
        local submsg = Str('결제 시도 시 결제에 실패할 경우 재접속 후 다시 시도해주세요.' .. '\n(' .. tostring(info) .. ')')
        MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg, ok_cb)
    end

    ServerData_IAP:getInstance():sdkBinder_BillingSetup(success_cb, fail_cb)
end

-------------------------------------
-- function workBillingGetItemList
-- @brief 인앱결제 상품 정보 획득 (sku를 통해 현지화된 가격 등을 획득)
-------------------------------------
function UI_TitleScene:workNewBillingGetItemList()
    -- 로딩 UI On
    self.m_loadingUI:showLoading()
    
    local function success_cb()
        -- 로딩 UI Off
        self.m_loadingUI:hideLoading()
        
        -- 다음 work로 이동
        self:doNextWork()
    end

    local function fail_cb(info)
        -- 로딩 UI Off
        self.m_loadingUI:hideLoading()

        -- 결제 시스템 초기화에 실패하더라도 게임 진입을 허용
        local function ok_cb()
            -- 다음 work로 이동
            self:doNextWork()
        end

        -- 인포에서 넘어온 msg는 무시
        -- local desc = Str(info_json.msg)
        local msg = Str('결제 시스템 초기화에 실패하였습니다.')
        local submsg = Str('결제 시도 시 결제에 실패할 경우 재접속 후 다시 시도해주세요.' .. '\n(' .. tostring(info) .. ')')
        MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg, ok_cb)
    end

    ServerData_IAP:getInstance():sdkBinder_BillingGetItemList(success_cb, fail_cb)
end

-------------------------------------
-- function workBillingGetIncompletePurchaseList
-- @brief 완료되지 않은 결제건 조회
-------------------------------------
function UI_TitleScene:workNewBillingGetIncompletePurchaseList()
    -- 로딩 UI On
    self.m_loadingUI:showLoading()

    local function success_cb()
        -- 로딩 UI Off
        self.m_loadingUI:hideLoading()

        -- 다음 work로 이동
        self:doNextWork()
    end

    local function fail_cb()
        -- 로딩 UI Off
        self.m_loadingUI:hideLoading()

        -- 다음 work로 이동
        self:doNextWork()
    end

    ServerData_IAP:getInstance():sdkBinder_BillingGetIncompletePurchaseList(success_cb, fail_cb)
end

-------------------------------------
-- function workBillingHandleIncompletePurchaseList
-- @brief 완료되지 않은 결제건 처리
-------------------------------------
function UI_TitleScene:workNewBillingHandleIncompletePurchaseList()
    local function coroutine_function(dt)
        local co = CoroutineHelper()

        local l_struct_iap_purchase = clone(ServerData_IAP:getInstance().m_structIAPPurchaseList)

        -- StructIAPPurchase
        for i,struct_iap_purchase in ipairs(l_struct_iap_purchase) do
            co:work()

            -- 로딩 UI On
            self.m_loadingUI:showLoading()

            local validation_key = nil
            local product_id = nil
            local sale_id = nil

            local sku = struct_iap_purchase:getSku()
            local purchase_time = struct_iap_purchase:getPurchaseTime()
            local order_id = struct_iap_purchase:getOrderId()
            local purchase_token = struct_iap_purchase:getPurchaseToken()
            local test_purchase = false

            -- 성공 시에는 billingConfirm으로 결제건 종료
            local success_cb = function(ret)
                -- 로딩 UI Off
                self.m_loadingUI:hideLoading()

                PerpleSDK:billingConfirm(order_id)

                -- 지표
                if (test_purchase == false) then
                    local currency_code = nil
                    local currency_price = nil
        
                    -- StructIAPProduct
                    local struct_iap_product = ServerData_IAP:getInstance():getStructIAPProduct(sku)
                    if struct_iap_product then
                        currency_code = struct_iap_product:getCurrencyCode()
                        currency_price = struct_iap_product:getCurrencyPrice()
                    end
        
                    -- @analytics
                    --Analytics:purchase(product_id, sku, currency_code, currency_price) -- params: product_id, sku, currency_code, currency_price
                end

                co.NEXT()
            end

            -- 실패
            local fail_cb = function(ret)
                -- 로딩 UI Off
                self.m_loadingUI:hideLoading()
                co.NEXT()
            end

            -- 성공 이외의 값
            local status_cb = function(ret)
                -- 로딩 UI Off
                self.m_loadingUI:hideLoading()

                if (IS_TEST_MODE() == true) then
                    if (ret['status'] ~= 0) then
                        local msg = '아이템 미지급 결제건 처리 도중 오류가 발생하였습니다. 결제건을 컨슘하시겠습니까?'
                        local sub_msg = '(status : ' .. tostring(ret['status']) .. ', message : ' .. tostring(ret['message']) .. ')'

                        local function ok_btn_cb()
                            -- PerpleSDK:billingConfirm(order_id(string))를 호출한 것과 같음
                            PerpleSDK:billingConfirm(order_id)
                            co.NEXT()
                        end

                        local function cancel_btn_cb()
                            co.NEXT()
                        end

                        MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, sub_msg, ok_btn_cb, cancel_btn_cb)
                        return true
                    end
                elseif (ret['status'] == 107) then
                    -- 이미 해당 order_id로 상품이 지급된 경우
                    -- ALREADY_EXIST(107 , "already exist"),
                    PerpleSDK:billingConfirm(order_id)
                    
                    co.NEXT()
                    return true

                else
                    -- 라이브 환경에서는 알 수 없는 오류에서 billingConfirm처리를 하고 cs로 해결하도록 한다.
                    -- PerpleSDK:billingConfirm(order_id(string))를 호출한 것과 같음
                    --SdkBinder.callPerpleSDKFunc('billingConfirm', order_id)
                    PerpleSDK:billingConfirm(order_id)

                    co.NEXT()
                    return true
                end
                return false
            end
    
            -- 실패시에도 게임 진행을 위해 다음으로 넘어감
            g_shopDataNew:request_checkReceiptValidation_v3(nil, validation_key, product_id, sale_id,
                sku, purchase_time, order_id, purchase_token,
                success_cb, co.NEXT, status_cb, -- params: success_cb, fail_cb, status_cb
                test_purchase)
            if co:waitWork() then return end
        end
	
        co:close()

        -- 로딩 UI Off
        self.m_loadingUI:hideLoading()

        -- 다음 work로 이동
        self:doNextWork()
    end

    Coroutine(coroutine_function)
end




--------------------------------------------------------------------








--@CHECK
UI:checkCompileError(UI_TitleScene)
