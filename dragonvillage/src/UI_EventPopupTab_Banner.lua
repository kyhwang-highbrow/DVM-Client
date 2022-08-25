local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Banner
-------------------------------------
UI_EventPopupTab_Banner = class(PARENT,{
        m_structBannerData = 'StructEventPopupTab',

        m_isResourcePng = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Banner:init(owner, struct_event_popup_tab)
    self.m_uiName = 'UI_EventPopupTab_Banner'
    self.m_structBannerData = struct_event_popup_tab.m_eventData
    local res = self.m_structBannerData['banner']
    self.m_isResourcePng = string.match(res, '%.ui') and true or false
    local target_ui = (self.m_isResourcePng == true) and res or 'event_banner.ui'
    self.m_resName = target_ui
end


-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Banner:init_after(owner, struct_event_popup_tab)
    local vars = self:load(self.m_resName)
    
    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:init_customUI()
end

-------------------------------------
-- function UI_EventPopupTab_Banner
-------------------------------------
function UI_EventPopupTab_Banner:initUI()

    -- 리소스가 png인 경우 이미지 추가
    if (self.m_isResourcePng == false) then
        local img = cc.Sprite:create(res)
        if img then
            img:setDockPoint(CENTER_POINT)
            img:setAnchorPoint(CENTER_POINT)
            vars['bannerNode']:addChild(img)
        end
    end

end

-------------------------------------
-- function UI_EventPopupTab_Banner
-------------------------------------
function UI_EventPopupTab_Banner:initButton()
    local vars = self.vars

    -- bannerBtn 경우 풀팝업에서는 동작하지 않아야 하고, linkBtn은 동작해야 한다.
    local banner_btn = vars['bannerBtn']
    if (banner_btn) then
        banner_btn:registerScriptTapHandler(function() self:click_bannerBtn() end)
    end

    -- 링크 버튼 동작 
    local url_data = self.m_structBannerData['url']
    if (url_data ~= '') then 
        local url_list = pl.stringx.split(url_data, '||')
        
        for index, url in ipairs(url_list) do
            local link_button = vars['linkBtn' .. index] or vars['linkBtn']
            if (link_button ~= nil) then
                if (url == 'cross_promotion') then
                    link_button:registerScriptTapHandler(function() self:goToCrossPromotionAppStore() end)
                else
                    link_button:registerScriptTapHandler(function() self:click_linkBtn(url) end)
                end
            end
        end
    end

    if vars['scenarioBtn'] then
        vars['scenarioBtn']:setVisible(false)
    end

    
    -- @yjkil 220825 : 5주년 기념 일일 퀘스트 이벤트 추가 시 외국 유저에게 네이버 카페 버튼 미노출을 위해 임시 추가 (제거 혹은 수정 필요)
    if (string.find(url_data, 'naver') ~= nil) then
        if (Translate:getGameLang() ~= 'ko')
            and (vars['linkBtn1'] ~= nil)
            and (vars['linkBtn2'] ~= nil) then
           vars['linkBtn1']:setVisible(false)
           vars['linkBtn2']:setPositionX(0)
        end
    end
end

-------------------------------------
-- function UI_EventPopupTab_Banner
-------------------------------------
function UI_EventPopupTab_Banner:refresh()

end

-------------------------------------
-- function update_timer
-------------------------------------
function UI_EventPopupTab_Banner:update_timer(dt)
    local parser = pl.Date.Format('yyyy-mm-dd HH:MM:SS')
    local end_date = self.m_structBannerData['end_date']
    local time_label = self.vars['timeLabel']

    if (end_date ~= nil) and (end_date ~= '') and time_label then
        local remain_time = ServerTime:getInstance():datestrToTimestampSec(end_date)
        local cur_time =  ServerTime:getInstance():getCurrentTimestampSeconds()
    
        local time = (remain_time - cur_time)

        if time and (time > 0) then
            time_label:setString(Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true)))
        else
            time_label:setString('')
            self.root:unscheduleUpdate()
        end
    else
        if (time_label ~= nil) then
            time_label:setString('')
        end

        self.root:unscheduleUpdate()
    end
end

