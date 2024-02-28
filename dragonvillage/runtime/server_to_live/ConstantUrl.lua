URL = {}

-- 점검중 라이브 접속이 필요한 경우 아래 앱버전, 패치버전을 라이브 버전과 같게 수정한 후 true로 변경
-- 라이브 접속은 꼭 필요한 경우에만!
LIVE_SERVER_CONNECT = false 
LIVE_SERVER_APP_VER = '1.1.4'
LIVE_SERVER_PATCH_VER = '29'
LIVE_SERVER_TARGET = nil

-- Game server 
URL['SERVER_DEV'] = 'http://dv-test.perplelab.com:9003'
URL['SERVER_QA'] = 'http://dv-qa.perplelab.com:9003'
URL['SERVER_LIVE'] = 'dvm-global.highbrow-inc.com'
function GetApiUrl()
    local target_server = CppFunctions:getTargetServer()
    local key = 'SERVER_' .. target_server
    local url = URL[key]
    if (not url) then
        error('key(Game server) : ' .. key)
    end
    return url
end
function SetApiUrl(url)
    local target_server = CppFunctions:getTargetServer()
    local key = 'SERVER_' .. target_server

	-- 해당 부분에 강제 접속할 게임 서버 주소 입력
    URL[key] = url
    
    if (LIVE_SERVER_CONNECT) then
        URL[key] = URL['SERVER_LIVE'] 
    end
end


-- Platform server
URL['PLATFORM_DEV'] = 'https://d27b1s0fi2x5xo.cloudfront.net/1003'
URL['PLATFORM_QA'] = 'https://d27b1s0fi2x5xo.cloudfront.net/1003'
URL['PLATFORM_LIVE'] = 'http://dn3bwi5jsw20r.cloudfront.net/1003'
function GetPlatformApiUrl()
    local target_server = CppFunctions:getTargetServer()
    local key = 'PLATFORM_' .. target_server
    local url = URL[key]
    if (not url) then
        error('key(Platform server) : ' .. key)
    end
    return url
end

-- Patch server
URL['PATCH_DEV'] = 'http://s3.dvm.perplelab.com/dv_test'
URL['PATCH_QA'] = 'http://s3.dvm.perplelab.com/dv_test'
URL['PATCH_LIVE'] = 'http://s3.dvm.perplelab.com/dv_test'
function GetPatchServer()
    local target_server = CppFunctions:getTargetServer()
    local key = 'PATCH_' .. target_server
    local url = URL[key]
    if (not url) then
        error('key(Patch server) : ' .. key)
    end
    return url
end

-- Chatting server 
URL['CHAT_DEV'] = 'dv-test.perplelab.com:9013'
URL['CHAT_QA'] = 'dv-qa.perplelab.com:9013'
URL['CHAT_LIVE'] = 'dvm-ch1.perplelab.com:2222'
function GetChatServerUrl()
    local target_server = CppFunctions:getTargetServer()
    local key = 'CHAT_' .. target_server
    local url = URL[key]
    if (not url) then
        error('key(Chatting server) : ' .. key)
    end
    local l_address = plSplit(url, ':')
    local ip = l_address[1]
    local port = l_address[2]
    return ip, port
end
function SetChatServerUrl(url)
    local target_server = CppFunctions:getTargetServer()
    local key = 'CHAT_' .. target_server
    URL[key] = url
end

-- Clan Chatting server 
URL['CLAN_CHAT_DEV'] = 'dv-test.perplelab.com:9014'
URL['CLAN_CHAT_QA'] = 'dv-qa.perplelab.com:9014'
URL['CLAN_CHAT_LIVE'] = 'dvm-ch1.perplelab.com:2223'
function GetClanChatServerUrl()
    local target_server = CppFunctions:getTargetServer()
    local key = 'CLAN_CHAT_' .. target_server
    local url = URL[key]
    if (not url) then
        error('key(Chatting server) : ' .. key)
    end
    local l_address = plSplit(url, ':')
    local ip = l_address[1]
    local port = l_address[2]
    return ip, port
end
function SetClanChatServerUrl(url)
    local target_server = CppFunctions:getTargetServer()
    local key = 'CLAN_CHAT_' .. target_server
    URL[key] = url
end

-- Perplelab
--URL['PERPLELAB_AGREEMENT'] = 'http://s3.dvm.perplelab.com/perplelab/agreement.html'
--URL['PERPLELAB_PI'] = 'http://s3.dvm.perplelab.com/perplelab/personalinformation.html'
--URL['PERPLELAB_AGREEMENT_EN'] = 'http://s3.dvm.perplelab.com/perplelab/agreement_en.html'
--URL['PERPLELAB_PI_EN'] = 'http://s3.dvm.perplelab.com/perplelab/personalinformation_en.html'

