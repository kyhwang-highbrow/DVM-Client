-------------------------------------
-- Class StructDragonSkinSale
-------------------------------------
StructDragonSkinSale = class({
    skin_id = 'number',
    money_product_list = 'List<StructProduct>',
    cash_product_list = 'List<StructProduct>',
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
    return g_userData:isDragonSkinOpened(skin_id)
end

-------------------------------------
-- function getDragonSkinDId
-------------------------------------
function StructDragonSkinSale:getDragonSkinDId()
    local skin_id = self:getDragonSkinSaleSkinId()
    local did = TableDragonSkin:getDragonSkinValue('did', skin_id)
    return did
end

-------------------------------------
-- function getDragonSkinProductOriginalPriceStr
-- @brief 할인가 표기를 위한 원가 가격 스트링
-------------------------------------
function StructDragonSkinSale:getDragonSkinProductOriginalPriceStr(price_type)
    local skin_id = self:getDragonSkinSaleSkinId()
    local t_data = {
        ['sku'] = '' ,
        ['price'] = '',
        ['price_dollar'] = '',
        ['xsolla_price_dollar'] = '',
    }

    for key_name, _ in pairs(t_data) do
        if key_name == 'price' then
            local str = string.format('%s_price', price_type)
            t_data[key_name] = TableDragonSkin:getDragonSkinValue(str, skin_id)
        else
            t_data[key_name] = TableDragonSkin:getDragonSkinValue(key_name, skin_id)
        end
    end

    t_data['price_type'] = price_type
    local struct_product = StructProduct()
    struct_product:applyTableData(t_data)
    return struct_product:getPriceStr(), struct_product:getPrice()
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

-------------------------------------
-- function getUIPriority
-------------------------------------
function StructDragonSkinSale:getUIPriority()
    local order = 1

    local did = self:getDragonSkinDId()

    -- 보유중인 드래곤일 경우
    if g_dragonsData:getNumOfDragonsByDid(did) > 0 then
        order = order + 1000
    end

    -- 소유한 스킨일 경우
    if self:isDragonSkinOwned() == true then
        order = order - 1000
    end

    -- 구매가 가능한 상태일 경우
    if self:checkDragonSkinPurchaseValidation() == true then
        order = order + 10
    end

    return order
end