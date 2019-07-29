-------------------------------------
-- table NaverCafeManager
-- @brief 네이버 카페 SDK 매니져
-------------------------------------
NaverCafeManager = {
    m_bDisableNaverSDK = false,
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

-- 네이버 카페 SDK 비활성화 (가능한 경우 웹브라우저로 카페 호출)
-- 네이버 카페 SDK에서 웹뷰로 인한 비정상 종료가 발생됨이 의심됨
-- 임시 방편으로 네이버 카페 SDK를 사용하지 않기로 함
NaverCafeManager.m_bDisableNaverSDK = true

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

    -- 네이버 카페 SDK 비활성화인 경우 함수를 호출하더라도 위젯을 띄우지 않음
    if (NaverCafeManager.m_bDisableNaverSDK == true) then
        return
    end

    PerpleSDK:naverCafeStartWidget()
end

-------------------------------------
-- function naverCafeStart
-- @param tapNumber : 0(Home) or 1(Notice) or 2(Event) or 3(Menu) or 4(Profile)
-------------------------------------
function NaverCafeManager:naverCafeStart(tapNumber)
    if (skip()) then 
        return
    end

    if (NaverCafeManager.m_bDisableNaverSDK == true) then
        local plug_url = self:getUrlByChannel(nil) -- article_id
        SDKManager:goToWeb(plug_url)
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
        return 'ko'
    end

    local channel_code = PerpleSDK:naverCafeGetChannelCode()

    -- 중국어는 ios와 aos가 다르게 넘어오는 것을 확인해서 보정 중
    if (channel_code == 'zh_tw') then
        channel_code = 'zh_TW'

    elseif (channel_code == 'zh') then
        channel_code = 'zh_TW'

    -- channel code가 없는 경우 처리
    elseif (channel_code == nil) then
        channel_code = 'en'
        cclog('## not channel_code -> en')
    end

    return channel_code
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
-- function setPluginInfoBtn
-- @brief 관리 용이하게 여기서 click_handler 등록, 글이 없다면 버튼 visible off
-- @brief ex) NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'rune_help')
-------------------------------------
function NaverCafeManager:setPluginInfoBtn(node, article_key)
    -- 파라미터 확인
    if (not article_key) then
        cclog('article_key가 nil입니다.')
        node:setVisible(false)
        return
    end

    -- 테이블 확인
    local table_naver_article = TABLE:get('table_naver_article')
    if (not table_naver_article) then
        cclog('table_naver_article가 nil입니다.')
        node:setVisible(false)
        return
    end

    -- 테이블에 해당 값 확인
    local t_data = table_naver_article[article_key]
    if (not t_data) then
        cclog('table_naver_article에서 ' .. article_key .. '값이 없습니다.')
        node:setVisible(false)
        return
    end

    local channel_code = self:naverCafeGetChannelCode()
    local article_id = t_data[channel_code]
    -- 연결된 채널코드에 article_id가 없다면 visible off
    if (not article_id or article_id == '') then
        node:setVisible(false)
    else
        node:setVisible(true)
        node:registerScriptTapHandler(function() self:naverCafeStartWithArticle(article_id) end)
    end
end

-------------------------------------
-- function naverCafeStartWithArticleByKey
-- @brief 네이버 카페에 특정게시글 보며 열기 
-------------------------------------
function NaverCafeManager:naverCafeStartWithArticleByKey(article_key)
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
    if (not article_id or article_id == '') then
        article_id = t_data['en']
    end
    
    -- 네이버 SDK 호출
    self:naverCafeStartWithArticle(article_id)
end

-------------------------------------
-- function naverCafeStartWithArticle
-------------------------------------
function NaverCafeManager:naverCafeStartWithArticle(article_id)
    if (CppFunctions:isWin32()) then
        local plug_url = self:getUrlByChannel(article_id)
        SDKManager:goToWeb(plug_url)

    elseif (NaverCafeManager.m_bDisableNaverSDK == true) then
        local plug_url = self:getUrlByChannel(article_id) -- article_id
        SDKManager:goToWeb(plug_url)
        
    else
        PerpleSDK:naverCafeStartWithArticle(article_id)
    end
end

