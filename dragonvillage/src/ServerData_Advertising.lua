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

        m_dailyAdInfo = 'table',
        m_reinitializeTime = 'timestamp',
    })

    
-- 서버 키
local DAILY_AD_KEY = {
    [AD_TYPE.FOREST] = 'forest',  -- 드래곤의 숲 시간 단축
    [AD_TYPE.EXPLORE] = 'explore',    -- 모험 시간 단축
    [AD_TYPE.FSUMMON] = 'fsummon'       -- 우정 뽑기
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_Advertising:init(server_data)
    self.m_serverData = server_data
    self.m_scheduleHandlerID = nil
    self.m_dailyAdInfo = {}
end

-------------------------------------
-- function showAdvPopup
-- @brief 광고 보기 팝업 노출
-------------------------------------
function ServerData_Advertising:showAdvPopup(ad_type, finish_cb)
    PerpleSdkManager.getCrashlytics():setLog('showAdvPopup_0')

	-- 광고 비활성화 시
	if (AdSDKSelector:isAdInactive()) then
		AdSDKSelector:makePopupAdInactive()
		return
	end

    local function show_popup()
        PerpleSdkManager.getCrashlytics():setLog('showAdvPopup_1')
        local ui = UI_AdvertisingPopup(ad_type)
        if (finish_cb) then
            ui:setCloseCB(finish_cb)
        end
    end
    
    if (ad_type == AD_TYPE.RANDOM_BOX_LOBBY) then
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
-- function showAd
-- @brief 광고 보기 (adMob)
-- @type 시간 제한
-------------------------------------
function ServerData_Advertising:showAd(ad_type, finish_cb)
    PerpleSdkManager.getCrashlytics():setLog('showAd_0')
    if (isWin32()) then 
        self:request_adv_reward(ad_type, finish_cb)
        return
    end

    self.m_is_fail = false
    
    local function result_cb(ret, info)
        PerpleSdkManager.getCrashlytics():setLog('showAd_2')

        -- 광고 시청 완료 -> 보상 처리
        if (ret == 'finish') then
            self:request_adv_reward(ad_type, finish_cb)

        -- 광고 시청 취소
        elseif (ret == 'cancel') then

        -- 광고 에러
        elseif (ret == 'error') then
            if (finish_cb) then
                finish_cb()
            end
        end
    end

    PerpleSdkManager.getCrashlytics():setLog('showAd_1')
    AdSDKSelector:showByAdType(ad_type, result_cb)
end

-------------------------------------
-- function getEnableShopAdv
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

    elseif (ad_type == AD_TYPE.RANDOM_BOX_LOBBY) then
        expired = self.m_adv_cool_time
    end

    local time = nil
    -- 서버상의 시간을 얻어옴
    if (expired) then
        local server_time = Timer:getServerTime()
        time = (expired/1000 - server_time)
        if (time > 0) then
            enable = false
            local show_second = true
            local first_only = true
            msg = Str('{1} 남음', datetime.makeTimeDesc(time, show_second, first_only))
        end
    end
    return msg, enable, time
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

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        self:networkCommonRespone(ret)
        self:showRewardResult(ret)

        -- 보급소(정액제)
        g_supply:applySupplyList_fromRet(ret)

        -- 자동 줍기으로 획득한 누적 아이템 수량 갱신
        g_subscriptionData:response_ingameDropInfo(ret)
        
		g_highlightData:setDirty(true)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/watch_adv')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', tonumber(ad_type))
    ui_network:setParam('ad_sdk', AdSDKSelector:getSDKName())
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
        UI_MailRewardPopup(item_info)

    -- 없다면 노티
    else
        local msg = Str('광고 보상을 받았습니다.')
        UIManager:toastNotificationGreen(msg)
    end
end

-------------------------------------
-- function request_dailyAdInfo
-------------------------------------
function ServerData_Advertising:request_dailyAdInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:response_dailyAdInfo(ret['adv_info'])
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/adv_info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_dailyAdInfo
-------------------------------------
function ServerData_Advertising:response_dailyAdInfo(ret)
    if (ret == nil) then
        return
    end

    self:setReinitailzeTime()
    self.m_dailyAdInfo = ret
end

-------------------------------------
-- function request_dailyAdShow
-------------------------------------
function ServerData_Advertising:request_dailyAdShow(ad_type, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    local ad_key = DAILY_AD_KEY[ad_type]

    -- 성공 콜백
    local function success_cb(ret)
        self:response_dailyAdInfo(ret['adv_info'])
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/adv_show')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', ad_key)
    ui_network:setParam('ad_sdk', AdSDKSelector:getSDKName())
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function isAllowToShow
-------------------------------------
function ServerData_Advertising:isAllowToShow(ad_type)
    if (self:isExpiredAdInfo()) then
        self:setReinitailzeTime()
        self:reinitializeAdInfo()
    end

    local ad_key = DAILY_AD_KEY[ad_type]
    return self.m_dailyAdInfo[ad_key] and (self.m_dailyAdInfo[ad_key] > 0)
end

-------------------------------------
-- function isExpiredAdInfo
-- @brief ad info가 만기되었는지 확인
-------------------------------------
function ServerData_Advertising:isExpiredAdInfo()
    if (self.m_reinitializeTime < Timer:getServerTime()) then
        return true
    end

    return false
end

-------------------------------------
-- function reinitializeAdInfo
-- @brief ad info 재초기화
-------------------------------------
function ServerData_Advertising:reinitializeAdInfo()
    for key, _ in pairs(self.m_dailyAdInfo) do
        self.m_dailyAdInfo[key] = 1
    end
end

-------------------------------------
-- function setReinitailzeTime
-- @brief 다음 자정으로 재초기화 타임 저장
-------------------------------------
function ServerData_Advertising:setReinitailzeTime()
    self.m_reinitializeTime = Timer:getServerTime_midnight()
end
