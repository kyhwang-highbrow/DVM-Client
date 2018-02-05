-------------------------------------
-- function Network_get_patch_info
-- @breif 패치 정보 요청
-------------------------------------
function Network_get_patch_info(app_ver, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['app_ver'] = app_ver -- '0.0.0'

    -- 요청 정보 설정
    local t_request = {}
    t_request['url'] = '/get_patch_info'
    t_request['data'] = t_data
    t_request['method'] = 'GET'

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:HMacRequest(t_request)
end

-------------------------------------
-- function MakeGameServerUid
-- @breif firebase uid와 게임 서버 이름으로 uid 생성
-------------------------------------
function MakeGameServerUid()
    -- 세이브파일에 저장된 uid를 불러옴
    local uid = g_localData:get('local', 'uid')

    -- 연결할 게임 서버명 얻어옴
    local server_name = g_localData:getServerName()

    -- 개발 서버는 그대로 리턴
    if (server_name == 'DEV') or (server_name == 'QA') then
        -- DEV(개발), QA 서버에서는 라이브 서버의 계정을 복사해서 사용하는 경우가 있기때문에
        -- 클라이언트에서 저장된 그대로의 uid를 사용
        return uid
    end

    -- fuid@server_name 형태의 uid일 경우 @server_name을 떼어줌
    local removeIdx = string.find(uid, '@')    
    if removeIdx then
        uid = string.sub(uid, 1, removeIdx - 1)
    end

    -- fuid@server_name 형태의 uid 생성
    local ret_uid = string.format('%s@%s', uid, server_name)
    return ret_uid
end

-------------------------------------
-- function Network_platform_issueRcode
-- @breif firebase uid로 
--        복구코드 생성 및pushToken저장
-- @param
--          rcode : platform에서 생성한 복구코드 
--          os : ( 0 : Android / 1 : iOS )
--          game_push : on - 1, off - 0
--          pushToken : firebase push token
-------------------------------------
function Network_platform_issueRcode(rcode, os, game_push, pushToken, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['game_id'] = 1003
    t_data['uid'] = MakeGameServerUid()
    t_data['rcode'] = rcode
    t_data['os'] = os
    t_data['game_push'] = game_push
    t_data['pushToken'] = pushToken
    t_data['server_name'] = g_localData:getServerName()
    t_data['lang'] = LocalData:getInstance():getLang()

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = GetPlatformApiUrl() .. '/user/issueRcode'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    t_request['check_hmac_md5'] = true

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_platform_registerToken
-- @breif   푸시 토큰 등록
-- @param
--          game_push : on - 1, off - 0
--          pushToken : firebase push token
-------------------------------------
function Network_platform_registerToken(game_push, pushToken, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['uid'] = g_localData:get('local', 'uid')
    t_data['game_push'] = game_push
    t_data['pushToken'] = pushToken

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = GetPlatformApiUrl() .. '/user/registerToken'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    t_request['check_hmac_md5'] = false

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_platform_updateTerms
-- @breif   약관 동의 여부 업데이트
-- @param
--          terms : 동의 여부 (0 or 1)
-------------------------------------
function Network_platform_updateTerms(terms, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['game_id'] = 1003
    t_data['uid'] = g_localData:get('local', 'uid')
    t_data['terms'] = terms

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = GetPlatformApiUrl() .. '/user/updateTerms'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    t_request['check_hmac_md5'] = true

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_platform_updateId
-- @breif   연동 플랫폼 아이디 업데이트
-- @param
--          fuid : uid
--          platform_id : google.com, facebook.com, gamecenter, firebase
--          account_info : id
-------------------------------------
function Network_platform_updateId(fuid, platform_id, account_info, success_cb, fail_cb)

    -- 파라미터 셋팅
    local t_data = {}
    t_data['game_id'] = 1003
    t_data['uid'] = fuid

    if platform_id == 'google.com' then
        t_data['google_id'] = account_info
    elseif platform_id == 'facebook.com' then
        t_data['facebook_id'] = account_info
    elseif platform_id == 'gamecenter' then
        t_data['apple_id'] = account_info
    else
        return
    end

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = GetPlatformApiUrl() .. '/user/updateId'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    t_request['check_hmac_md5'] = true

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_platform_getUserByUid
-- @breif   플랫폼 서버에 유저 아이디 검색
-- @param
--          uid : uid
-------------------------------------
function Network_platform_getUserByUid(uid, success_cb, fail_cb)

    -- 파라미터 셋팅
    local t_data = {}
    t_data['game_id'] = 1003
    t_data['uid'] = uid

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = GetPlatformApiUrl() .. '/user/getUserByUid'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    t_request['check_hmac_md5'] = false

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_platform_getPatchVersionInfo
-- @breif   플랫폼 서버에 패치 정보확인
-- @param
--          app_ver : app_ver
-------------------------------------
function Network_platform_getPatchVersionInfo(app_ver, success_cb, fail_cb)

    -- 파라미터 셋팅
    local t_data = {}
    t_data['game_id'] = 1003
    t_data['app_ver'] = app_ver
    t_data['server'] = CppFunctions:getTargetServer()

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = GetPlatformApiUrl() .. '/versions/getPatchInfo'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    t_request['check_hmac_md5'] = false

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_platform_getServerList
-- @breif   플랫폼 서버에 서버 리스트 가져오기
-------------------------------------
function Network_platform_getServerList(success_cb, fail_cb)
    -- 파라미터 셋팅
    local ip = getIPAddress()
        
    local t_data = {}    
    t_data['uid'] = g_localData:get('local', 'uid')        
    t_data['ip'] = ip
    t_data['server'] = CppFunctions:getTargetServer()
    
    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = GetPlatformApiUrl() .. '/gateway/serverList'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    t_request['check_hmac_md5'] = false

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_platform_electionServer
-- @breif   플랫폼 서버에 선택한 서버 알려주기
-------------------------------------
function Network_platform_electionServer(success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}    
    t_data['uid'] = g_localData:get('local', 'uid')
    t_data['server_name'] = g_localData:getServerName()
    
    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = GetPlatformApiUrl() .. '/gateway/electionServer'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    t_request['check_hmac_md5'] = false

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_platform_changeLang
-- @breif   언어변경 된것 알려주기
-------------------------------------
function Network_platform_changeLang(success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}    
    t_data['uid'] = g_localData:get('local', 'uid')
    t_data['lang'] = g_localData:getLang()
    t_data['push_token'] = g_localData:get('local', 'push_token')
        
    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = GetPlatformApiUrl() .. '/user/changeLang'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    t_request['check_hmac_md5'] = false

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_login
-- @breif 로그인
-------------------------------------
function Network_login(uid, nickname, device_info_json, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['uid'] = uid
    t_data['nickname'] = nickname
    t_data['hashed_uid'] = nil
    t_data['imei'] = nil
    t_data['market'] = nil

    -- 로그인 시 os 정보 추가
    local os = 'android'
    if isAndroid() then
        os = 'android'
    elseif isIos() then
        os = 'ios'
    elseif isWin32() then
        os = 'windows'
    end
    t_data['os'] = os

    -- 단말 정보 추가
    for key,value in pairs(device_info_json) do
        if (t_data[key] == nil) then
            t_data[key] = value
        end
    end
    -- device_info_json은 android에서 아래와 같은 형태로 넘어옴
    -- 2017-17-08-24 sgkim
    --{
    --    ['OS_VERSION']='3.10.61-11396000';
    --    ['DISPLAY']='NRD90M.N920SKSU2DQE1';
    --    ['MANUFACTURER']='samsung';
    --    ['VERSION_SDK_INT']=24;
    --    ['desc']='samsung SM-N920S(Android 7.0, API 24)';
    --    ['VERSION_RELEASE']='7.0';
    --    ['DEVICE']='noblelteskt';
    --    ['BOARD']='universal7420';
    --    ['VERSION_INCREMENTAL']='N920SKSU2DQE1';
    --    ['BRAND']='samsung';
    --}


    -- 요청 정보 설정
    local t_request = {}
    t_request['url'] = '/login'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:HMacRequest(t_request)
end

-------------------------------------
-- function Network_get_deck
-- @breif 덱 정보 얻어옴
-------------------------------------
function Network_get_deck(uid, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['uid'] = uid

    -- 요청 정보 설정
    local t_request = {}
    t_request['url'] = '/users/get_deck'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:HMacRequest(t_request)
end

function getTargetOSName()
    if isWin32() then
        return 'windows'

    elseif isAndroid() then
        return 'android'

    elseif isIos() then
        return 'ios'

    else
        return nil
    end
end

function slack_api(msg)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['token'] = 'xoxp-4049551466-60623372247-67908400245-53f29cbca3'
    t_data['channel'] = 'C1RUT070B'
    t_data['text'] = msg
    t_data['username'] = 'DVM ERROR BOT'
    t_data['icon_emoji'] = ':fix:'

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = 'https://slack.com/api/chat.postMessage'
    t_request['method'] = 'GET'
    t_request['data'] = t_data

    -- 성공 시 콜백 함수
    t_request['success'] = function(ret)
    end

    -- 실패 시 콜백 함수
    t_request['fail'] = function(ret)

    end

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end