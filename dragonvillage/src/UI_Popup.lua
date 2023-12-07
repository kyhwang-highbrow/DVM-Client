local POPUP_CONTENT_WIDTH = 410
local POPUP_CONTENT_HEIGHT = 360

POPUP_TYPE = {
    OK = 1,            -- 확인
    YES_NO = 2,        -- 예, 아니오
}


-------------------------------------
-- function MakeSimplePopupLog
-------------------------------------
function MakeSimplePopupLog(msg, submsg)
    do -- 
        --if (CppFunctions:isIos()) then
            local log = 'Popup Message => ' .. (msg or '') .. '/' .. (submsg or '')
            cclog(log)
            PerpleSdkManager.getCrashlytics():setLog(log)
        --end
    end
end

-------------------------------------
-- function MakeSimplePopup
-------------------------------------
function MakeSimplePopup(type, msg, ok_btn_cb, cancel_btn_cb)

    local popup = UI_SimplePopup(type, msg, ok_btn_cb, cancel_btn_cb)
    --local popup = UI_Popup(type, msg, ok_btn_cb, cancel_btn_cb)
    --popup.m_cbOKBtn = ok_btn_cb
    --popup.m_cbCancelBtn = cancel_btn_cb
    --popup:setMessage(msg)
    return popup
end

-------------------------------------
-- function MakeSimplePopup2
-------------------------------------
function MakeSimplePopup2(type, msg, submsg, ok_btn_cb, cancel_btn_cb, dont_show_today_key)
    if dont_show_today_key ~= nil then
        -- 스킵 상태일 경우
        if g_settingData:isSkipWarningTodayConfimPopup(dont_show_today_key) == true then
            SafeFuncCall(ok_btn_cb)
            return
        end
    end

    local popup = UI_SimplePopup2(type, msg, submsg, ok_btn_cb, cancel_btn_cb)
    if dont_show_today_key ~= nil then
        popup:setCheckBoxCallback(function() g_settingData:setSkipWarningTodayConfimPopup(dont_show_today_key)  end)
    end

    return popup
end

-------------------------------------
-- function MakeSimplePricePopup
-------------------------------------
function MakeSimplePricePopup(type, msg, submsg, ok_btn_cb, cancel_btn_cb)
    local popup = UI_SimplePricePopup(type, msg, submsg, ok_btn_cb, cancel_btn_cb)
    return popup
end

-------------------------------------
-- function MakeNetworkPopup
-- @brief 네트워크 통신에서 사용되는 SimplePopup
--        LOADING과 NETWORK POPUP은 동일한 레이어를 사용
-------------------------------------
function MakeNetworkPopup(type, msg, ok_btn_cb, cancel_btn_cb)
    local popup = UI_SimplePopup(type, msg, ok_btn_cb, cancel_btn_cb, UIManager.LOADING)
    return popup
end

-------------------------------------
-- function MakeNetworkPopup2
-- @brief 네트워크 통신에서 사용되는 SimplePopup2
--        LOADING과 NETWORK POPUP은 동일한 레이어를 사용
-------------------------------------
function MakeNetworkPopup2(type, msg, submsg, ok_btn_cb, cancel_btn_cb)
    local popup = UI_SimplePopup2(type, msg, submsg, ok_btn_cb, cancel_btn_cb, UIManager.LOADING)
    return popup
end

function MakeConfirmPopup()

end

-------------------------------------
-- function MakeSimplePopup_Confirm
-- @brief 단일 재화인 경우를 상정
-------------------------------------
function MakeSimplePopup_Confirm(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb)
    
    if (not ConfirmPrice(item_key, item_value)) then
        return
    end

    return UI_ConfirmPopup(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb)
end

-------------------------------------
-- function MakeSimplePopup_SummonConfirm
-------------------------------------
function MakeSimplePopup_SummonConfirm(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb, ad_btn_cb)
    require('UI_SummonConfirmPopup')
    return UI_SummonConfirmPopup(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb, ad_btn_cb)
end