-- @sgkim 2019.02.28 운영 주체가 하이브로로 이관되면서 변경된 이용 약관 적용 (네이버 카페, PLUG)
URL['PERPLELAB_AGREEMENT'] = 'https://cafe.naver.com/dragonvillagemobile/105981' -- 이용 약관 (Terms of Service)
-- Changed at 2021-09-07 from url below
-- https://cafe.naver.com/dragonvillagemobile/105979
URL['PERPLELAB_PI'] = 'https://cafe.naver.com/dragonvillagemobile/126209' -- 개인 정보 취급 방침 (Privacy Policy)
URL['PERPLELAB_AGREEMENT_EN'] = 'https://cafe.naver.com/dragonvillagemobile/149221' -- 이용 약관 (Terms of Service)
URL['PERPLELAB_PI_EN'] = 'https://cafe.naver.com/dragonvillagemobile/149220' -- 개인 정보 취급 방침 (Privacy Policy)

-- Highbrow
URL['HIGHBROW'] = 'http://account.game.highbrow-inc.com:8080/'
URL['HIGHBROW_CS'] = 'http://m.dragonvillage.net/support/customer/faq'

-- CS
URL['DVM_CS'] = 'http://ask.dvm.perplelab.com'
URL['DVM_CS_EN'] = 'http://ask.dvm.perplelab.com/index_en.html'

-- Xsolla 
URL['DVM_CS_XSOLLA'] = 'http://ask.dvm.perplelab.com/index_xsolla.html'
URL['DVM_CS_XSOLLA_EN'] = 'http://ask.dvm.perplelab.com/index_xsolla_en.html'
URL['DVM_XSOLLA_DOWNLOAD'] = 'http://dvmx.perplelab.com'

-- 원스토어(ONEstore)
URL['DVM_ONESTORE_DOWNLOAD'] = 'https://onesto.re/0000746979'

function GetCSUrl(server)
    if ((server == SERVER_NAME.KOREA) or (g_localData:getLang() == 'ko'))then
        return PerpleSdkManager:xsollaIsAvailable() and URL['DVM_CS_XSOLLA'] or URL['DVM_CS']
    else
        return PerpleSdkManager:xsollaIsAvailable() and URL['DVM_CS_XSOLLA_EN'] or URL['DVM_CS_EN']
    end
end

-- 약관동의 홈페이지 연결
function GoToAgreeMentUrl()
    local url
    -- '한국어' 일때만
    if (g_localData:getLang() == 'ko') then
        url = URL['PERPLELAB_AGREEMENT']
    else
        url = URL['PERPLELAB_AGREEMENT_EN']
    end
    UI_WebView(url)
end

-- 개인정보 홈페이지 연결
function GoToPersonalInfoUrl()
    local url
    -- '한국어' 일때만
    if (g_localData:getLang() == 'ko') then
        url = URL['PERPLELAB_PI']
    else
        url = URL['PERPLELAB_PI_EN']
    end
    UI_WebView(url)
end

-- 고객센터 URL 연결
function GetCustomerCenterUrl()
    local is_not_global = (g_localData:getLang() == 'ko')
    local access_key = (is_not_global and 'a93d04e5bb650d54') or '88aa568a2ff202f6'
    local url_param = 'access_key=' .. access_key

    local secret_key = (is_not_global and '61313ed352410a4586c3e9d956a6cf40') or '1426e06449ea8a3ae5f0370fb7e77825'
    url_param = url_param .. '&secret_key=' .. secret_key

    local brand_key = (is_not_global and 'dvm') or 'dvm_g'
    url_param = url_param .. '&brand_key1=' .. brand_key

    local user_name = g_userData:get('nick')
    if CppFunctions:isIos() and (IS_TEST_MODE() == false) and (getAppVerNum() < 1003007) then -- @yjkil 22.06.07 - 1.3.7 빌드 및 1.3.6 지원 종료 시 코드 제거해야 함
    elseif user_name then
        url_param = url_param .. '&userName=' .. user_name
    end

    local market, os = GetMarketAndOS()
    if os then
        url_param = url_param .. '&operatingSystem=' .. os
    end

    local device = ErrorTracker:getDevice()
    if device then
        url_param = url_param .. '&deviceModel=' .. device
    end

    local uid = g_userData:get('uid')
    local server = ServerListData.getInstance():getSelectServer()
    if uid then
        url_param = url_param .. '&extra_field1=' .. uid
    end
    if server then
        url_param = url_param .. '&extra_field2=' .. server
    end

    if market then
        url_param = url_param .. '&extra_field3=' .. market
    end

    local url = 'https://highbrow.oqupie.com/portals/finder?' .. url_param
    return url
end