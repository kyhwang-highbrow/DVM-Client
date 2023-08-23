-------------------------------------
-- table NaverCafeManager
-- @brief 네이버 카페 매니져

-- 수정 2020.10.12

-- [개요]
-- 이전에는 네이버 카페 SDK 기능을 관리했으나 네이버 카페 SDK를 제거함에 따라 네이버 카페 관련 유틸성 클래스로 변경함
-- 네이버 카페는 웹뷰를 통해 접근한다.
-- 게임 언어가 한국어가 아닌 경우 가장 적합한 플러그 채널로 보낸다.

-- [주요 기능]
-- 네이버 카페 출력
-- 네이버 카페 특정 게시글 출력
-- 네이버 도움말 버튼 관리
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
-- function naverCafeStart
-------------------------------------
function NaverCafeManager:naverCafeStart()
    if (skip()) then 
        return
    end

    local plug_url = self:getUrlByChannel(nil) -- article_id
    SDKManager:goToWeb(plug_url)
end

-------------------------------------
-- function naverCafeGetChannelCode
-------------------------------------
function NaverCafeManager:naverCafeGetChannelCode()
    if (skip()) then 
        return 'ko'
    end

    local lang = g_localData:getLang()
    local channel_code

    -- 번체 변환 필요
    if (lang == 'zh') then
        channel_code = 'zh_TW'

    -- 태국어 / 스페인어는 영어로 변경
    elseif (lang == 'th') then
        channel_code = 'en'
    elseif (lang == 'es') then
        channel_code = 'en'

    -- lang이 없는 경우 영어로 처리
    elseif (lang == nil) then
        channel_code = 'en'

    -- 한국어, 영어, 일본어
    else
        channel_code = lang
    end

    cclog('############## cafe channel_code', channel_code)
    return channel_code
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
    local plug_url = self:getUrlByChannel(article_id) -- article_id
    SDKManager:goToWeb(plug_url)
end

-------------------------------------
-- function getUrlByChannel
-------------------------------------
function NaverCafeManager:getUrlByChannel(article_id)
    local plug_url
    local channel_code = self:naverCafeGetChannelCode()
    if (channel_code == 'ko') then
        plug_url = 'https://m.cafe.naver.com/ca-fe/web/cafes/29168475/menus/6'
    elseif (channel_code == 'en') then
        plug_url = 'https://www.plug.game/DragonvillageMGlobal/1031345#/posts/'
    elseif (channel_code == 'ja') then
        plug_url = 'https://www.plug.game/DragonvillageMGlobal/1031352#/posts/'
    elseif (channel_code == 'zh') then
        plug_url = 'https://www.plug.game/DragonvillageMGlobal/1031353#/posts/'
    elseif (channel_code == 'zh_TW') then
        plug_url = 'https://www.plug.game/DragonvillageMGlobal/1031353#/posts/'
    else
        plug_url = 'https://www.plug.game/DragonvillageMGlobal/1031345#/posts/'
    end

    if article_id then
        plug_url = plug_url .. article_id
    end

    return plug_url
end