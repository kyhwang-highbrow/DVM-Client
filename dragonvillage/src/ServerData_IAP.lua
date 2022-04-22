-------------------------------------
-- Class ServerData_IAP
-- @brief In App Purchase (현금 결제)
-------------------------------------
ServerData_IAP = class({
    m_updatedAt = 'ExperationTime', -- 정보 갱신 시간
    m_bBillingSetup = 'boolean', -- 결제 초기화 성공 여부
    m_structIAPProductMap = 'table', -- key:sku, value:StructIAPProduct
    m_structIAPPurchaseList = 'table', -- key:idx, value:StructIAPPurchase -- 처리가 완료되지 않은 결제

    m_currencyCode = 'string', -- KRW, USD, JPY, ...
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_IAP:init()
    self.m_updatedAt = ExperationTime:createWithUpdatedAyInitialized()
    self.m_bBillingSetup = false
    self.m_structIAPProductMap = {}
    self.m_structIAPPurchaseList = {}
end

local instance = nil

-------------------------------------
-- function getInstance
-------------------------------------
function ServerData_IAP:getInstance()
    if (instance == nil) then
        instance = ServerData_IAP()
    end
   
    return instance
end


-------------------------------------
-- function sdkBinder_BillingSetup
-- @breif API(결제) 초기화
-------------------------------------
function ServerData_IAP:sdkBinder_BillingSetup(success_cb, fail_cb)
    -- 로딩 UI로 사용
    local ui = UI_Network()
    ui:hideBGLayerColor() -- 배경에 어두은 음영 숨김
    ui:setLoadingMsg(Str('통신 중 ...')) -- 메세지

    -- PerpleSDK:billingSetup(str, str, function(ret, info) end)를 호출한 것과 같음
    local checkReceiptServerUrl = '' -- 현재 사용하지 않지만 드빌M의 구조를 그대로 사용하기 때문에 남겨둠
    local saveTransactionIdUrl = '' -- 현재 사용하지 않지만 드빌M의 구조를 그대로 사용하기 때문에 남겨둠
    PerpleSDK:billingSetup(checkReceiptServerUrl, saveTransactionIdUrl, function(ret, info)

        -- @sgkim 2021.03.17 billingSetup의 ret은 'success'와 'fail' 두가지 경우만 리턴된다.
        if (ret == 'success') then
            -- success일 경우 info의 케이스
            -- 1. 'In-app billing setup finished.' 정상적인 성공
            -- 2. 'In-app billing setup is already completed.' 중복 호출되었을 경우
            self.m_bBillingSetup = true
            ui:close()
            success_cb(info)            

        else--if (ret == 'fail') then
            -- fail일 경우 info의 케이스
            -- 1. '{"code":"-1501","subcode":"0","msg":""}' 형태의 json 문자열
            -- @sgkim 2021.03.17 billingSetup이 실패하면 결제를 못하게 되지만 유저 입장에서 게임 플레이를 못하게 되면 안된다.
            --local info_json = json_decode(info) -- 문자열에서 json형태로 변환하는 코드
            ui:close()
            fail_cb(info)
        end
    end)
end



-------------------------------------
-- function sdkBinder_BillingGetItemList
-- @breif 인앱결제 상품 정보 획득 (sku를 통해 현지화된 가격 등을 획득)
-------------------------------------
function ServerData_IAP:sdkBinder_BillingGetItemList(success_cb, fail_cb)
    if (self.m_bBillingSetup == false) then
        success_cb('')
        return
    end

    -- 로딩 UI로 사용
    local ui = UI_Network()
    ui:hideBGLayerColor() -- 배경에 어두은 음영 숨김
    ui:setLoadingMsg(Str('통신 중 ...')) -- 메세지

    -- PerpleSDK:billingGetItemList(skuList(string), function(ret, info) end)를 호출한 것과 같음
    local skuList = g_shopData:getSkuList() -- e.g. 'dvnew_default_1.1k;dvnew_default_2.2k'
    PerpleSDK:billingGetItemList(skuList, function(ret, info)

        -- @sgkim 2021.03.17 billingGetItemList ret은 'success'와 'fail' 두가지 경우만 리턴된다.
        if (ret == 'success') then
            -- success일 경우 info의 케이스
            local info_json = json_decode(info) -- 문자열에서 json형태로 변환하는 코드
            self.m_structIAPProductMap = {}

            g_shopData:setMarketPrice(info_json)

            for i,v in pairs(info_json) do

                local struct_iap_product = StructIAPProduct:create(v)
                local sku = struct_iap_product:getSku()
                self.m_structIAPProductMap[sku] = struct_iap_product


                if (self.m_currencyCode == nil) then
                    self.m_currencyCode = struct_iap_product:getCurrencyCode()
                end

                --cclog('i: ' .. i)
                --ccdump(v)
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
            end
            ui:close()
            success_cb(info)

            -- 데이터 갱신 시점 기록
            self:setUpdateTimeForIAP()

        else--if (ret == 'fail') then
            -- fail일 경우 info의 케이스
            -- 1. '{"code":"-1501","subcode":"0","msg":""}' 형태의 json 문자열
            --local info_json = json_decode(info) -- 문자열에서 json형태로 변환하는 코드
            ui:close()
            fail_cb(info)
        end
    end)
end

-------------------------------------
-- function sdkBinder_BillingGetIncompletePurchaseList
-- @breif 완료되지 않은 결제건 조회
-------------------------------------
function ServerData_IAP:sdkBinder_BillingGetIncompletePurchaseList(success_cb, fail_cb)
    -- 로딩 UI로 사용
    local ui = UI_Network()
    ui:hideBGLayerColor() -- 배경에 어두은 음영 숨김
    ui:setLoadingMsg(Str('통신 중 ...')) -- 메세지

    PerpleSDK:billingGetIncompletePurchaseList(function(ret, info)

        if (ret == 'success') then
            -- ccdump(info_json)

            self.m_structIAPPurchaseList = {}
            local purchase_list = json_decode(info) -- 문자열에서 json형태로 변환하는 코드
            if purchase_list then
                for _,v in pairs(purchase_list) do
                    local struct_iap_purchase = StructIAPPurchase:create(v)
                    table.insert(self.m_structIAPPurchaseList, struct_iap_purchase)
                end
            end

            ui:close()
            success_cb(info)

            -- 데이터 갱신 시점 기록
            self:setUpdateTimeForIAP()

        else--if (ret == 'fail') then
            ui:close()
            fail_cb(info)
        end
    end)
end

-------------------------------------
-- function getStructIAPProduct
-- @breif
-- @param sku(string)
-- @return struct_iap_product(StructIAPProduct) nil이 리턴될 수 있음
-------------------------------------
function ServerData_IAP:getStructIAPProduct(sku)
    local struct_iap_product = self.m_structIAPProductMap[sku]
    return struct_iap_product
end




-------------------------------------
-- function request_getValidationKey
-- @breif 상점 정보 요청
-------------------------------------
function ServerData_IAP:request_getValidationKey(product_id, sale_id, sku, success_cb, fail_cb, status_cb)

    -- param 설정
    local uid = g_userData:get('uid')
    local market, os = GetMarketAndOS()
    local store = market -- 'google', 'apple'

    -- 성공 콜백
    local function _success_cb(ret)
        --ret['validation_key']

        -- 데이터 갱신 시점 기록
        self:setUpdateTimeForIAP()

        if success_cb then
            success_cb(ret)
        end
    end

    -- 실패 콜백
    local function _fail_cb(ret)
        if fail_cb then
            fail_cb(ret)
        end
    end

    -- 성공 이외의 상태 처리
    -- (true를 리턴하면 임의 처리를 완료했다는 의미)
    local function _status_cb(ret)
        -- "status": 102, "message": "not exist user"
        if status_cb then
            return status_cb(ret)
        end

        return false
    end

    -- 개발 중일 때 로컬에서 통신 대신 json파일로 대체
    --[[
    if true then
        local ui_network = UI_Network()
        ui_network:hideBGLayerColor()
        ui_network:setDevelopRequest(Str('통신 중 ...'), 1, function()
            --local ret = LoadJsonToTable('json/mail_list.json')
            local ret = {}
            ret['validation_key'] = 'dslkfjslkdfjdsl'
            _success_cb(ret)
        end)
        return
    end
    --]]

    -- 네트워크 통신
    local ui_network = UI_Network()
    --ui_network:setSuccessCBDelayTime(1) -- 레이턴시 강제로 조정 (개발 중에 통신 중임을 확인하기 위함)
    ui_network:hideBGLayerColor() -- 배경에 어두은 음영 숨김
    ui_network:setLoadingMsg(Str('통신 중 ...')) -- 메세지
    ui_network:setUrl('/shop/validation_key') -- API명
    ui_network:setParam('uid', uid)
    ui_network:setParam('store', store)
    ui_network:setParam('product_id', product_id)
    ui_network:setParam('sale_id', sale_id)
    ui_network:setParam('sku', sku)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(_success_cb)
    --ui_network:setResponseStatusCB(_status_cb)
    --ui_network:setFailCB(_fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function makeSkuListString
-- @breif
-- @retur sku_list_str(string) nil 허용 안됨
--        e.g. 'dvnew_default_1.1k;dvnew_default_2.2k'
-------------------------------------
function ServerData_IAP:makeSkuListString()
    -- t_ret_map(table) key:product_id, value:StructProduct
    local t_ret_map = g_shopData:getAllProductMap()

    local sku_list_str = ''
    for _,struct_product in pairs(t_ret_map) do
        local sku = struct_product:getProductSku()

        -- sku가 유효한 경우
        if (sku ~= nil) and (sku ~= '') then
            if (sku_list_str == '') then
                sku_list_str = sku
            else
                sku_list_str = sku_list_str .. ';' .. sku
            end
        end
    end

    return sku_list_str
end

-------------------------------------
-- function setUpdateTimeForIAP
-- @breif 정보가 변경된 시간을 현재 시간으로 설정
-------------------------------------
function ServerData_IAP:setUpdateTimeForIAP()
    self.m_updatedAt:setUpdatedAt() -- 현재 시간을 저장
end

-------------------------------------
-- function getUpdateTimeForIAP
-- @breif 정보가 변경된 시간
-- @return timestamp(number) 단위:milliseconds, nil이 리턴될 수 있음
-------------------------------------
function ServerData_IAP:getUpdateTimeForIAP()
    local timestamp = self.m_updatedAt:getUpdatedAt()
    return timestamp
end

-------------------------------------
-- function checkGooglePlayPromotioPricePeriod
-- @breif 구글 플레이 프로모션으로 인해 상품 인앱 구매 할인하는 경우
-------------------------------------
function ServerData_IAP:checkGooglePlayPromotioPricePeriod()
    if (self:checkGooglePlayPromotionPeriod() == true) then
        if ((CppFunctions:isAndroid() == true) and (g_hotTimeData:isActiveEvent('google_play_promotion_price') == true)) then
            -- @yjkil : 22.02.24. 스토어 국가가 한국인지 확인 하는 함수를 찾지 못해 price_currency_code로 대체.
            -- 원화를 사용하는 나라는 한국 밖에 없기에 가능하지만, 다른 통화의 경우 다른 조건을 찾아야함.
            if (self.m_currencyCode == 'KRW') then
                return true
            end
        end

        if ((isWin32() == true) and (IS_TEST_MODE() == true) and (g_hotTimeData:isActiveEvent('google_play_promotion_price') == true)) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function checkGooglePlayPromotionPeriod
-- @breif 구글 플레이 프로모션으로 인해 상품 인앱 구매 할인하는 경우
-------------------------------------
function ServerData_IAP:checkGooglePlayPromotionPeriod()
    if ((CppFunctions:isAndroid() == true) and (g_hotTimeData:isActiveEvent('google_play_promotion') == true)) then
        -- @yjkil : 22.02.24. 스토어 국가가 한국인지 확인 하는 함수를 찾지 못해 price_currency_code로 대체.
        -- 원화를 사용하는 나라는 한국 밖에 없기에 가능하지만, 다른 통화의 경우 다른 조건을 찾아야함.
        if (self.m_currencyCode == 'KRW') then
            return true
        end
    end

    if ((isWin32() == true) and (IS_TEST_MODE() == true) and (g_hotTimeData:isActiveEvent('google_play_promotion') == true)) then
        return true
    end

    return false
end

-------------------------------------
-- function checkGooglePlayPromotionPriceChanged
-------------------------------------
function ServerData_IAP:checkGooglePlayPromotionPriceChanged(original_price, sku)
    if (ServerData_IAP.getInstance():checkGooglePlayPromotioPricePeriod() == true) then
        local struct_iap_product = self:getStructIAPProduct(sku)

        if struct_iap_product then
            local currency_code = struct_iap_product:getCurrencyCode()
            local market_price = struct_iap_product:getCurrencyPrice()

            if (currency_code == 'KRW') and (market_price < original_price) then
                return true
            end
        end
    end

    return false
end

-------------------------------------
-- function getGooglePlayPromotionPrice
-------------------------------------
function ServerData_IAP:getGooglePlayPromotionPriceStr(struct_product)
    
    local result = struct_product:getPriceStr()

    if (ServerData_IAP.getInstance():checkGooglePlayPromotioPricePeriod() == true) then
        local price = struct_product:getPrice()

        if (ServerData_IAP.getInstance():checkGooglePlayPromotionPriceChanged(price, sku) == true) then
            local sku = struct_product:getProductSku()

            local struct_iap_product = ServerData_IAP.getInstance():getStructIAPProduct(sku)

            price = struct_iap_product:getCurrencyPrice()
        else
            price = price * 0.85
        end

        result = '￦' .. comma_value(price)
    end

	return result
end

-------------------------------------
-- function setGooglePlayPromotionSaleTag
-------------------------------------
function ServerData_IAP:setGooglePlayPromotionSaleTag(class_, struct_product, index)
    if (self:checkGooglePlayPromotionPeriod() == true) then
        local vars = class_.vars

        if (index == nil) then index = 1 end

        local sale_sprite = vars['saleSprite' .. index] or vars['saleSprite']

        if sale_sprite then
            local is_it_buyable = struct_product and struct_product:isItBuyable()
            sale_sprite:setVisible(is_it_buyable)           

            return true
        end
    end

    return false
end

-------------------------------------
-- function setGooglePlayPromotionPrice
-------------------------------------
function ServerData_IAP:setGooglePlayPromotionPrice(class_, struct_product, index)
    if (self:checkGooglePlayPromotioPricePeriod() == true) then
        local vars = class_.vars

        if (index == nil) then index = 1 end
    
        local promotion_sprite = vars['promotionSprite' .. index] or vars['promotionSprite']
    
        if promotion_sprite then
            promotion_sprite:setVisible(true)
            local origin_price_label = vars['originalPriceLabel' .. index] or vars['originalPriceLabel']
            local promotion_price_label = vars['promotionPriceLabel' .. index] or vars['promotionPriceLabel']
            
            if origin_price_label and promotion_price_label then
                origin_price_label:setString(struct_product:getPriceStr())
    
                local price_str = self:getGooglePlayPromotionPriceStr(struct_product)
                
                promotion_price_label:setString(price_str)
    
                return true
            end
        end 
    end

    return false
end
