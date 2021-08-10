-------------------------------------
-- class ServerData_Supply
-- @instance g_supply
-- @brief 보급소(정액제)
-------------------------------------
ServerData_Supply = class({
        m_serverData = 'ServerData',
        m_tSupplyList = 'list',
        m_tSupplyMap = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Supply:init(server_data)
    self.m_serverData = server_data
    self.m_tSupplyList = {}
    self.m_tSupplyMap = {}
end

-------------------------------------
-- function applySupplyList_fromRet
-- @brief
-- @used_at
-------------------------------------
function ServerData_Supply:applySupplyList_fromRet(ret)
    if (ret == nil) then
        return
    end

    if (ret['supply_list'] == nil) then
        return
    end

    if (ret['supply_list'] == false) then
        return
    end

    self:applySupplyList(ret['supply_list'])
end

-------------------------------------
-- function applySupplyList
-- @brief
-------------------------------------
function ServerData_Supply:applySupplyList(l_data)
    self.m_tSupplyList = l_data
    self.m_tSupplyMap = {}

    for i,v in pairs(self.m_tSupplyList) do
        local supply_type = v['type']
        if supply_type then
            self.m_tSupplyMap[supply_type] = v
        end
    end
end

-------------------------------------
-- function getSupplyInfoByType
-- @brief
-- @param supply_type string
-- @return supply_info table
-- {
--  "type":"daily_cash", // 30일 다이아 상품
--  "start":1587976361007,
--  "end":1587976361584,
--  "update":1587976361007,
--  "reward":1 // 수령 완료 상태 sample
-- }
-------------------------------------
function ServerData_Supply:getSupplyInfoByType(supply_type)
    if (self.m_tSupplyMap == nil) then
        return nil
    end

    return self.m_tSupplyMap[supply_type]
end

-------------------------------------
-- function request_supplyReward
-- @brief 보급소(정액제) 일일 보상
-- @api /users/supply/reward
-------------------------------------
function ServerData_Supply:request_supplyReward(supply_type, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 지급된 아이템 동기화
        g_serverData:networkCommonRespone_addedItems(ret)

       self:applySupplyList_fromRet(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/supply/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', supply_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function isHighlightSupply
-------------------------------------
function ServerData_Supply:isHighlightSupply()
    local reward_supply_cnt = 0

    local l_supply_product = TableSupply:getSupplyProductList()

    for _, t_data in pairs(l_supply_product) do
        local supply_type = t_data['type']
        local t_supply_info = self:getSupplyInfoByType(supply_type)

        if t_supply_info then
            local curr_time = Timer:getServerTime()
            local end_time = (t_supply_info['end'] / 1000)

            -- 시간 확인
            if (curr_time < end_time) then
                if (t_supply_info['reward'] == 0) then
                    -- 일일 지급품이 있는지 확인
                    local package_item_str = t_data['daily_content']
                    local l_item_list = ServerData_Item:parsePackageItemStr(package_item_str)
                    if (0 < #l_item_list) then
                        -- ## 모든 조건 충족 시 증가
                        reward_supply_cnt = (reward_supply_cnt + 1)
                    end
                end
            end
        end
    end

    return (0 < reward_supply_cnt), reward_supply_cnt
end


-------------------------------------
-- function isActiveSupply
-- @brief 보급소(정액제)에서 supply_type에 해당하는 보급이 활성 중인지
-- @return boolean
-------------------------------------
function ServerData_Supply:isActiveSupply(supply_type)
    local t_supply_info = self:getSupplyInfoByType(supply_type)
    if (t_supply_info == nil) then
        return false
    end

    local curr_time = Timer:getServerTime()
    local end_time = (t_supply_info['end'] / 1000)

    if (curr_time < end_time) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getSupplyTimeRemainingString
-- @brief 보급소(정액제)에서 supply_type에 해당하는 보급의 남은 시간 문자열
-- @param is_simple boolean
-- @return string
-------------------------------------
function ServerData_Supply:getSupplyTimeRemainingString(supply_type, is_simple)
    local t_supply_info = self:getSupplyInfoByType(supply_type)

    if (not is_simple) then    
        if (t_supply_info == nil) then
            return ''
        end

        local curr_time = Timer:getServerTime()
        local end_time = (t_supply_info['end'] / 1000)

        if (curr_time < end_time) then
            local _curr_time = Timer:getServerTime_Milliseconds()
            local _end_time = t_supply_info['end']
            local time_millisec = math_max(_end_time - _curr_time, 0)
            local time_str = datetime.makeTimeDesc_timer(time_millisec, true) -- param : milliseconds, day_special
            local str = Str('남은 시간 : {1}', '{@green}' .. time_str)
            return str
        else
            return ''
        end
    else -- (is_simple == true)
        if (t_supply_info == nil) then
            return Str('획득 가능')
        end

        local curr_time = Timer:getServerTime()
        local end_time = (t_supply_info['end'] / 1000)

        if (curr_time < end_time) then
            local time = (end_time - curr_time)
            local show_second = true
            local first_only = true
            local str = Str('{1} 남음', datetime.makeTimeDesc(time, show_second, first_only))
            return str
        else
            return Str('획득 가능')
        end
    end
end




-------------------------------------
-- function isActiveSupply_dailyQuest
-- @brief 보급소(정액제)에서 일일 퀘스트 보상 2배가 활성화 중인지
-- @return boolean
-------------------------------------
function ServerData_Supply:isActiveSupply_dailyQuest()
    local supply_type = 'daily_quest'
    local ret = self:isActiveSupply(supply_type)
    return ret
end

-------------------------------------
-- function getSupplyTimeRemainingString_dailyQuest
-- @brief 보급소(정액제)에서 일일 퀘스트 보상 2배의 남은 시간 문자열
-- @return string
-------------------------------------
function ServerData_Supply:getSupplyTimeRemainingString_dailyQuest()
    local supply_type = 'daily_quest'
    local ret = self:getSupplyTimeRemainingString(supply_type)
    return ret
end


-------------------------------------
-- function isActiveSupply_autoPickup
-- @brief 보급소(정액제)에서 자동 줍기가 활성화 중인지
-- @return boolean
-------------------------------------
function ServerData_Supply:isActiveSupply_autoPickup()
    local supply_type = 'auto_pickup'
    local ret = self:isActiveSupply(supply_type)
    return ret
end

-------------------------------------
-- function getSupplyTimeRemainingString_autoPickup
-- @brief 보급소(정액제)에서 자동 줍기 남은 시간 문자열
-- @return string
-------------------------------------
function ServerData_Supply:getSupplyTimeRemainingString_autoPickup()
    local supply_type = 'auto_pickup'
    local ret = self:getSupplyTimeRemainingString(supply_type)
    return ret
end

-------------------------------------
-- function refreshSubscriptionInfoAndShowSupplyPopup
-- 일일 획득 정보가 추가됨에 따라
-- 팝업이 뜰 때마다 한번씩 정보가 업뎃 되어야 한다.
-------------------------------------
function ServerData_Supply:refreshSubscriptionInfoAndShowSupplyPopup(buy_cb_func)
    local function cb_func()
        local hide_ad = false
        UI_SupplyProductInfoPopup_AutoPickup(buy_cb_func, hide_ad)
    end

    local function fail_cb()

    end

    g_subscriptionData:request_subscriptionInfo(cb_func, fail_cb)
end


-------------------------------------
-- function getSupplyTimeRemainingSimpleStringAutoPickup
-- @brief 자동 줍기 UI 남은 시간 간단 문자열
-- @return string
-------------------------------------
function ServerData_Supply:getSupplyTimeRemainingSimpleStringAutoPickup()
    local supply_type = 'auto_pickup'
    local is_simple = true

    local str = self:getSupplyTimeRemainingString(supply_type, is_simple)
    return str
end

-------------------------------------
-- function getTargetSupplyData
-------------------------------------
function ServerData_Supply:getTargetSupplyData(supply_type)

    if (not supply_type) then return end

    local l_supply_product = TableSupply:getSupplyProductList()
    local target_data

    for _, t_data in pairs(l_supply_product) do
        if (t_data['type'] == supply_type) then
            return t_data
        end
    end
end


-------------------------------------
-- function getSupplyProductIdByType
-------------------------------------
function ServerData_Supply:getSupplyProductIdByType(supply_type)

    if (not supply_type) then return end

    local l_supply_product = TableSupply:getSupplyProductList()
    local target_data

    for _, t_data in pairs(l_supply_product) do
        if (t_data['type'] == supply_type) then
            target_data = t_data
            break
        end
    end

    if (not target_data) then return end

    return target_data['product_id']
end


-------------------------------------
-- function getSupplyProductIdByType
-------------------------------------
function ServerData_Supply:getSupplyProductByType(supply_type)

    if (not supply_type) then return end

    local l_supply_product = TableSupply:getSupplyProductList()
    local target_data

    for _, t_data in pairs(l_supply_product) do
        if (t_data['type'] == supply_type) then
            target_data = t_data
            break
        end
    end

    if (not target_data) then return end

    return target_data
end
