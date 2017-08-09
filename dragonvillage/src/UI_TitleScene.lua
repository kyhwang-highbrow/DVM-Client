local PARENT = UI

-------------------------------------
-- class UI_TitleScene
-------------------------------------
UI_TitleScene = class(PARENT,{
        m_lWorkList = 'list',
        m_workIdx = 'number',
        m_loadingUI = 'UI_TitleSceneLoading',
        m_bNewUser = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TitleScene:init()
    local vars = self:load('title.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_TitleScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh() 

    -- @brief work초기화 용도로 사용함
    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TitleScene:initUI()
    local vars = self.vars

    vars['messageLabel']:setVisible(false)
    vars['downloadLabel']:setVisible(false)
	vars['downloadGauge']:setVisible(false)

    do -- 앱버전과 패치 정보를 출력
        local patch_idx_str = PatchData:getInstance():getAppVersionAndPatchIdxString()
        if (TARGET_SERVER == nil) then
            patch_idx_str = patch_idx_str
        elseif (TARGET_SERVER == 'FGT') then
            patch_idx_str = patch_idx_str .. ' (FGT server)'
		elseif (TARGET_SERVER == 'PUBLIC') then
            patch_idx_str = patch_idx_str .. ' (PUBLIC server)'
        else
            error('TARGET_SERVER : ' .. TARGET_SERVER)
        end

        vars['patchIdxLabel']:setString(patch_idx_str)
    end    

    self.m_loadingUI = UI_TitleSceneLoading()
    self.m_loadingUI:hideLoading()
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
    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
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
    --local ip = '192.168.1.63'
    --local port = '3927'

    -- 테스트 채팅 서버
    local ip = 'dv-test.perplelab.com'
    local port = '9013'

    if (TARGET_SERVER == 'PUBLIC') then
        port = '9015'
    end

    local chat_client_socket = ChatClientSocket(ip, port)

    -- 유저 정보 입력
    local uid = g_serverData:get('local', 'uid')
    local tamer = g_userData:get('tamer')
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
    t_data['tamer'] = tostring(tamer)
    t_data['nickname'] = nickname
    t_data['did'] = did
    t_data['level'] = lv
    t_data['x'] = 0
    t_data['y'] = -150
    t_data['tamerTitleID'] = tamer_title_id
    
    do -- 최초 랜덤 위치 지정
        local x, y = LobbyMapSpotMgr:makeRandomSpot()
        t_data['x'] = x
        t_data['y'] = y
    end

    chat_client_socket:setUserInfo(t_data)

    -- 전역 변수로 설정
    g_chatClientSocket = chat_client_socket

    self:initLobbyManager(chat_client_socket)
    self:initChatManager(chat_client_socket)
end

-------------------------------------
-- function initLobbyManager
-- @brief
-------------------------------------
function UI_TitleScene:initLobbyManager(chat_client_socket)
    LobbyManager:initInstance()
    g_lobbyManager:setChatClientSocket(chat_client_socket)
    chat_client_socket:addRegularListener(g_lobbyManager)
end

-------------------------------------
-- function initChatManager
-- @brief
-------------------------------------
function UI_TitleScene:initChatManager(chat_client_socket)
    ChatManager:initInstance()
    g_chatManager:setChatClientSocket(chat_client_socket)
    chat_client_socket:addRegularListener(g_chatManager)
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
    table.insert(self.m_lWorkList, 'workCheckUserID')
    table.insert(self.m_lWorkList, 'workPlatformLogin')
    table.insert(self.m_lWorkList, 'workGameLogin')
    table.insert(self.m_lWorkList, 'workGetDeck')
    table.insert(self.m_lWorkList, 'workGetServerInfo')
    table.insert(self.m_lWorkList, 'workBook')

    -- @perpelsdk
    if (isAndroid() or isIos()) then
        table.insert(self.m_lWorkList, 'workBillingSetup')
    end

    table.insert(self.m_lWorkList, 'workSoundPreload')
    table.insert(self.m_lWorkList, 'workFinish')
    
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_TitleScene:doNextWork()
    self.m_workIdx = (self.m_workIdx + 1)
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
-- function workCheckUserID
-- @breif uid가 있는지 체크, UID가 없을 경우 난수 발생하여
--        uid로 사용
-------------------------------------
function UI_TitleScene:workCheckUserID()
    self.m_loadingUI:showLoading(Str('유저 계정 확인 중...'))

    SoundMgr.m_bStopPreload = false

    if isWin32() then

        local uid = g_serverData:get('local', 'uid')
   
        if uid then
            self:doNextWork()
        else
            self:makeRandomUid()
            self:doNextWork()
        end

        return
    end

    -- @perplesdk
    PerpleSDK:autoLogin(function(ret, info)

        self.m_loadingUI:hideLoading()

        if ret == 'success' then
            cclog('Firebase autoLogin was successful.')

            local t_info = dkjson.decode(info)
            local fuid = t_info.fuid
            local push_token = t_info.pushToken
            local platform_id = t_info.providerId
            local account_info = t_info.name

            local app_ver = getAppVer()
            if app_ver == '0.2.2' then
                platform_id = g_serverData:get('local', 'platform_id') or 'firebase'
                account_info = g_serverData:get('local', 'account_info') or 'Guest'
            end

            cclog('fuid: ' .. fuid)
            cclog('push_token: ' .. push_token)
            cclog('platform_id:' .. platform_id)
            cclog('account_info:' .. account_info)

            -- Firebase에서 발급하는 uid
            -- 게임 uid로 그대로 사용하면 됨
            g_serverData:applyServerData(fuid, 'local', 'uid')

            -- 푸시 발송을 위한 푸시토큰
            -- 로그인할 때마다 플랫폼 서버에 저장해야 함
            g_serverData:applyServerData(push_token, 'local', 'push_token')

            -- 현재 로그인된 계정의 플랫폼ID
            -- Google: 'google.com'
            -- Facebook: 'facebook.com'
            -- Guest: 'firebase'
            g_serverData:applyServerData(platform_id, 'local', 'platform_id')

            -- 계정 정보(이름 or 이메일)
            g_serverData:applyServerData(account_info, 'local', 'account_info')

            if platform_id == 'google.com' then
                local app_ver = getAppVer()
                if app_ver == '0.2.2' then
                    PerpleSDK:googleLogin(function(ret, info)
                        g_serverData:applyServerData('on', 'local', 'googleplay_connected')
                        self:doNextWork()
                    end)
                else
                    PerpleSDK:googleLogin(1, function(ret, info)
                        g_serverData:applyServerData('on', 'local', 'googleplay_connected')
                        self:doNextWork()
                    end)
                end
            else
                g_serverData:applyServerData('off', 'local', 'googleplay_connected')
                self:doNextWork()
            end

        elseif ret == 'fail' then
            cclog('Firebase autoLogin failed.')

            -- 자동로그인에 실패한 경우 로그인 팝업 출력
            -- 앱을 처음으로 설치한 경우임
            local ui = UI_LoginPopup()
            local function close_cb()
                self:doNextWork()
            end
            ui:setCloseCB(close_cb)

        end
    end)

end

function UI_TitleScene:workCheckUserID_click()
end

-------------------------------------
-- function workPlatformLogin
-- @brief 플랫폼 서버에 게스트 로그인
-------------------------------------
function UI_TitleScene:workPlatformLogin()
    self.m_loadingUI:showLoading(Str('플랫폼 서버에 로그인 중...'))

    local success_cb = function(ret)
        self.m_loadingUI:hideLoading()
        local t_status = ret['status']
        if (t_status['retcode'] == 0) then
            ccdump(ret)

            -- 복구코드 저장            
            g_serverData:applyServerData(ret['rcode'], 'local', 'recovery_code')

            local terms = (ret['terms'] or 1)
            if (terms == 0) then
                -- 약관 동의 팝업
                local ui = UI_TermsPopup()
                local function close_cb()
                    local agree_terms = g_serverData:get('local', 'agree_terms')
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

    local game_id = 1003
    local fuid = g_serverData:get('local', 'uid')
    local rcode = g_serverData:get('local', 'recovery_code')
    local os = 0 -- ( 0 : Android / 1 : iOS )
    local game_push = 1 -- on - 1, off - 0
    local pushToken = g_serverData:get('local', 'push_token')
    Network_platform_issueRcode(game_id, fuid, rcode, os, game_push, pushToken, success_cb, fail_cb)
end
function UI_TitleScene:workPlatformLogin_click()
end

-------------------------------------
-- function workGameLogin
-- @brief 게임서버에 로그인
-------------------------------------
function UI_TitleScene:workGameLogin()
    self.m_loadingUI:showLoading(Str('게임 서버에 로그인 중...'))

    local uid = g_serverData:get('local', 'uid')
    local success_cb = function(ret)
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

		g_serverData:unlockSaveData()

        -- server_info 정보를 갱신
        g_serverData:networkCommonRespone(ret)
        
        self:doNextWork()
    end

    local fail_cb = function(ret)
        self:makeFailPopup(nil, ret)
    end

    Network_login(uid, nickname, success_cb, fail_cb)
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

    local uid = g_serverData:get('local', 'uid')

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
            self:makeFailPopup(nil, ret)
        end

        -- (테이블 정보를 받는 중)
        co:work()
        self.m_loadingUI:showLoading(Str('지도를 챙기는 중...'))
        local ui_network = g_serverData:request_serverTables(co.NEXT, fail_cb)
        ui_network:hideLoading()
        if co:waitWork() then return end

        -- 룬 정보 받기
        co:work()
        self.m_loadingUI:showLoading(Str('룬을 챙기는 중...'))
        local ui_network = g_runesData:request_runesInfo(co.NEXT, fail_cb)
        ui_network:hideLoading()
        if co:waitWork() then return end

        -- 드래곤 정보 받기
        co:work()
        self.m_loadingUI:showLoading(Str('드래곤들을 부르는 중...'))
        local ui_network = g_dragonsData:request_dragonsInfo(co.NEXT, fail_cb)
        ui_network:hideLoading()
        if co:waitWork() then return end

		-- 스테이지 리스트 받기
        co:work()
        self.m_loadingUI:showLoading(Str('지난 흔적을 찾는 중...'))
        local ui_network = g_adventureData:request_adventureInfo(co.NEXT, fail_cb)
        ui_network:hideLoading()
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
        ui_network:setRevocable(false)
        ui_network:setFailCB(fail_cb)
        ui_network:hideLoading()
        if co:waitWork() then return end

        -- 핫 타임
        co:work()
        self.m_loadingUI:showLoading(Str('핫타임 정보 요청 중...'))
        local ui_network = g_hotTimeData:request_hottime(co.NEXT, fail_cb)
        ui_network:setRevocable(false)
        ui_network:setFailCB(fail_cb)
        ui_network:hideLoading()
        if co:waitWork() then return end

        -- 접속시간 이벤트
        co:work()
        self.m_loadingUI:showLoading(Str('접속시간 정보 요청 중...'))
        local ui_network = g_accessTimeData:request_accessTime(co.NEXT, fail_cb)
        ui_network:setRevocable(false)
        ui_network:setFailCB(fail_cb)
        ui_network:hideLoading()
        if co:waitWork() then return end

        -- 마스터의 길
        co:work()
        self.m_loadingUI:showLoading(Str('마스터의 길을 닦는 중...'))
        local ui_network = g_masterRoadData:request_roadInfo(co.NEXT, fail_cb)
        ui_network:setRevocable(false)
        ui_network:setFailCB(fail_cb)
        ui_network:hideLoading()
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
        cclog('# UI_TitleScene:workBillingSetup() result : ' .. ret)
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
            
        elseif (ret == 'error') then
            cclog('#### billingSetup failed - info : ')
            ccdump(info)
            local info_json = dkjson.decode(info)

            -- 결제 시스템 초기화에 실패하더라도 게임 진입을 허용
            local function finish_cb()
                self:doNextWork()
            end
            self:makeFailPopup(Str(info_json.msg), finish_cb)
        end
    end

    -- 영수증 검증 API 주소
    local url = 'http://dev.platform.perplelab.com/1003/payment/receiptValidation/'
    PerpleSDK:billingSetup(url, call_back)
end
function UI_TitleScene:workBillingSetup_click()
end

-------------------------------------
-- function workSoundPreload
-- @brief 사운드 프리로드
-------------------------------------
function UI_TitleScene:workSoundPreload()
    self:initChatClientSocket()
    --ChatManager:initInstance()

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
end
function UI_TitleScene:workFinish_click()
    -- 모든 작업이 끝난 경우 로비로 전환
    local lobby_func
    local check_intro_func

    -- 로비 진입
    lobby_func = function()
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
        -- 해킹 체크
	    if (HackingDetector:checkHack()) then return end
        lobby_func()
    end
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

    g_serverData:applyServerData(uuid, 'local', 'uid')

    if isWin32() then
        g_serverData:applyServerData('', 'local', 'push_token')
        g_serverData:applyServerData('firebase', 'local', 'platform_id')
        g_serverData:applyServerData('Guest', 'local', 'account_info')
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
        local scenario_name = 'scenario_prologue'
        local prologue = UI_ScenarioPlayer(scenario_name)
        prologue:setCloseCB(tamer_sel_func)
        prologue:next()
    end

    tamer_sel_func = function()
        UI_StartTamerSelect(login_func)
    end

    login_func = function()
        self.m_bNewUser = true
        self.m_loadingUI:showLoading()
        self:retryCurrWork()
    end
    
    prologue_func()
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function makeFailPopup
-- @brief
-------------------------------------
function UI_TitleScene:makeFailPopup(msg, ret)
    local function ok_btn_cb()
        self.m_loadingUI:showLoading()
        self:retryCurrWork()
    end

    local msg = msg or '네트워크 연결에 실패하였습니다. 다시 시도하시겠습니까?'

    if ret then
        local add_msg = '(status : ' .. tostring(ret['status']) .. ', message : ' .. tostring(ret['message']) .. ')'
        msg =  msg .. '\n\n' .. add_msg
    end

    self.m_loadingUI:hideLoading()
    MakeSimplePopup(POPUP_TYPE.OK, msg, ok_btn_cb)
end

--@CHECK
UI:checkCompileError(UI_TitleScene)
