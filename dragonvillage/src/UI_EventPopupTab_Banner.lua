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


    local struct_banner_data = self.m_structBannerData
    -- 남은 시간 등록
    if struct_banner_data['end_date'] and vars['timeLabel'] then
        self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update_timer(dt) end, 0)
    elseif vars['reservationLinkBtn'] ~= nil then 
        self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update_reservation_timer(dt) end, 0)
    end
end

-------------------------------------
-- function UI_EventPopupTab_Banner
-------------------------------------
function UI_EventPopupTab_Banner:initUI()
    local vars = self.vars
    local struct_banner_data = self.m_structBannerData

    local banner = struct_banner_data['banner']

    -- 리소스가 png인 경우 이미지 추가
    if (self.m_isResourcePng == false) then
        local img = cc.Sprite:create(res)
        if img then
            img:setDockPoint(CENTER_POINT)
            img:setAnchorPoint(CENTER_POINT)
            vars['bannerNode']:addChild(img)
        end
    end

    local banner = struct_banner_data['banner']
    if (banner == 'event_capsule_1st.ui') then
        self:initEventCapsule()
    end
end

-------------------------------------
-- function UI_EventPopupTab_Banner
-------------------------------------
function UI_EventPopupTab_Banner:initButton()
    local vars = self.vars

    -- 사전 예약 버튼이 있으면 우선 적용
    if vars['reservationLinkBtn'] ~= nil then
        vars['reservationLinkBtn']:registerScriptTapHandler(function() self:click_reservationBtn() end)
    end

     -- 링크 버튼 동작 
    local link_button = vars['linkBtn'] or vars['gameLinkBtn']
    if link_button then
        link_button:registerScriptTapHandler(function() self:click_linkBtn() end)
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
-- function update_reservation_timer
-------------------------------------
function UI_EventPopupTab_Banner:update_reservation_timer(dt)
    local vars = self.vars
    local seconds = g_userData:getAfterReservationSeconds()
    -- 사전예약 바로가기
    if vars['reservationLinkBtn'] == nil then
        return
    end

    if g_userData:isReceivedAfterReservationReward() == true then
        vars['reservationLinkLabel']:setString(Str('보상 수령 완료!!'))
    elseif seconds == 0 then
        vars['reservationLinkLabel']:setString(Str('사전예약하러 가기'))
    elseif seconds > 0 and seconds < 60 then
        vars['reservationLinkLabel']:setString(Str('보상 정산 중..'))
    else
        vars['reservationLinkLabel']:setString(Str('보상 받기'))
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

            -- 해치 정지상태의 애니메이션 추가
            if vars['dragonNode_hatch'] then
                local animator = UIC_DragonAnimator()
                animator:setTalkEnable(false)    

                vars['dragonNode_hatch']:addChild(animator.m_node)
                animator:setDragonAnimator(dragon_id, 1)                                
                animator:setFlip(true)         
                animator:setAnimationPause(true)
                animator:setChangeAniEnable(false)
            end

            -- 성룡 정지상태의 애니메이션 추가
            if vars['dragonNode_adult'] then
                local animator = UIC_DragonAnimator()
                animator:setTalkEnable(false)

                vars['dragonNode_adult']:addChild(animator.m_node)
                animator:setDragonAnimator(dragon_id, 3)        
                animator:setFlip(true)                        
                animator:setAnimationPause(true)
                animator:setChangeAniEnable(false)
            end


            -- 속성에 따른 배경 추가
            if vars['bgNode'] and vars['bgNode']:isVisible() then
                vars['bgNode']:removeAllChildren()
                
                local res_name = string.format('res/ui/event/bg_1st_capsule_%s.png', dragon_attr)

                local sprite = cc.Sprite:create(res_name)
                if sprite then
                    sprite:setDockPoint(CENTER_POINT)
                    sprite:setAnchorPoint(CENTER_POINT)

                    vars['bgNode']:addChild(sprite)
                else
                    local animator = ResHelper:getUIDragonBG(dragon_attr, 'idle')
                    vars['bgNode']:addChild(animator.m_node)  
                    animator:setAnimationPause(true)
                end
            
            end
        end
    end
end

-------------------------------------
-- function click_linkBtn
-------------------------------------
function UI_EventPopupTab_Banner:click_linkBtn()
    local url = self.m_structBannerData['url']
    if (url == '') then
        return
    end
    
    g_eventData:goToEventUrl(url)
end

-------------------------------------
-- function click_reservationBtn
-------------------------------------
function UI_EventPopupTab_Banner:click_reservationBtn()
    if g_userData:isAvailableAfterReservationReward() == true then
        return
    end

    local seconds = g_userData:getAfterReservationSeconds()
    if seconds == 0 then
        g_userData:saveReservationTime()
    end

    local url = self.m_structBannerData['url']
    if (url == '') then
        return
    end

    g_eventData:goToEventUrl(url)
end