-------------------------------------
-- function getUrlByChannel
-------------------------------------
function NaverCafeManager:getUrlByChannel(article_id)
    local plug_url
    local channel_code = self:naverCafeGetChannelCode()
    if (channel_code == 'ko') then
        plug_url = 'http://cafe.naver.com/dragonvillagemobile/'
    elseif (channel_code == 'en') then
        plug_url = 'https://www.plug.game/DragonvillageMGlobal/1031345#/posts/'
    elseif (channel_code == 'ja') then
        plug_url = 'https://www.plug.game/DragonvillageMGlobal/1031352#/posts/'
    elseif (channel_code == 'zh') then
        plug_url = 'https://www.plug.game/DragonvillageMGlobal/1031353#/posts/'
    else
        plug_url = 'https://www.plug.game/DragonvillageMGlobal/1031345#/posts/'
    end

    if article_id then
        plug_url = plug_url .. article_id
    end

    return plug_url
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
    -- plug를 계정 생성 전에 하는 경우 문제 발생
    if (not g_userData) or (not g_userData:get('uid')) then
        cclog('## uid is nil')
        return
    end

    -- 활성 이벤트 체크
    local l_active_event = TableNaverEvent:getOnTimeEventList()
    
    local channel_code = self:naverCafeGetChannelCode()
    local event_key, event_cond = nil
    
    -- 타입에 따라 별도 처리
    if (cb_type == 'article') then
        local t_info = dkjson.decode(cb_info)
		if (t_info) then
			cb_info = tonumber(t_info['menuId'])
		end
    elseif isExistValue(cb_type, 'comment', 'vote') then
        cb_info = tonumber(cb_info)
    end

    -- 조건 충족 체크
    local is_event_match
    for i, t_event in ipairs(l_active_event) do
        event_key = t_event['event_key']
        event_cond = t_event['cond_' .. channel_code]
        is_event_match = true

        -- 이미 클리어
        if (g_naverEventData:isAlreadyDone(event_key)) then
            is_event_match = false
        end

        -- 콜백 타입과 이벤트 타입 불일치
        if (cb_type ~= t_event['event_type']) then
            is_event_match = false
        end

        -- 조건 체크 안하는 이벤트 -> 통과
        if (cb_type == 'join') then

        -- 조건 체크 이벤트
        else
            if (cb_info ~= event_cond) then
                is_event_match = false
            end
        end

        if (is_event_match) then
            cclog('## naver cafe plug event request : ', event_key, cb_type, cb_info)
            local function finish_cb()
                self:naverCafeStop()
            end
            g_naverEventData:request_naverEventReward(event_key, cb_type, TableNaverEvent.getEventName(t_event), finish_cb)
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

    local NAVER_NEO_ID_CONSUMER_KEY = '_hBggTZAp2IPapvAxwQl'
    local NAVER_COMMUNITY_ID        = 1013702
    
    local NAVER_CHANNEL_KOREA       = 0
    local NAVER_CHANNEL_EN     = 1031345
    local NAVER_CHANNEL_JA       = 1031352
    local NAVER_CHANNEL_ZH_TW  = 1031353
    --local NAVER_CHANNEL_ASIA_EN     = 1031441

    local NAVER_CHANNEL_CODE_KOREAN = 'ko'
    local NAVER_CHANNEL_CODE_ENGLISH = 'en'
    local NAVER_CHANNEL_CODE_JAPANESE = 'ja'
    local NAVER_CHANNEL_CODE_CHINESE_TRADITIONAL ='zh_TW'

    --선택한서버와 언어에따라 플러그 채널을 강제 선택해줍니다. --김종환이사님
    -- @Nullable
    local channel_id = 0
    local channel_code

    if (lang == 'en') then
        channel_id = NAVER_CHANNEL_EN
        channel_code = NAVER_CHANNEL_CODE_ENGLISH

    elseif (lang == 'ja') then
        channel_id = NAVER_CHANNEL_JA
        channel_code = NAVER_CHANNEL_CODE_JAPANESE

    elseif (lang == 'zh') then
        channel_id = NAVER_CHANNEL_ZH_TW
        channel_code = NAVER_CHANNEL_CODE_CHINESE_TRADITIONAL

    elseif (lang == 'ko') then
        channel_id = NAVER_CHANNEL_KOREA
        channel_code = NAVER_CHANNEL_CODE_KOREAN

    else
        channel_id = NAVER_CHANNEL_EN
        channel_code = NAVER_CHANNEL_CODE_ENGLISH

    end

    -- 다음 패치에 적용
    -- 이때는 sdk에 저장되어 있는값으로 그냥 사용하기 위해서
    -- elseif isSaved and isSaved > 0 then
    -- end

    cclog('NaverCafeManager:naverInitGlobalPlug')
    cclog('isSaved : ' .. (isSaved or 'not') )
    cclog('server : ' .. ( server or 'not' ) )
    cclog('lang : ' .. ( lang or  'not' ) )
    cclog('channel_id : ' .. channel_id)
    cclog('channel_code : ' .. (channel_code or 'not') )

    PerpleSDK:naverCafeInitGlobalPlug(NAVER_NEO_ID_CONSUMER_KEY, NAVER_COMMUNITY_ID, channel_id)
    if channel_code then
        PerpleSDK:naverCafeSetChannelCode(channel_code)
    end

    return channel_id
end
