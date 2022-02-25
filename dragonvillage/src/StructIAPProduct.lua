-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure

-------------------------------------
-- Class StructIAPProduct
-- @instance struct_iap_product(StructIAPProduct)
-------------------------------------
StructIAPProduct = class(PARENT, {
    -- rawdata
    skuDetailsToken = 'string', -- e.g. 'AEuhp4KgGu-Ibs03LV6HOsl-jf8B9pEHlmG6ly1AEG_GPr3CV0wMekvW53Rf9g6hweZx'
    price = 'string', -- e.g. '₩1,100'
    title = 'string', -- e.g. '1100원 상품 (Bubbly Operator)'
    description = 'string', -- e.g. '1100원 상품'
    --productId = 'string', -- e.g. 'dvnew_default_1.1k' -- key값을 sku로 변경해서 사용
    sku = 'string',
    type = 'string', -- e.g. 'inapp'
    price_amount_micros = 'number', -- e.g. 1100000000
    price_currency_code = 'string', -- e.g. 'KRW'
    name = 'string', -- e.g. "1,100원 캐시 상품"

    -- android e.g.
    --{
    --    ['skuDetailsToken']='AEuhp4KgGu-Ibs03LV6HOsl-jf8B9pEHlmG6ly1AEG_GPr3CV0wMekvW53Rf9g6hweZx';
    --    ['price']='₩1,100';
    --    ['title']='1100원 상품 (Bubbly Operator)';
    --    ['description']='1100원 상품';
    --    ['productId']='dvnew_default_1.1k';
    --    ['type']='inapp';
    --    ['price_amount_micros']=1100000000;
    --    ['price_currency_code']='KRW';
    --}
    -- apple e.g.
    --{
    --    ['price']='¥120';
    --    ['title']='1100원 상품';
    --    ['price_amount_micros']=120000000;
    --    ['price_currency_code']='JPY';
    --    ['productID']='dvnew_default_1.1k';
    --    ['description']='1100원 상품';
    --}
})

local THIS = StructIAPProduct

-------------------------------------
-- function getClassName
-------------------------------------
function StructIAPProduct:getClassName()
    return 'StructIAPProduct'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructIAPProduct:getThis()
    return THIS
end

-------------------------------------
-- function init
-------------------------------------
function StructIAPProduct:init()
end

-------------------------------------
-- function getSku
-- @brief 상품 식별자 리턴 e.g. 'dvnew_default_1.1k'
-------------------------------------
function StructIAPProduct:getSku()
    return self.sku
end

-------------------------------------
-- function getPriceStr
-- @brief 현지화된 상품 가격 문자열 리턴
--        e.g. '₩1,100', '¥120'
-------------------------------------
function StructIAPProduct:getPriceStr()
    return self.price
end

-------------------------------------
-- function getCurrencyCode
-- @brief 결제 통화
-- @return currency_code(string) e.g. 'KRW', 'USD', 'JPY' ...
-------------------------------------
function StructIAPProduct:getCurrencyCode()
    local currency_code = self.price_currency_code
    return currency_code
end

-------------------------------------
-- function getCurrencyPrice
-- @brief 현지화된 통화에 대한 상품 가격
-- @return currency_price(number)
-------------------------------------
function StructIAPProduct:getCurrencyPrice()
    local currency_price = self.price_amount_micros

    if (type(currency_price) == 'number') then
        currency_price = (currency_price / 1000000)
    end

    return currency_price
end

-------------------------------------
-- function create
-- @param t_data(table)
-------------------------------------
function StructIAPProduct:create(t_data)
    local t_date_clone = clone(t_data)

    -- 마켓(구글 플레이, 앱스토어)에서는 sku와 product_id를 혼용해서 사용한다.
    -- 드빌NEW에서 sku는 마켓에서 상품을 식별하는 값으로, product_id는 게임 내에서 상품을 식별하는 값으로 구분해서 사용한다.
    -- 따라서 마켓에서 전달 받은 product_id값을 sku로 명명한다.

    -- 구글 플레이에 key값 productId
    if (t_date_clone['productId']) then
        t_date_clone['sku'] = t_date_clone['productId']
        t_date_clone['productId'] = nil
    end

    -- 앱스토어 key값 productID
    if (t_date_clone['productID']) then
        t_date_clone['sku'] = t_date_clone['productID']
        t_date_clone['productID'] = nil
    end

    local struct_product = StructIAPProduct()
    struct_product:applyTableData(t_date_clone)
    return struct_product
end