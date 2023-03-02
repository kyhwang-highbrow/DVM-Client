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
-- function getDragonSkinProduct
-------------------------------------
function StructDragonSkinSale:getDragonSkinProduct(price_type)
    local price_type_str = string.format('%s_product_list', price_type)
    local product_list = self[price_type_str]

    if self.is_price_sorted == false then
        table.sort(product_list, function (a, b)
            return a:getPrice() < b:getPrice()
        end)

        self.is_price_sorted = true
    end

    return table.getFirst(product_list)
end