-------------------------------------
-- function ConfirmPrice_original
-- @brief
-- @return bool
-------------------------------------
function ConfirmPrice_original(price_type, price_value)
    if (price_type == 'cash') then
        local cash = g_userData:get('cash')

        -- 캐시가 충분히 있는지 체크
        if (cash < price_value) then
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('다이아몬드가 부족합니다.\n상점으로 이동하시겠습니까?'), function() UINavigatorDefinition:goTo('package_shop', 'diamond_shop') end)
            return false
        end
    elseif (price_type == 'gold') then
        local gold = g_userData:get('gold')

        -- 재화가 충분히 있는지 체크
        if (gold < price_value) then
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('골드가 부족합니다.\n상점으로 이동하시겠습니까?'), function() g_shopDataNew:openShopPopup('gold') end)
            return false
        end
    elseif (price_type == 'fp') then
        local fp = g_userData:get('fp')

        -- 재화가 충분히 있는지 체크
        if (fp < price_value) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('우정포인트가 부족합니다.\n친구에게 우정포인트를 요청해보세요!'))
            return false
        end

    elseif (price_type == 'rune_bless') then
        local cur_rune_bless = g_userData:get('rune_bless')
        -- 재화가 충분히 있는지 체크
        local goto_shop_str = Str('\n\n상점으로 이동하시겠습니까?')
        goto_shop_str = string.gsub(goto_shop_str, '\n', '')
        if (cur_rune_bless < price_value) then
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('{1}가 부족합니다.', Str('룬 축복서')) .. '\n' .. goto_shop_str, function() g_shopDataNew:openShopPopup('amethyst') end)
            return false
        end
    elseif (price_type == 'ancient') then
        local ancient = g_userData:get('ancient')

        -- 재화가 충분히 있는지 체크
        if (ancient < price_value) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('고대주화가 부족합니다.\n고대주화는 고대의 탑에서 획득할 수 있습니다.'))
            return false
        end
    elseif (price_type == 'summon_dragon_ticket') then 
        local summon_dragon_ticket = g_userData:get('summon_dragon_ticket')
        
        --드래곤 티켓 체크
        if (summon_dragon_ticket < price_value) then
           MakeSimplePopup(POPUP_TYPE.OK, Str('드래곤 소환권이 부족합니다.')) 
           return false
        end

    elseif (price_type == 'ticket_story_dungeon') then 
        local ticket_story_dungeon = g_userData:get('ticket_story_dungeon')
        -- 티켓
        if (ticket_story_dungeon < price_value) then
            local _,season_code =  g_eventDragonStoryDungeon:getStoryDungeonSeasonId()
            g_fullPopupManager:showFullPopup(string.format('package_ticket_event_%s', season_code))
            
            UIManager:toastNotificationRed(Str('{1}이 부족합니다.', TableItem:getItemName(price_type)))
           return false
        end

    elseif (price_type == 'event_popularity_ticket') then 
        local ticket_story_dungeon = g_userData:get('event_popularity_ticket')
        -- 티켓
        if (ticket_story_dungeon < price_value) then
            g_fullPopupManager:showFullPopup('package_popularity')
            UIManager:toastNotificationRed(Str('{1}이 부족합니다.', TableItem:getItemName(price_type)))
           return false
        end

    elseif (price_type == 'subjugation_ticket') then 
        local subjugation_ticket_count = g_userData:get('subjugation_ticket') or 0
        -- 티켓
        if (subjugation_ticket_count < price_value) then            
           MakeSimplePopup(POPUP_TYPE.YES_NO, Str('{1}이(가) 부족합니다.\n상점으로 이동하시겠습니까?', 
                        TableItem:getItemName(price_type)), 
                        function() UINavigator:goTo('shop') end)
           return false
        end

    else 
        local item_count = g_userData:get(price_type)
        if (item_count < price_value) then
           MakeSimplePopup(POPUP_TYPE.OK, Str('{1}이(가) 부족합니다.', TableItem:getItemName(price_type))) 
           return false
        end
    end

    return true
end

-------------------------------------
-- function ConfirmPrice
-- @brief
-- @return bool
-------------------------------------
function ConfirmPrice(price_type, price_value)
    -- 보유량
    local amount = 0

    if (price_type == 'cash') then
        amount = g_userData:get('cash')

    elseif (price_type == 'gold') then
        amount = g_userData:get('gold')

    elseif (price_type == 'fp') then
        amount = g_userData:get('fp')

    elseif (price_type == 'ancient') then
        amount = g_userData:get('ancient')

    elseif (price_type == 'summon_dragon_ticket') then
        amount = g_userData:get('summon_dragon_ticket')

    elseif (price_type == 'token_story_dungeon') then
        amount = g_userData:get('token_story_dungeon')

    elseif (price_type == 'ticket_story_dungeon') then
        amount = g_userData:get('ticket_story_dungeon')

    elseif (price_type == 'event_popularity_ticket') then
        amount = g_userData:get('event_popularity_ticket')

    elseif (price_type == 'blessing_ticket') then
        amount = g_userData:get('blessing_ticket')

    else
        
        return true
    end

    if (price_value <= amount) then
        return true
    end

    -- 깜짝 할인 상품이 있는지 확인
    if (ServerData_SpotSale:checkSpotSale(price_type)) then
        return false
    end

    return ConfirmPrice_original(price_type, price_value)
end

-------------------------------------
-- function ConfirmPriceByItemID
-- @brief
-- @return bool
-------------------------------------
function ConfirmPriceByItemID(item_id, item_price)
    local item_data = TABLE:get('item')[tonumber(item_id)]
    local item_type = item_data['type']

    local user_data = g_userData:get(item_type)
    local own_value

    if(type(user_data) ~= 'table') then
        own_value = user_data
    else
        if isExistValue(item_type, 'medal', 'memory') then
            own_value = user_data[tostring(item_id)]
        else
            if (IS_DEV_SERVER()) then
                error('의도치 않게 table 형식을 가지고 있는 재화 형태입니다.')
            end
            own_value = 0
        end
    end

    if item_price <= own_value then
        return true
    end

    -- -- 깜짝 할인 상품이 있는지 확인
    -- if (ServerData_SpotSale:checkSpotSale(item_type)) then
    --     return false
    -- end

    MakeSimplePopup(POPUP_TYPE.OK, Str(item_data['t_name'] ..'이 부족합니다.\n'))
    return false
end

-------------------------------------
-- function MakePopup
-- @brief 도움말 팝업과 같이 ui load만 필요한 팝업 만들 때 사용한다
-------------------------------------
function MakePopup(ui_path, close_cb)
    local ui = UI()
    
    ui:load(ui_path)
    UIManager:open(ui, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, ui_path)

    if (ui.vars['closeBtn'] ~= nil) then
        ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    end
    if (ui.vars['okBtn'] ~= nil) then
        ui.vars['okBtn']:registerScriptTapHandler(function() ui:close() end)
    end
    if (close_cb) then
        ui:setCloseCb(close_cb)
    end

    return ui
end