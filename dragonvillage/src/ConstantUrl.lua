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

-- Platform server 
URL['PLATFORM_DEV'] = 'http://dev.platform.perplelab.com/1003'
URL['PLATFORM_QA'] = 'http://dev.platform.perplelab.com/1003'
URL['PLATFORM_LIVE'] = 'http://platform.perplelab.com/1003'
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
    return ip
end

-- Perplelab
URL['PERPLELAB_AGREEMENT'] = 'http://s3.dvm.perplelab.com/perplelab/agreement.html'
URL['PERPLELAB_PI'] = 'http://s3.dvm.perplelab.com/perplelab/personalinformation.html'

-- Highbrow
URL['HIGHBROW'] = 'http://account.game.highbrow-inc.com:8080/'
URL['HIGHBROW_CS'] = 'http://www.dragonvillage.net/support/customer/faq'
