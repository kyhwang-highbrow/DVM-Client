local PARENT = TableClass
-------------------------------------
-- class TableDragonSkinSale
-------------------------------------
TableDragonSkinSale = class(PARENT, {
    m_skinPackageMap = 'table',
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableDragonSkinSale:init()
    self.m_tableName = 'table_dragon_skin_sale'
    self.m_orgTable = TABLE:get(self.m_tableName)
    self.m_skinPackageMap = nil
end

-------------------------------------
-- function getInstance
-------------------------------------
function TableDragonSkinSale:getInstance()
    if (instance == nil) then
        instance = TableDragonSkinSale()
    end
    return instance
end
--[[ 
-------------------------------------
-- function geDragonSkinSaleList
-- @brief 현재 판매중인 스킨 리스트를 반환
-------------------------------------
function TableDragonSkinSale:geDragonSkinSaleList()
    -- 시간 정보로 먼저 거름
    local map = self:filterTable_conditionDate('start_date', 'end_date')
    local skin_sale_list =  {}
    local skin_id_map = {}

    for _, t_data in pairs(map) do
        local struct_dragon_skin_sale = StructDragonSkinSale(t_data)        
        local skin_id = struct_dragon_skin_sale:getDragonSkinSaleSkinId()
        if skin_id_map[skin_id] ~= true then
            skin_id_map[skin_id] = true
            table.insert(skin_sale_list, struct_dragon_skin_sale)

            local cash_id = struct_dragon_skin_sale:getDragonSkinSaleCashId()
            local basic_id = struct_dragon_skin_sale:getDragonSkinSaleCashId()

            self.m_skinPackageMap[cash_id] = struct_dragon_skin_sale
            self.m_skinPackageMap[basic_id] = struct_dragon_skin_sale

        else
            if (IS_TEST_MODE() == true) then
                error('[table_dragon_skin_sale] 하나의 skin_id를 다른 가격으로 세팅하고 있습니다. 날짜 확인해주세요.' .. skin_id)
            end
        end
    end

    return skin_sale_list
end ]]

-------------------------------------
-- function makeDragonSkinSaleMap
-------------------------------------
function TableDragonSkinSale:makeDragonSkinSaleMap()
    local struct_dragon_skin_sale_map = {}
    local struct_product_list = g_shopDataNew:getProductList('dragon_skin')
    cclog('struct_product_list',table.count(struct_product_list) )

    for _, struct_product in pairs(struct_product_list) do
        local is_skin_product, skin_id = struct_product:isDragonSkinProduct()
        cclog('is_skin_product, skin_id',is_skin_product, skin_id )

        if is_skin_product == true then
            local struct_dragon_skin_sale = struct_dragon_skin_sale_map[skin_id]
            if struct_dragon_skin_sale == nil then
                struct_dragon_skin_sale = StructDragonSkinSale(skin_id)
                struct_dragon_skin_sale_map[skin_id] = struct_dragon_skin_sale
            end

            struct_dragon_skin_sale:insertDragonSkinProduct(struct_product)
        end
    end

    self.m_skinPackageMap = struct_dragon_skin_sale_map
end

-------------------------------------
-- function getDragonSkinSaleMap
-------------------------------------
function TableDragonSkinSale:getDragonSkinSaleMap(force_make)
    if self.m_skinPackageMap == nil or force_make == true then
        self:makeDragonSkinSaleMap()
    end   

    return self.m_skinPackageMap
end