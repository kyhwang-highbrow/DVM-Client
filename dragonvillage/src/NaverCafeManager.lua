local NAVER_NEO_ID_CONSUMER_KEY = '_hBggTZAp2IPapvAxwQl'
local NAVER_COMMUNITY_ID        = 1013702
local NAVER_CHANNEL_KOREA       = 0
local NAVER_CHANNEL_AMERICA     = 1031345
local NAVER_CHANNEL_JAPAN       = 1031352
local NAVER_CHANNEL_ASIA_TH_TW  = 1031353
local NAVER_CHANNEL_ASIA_EN     = 1031441

-- 네이버 SDK로 게시글 바로가기에 사용되는 테이블 키 값(table_naver_article)
local T_ARTICLE_TABLE_KEY = {}
T_ARTICLE_TABLE_KEY[NAVER_CHANNEL_KOREA] = 'korea'
T_ARTICLE_TABLE_KEY[NAVER_CHANNEL_AMERICA] = 'america'
T_ARTICLE_TABLE_KEY[NAVER_CHANNEL_JAPAN] = 'japan'
T_ARTICLE_TABLE_KEY[NAVER_CHANNEL_ASIA_EN] = 'asia_en'
T_ARTICLE_TABLE_KEY[NAVER_CHANNEL_ASIA_TH_TW] = 'asia_twzh'

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
-- function naverCafeGetChannelCode
-------------------------------------
function NaverCafeManager:naverCafeGetChannelCode()
    if (skip()) then 
        return
    end

    return PerpleSDK:naverCafeGetChannelCode()
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
-- function naverCafeStartWithArticleByKey
-- @brief 네이버 카페에 특정게시글 보며 열기 
-------------------------------------
function NaverCafeManager:naverCafeStartWithArticleByKey(article_key, server_name, lang)
    -- 파라미터 확인
    if (not article_key) then
        cclog('article_key가 nil입니다.')
        return
    end

    -- 테이블 확인
    local table_naver_article = TABLE:get('table_naver_article')
    if (not table_naver_article) then
        cclog('table_naver_article가 nil입니다.')
        return
    end

    -- 테이블에 해당 값 확인
    local t_data = table_naver_article[article_key]
    if (not t_data) then
        cclog('table_naver_article에서 ' .. article_key .. '값이 없습니다.')
        return
    end

    local channel_code = self:naverCafeGetChannelCode()
    local article_id = t_data[channel_code]
    cclog('article id : ' .. article_id)

    -- 네이버 SDK 호출
    self:naverCafeStartWithArticle(artice_id)
end

-------------------------------------
-- function naverCafeStartWithArticle
-------------------------------------
function NaverCafeManager:naverCafeStartWithArticle(artice_id)
    if (skip()) then
        return
    end
    PerpleSDK:naverCafeStartWithArticle(artice_id)
end

-------------------------------------
-- function naverCafeSetCallback
-- @brief 네이버 카페에 callback 세팅
-------------------------------------
function NaverCafeManager:naverCafeSetCallback()
    if (skip()) then
        return
    end
    PerpleSDK:naverCafeSetCallback(function(ret, info) self:onNaverCafeCallback(ret, info) end)
end

-------------------------------------
-- function onNaverCafeCallback
-- @brief 네이버 카페에 callback 세팅
-- @param info : String
-------------------------------------
function NaverCafeManager:onNaverCafeCallback(ret, info)
	cclog('## naver cafe call back', ret, info)
    
    -- onSdkStarted / info = nil
    -- 카페 plug open (앱 구동시는 아님. 띄울때마다 동작)
    if (ret == 'start') then
        cclog('# channel_code : ' .. self:naverCafeGetChannelCode())
        return

    -- onSdkStopped / info = nil
    -- 카페 plug close
    elseif (ret == 'stop') then
        return

    -- onWidgetScreenshotClick / info = nil
    -- widget의 스크린샷 버튼 클릭
    elseif ret == 'screenshot' then
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
        
    -- onJoined / info = nil
    elseif (ret == 'join') then

    -- onPostedArticle / info = {menuId, imageCount, videoCount}
    elseif (ret == 'article') then
        ccdump(info)

	-- onPostedComment / info = articleId
	elseif (ret == 'comment') then
	
	-- onClickAppSchemeBanner / info = appScheme
	elseif (ret == 'banner') then

	-- onVoted / info = articleId
	elseif (ret == 'vote') then

	-- onRecordFinished / info = url
	elseif (ret == 'record') then

	-- onError / info = info
	elseif (ret == 'error') then

    end

    -- event 처리
    self:naverCafeEvent(ret, info)
end

-------------------------------------
-- function naverCafeEvent
-------------------------------------
function NaverCafeManager:naverCafeEvent(cb_type, cb_info)
    -- 활성 이벤트 체크
    local l_active_event = TableNaverEvent:getActiveEventList()

    local channel_code = self:naverCafeGetChannelCode()
    local event_key, event_cond = nil
    
    -- 타입에 따라 별도 처리
    if (cb_type == 'article') then
        cb_info = tonumber(cb_info['menuId'])
    elseif isExistValue(cb_type, 'comment', 'article', 'vote') then
        cb_info = tonumber(cb_info)
    end

    -- 조건 충족 체크
    for i, t_event in ipairs(l_active_event) do
        event_key = t_event['event_key']
        event_cond = t_event['cond_' .. channel_code]

        -- 이벤트 수행 여부 확인
        if (not g_naverEventData:isAlreadyDone(event_key))
        and (cb_type == t_event['event_type'])
        and ((cb_info == event_cond) or (cb_info == '')) then
                    
            -- (cb_info == '')
            -- cb_type 중에서 join과 같이 별도의 info가 넘어오지 않는 경우 통과시키기 위한 처리
            
            cclog('## naver cafe plug event request : ', event_key, cb_type, cb_info)
            local function finish_cb()
                self:naverCafeStop()
            end
            g_naverEventData:request_naverEventReward(event_key, cb_type, finish_cb)
            break
        end
    end
    
end

-------------------------------------
-- function naverInitGlobalPlug(server, lang, isSaved)
-- @brief 네이버 글로벌 플러그 init
-------------------------------------
function NaverCafeManager:naverInitGlobalPlug(server, lang, isSaved)
    if (skip()) then
        return NAVER_CHANNEL_KOREA
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
    if channelCode then        
        PerpleSDK:naverCafeSetChannelCode(channelCode)
    end

    return channelID
end