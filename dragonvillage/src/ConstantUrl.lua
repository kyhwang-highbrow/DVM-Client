URL = {}

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
    URL[key] = url
end


-- Platform server 
-- 아직 라이브,QA서버는 작업전이라 개발로 전부 붙입니다.
URL['PLATFORM_DEV'] = 'http://dn3bwi5jsw20r.cloudfront.net/1003'
URL['PLATFORM_QA'] = 'http://dn3bwi5jsw20r.cloudfront.net/1003'
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

-- Highbrow
URL['HIGHBROW'] = 'http://account.game.highbrow-inc.com:8080/'
URL['HIGHBROW_CS'] = 'http://m.dragonvillage.net/support/customer/faq'
URL['DVM_CS'] = 'http://ask.dvm.perplelab.com'
URL['DVM_COMMUNITY'] = 'http://m.dragonvillage.net/dvm'