-------------------------------------
-- class ServerData_PurchaseDaily
-- @instance g_purchaseDailyData
-------------------------------------
ServerData_PurchaseDaily = class({
        m_serverData = 'ServerData',
        m_purchaseDailyInfo = 'table', -- 서버에서 내려받아서 설정
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_PurchaseDaily:init(server_data)
    self.m_serverData = server_data
    self.m_purchaseDailyInfo = {}
end

-------------------------------------
-- function applyPurchaseDailyInfo
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:applyPurchaseDailyInfo(t_data)
    if (not t_data) then
        return
    end
    -- t_data : ret에 purchase_daily_info라는 key 값으로 아래와 같은 형태로 전달됨
    --[[
        "purchase_daily_info" : {
            "version1" : {
                some info .. 
            },
            ...
            "purchase_point" : 100
        }
    ]]
    self.m_purchaseDailyInfo = t_data
end

-------------------------------------
-- function isActive
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:isActive(version)
    return self.m_purchaseDailyInfo[tostring(version)] ~= nil
end

-------------------------------------
-- function getPurchaseDailyInfo
-- @brief 해당 버전에 대한 정보 리턴 (raw data)
-------------------------------------
function ServerData_PurchaseDaily:getPurchaseDailyInfo(version)
    return self.m_purchaseDailyInfo[tostring(version)]
end

-------------------------------------
-- function getPurchasePoint
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:getPurchasePoint()
    return self.m_purchaseDailyInfo['purchase_point']
end

-------------------------------------
-- function getCurrentStep
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:getCurrentStep(version)
    assert(self:isActive(version), 'ServerData_PurchaseDaily invalid access')

    local purchase_daily_info = self:getPurchaseDailyInfo(version)
    return purchase_daily_info['current_step']
end

-------------------------------------
-- function isRewardReceived
-- @brief 많은 step 중 이곳의 step 은 number 인 것에 주의
-------------------------------------
function ServerData_PurchaseDaily:isRewardReceived(version, step)
    assert(self:isActive(version), 'ServerData_PurchaseDaily invalid access')

    local received_list = self.m_purchaseDailyInfo[tostring(version)]['received_list'] or {}
    return isContainValue(step, received_list)
end

-------------------------------------
-- function getClearStep
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:getClearStep(version)
    assert(self:isActive(version), 'ServerData_PurchaseDaily invalid access')

    local purchase_daily_info = self:getPurchaseDailyInfo(version)
    return purchase_daily_info['clear_step']
end

-------------------------------------
-- function getTotalStep
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:getTotalStep(version)
    assert(self:isActive(version), 'ServerData_PurchaseDaily invalid access')

    return table.count(self.m_purchaseDailyInfo[tostring(version)]['step_list'])
end

-------------------------------------
-- function canCollectPoint
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:canCollectPoint(version)
    local curr_step = self:getCurrentStep(version)
    local clear_step = self:getClearStep(version)
    local purchase_point = self:getPurchasePoint(version)
    local target_point = self:getTargetPoint(version, curr_step)

    return (target_point > purchase_point) and (curr_step > clear_step)
end

-------------------------------------
-- function getRewardList
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:getRewardList(version, step)
    assert(self:isActive(version), 'ServerData_PurchaseDaily invalid access')
    
    local reward_list = self.m_purchaseDailyInfo[tostring(version)]['step_list']
    return ServerData_Item:parsePackageItemStr(reward_list[tostring(step)]['item'])
end

-------------------------------------
-- function getTargetPoint
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:getTargetPoint(version, step)
    assert(self:isActive(version), 'ServerData_PurchaseDaily invalid access')

    local reward_list = self.m_purchaseDailyInfo[tostring(version)]['step_list']
    return reward_list[tostring(step)]['purchase_point']
end


-------------------------------------
-- function request_purchasePointReward
-------------------------------------
function ServerData_PurchaseDaily:request_purchasePointReward(version, reward_step, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self.m_purchaseDailyInfo[version] = ret['purchase_daily_info'][version]
        -- 보상 획득 UI
        -- ItemObtainResult(ret) -- UI 에서 출력함

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/purchase_daily/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('version', version)
    ui_network:setParam('reward_step', reward_step)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getPurchasePointEventRemainTime
-- @brief event 항목의 남은 시간
-- @return sec
-------------------------------------
function ServerData_PurchaseDaily:getPurchasePointEventRemainTime(version)
    if (not self:isActive(version)) then
        return 0
    end

    local purchase_daily_info = self:getPurchaseDailyInfo(version)
    local end_time = purchase_daily_info['end']
    if (not end_time) or (end_time == 0) then
        return 0
    end

    end_time = end_time / 1000

    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local time = (end_time - curr_time)

    return time
end

-------------------------------------
-- function getPurchasePointEventRemainTimeText
-- @brief event 항목의 남은 시간 텍스트
-------------------------------------
function ServerData_PurchaseDaily:getPurchasePointEventRemainTimeText(version)
	local time = self:getPurchasePointEventRemainTime(version)
    if (time > 0) then
        local time_str = Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time))
        return time_str
    else
        return ''
    end
end

-------------------------------------
-- function getEventPopupTabList
-- @brief UI_EventPopup의 탭 리스트 생성 용도
-------------------------------------
function ServerData_PurchaseDaily:getEventPopupTabList()
    local l_item_list = {}

    for version, v in pairs(self.m_purchaseDailyInfo) do
        if self:isActivePurchaseDailyEvent(version) then
            local event_data = {}
            event_data['t_name'] = Str('일일 충전 선물')
            event_data['icon'] = 'ui/event/list_purchase_daily.png'
            event_data['version'] = version

            local struct_event_popup_tab = StructEventPopupTab(event_data)
            local type_name = 'purchase_daily_' .. version
            struct_event_popup_tab.m_type = type_name
            struct_event_popup_tab.m_sortIdx = 0

            l_item_list[type_name] = struct_event_popup_tab
        end
    end

    return l_item_list
end

-------------------------------------
-- function isActivePurchaseDailyEvent
-- @brief 해당 버전이 활성화 상태인지 여부
-------------------------------------
function ServerData_PurchaseDaily:isActivePurchaseDailyEvent(version)
    if (version == 'purchase_point') then
        return false
    end    
    
    -- 핫타임에  event_purchase_daily 가 설정되어 있어야 함
    if (not g_hotTimeData) or (not g_hotTimeData:isActiveEvent('event_purchase_daily')) then
        return false
    end

    -- 해당 버전 정보가 없는 경우
    if (not self:isActive(version)) then
        return false
    end

    local purchase_daily_info = self:getPurchaseDailyInfo(version)
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local start_time = purchase_daily_info['start'] / 1000
    local end_time = purchase_daily_info['end'] / 1000

    -- 이벤트 시작 시간 전
    if (curr_time < start_time) then
        return false
    end

    -- 이벤트 시작 시간 후
    if (end_time < curr_time) then
        return false
    end

    return true
end

-------------------------------------
-- function LocalizedOrdinalDay
-- @brief 번역된 날짜의 서수적 표현
-------------------------------------
function ServerData_PurchaseDaily.LocalizedOrdinalDay(step)
    if (step == 1) then
        return Str('첫째 날')
    elseif (step == 2) then
        return Str('둘째 날')
    elseif (step == 3) then
        return Str('셋째 날')
    elseif (step == 4) then
        return Str('넷째 날')
    elseif (step == 5) then
        return Str('다섯째 날')
    end
end

-------------------------------------
-- function isGetLastReward
-- @breif 최종 보상 받았는지 확인
-------------------------------------
function ServerData_PurchaseDaily:isGetLastReward(version)
    if (not self:isActive(version)) then
        return false
    end

    local last_step = self:getTotalStep(version) -- number

    for step = 1, last_step do
        -- isRewardReceived에서 step은 number
        -- 한 단계라도 보상을 수령하지 않았으면 false
        if (self:isRewardReceived(version, step) == false) then
            return false
        end
    end

    return true
end


-------------------------------------
-- function hasAvailableReward
-- @brief
-------------------------------------
function ServerData_PurchaseDaily:hasAvailableReward(version)
    local curr_step = self:getCurrentStep(version)

    local curr_point = self:getPurchasePoint()

    for step = 1, curr_step do
        local target_point = self:getTargetPoint(version, step)

        if (not self:isRewardReceived(version, step))
                and (curr_point >= target_point) then
            return true
        end
    end

    return false
end


