local PARENT = TableClass

-------------------------------------
-- class TableSupply
-------------------------------------
TableSupply = class(PARENT, {
    })

TableSupply.SUPPLY_ID_AUTO_PICKUP = 1002
TableSupply.SUPPLY_ID_DAILY_QUEST = 1003

local THIS = TableSupply

-------------------------------------
-- function init
-------------------------------------
function TableSupply:init()
    self.m_tableName = 'table_supply'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getSupplyProductList
-------------------------------------
function TableSupply:getSupplyProductList()
    if (self == THIS) then
        self = THIS()
    end

    local l_ret ={}

    -- ui_priority가 -1인 항목은 보급소 UI에서 노출하지 않음
    for key,value in pairs(self.m_orgTable) do

        if (value['ui_priority'] ~= -1) then
            local struct_product = g_shopDataNew:getTargetProduct(value['product_id'])

            if (struct_product == nil) or (not struct_product:isItOnTime()) then
                local supply_type = value['type']
                local t_supply_info = g_supply:getSupplyInfoByType(supply_type)
    
                -- 상태 체크 -1:비활성, 0:일일 보상 수령 가능, 1:일일 보상 수령 완료
                local reward_status = -1

                if t_supply_info then
                    local curr_time = Timer:getServerTime()
                    local end_time = (t_supply_info['end'] / 1000)
                    
                    if (end_time < curr_time) then
                        reward_status = -1
                    elseif (t_supply_info['reward'] == 0) then
                        -- 일일 지급품이 있는지 확인
                        local package_item_str = t_data['daily_content']
                        local l_item_list = ServerData_Item:parsePackageItemStr(package_item_str)
                        if (0 < #l_item_list) then
                            reward_status = 0
                        else
                            reward_status = 1
                        end
                    else
                        reward_status = t_supply_info['reward'] -- 1이어야 한다.
                    end
                end

                if reward_status ~= -1 then
                    l_ret[key] = clone(value)
                end
            else
                l_ret[key] = clone(value)
            end
        end
    end
    return l_ret
end

-------------------------------------
-- function getSupplyData_dailyQuest
-- @breif 일일 퀘스트 보상 2배 데이터 리턴
-------------------------------------
function TableSupply:getSupplyData_dailyQuest()
    if (self == THIS) then
        self = THIS()
    end

    local supply_id = TableSupply.SUPPLY_ID_DAILY_QUEST
    local ret = self:get(supply_id)
    return ret
end

-------------------------------------
-- function getSupplyData_autoPickup
-- @breif 자동 줍기 데이터 리턴
-------------------------------------
function TableSupply:getSupplyData_autoPickup()
    if (self == THIS) then
        self = THIS()
    end

    local supply_id = TableSupply.SUPPLY_ID_AUTO_PICKUP
    local ret = self:get(supply_id)
    return ret
end

-------------------------------------
-- function getAutoPickupDataByProductID
-- @breif
-------------------------------------
function TableSupply:getAutoPickupDataByProductID(product_id)
    if (self == THIS) then
        self = THIS()
    end

    for i,v in pairs(self.m_orgTable) do
        if (v['product_id'] == product_id) and (v['type'] == 'auto_pickup') then
            return v['period']
        end
    end

    return 0
end

--{
--    "supply_id":1001,
--    "period":30,
--    "period_option":1,
--    "daily_content":"cash;1000",
--    "product_content":"cash;3300",
--    "t_desc":"",
--    "type":"daily_cash",
--    "ui_priority":10,
--    "product_id":120101,
--    "t_name":"30일 다이아 보급"
--}