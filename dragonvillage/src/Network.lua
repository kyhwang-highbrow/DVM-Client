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

    -- 성공 시 콜백 함수
    t_request['success'] = success_cb

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function Network_platform_issueRcode
-- @breif firebase uid로 
--        복구코드 생성 및pushToken저장
-- @param
--          game_id
--          fuid : firebase uid
--          rcode : platform에서 생성한 복구코드 
--          os : ( 0 : Android / 1 : iOS )
--          game_push : on - 1, off - 0
--          pushToken : firebase push token
-------------------------------------
function Network_platform_issueRcode(game_id, fuid, rcode, os, game_push, pushToken, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['game_id'] = game_id
    t_data['fuid'] = fuid
    t_data['rcode'] = rcode
    t_data['os'] = os
    t_data['game_push'] = game_push
    t_data['pushToken'] = pushToken

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
-- function Network_platform_updateTerms
-- @breif   약관 동의 여부 업데이트
-- @param
--          game_id
--          uid : player id
--          terms : 동의 여부 (0 or 1)
-------------------------------------
function Network_platform_updateTerms(game_id, uid, terms, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['game_id'] = game_id
    t_data['uid'] = uid
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
-- function Network_login
-- @breif 로그인
-------------------------------------
function Network_login(uid, nickname, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['uid'] = uid
    t_data['nickname'] = nickname
    t_data['hashed_uid'] = nil
    t_data['imei'] = nil
    t_data['market'] = nil

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
    Network:SimpleRequest(t_request)
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
    Network:SimpleRequest(t_request)
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