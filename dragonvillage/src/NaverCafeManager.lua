local NAVER_NEO_ID_CONSUMER_KEY = '_hBggTZAp2IPapvAxwQl'
local NAVER_COMMUNITY_ID        = 1013702
local NAVER_CHANNEL_AMERICA     = 1031345
local NAVER_CHANNEL_JAPAN       = 1031352
local NAVER_CHANNEL_ASIA_TH_TW  = 1031353
local NAVER_CHANNEL_ASIA_EN     = 1031441

local NAVER_CHANNEL_CODE_KOREAN = 'ko'
local NAVER_CHANNEL_CODE_ENGLISH = 'en'
local NAVER_CHANNEL_CODE_CHINESE_TRADITIONAL ='zh_TW'
local NAVER_CHANNEL_CODE_JAPANESE = 'ja'

-------------------------------------
-- table NaverCafeManager
-- @brief 네이버 카페 SDK 매니져
-------------------------------------
NaverCafeManager = {
}

-------------------------------------
-- function skip
-------------------------------------
local function skip()
    if (isWin32()) then 
        return true
    end

    return false
end

-------------------------------------
-- function naverCafeShowWidgetWhenUnloadSdk
-------------------------------------
function NaverCafeManager:naverCafeShowWidgetWhenUnloadSdk(isShowWidget)
    if (skip()) then 
        return
    end

    -- @isShowWidget : 1(SDK unload 시 카페 위젯 보여주기) or 0(안 보여주기)
    PerpleSDK:naverCafeShowWidgetWhenUnloadSdk(isShowWidget)
end

-------------------------------------
-- function naverCafeStartWidget
-------------------------------------
function NaverCafeManager:naverCafeStartWidget()
    if (skip()) then 
        return
    end

    PerpleSDK:naverCafeStartWidget()
end

-------------------------------------
-- function naverCafeStart
-------------------------------------
function NaverCafeManager:naverCafeStart(tapNumber)
    if (skip()) then 
        return
    end

    -- @tapNumber : 0(Home) or 1(Notice) or 2(Event) or 3(Menu) or 4(Profile)
    PerpleSDK:naverCafeStart(tapNumber)
end

-------------------------------------
-- function naverCafeStop
-------------------------------------
function NaverCafeManager:naverCafeStop()
    if (skip()) then 
        return
    end

    PerpleSDK:naverCafeStop()
end

-------------------------------------
-- function naverCafeSyncGameUserId
-- @brief 네이버 카페에 user id 연동
-------------------------------------
function NaverCafeManager:naverCafeSyncGameUserId(uid)
    if (skip()) then 
        return
    end

    if (not uid) then
        return
    end

    if (uid == '') then
        return
    end

    if (type(uid) ~= 'string') then
        return
    end

    PerpleSDK:naverCafeSyncGameUserId(uid)
end

-------------------------------------
-- function naverCafeStartImageWrite
-- @brief 네이버 카페에 이미지 글쓰기 시작
-------------------------------------
function NaverCafeManager:naverCafeStartImageWrite(fileUri)
    if (skip()) then
        return
    end

    if not fileUri then
        return
    end

    PerpleSDK:naverCafeStartImageWrite(fileUri)
end

-------------------------------------
-- function naverCafeStartWithArticle
-- @brief 네이버 카페에 특정게시글 보며 열기 
-------------------------------------
function NaverCafeManager:naverCafeStartWithArticle(articeId)
    if (skip()) then
        return
    end

    if not articeId then
        return
    end

    PerpleSDK:naverCafeStartWithArticle(articeId)
end

-------------------------------------
-- function naverCafeSetCallback
-- @brief 네이버 카페에 callback 세팅
-------------------------------------
function NaverCafeManager:naverCafeSetCallback()
    if (skip()) then
        return
    end

    --콜백 세팅할때 세팅되는게 필요해서
    --현재는 스크린샷 기능만 콜백으로 사용
    PerpleSDK:naverCafeSetCallback(function(ret, info) self:onNaverCafeCallback(ret, info) end)
end

-------------------------------------
-- function naverCafeSetCallback
-- @brief 네이버 카페에 callback 세팅
-------------------------------------
function NaverCafeManager:onNaverCafeCallback(ret, info)
    if ret == 'screenshot' or ret == 'article' then
        local size = cc.Director:getInstance():getWinSize()
        local texture = cc.RenderTexture:create( size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES )
        texture:setPosition( size.width / 2, size.height / 2 )

        texture:begin()
        g_currScene.m_scene:visit()
        texture:endToLua()
                
        local fileName = 'screenShot_' .. TimeLib:initInstance():getServerTime() .. '.png'
        texture:saveToFile( fileName, cc.IMAGE_FORMAT_PNG, true, function(node, retFileName)
            cclog( 'retFileName : ' .. retFileName )
            self:naverCafeStartImageWrite( retFileName )
        end )
        
    end
end

local function isUseChannelCode( ver )
    local server = CppFunctionsClass:getTargetServer()
    if server == "DEV" then
        return (ver == "0.4.9" or ver == "9.9.9")
    elseif server == "QA" then
        return ver == "0.5.0"
    elseif server == "LIVE" then
        return ver == "1.1.0"
    end

    return false
end

-------------------------------------
-- function naverInitGlobalPlug(server, lang, isSaved)
-- @brief 네이버 글로벌 플러그 init
-------------------------------------
function NaverCafeManager:naverInitGlobalPlug(server, lang, isSaved)
    if (skip()) then
        return
    end

    --선택한서버와 언어에따라 플러그 채널을 강제 선택해줍니다. --김종환이사님
    local channelID = 0
    local channelCode    
    --네이버 sdk버그 때문에 한국서버 한국어 사용자는 강제로 한국 커뮤니티로 자동 세팅한다.
    if g_localData:isKoreaServer() and lang == 'ko' then
        channelID = 0
        channelCode = NAVER_CHANNEL_CODE_KOREAN
    elseif isSaved and isSaved > 0 then
        --이때는 sdk에 저장되어 있는값으로 그냥 사용하기 위해서 
    elseif server == SERVER_NAME.AMERICA then
        channelID = NAVER_CHANNEL_AMERICA
    elseif server == SERVER_NAME.JAPAN then
        channelID = NAVER_CHANNEL_JAPAN
    elseif server == SERVER_NAME.ASIA then
        if lang == 'en' then
            channelID = NAVER_CHANNEL_ASIA_EN
        else
            channelID = NAVER_CHANNEL_ASIA_TH_TW
        end
    end

    cclog('NaverCafeManager:naverInitGlobalPlug')
    cclog('isSaved : ' .. (isSaved or 'not') )
    cclog('server : ' .. ( server or 'not' ) )
    cclog('lang : ' .. ( lang or  'not' ) )
    cclog('channelID : ' .. channelID)
    cclog('channelCode : ' .. (channelCode or 'not') )

    PerpleSDK:naverCafeInitGlobalPlug(NAVER_NEO_ID_CONSUMER_KEY, NAVER_COMMUNITY_ID, channelID)
    if channelCode and isUseChannelCode( CppFunctionsClass:getAppVer() ) then        
        PerpleSDK:naverCafeSetChannelCode(channelCode)
    end

end


