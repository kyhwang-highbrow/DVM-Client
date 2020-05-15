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
            l_ret[key] = clone(value)
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