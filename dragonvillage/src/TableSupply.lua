local PARENT = TableClass

-------------------------------------
-- class TableSupply
-------------------------------------
TableSupply = class(PARENT, {
    })

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
    local l_ret = self:cloneOrgTable()

    table.sort(l_ret, function(a, b)
        return a['ui_priority'] < b['ui_priority']
    end)

    return l_ret or {}
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