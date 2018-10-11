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
URL['SERVER_LIVE'] = 'http://dvm-api.perplelab.com'
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
-- 아직 라이브,QA서버는 작업전이라 개발로 전부 붙입니다.
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
URL['PATCH_DEV'] = 'http://patch-12.perplelab.net/dv_test'
URL['PATCH_QA'] = 'http://patch-12.perplelab.net/dv_test'
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
URL['PERPLELAB_AGREEMENT'] = 'http://s3.dvm.perplelab.com/perplelab/agreement.html'
URL['PERPLELAB_PI'] = 'http://s3.dvm.perplelab.com/perplelab/personalinformation.html'
URL['PERPLELAB_AGREEMENT_EN'] = 'http://s3.dvm.perplelab.com/perplelab/agreement_en.html'
URL['PERPLELAB_PI_EN'] = 'http://s3.dvm.perplelab.com/perplelab/personalinformation_en.html'


-- Highbrow
URL['HIGHBROW'] = 'http://account.game.highbrow-inc.com:8080/'
URL['HIGHBROW_CS'] = 'http://m.dragonvillage.net/support/customer/faq'
URL['DVM_COMMUNITY'] = 'http://m.dragonvillage.net/dvm'

--cs
URL['DVM_CS'] = 'http://ask.dvm.perplelab.com'
URL['DVM_CS_GLOBAL'] = 'http://ask.dvm.perplelab.com/index_en.html'

function GetCSUrl( server )
    if server == SERVER_NAME.KOREA then
        return URL['DVM_CS']
    else
        return URL['DVM_CS_GLOBAL']
    end
end

-- 약관동의 홈페이지 연결
function GoToAgreeMentUrl()
    local url
    if (g_localData:isKoreaServer()) then
        url = URL['PERPLELAB_AGREEMENT']
    else
        url = URL['PERPLELAB_AGREEMENT_EN']
    end
    UI_WebView(url)
end

-- 개인정보 홈페이지 연결
function GoToPersonalInfoUrl()
    local url
    if (g_localData:isKoreaServer()) then
        url = URL['PERPLELAB_PI']
    else
        url = URL['PERPLELAB_PI_EN']
    end
    UI_WebView(url)
end