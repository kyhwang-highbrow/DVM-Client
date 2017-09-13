AD_TYPE = {
    AUTO_ITEM_PICK = 1,     -- 광고 보기 보상 : 자동획득
    RANDOM_BOX_LOBBY = 2,   -- 광고 보기 보상 : 랜덤박스 (로비 진입)
    RANDOM_BOX_SHOP = 3,    -- 광고 보기 보상 : 랜덤박스 (상점 진입)
    NONE = 4,               -- 광고 없음(에러코드 처리) : 보상은 존재
}

-------------------------------------
-- class ServerData_Advertising
-------------------------------------
ServerData_Advertising = class({
        m_serverData = 'ServerData',
        m_rewardList = 'list',

        m_selAdtype = 'AD_TYPE',

        m_countLabel = 'LabelTTF',
        m_scheduleHandlerID = 'number',

        m_is_fail = 'boolean',
        m_adv_cool_time = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Advertising:init(server_data)
    self.m_serverData = server_data
    self.m_scheduleHandlerID = nil
end

-------------------------------------
-- function showAdvPopup
-- @brief 광고 보기 팝업 노출
-------------------------------------
function ServerData_Advertising:showAdvPopup(ad_type, finish_cb)
    local function show_popup()
        local ui = UI_AdvertisingPopup(ad_type)
        if (finish_cb) then
            ui:setCloseCB(finish_cb)
        end
    end
    
    if (ad_type == AD_TYPE.AUTO_ITEM_PICK) then
        -- 자동획득 적용되있다면 로비에서는 광고 못봄
        if (g_autoItemPickData:isActiveAutoItemPick()) then
            local msg = Str('이미 자동 획득이 적용되어 광고를 볼 수 없습니다.')
            UIManager:toastNotificationRed(msg)
        else
            show_popup()
        end
    
    elseif (ad_type == AD_TYPE.RANDOM_BOX_LOBBY or ad_type == AD_TYPE.RANDOM_BOX_SHOP) then
        -- 보상 정보 있다면 호출 x
        if (self.m_rewardList) then
            show_popup()
        else
            self:request_adv_reward_list(show_popup)
        end

    elseif (ad_type == AD_TYPE.NONE) then
        show_popup()
    end
end

-------------------------------------
-- function showAdv
-- @brief 광고 보기
-------------------------------------
function ServerData_Advertising:showAdv(ad_type, fnish_cb)
    if (isWin32()) then 
        self:request_adv_reward(ad_type, fnish_cb)
        return
    end

    self.m_is_fail = false
    ShowLoading(Str('광고 정보 요청중'))

    local placement_id = ''
    if (ad_type == AD_TYPE.AUTO_ITEM_PICK) then
        placement_id = 'rewardedVideo'

    elseif (ad_type == AD_TYPE.RANDOM_BOX_LOBBY) then
        placement_id = 'lobbyGiftBox'

    elseif (ad_type == AD_TYPE.RANDOM_BOX_SHOP) then
        placement_id = 'storeGiffbox'
    end

    AdsManager:showPlacement(placement_id, function(ret, info)
        HideLoading()
        if ret == 'finish' then
            local t_info = dkjson.decode(info)
            if (t_info.placementId == placement_id) then
                if t_info.result ~= 'SKIPPED' then
                    -- 보상 처리
                    self:request_adv_reward(ad_type, fnish_cb)
                end
            end

        elseif ret == 'error' then
            if info == 'NOT_READY' then
                -- 광고가 없는 경우 또는 못 가져오는 경우 (보상은 받음)
                --self.m_is_fail = true
                --self:request_adv_reward(ad_type, fnish_cb)
                if (finish_cb) then
                    finish_cb()
                end
                -- 앱이 백그라운드로 갔다 왔을 때, 불규칙하게 NOT_READY를 리턴하므로 보상을 지급하지 않기로 함
                MakeSimplePopup(POPUP_TYPE.OK, Str('더 이상 시청 가능한 광고가 없거나, 광고 시청 종료전에 시청이 중단되어 보상 지급이 불가능합니다.'))
            end
        end
    end)
end

-------------------------------------
-- function getEnableShopAdv()
-------------------------------------
function ServerData_Advertising:getEnableShopAdv()
    -- 서버상의 시간을 얻어옴
    local server_time = Timer:getServerTime()

    if (not self.m_adv_cool_time) then
        return false
    end

    local time = (self.m_adv_cool_time/1000 - server_time)
    return (time <= 0) 
end

-------------------------------------
-- function getCoolTimeStatus
-- @brief 다음 광고 보기까지 쿨타임 정보
-------------------------------------
function ServerData_Advertising:getCoolTimeStatus(ad_type)
    local msg = Str('획득 가능')
    local enable = true

    -- 남은 시간
    local expired
    if (ad_type == AD_TYPE.AUTO_ITEM_PICK) then
        expired = g_autoItemPickData:getAutoItemPickExpired()

    elseif (ad_type == AD_TYPE.RANDOM_BOX_LOBBY or ad_type == AD_TYPE.RANDOM_BOX_SHOP) then
        expired = self.m_adv_cool_time
    end

    -- 서버상의 시간을 얻어옴
    if (expired) then
        local server_time = Timer:getServerTime()
        local time = (expired/1000 - server_time)
        if (time > 0) then
            enable = false
            local show_second = true
            local first_only = true
            msg = Str('{1} 남음', datetime.makeTimeDesc(time, show_second, first_only))
        end
    end
    
    return msg, enable 
end

-------------------------------------
-- function request_adv_reward_list
-------------------------------------
function ServerData_Advertising:request_adv_reward_list(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self.m_rewardList = ret['normal']

        if finish_cb then
            finish_cb(ret)
        end

        -- 실패한 경우 추가 팝업 노출
        if (self.m_is_fail) then
            self.m_is_fail = false
            self:showAdvPopup(AD_TYPE.NONE)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/randombox_info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_adv_reward
-------------------------------------
function ServerData_Advertising:request_adv_reward(ad_type, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    local ad_type = ad_type
    -- shop과 lobby가 분리됬지만 서버에는 같은 값으로 보내줘야함.
    if (ad_type == AD_TYPE.RANDOM_BOX_SHOP) then
        ad_type = AD_TYPE.RANDOM_BOX_LOBBY
    end

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        self:networkCommonRespone(ret)
        self:showRewardResult(ret)
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/watch_adv')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', tonumber(ad_type))
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function networkCommonRespone
-------------------------------------
function ServerData_Advertising:networkCommonRespone(ret)
    if (ret['adv_cool_time']) then
        self.m_adv_cool_time = ret['adv_cool_time']
    end
end

-------------------------------------
-- function showRewardResult
-------------------------------------
function ServerData_Advertising:showRewardResult(ret)
    local item_info = ret['item_info']

    -- 아이템 정보가 있다면 팝업 처리
    if (item_info) then
        local id = item_info['item_id']
        local cnt = item_info['count']
        local item_card = UI_ItemCard(id, cnt)

        if (item_card) then
            local ui = UI()
            ui:load('popup_ad_confirm.ui')
            ui.vars['itemNode']:addChild(item_card.root)
            ui.vars['okBtn']:registerScriptTapHandler(function() ui:close() end)
            UIManager:open(ui, UIManager.POPUP)
        end

    -- 없다면 노티
    else
        local msg = Str('광고 보상을 받았습니다.')
        UIManager:toastNotificationGreen(msg)
    end
end




