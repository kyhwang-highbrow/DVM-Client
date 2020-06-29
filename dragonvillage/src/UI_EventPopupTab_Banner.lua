local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Banner
-------------------------------------
UI_EventPopupTab_Banner = class(PARENT,{
        m_structBannerData = 'StructEventPopupTab',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Banner:init(owner, struct_event_popup_tab)
    self.m_structBannerData = struct_event_popup_tab.m_eventData
    local res = self.m_structBannerData['banner']
    local is_ui_res = string.match(res, '%.ui') and true or false
    local target_ui = (is_ui_res == true) and res or 'event_banner.ui'
    local vars = self:load(target_ui) 
    
    -- 리소스가 png인 경우 이미지 추가
    if (is_ui_res == false) then
        local img = cc.Sprite:create(res)
        if img then
            img:setDockPoint(CENTER_POINT)
            img:setAnchorPoint(CENTER_POINT)
            vars['bannerNode']:addChild(img)
        end
    end

    local banner_btn = vars['bannerBtn']
    if (banner_btn) then
        banner_btn:registerScriptTapHandler(function() self:click_bannerBtn() end)
    end

    -- bannerBtn 경우 풀팝업에서는 막히지만 linkBtn은 막히지 않게
    local link_btn = vars['linkBtn']
    if (link_btn) then
        link_btn:registerScriptTapHandler(function() self:click_bannerBtn() end)
    end
    
    self:init_customUI()
end

-------------------------------------
-- function init_customUI
-------------------------------------
function UI_EventPopupTab_Banner:init_customUI()
    local vars = self.vars
    local struct_banner_data = self.m_structBannerData


    local banner = struct_banner_data['banner']

    -- 드래곤 히어로즈 택틱스 크로스 프로모션
    if (banner == 'event_dht_promotion.ui') then

        -- 공지로 이동
        if vars['noticeLinkBtn'] then
            vars['noticeLinkBtn']:registerScriptTapHandler(function()
                    local article_key = 'event_dht_promotion'
                    NaverCafeManager:naverCafeStartWithArticleByKey(article_key)
                end)
        end
        
        -- 게임으로 이동 (구글 플레이 or 앱스토어)
        if vars['gameLinkBtn'] then
            vars['gameLinkBtn']:registerScriptTapHandler(function()
                    SDKManager:goToWeb('https://perplelab.sng.link/Don2b/v08o')
                end)
        end

    -- 거대용 던전, 거목 던전 요일 입장 제한 해제 기념 핫타임
    elseif (banner == 'event_fevertime_notice_01.ui') then
        do -- 거목 던전 (친밀도 열매)
            local label = vars['infoLabel1']
            if label then
                local str = Str('거목 던전에서 친밀도 열매 획득량이 {@yellow}{1}% 증가{@default}합니다.', 100)
                label:setString(str)
            end

            local label = vars['timeLabel1']
            if label then
                label:setString('6/30 00:00 ~ 7/2 23:59')
            end
        end

        do -- 거대용 던전 (진화 재료)
            local label = vars['infoLabel2']
            if label then
                local str = Str('거대용 던전에서 진화재료 획득량이 {@yellow}{1}% 증가{@default}합니다.', 100)
                label:setString(str)
            end

            local label = vars['timeLabel2']
            if label then
                label:setString('7/3 00:00 ~ 7/5 23:59')
            end
        end

    -- 콜로세움 명예 획득량 증가 핫타임
    elseif (banner == 'event_fevertime_notice_02.ui') then
        local label = vars['infoLabel']
        if label then
            local str = Str('콜로세움에서 획득하는 명예 획득량이 {@yellow}{1}% 증가{@default}합니다.', 100)
            label:setString(str)
        end

        local label = vars['timeLabel']
        if label then
            if (g_localData:isAmericaServer() == true) then
                label:setString('6/29 00:00 ~ 7/5 23:59')
            else
                label:setString('6/30 00:00 ~ 7/5 23:59')
            end
        end
    end
end

-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_EventPopupTab_Banner:click_bannerBtn()
    local url = self.m_structBannerData['url']
    if (url == '') then 
        return 
    end

    if (url == 'cross_promotion') then
        self:goToCrossPromotionAppStore()
        return
    end

    g_eventData:goToEventUrl(url)
end

-------------------------------------
-- function goToCrossPromotionAppStore
-- @brief 크로스 프로모션 마켓 연결 (마이 오아시스)
-------------------------------------
function UI_EventPopupTab_Banner:goToCrossPromotionAppStore()
    if isWin32() then return end 
    local appId = 'com.buffstudio.myoasis'
    if isIos() then
        -- AppStore App ID
        appId = '1247889896'
    end
    SDKManager:sendEvent('app_gotoStore', appId)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Banner:onEnterTab()
    local vars = self.vars
end