-------------------------------------
-- function init_customUI
-------------------------------------
function UI_EventPopupTab_Banner:init_customUI()
    local vars = self.vars
    local struct_banner_data = self.m_structBannerData

    local banner = struct_banner_data['banner']


    -- 남은 시간 등록
    if struct_banner_data['end_date'] and vars['timeLabel'] then
        self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update_timer(dt) end, 0)
    end

    -- 드래곤 히어로즈 택틱스 크로스 프로모션
    -- 드빌 뉴 크로스 프로모션
    if (banner == 'event_dht_promotion.ui') or (string.find(banner, 'event_cross_promotion')) then

        -- 공지로 이동
        --[[
        if vars['noticeLinkBtn'] then
            vars['noticeLinkBtn']:registerScriptTapHandler(function()
                    local article_key = 'event_dht_promotion'
                    NaverCafeManager:naverCafeStartWithArticleByKey(article_key)
                end)
        end]]
        local url_data = struct_banner_data['url']
        local url_list = pl.stringx.split(url_data, ';')

        for index, url in ipairs(url_list) do
            
        end

        -- 게임으로 이동 (구글 플레이 or 앱스토어)
        if vars['gameLinkBtn'] then
            vars['gameLinkBtn']:registerScriptTapHandler(function()
                    SDKManager:goToWeb(url)
                end)
        end

    -- 드래곤빌리지(드빌1) 크로스 프로모션 2020.09.28
    elseif (banner == 'event_dv1_promotion.ui') then

        -- 공지로 이동
        if vars['noticeLinkBtn'] then

            -- 공지 게시글이 없으면 visible off (네이버 sdk 링크)
            NaverCafeManager:setPluginInfoBtn(vars['noticeLinkBtn'], 'event_dv1_promotion')

            vars['noticeLinkBtn']:registerScriptTapHandler(function()
                    local article_key = 'event_dv1_promotion'
                    NaverCafeManager:naverCafeStartWithArticleByKey(article_key)
                end)
        end
        
        -- 게임으로 이동 (구글 플레이 or 앱스토어)
        if vars['gameLinkBtn'] then
            vars['gameLinkBtn']:registerScriptTapHandler(function()
                    SDKManager:goToWeb('https://app.adjust.com/aie6c8f?campaign=DragonVillageM_20200928')
                end)
        end

    elseif (banner == 'event_balance.ui') then
        local item_id = 770743
        local table_item = TableItem()
        local did = table_item:getDidByItemId(item_id)

        local item_card = UI_ItemCard(item_id, 1)
	    vars['itemNode']:addChild(item_card.root)

        -- 드래곤이면 도감버젼으로 Info팝업 띄우는 함수 등록
        local func_tap_dragon_card = function()
            UI_BookDetailPopup.openWithFrame(did, nil, 1, 0.8, true)    -- param : did, grade, evolution scale, ispopup
        end
        item_card.vars['clickBtn']:registerScriptTapHandler(function() func_tap_dragon_card() end)

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
        -- otherMarketSprite / googleSprite 제거에 따른 대응
        --self:changeTitleSprite(vars)
        local label = vars['infoLabel']
        if label then
            local str = Str('콜로세움에서 획득하는 명예 획득량이 {@yellow}{1}% 증가{@default}합니다.', 100)
            label:setString(str)
        end

    -- 인스타그램 관련 배너
    elseif (banner == 'event_instagram.ui') then
        -- 인스타그램 페이지로 이동
        if vars['gameLinkBtn'] then
            vars['gameLinkBtn']:registerScriptTapHandler(function()
                    SDKManager:goToWeb('https://bit.ly/3v9ZCCJ')
                end)
        end

    elseif (banner == 'event_capsule_1st.ui') then
        self:initEventCapsule()
    end
end

-------------------------------------
-- function initEventCapsule
-------------------------------------
function UI_EventPopupTab_Banner:initEventCapsule()
    local vars = self.vars

    local box_key = 'first'
    local capsulebox_data = g_capsuleBoxData:getCapsuleBoxInfo()
    if (not capsulebox_data) then
        return
    end

    local struct_capsule_box = capsulebox_data[box_key]
    local rank = 1
    local l_reward = struct_capsule_box:getRankRewardList(rank) or {}

    if l_reward and l_reward[1] then
        local table_dragon = TableDragon()
        local item_id = l_reward[1]['item_id']

        local dragon_id = TableItem:getDidByItemId(item_id)

        if item_id and dragon_id and (dragon_id ~= '') then
            local dragon_data = table_dragon:get(tonumber(dragon_id))     
            local dragon_rarity_str = dragon_data['rarity']
            local dragon_rarity_num = dragonRarityStrToNum(dragon_rarity_str)
            
            local string_rarity = getDragonRarityName(dragon_rarity_num)
            local dragon_category = dragon_data['category']

            if (dragon_category == 'cardpack') then
                string_rarity = '토파즈'
            elseif (dragon_category == 'limited') then
                string_rarity = '한정'
            elseif (dragon_category == 'event') then
                string_rarity = '이벤트'
            end

            string_rarity = string_rarity .. ' 드래곤'
            string_rarity = Str(string_rarity)

            local dragon_name = table_dragon:getDragonNameWithAttr(dragon_id)
            local dragon_attr = table_dragon:getDragonAttr(dragon_id)
            dragon_name = pl.stringx.replace(dragon_name, ' ', '')

            dragon_name = Str('{@default}{@{1}}' .. Str(dragon_name) .. '{@default}', dragon_attr)

            vars['infoLabel']:setString(Str('{1} {2} 획득 기회!', string_rarity, dragon_name))
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
-- function click_linkBtn
---@param url string
-------------------------------------
function UI_EventPopupTab_Banner:click_linkBtn(url)
    if (url ~= nil) and (url ~= '') then
        g_eventData:goToEventUrl(url)
    end
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