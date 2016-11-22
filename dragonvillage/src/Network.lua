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
-- function Network_platform_guest_login
-- @breif 패치 정보 요청
-- player_id : 타 플랫폼 접속시 리턴받은 유일값(없으면 비워둠)
-- uid: 이전 접속시 생성 받은 uid(없으면 비워둠)
-- idfa : 기기 고유의 광고 고유 식별자(필수)
-- deviceOS : 기기 OS (필수, 0:android, 1:ios, 2:windows, 3:....)
-- pushToken : 푸쉬 토큰
-------------------------------------
function Network_platform_guest_login(player_id, uid, idfa, deviceOS, pushToken, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['player_id'] = player_id
    t_data['uid'] = uid
    t_data['idfa'] = idfa
    t_data['deviceOS'] = deviceOS
    t_data['pushToken'] = pushToken

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = 'http://dv-test.perplelab.com:3000/1003/user/guestLogin'
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
-- function Network_login
-- @breif 로그인
-------------------------------------
function Network_login(uid, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['uid'] = uid
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