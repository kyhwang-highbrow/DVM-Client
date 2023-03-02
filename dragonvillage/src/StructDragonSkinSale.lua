-------------------------------------
-- Class StructDragonSkinSale
-------------------------------------
StructDragonSkinSale = class({
    skin_id = 'number',
    money_product_list = 'List<StructProduct>',
    cash_product_list = 'List<StructProduct>',
    is_price_sorted = 'boolean'
})

local THIS = StructDragonSkinSale
-------------------------------------
-- function getClassName
-------------------------------------
function StructDragonSkinSale:getClassName()
    return 'StructDragonSkinSale'
end

-------------------------------------
-- virtual function getThis
-- @override Structure
-------------------------------------
function StructDragonSkinSale:getThis()
    return THIS
end

-------------------------------------
-- function init
-------------------------------------
function StructDragonSkinSale:init(skin_id)
    self.skin_id = skin_id
    self.is_price_sorted = false
end

-------------------------------------
-- function getDragonSkinSaleSkinId
-------------------------------------
function StructDragonSkinSale:getDragonSkinSaleSkinId()
    return self.skin_id
end

-------------------------------------
-- function insertDragonSkinProduct
-------------------------------------
function StructDragonSkinSale:insertDragonSkinProduct(struct_product)
    local price_type = struct_product:getPriceType()
    local price_type_str = string.format('%s_product_list', price_type)

    if self[price_type_str] == nil then
        self[price_type_str] = {}
    end

    table.insert(self[price_type_str], struct_product)
end

-------------------------------------
-- function isDragonSkinOwned
-------------------------------------
function StructDragonSkinSale:isDragonSkinOwned()
    local skin_id = self:getDragonSkinSaleSkinId()
    return g_dragonSkinData:isDragonSkinOpened(skin_id)
end

-------------------------------------
-- function isDragonSkinSaleOnSale
-------------------------------------
function StructDragonSkinSale:isDragonSkinSaleOnSale()
    local struct_product = self:getDragonSkinProduct('money')
    if struct_product:getProductBadge() == 'sale' then
        return true        
    end
    return false
end

-------------------------------------
-- function getDragonSkinProductList
-------------------------------------
function StructDragonSkinSale:getDragonSkinProductList(price_type)
    local price_type_str = string.format('%s_product_list', price_type)
    if self[price_type_str] == nil then
        return nil
    end

    local product_list = self[price_type_str]
    return product_list
end

-------------------------------------
-- function getDragonSkinProduct
-------------------------------------
function StructDragonSkinSale:getDragonSkinProduct(price_type)
    local product_list = self:getDragonSkinProductList(price_type)
    if product_list == nil then
        return nil
    end

    -- 가장 싼 가격의 상품을 살 수 있도록 우선 노출시킴
    local cur_price = 0
    local result_struct_product = nil
    for _, struct_product in ipairs(product_list) do
        if cur_price == 0 or struct_product:getPrice() < cur_price  then
            cur_price = struct_product:getPrice()
            result_struct_product = struct_product
        end
    end

    return result_struct_product
end

-------------------------------------
-- function checkDragonSkinPurchaseValidation
-------------------------------------
function StructDragonSkinSale:checkDragonSkinPurchaseValidation()
    if self:getDragonSkinProduct('money') == nil then
        return false
    end

    if self:getDragonSkinProduct('cash') == nil then
        return false
    end

    return true
end