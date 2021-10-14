-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure

-------------------------------------
-- Class StructIAPPurchase
-- @brief IAP에서 결제 1건에 대한 데이터
-- @instance struct_iap_purchase(StructIAPPurchase)
-------------------------------------
StructIAPPurchase = class(PARENT, {
    -- rawdata
    orderId = 'string', -- e.g. 'GPA.3383-2200-7533-03221'
    purchaseTime = 'number', -- e.g. 1616051904887
    purchaseToken = 'string', -- e.g. 'gnomdhcppdbcoehbojajlpld.AO-J1OzveHOrTr3GicfLMpl8ErpZVRm65aDa5itzkSNrz5ezjYaoOfVwi03pd7OXMOKje8EJqgmy-ry6tvn1Ba9yHXtSL5Z6I7VSxWvj79h2EiWtGIBmqWY'
    --productId = 'string', -- e.g. 'dvnew_default_1.1k' -- key값을 sku로 변경해서 사용
    sku = 'string',

    -- 사용하지 않는 rawdata (google play)
    packageName = 'string', -- e.g. 'com.highbrow.games.dvnew'
    purchaseState = 'number', -- e.g. 0
    acknowledged = 'boolean', -- e.g. false

    quantity = 'number',
})

local THIS = StructIAPPurchase

-------------------------------------
-- function getClassName
-------------------------------------
function StructIAPPurchase:getClassName()
    return 'StructIAPPurchase'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructIAPPurchase:getThis()
    return THIS
end

-------------------------------------
-- function init
-------------------------------------
function StructIAPPurchase:init()
end

-------------------------------------
-- function getOrderId
-- @brief 주문 번호 리턴
-- @return order_id(string)
-------------------------------------
function StructIAPPurchase:getOrderId()
    local order_id = self.orderId
    return order_id
end

-------------------------------------
-- function getPurchaseToken
-- @brief 결제 토큰 (영수증 검사에 사용. receipt validation)
-- @return order_id(string)
-------------------------------------
function StructIAPPurchase:getPurchaseToken()
    local purchase_token = self.purchaseToken
    return purchase_token
end

-------------------------------------
-- function getSku
-- @brief 상품 식별자 리턴 e.g. 'dvnew_default_1.1k'
-------------------------------------
function StructIAPPurchase:getSku()
    return self.sku
end

-------------------------------------
-- function getPurchaseTime
-- @brief 결제 시간
-- @return purchase_time(number) timestamp (단위:초)
-------------------------------------
function StructIAPPurchase:getPurchaseTime()
    local purchase_time = self.purchaseTime
    return purchase_time
end

-------------------------------------
-- function create
-- @param t_data(table)
-------------------------------------
function StructIAPPurchase:create(t_data)
    local t_date_clone = clone(t_data)

    -- t_data e.g. google play
    -- {"orderId":"GPA.3383-2200-7533-03221","packageName":"com.highbrow.games.dvnew","productId":"dvnew_default_1.1k","purchaseTime":1616051904887,"purchaseState":0,"purchaseToken":"gnomdhcppdbcoehbojajlpld.AO-J1OzveHOrTr3GicfLMpl8ErpZVRm65aDa5itzkSNrz5ezjYaoOfVwi03pd7OXMOKje8EJqgmy-ry6tvn1Ba9yHXtSL5Z6I7VSxWvj79h2EiWtGIBmqWY","acknowledged":false}

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

    local struct_iap_purchase = StructIAPPurchase()
    struct_iap_purchase:applyTableData(t_date_clone)
    return struct_iap_purchase
end