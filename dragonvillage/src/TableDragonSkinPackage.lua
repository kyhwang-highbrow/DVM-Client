local PARENT = TableClass
-------------------------------------
-- class TableDragonSkinPackage
-------------------------------------
TableDragonSkinPackage = class(PARENT, {
    m_skinPackageMap = 'table',
})

local THIS = TableDragonSkinPackage
-------------------------------------
-- function init
-------------------------------------
function TableDragonSkinPackage:init()
    self.m_tableName = 'table_dragon_skin_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function geDragonSkinPackageProductList
-------------------------------------
function TableDragonSkinPackage:geDragonSkinPackageProductList()
    -- 시간 정보로 먼저 거름
    local map = self:filterTable_conditionDate('start_date', 'end_date')
    local product_list =  {}
    for _, v in pairs(map) do
        table.insert(product_list)
        --ServerData_Shop:getInstance():getStructMarketProduct(sku)
--[[         local t_product = table_shop_cash[product_id] or table_shop_basic[product_id]
        if t_product then
            local struct_product = StructProduct(t_product)
        end ]]
    end
end