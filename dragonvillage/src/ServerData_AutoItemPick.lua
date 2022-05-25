-------------------------------------
-- class ServerData_AutoItemPick
-------------------------------------
ServerData_AutoItemPick = class({
        m_serverData = 'ServerData',
        m_autoItemPickList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AutoItemPick:init(server_data)
    self.m_serverData = server_data
    self.m_autoItemPickList = {}
end

-------------------------------------
-- function applyAutoItemPickData
-------------------------------------
function ServerData_AutoItemPick:applyAutoItemPickData(data)
    -- 2017-07-28 sgkim
    --  "auto_item_pick":[{
    --      "expired":1504796400000,
    --      "type":"subscription"
    --    }],
    self.m_autoItemPickList = data
end

-------------------------------------
-- function isActiveAutoItemPick
-------------------------------------
function ServerData_AutoItemPick:isActiveAutoItemPick()
    local expired = self:getAutoItemPickExpired()

    -- 만료 시간이 없으면 비활성 상태
    if (not expired) then
        return false
    end
    
    -- 만료 시간이 지났는지 체크
    expired = (expired / 1000)
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    if (expired < curr_time) then
        return false
    end

    return true
end

-------------------------------------
-- function isActiveAutoItemPickWithType
-- @brief 타입별로 현재 자동줍기 적용중인지 
-- @param type - 'advertising', 'auto_root'
-------------------------------------
function ServerData_AutoItemPick:isActiveAutoItemPickWithType(type)
    local expired = self:getAutoItemPickExpiredWithType(type)

    -- 만료 시간이 없으면 비활성 상태
    if (not expired) then
        return false
    end

    -- 만료 시간이 지났는지 체크
    expired = (expired / 1000)
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    if (expired < curr_time) then
        return false
    end

    local is_active = false
    for i,v in pairs(self.m_autoItemPickList) do
        local auto_item_type = v['type'] 
        
        if (auto_item_type) and (auto_item_type == type) then
            is_active = true
            break
        end
    end

    return is_active
end

-------------------------------------
-- function getAutoItemPickExpired
-------------------------------------
function ServerData_AutoItemPick:getAutoItemPickExpired()
    local expired = nil

    for i,v in pairs(self.m_autoItemPickList) do
        if (not expired) or (expired < v['expired']) then
            expired = v['expired']
        end
    end

    return expired
end

-------------------------------------
-- function getAutoItemPickExpiredWithType
-------------------------------------
function ServerData_AutoItemPick:getAutoItemPickExpiredWithType(type)
    local expired = nil

    for i,v in pairs(self.m_autoItemPickList) do
        if (type == v['type']) then
            expired = v['expired'] or nil
        end
    end

    return expired
end

-------------------------------------
-- function checkSubsAlarm
-- @return 자동줍기 아이템에 노티 붙이는 조건 충족 시 true 반환
-------------------------------------
function ServerData_AutoItemPick:checkSubsAlarm(auto_type, day)
    
    -- 1.활성화 된 자동 줍기가 ad_type 상품인지 확인
    -- 2.남은 기간이 day일 이하인지 확인
    -- 3.살 수 있는 구독 상품이 남아 있는지 확인

    -- 1.활성화 된 자동 줍기가 ad_type 상품인지 확인
    local subs_expired = self:getAutoItemPickExpiredWithType(auto_type)
    if (not subs_expired) then
        return false
    end

    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local time = (subs_expired/1000 - server_time)
    if (time < 0) then
        return false
    end

    -- 2.남은 기간이 day일 이하인지 확인
    if (time > datetime.dayToSecond(day)) then
        return false
    end
    
    -- 3.살 수 있는 구독 상품이 남아 있는지 확인
    local struct_product, base_product = g_subscriptionData:getAvailableProduct() -- StructProductSubscription
    if (not struct_product) then
        return false
    end
    
    return true
end