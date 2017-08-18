-------------------------------------
-- class ServerData_Advertising
-------------------------------------
ServerData_Advertising = class({
        m_serverData = 'ServerData',
        m_rewardList = 'list',

        m_is_fail = 'boolean',
        m_adv_cool_time = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Advertising:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function showAdvPopup
-------------------------------------
function ServerData_Advertising:showAdvPopup(ad_type, finish_cb)
    local function show_popup()
        local ui = UI_AdvertisingPopup(ad_type)
        if (finish_cb) then
            ui:setCloseCB(finish_cb)
        end
    end
    
    if (ad_type == AD_TYPE.LOBBY) then
        -- 자동 재화 줍기 적용되있다면 로비에서는 광고 못봄
        if (g_autoItemPickData:isActiveAutoItemPick()) then
            local msg = Str('이미 자동 획득이 적용되어 광고를 볼 수 없습니다.')
            UIManager:toastNotificationRed(msg)
        else
            show_popup()
        end
    
    elseif (ad_type == AD_TYPE.SHOP) then
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
-------------------------------------
function ServerData_Advertising:showAdv(ad_type, fnish_cb)
    if (isWin32()) then 
        self:request_adv_reward(ad_type, fnish_cb)
        return
    end

    self.m_is_fail = false

    -- 광고 보기
    AdsManager:showPlacement('rewardedVideo', function(ret, info)
        if ret == 'finish' then
            local t_info = dkjson.decode(info)
            if t_info.placementId == 'rewardedVideo' then
                if t_info.result ~= 'SKIPPED' then
                    -- 보상 처리
                    self:request_adv_reward(ad_type, fnish_cb)
                end
            end

        elseif ret == 'error' then
            if info == 'NOT_READY' then
                self.m_is_fail = true

                -- 광고가 없는 경우 또는 못 가져오는 경우 (보상은 받음)
                self:request_adv_reward(ad_type, fnish_cb)
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

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        
        local adv_cool_time = ret['adv_cool_time']
        if (adv_cool_time) then
            self.m_adv_cool_time = adv_cool_time
        end

        local msg = Str('광고 보상을 받았습니다.')
        UIManager:toastNotificationGreen(msg)

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



