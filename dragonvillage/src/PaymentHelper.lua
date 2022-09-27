PaymentHelper = {}


-------------------------------------
-- function buy_iap
-- @brief 인앱 결제 3.0
-- @param cb_func(ret)
-------------------------------------
function PaymentHelper.buy_iap(struct_product, cb_func)    
    local validation_key = nil
    local test_purchase = false
    local product_id = struct_product:getProductID()
    local sale_id = struct_product:getProductSaleID()
    local sku = struct_product:getProductSku() -- e.g. 'dvnew_default_2.2k'
    local order_id = nil
    local purchase_time = nil
    local purchase_token = nil

    --MakeSimplePopup(POPUP_TYPE.OK, '인앱 결제 구현 예정')
    local func_request_get_validation_key
    local func_response_get_validation_key
    local func_checkTestPurchase
    local func_billingPurchase
    local func_check_incomplete_purchase_test
    local func_request_buy
    local func_response_buy

    -- validation key 발급 요청
    func_request_get_validation_key = function()

        local success_cb = func_response_get_validation_key -- @nextfunc
        local fail_cb = nil
        local status_cb = nil
        ServerData_IAP:getInstance():request_getValidationKey(product_id, sale_id, sku, success_cb, fail_cb, status_cb)
    end

    -- validation key 발급
    func_response_get_validation_key = function(ret)
        validation_key = ret['validation_key']

        if (validation_key ~= nil) and (validation_key ~= '') then
            -- @nextfunc
            func_checkTestPurchase()            
        else
            local msg = '일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'
            MakeSimplePopup(POPUP_TYPE.OK,  msg)
            return
        end        
    end

    -- 테스트 결제 프로세스 확인
    func_checkTestPurchase = function()
        if (isWin32() or isMac()) then
            test_purchase = true
            -- @nextfunc
            local msg = '스토어 결제 진행 시점입니다.'
            local sub_msg = '에뮬레이터에서 노출되는 팝업입니다.\n스토어 결제가 이루어졌다고 간주합니다.'
            MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg, func_check_incomplete_purchase_test)
            return
        end
        
        -- 테스트 모드에서는 테스트 결제를 확인
        if (IS_TEST_MODE() == true) then
            local msg = '테스트 결제, 스토어 결제를 선택하세요.'
            local sub_msg = '테스트 모드가 설정된 빌드에서만 노출되는 팝업입니다.'

            -- 스토어 결제 버튼 터치
            local function ok_btn_cb()
                test_purchase = false
                -- @nextfunc
                func_billingPurchase()
            end

            -- 테스트 결제 버튼 터치
            local function cancel_btn_cb()
                test_purchase = true
                -- @nextfunc
                func_billingPurchase()
            end
            local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, sub_msg, ok_btn_cb, cancel_btn_cb)

            if (ui.vars['okLabel']) then ui.vars['okLabel']:setString('스토어 결제') end
            if (ui.vars['cancelLabel']) then ui.vars['cancelLabel']:setString('테스트 결제') end
            
            
        else
            -- @nextfunc 
            func_billingPurchase()
        end
    end

    -- 스토어 결제
    func_billingPurchase = function()
        if (test_purchase == true) then
            -- @nextfunc
            func_check_incomplete_purchase_test()
            return
        end

        -- 로딩 UI로 사용
        local ui = UI_Network()
        ui:hideBGLayerColor() -- 배경에 어두은 음영 숨김
        ui:setLoadingMsg(Str('통신 중 ...')) -- 메세지

        -- PerpleSDK:billingPurchase(sku(string), function(ret, info) end)를 호출한 것과 같음
        local payload = '' -- 드빌M에서 사용하던 구조를 그대로 사용하기 위해 파라미터는 남아있지만 사용하지 않음
        PerpleSDK:billingPurchase(sku, payload, function(ret, info)

            -- @sgkim 2021.03.17 billingPurchase ret은 'success'와 'fail' 두가지 경우만 리턴된다.
            if (ret == 'success') then
                local info_json = json_decode(info) -- 문자열에서 json형태로 변환하는 코드
                -- {"orderId":"GPA.3383-2200-7533-03221","packageName":"com.highbrow.games.dvnew","productId":"dvnew_default_1.1k","purchaseTime":1616051904887,"purchaseState":0,"purchaseToken":"gnomdhcppdbcoehbojajlpld.AO-J1OzveHOrTr3GicfLMpl8ErpZVRm65aDa5itzkSNrz5ezjYaoOfVwi03pd7OXMOKje8EJqgmy-ry6tvn1Ba9yHXtSL5Z6I7VSxWvj79h2EiWtGIBmqWY","acknowledged":false}

                order_id = info_json['orderId']
                purchase_time = info_json['purchaseTime']
                purchase_token = info_json['purchaseToken']

                ui:close()

                -- @nextfunc
                func_check_incomplete_purchase_test()
            else--if (ret == 'fail') then
                ui:close()
                if (info == 'cancel') then
                    MakeSimplePopup(POPUP_TYPE.OK, Str('결제를 취소하였습니다.'))
                elseif (info == 'item_already_owned') then
                    MakeSimplePopup(POPUP_TYPE.OK, Str('이미 보유하고 있는 아이템입니다.'))
                else
                    local msg = Str('알 수 없는 문제가 발생했습니다.')
                    local sub_msg = nil
                    if (type(info) == 'string') and (info ~= '') then
                        sub_msg = info
                    end
                    if (sub_msg == nil) then
                        MakeSimplePopup(POPUP_TYPE.OK, msg)
                    else
                        MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
                    end
                end
                -- fail일 경우 info의 케이스
                -- 1. '{"code":"-1501","subcode":"0","msg":""}' 형태의 json 문자열
                --local info_json = json_decode(info) -- 문자열에서 json형태로 변환하는 코드 
            end
        end)
    end

    -- 아이템 미지급 테스트 확인
    func_check_incomplete_purchase_test = function()
        -- 테스트 모드이고 실결제인 경우에만 노출
        if (IS_TEST_MODE() == true) and (test_purchase == false) then
            local msg = '아이템 미지급 테스트 여부를 결정해주세요.'
            local sub_msg = '테스트 모드가 설정된 빌드에서만 노출되는 팝업입니다.'

            local function ok_btn_cb()
                -- 정상 지급
                -- @nextfunc
                func_request_buy()
            end

            local function cancel_btn_cb()
                -- 미지급 테스트
                -- 아무것도 하지 않음
            end
            local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, sub_msg, ok_btn_cb, cancel_btn_cb)

            if (ui.vars['okLabel']) then ui.vars['okLabel']:setString('정상 지급') end
            if (ui.vars['cancelLabel']) then ui.vars['cancelLabel']:setString('미지급 테스트') end
        else
            -- @nextfunc
            func_request_buy()
        end
    end

    -- 영수증 검사 + 상품 지급 요청 통신
    func_request_buy = function()
        local success_cb = func_response_buy -- @nextfunc
        local function fail_cb(ret)
            ccdump(ret)
            error_msg = Str('영수증 확인에 실패하였습니다.')
        end
            
        -- 특정 리턴값 처리
        local function response_status_cb(ret)
            -- -3161 : already use receipt, -1161 : not exist receipt
            if (ret['status'] == -3161) or (ret['status'] == -1161) then
                cclog('#### ret : ')
                ccdump(ret)
                if (cb_func) then cb_func(ret) end
                return true
            end
        end

        g_shopDataNew:request_checkReceiptValidation_v3(struct_product, validation_key, product_id, sale_id,
            sku, purchase_time, order_id, purchase_token,
            success_cb, fail_cb, response_status_cb,
            test_purchase)
    end

    -- 구매 통신 결과
    func_response_buy = function(ret)
        cclog('#### ret : ')
        ccdump(ret)

        -- 지표
        if (test_purchase == false) then
            local currency_code = nil
            local currency_price = nil

            -- StructIAPProduct
            local struct_iap_product = struct_product:getStructIAPProduct()
            if struct_iap_product then
                currency_code = struct_iap_product:getCurrencyCode()
                currency_price = struct_iap_product:getCurrencyPrice()
            else
                -- StructIAPProduct가 없을 경우에 기본값 설정
                currency_code = 'KRW'
                currency_price = struct_product:getPrice()
            end

            -- @analytics
            --Analytics:purchase(product_id, sku, currency_code, currency_price) -- params: product_id, sku, currency_code, currency_price
        end
        
        -- 컨슘 (스토어 구매 과정 종료)
        if (test_purchase == false) then
            PerpleSDK:billingConfirm(order_id)
        end

        if cb_func then
            cb_func(ret)
        end

        local msg = Str('결제에 성공하였습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
    end

    func_request_get_validation_key()
end


-------------------------------------
-- function payment
-- legacy
-- @brief 결제 상품 처리
-------------------------------------
function PaymentHelper.payment(struct_product, cb_func)
    local is_billing_3 = false
    -- @ochoi 2021.09.23, 1.3.0 앱 업데이트 분기 처리
    -- LIVE 1.3.0, QA 0.7.9, DEV 0.7.9 이상은 새로운 결제 처리 로직을 사용하도록 한다.
    if (CppFunctionsClass:isAndroid() == true and getAppVerNum() >= 1003000) 
        or (IS_QA_SERVER() and getAppVerNum() >= 7009)
        or (CppFunctions:getTargetServer() == 'DEV' and getAppVerNum() >= 7009) then

        is_billing_3 = true
    end

    if (is_billing_3 == true) then
        PaymentHelper.buy_iap(struct_product, cb_func)
        return
    end


    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        -- 중간에 에러가 발생했을 경우 처리 (코루틴이 종료되는 시점에 무조건 호출되는 함수)
        local error_msg, error_info = nil
        local function coroutine_finidh_cb()
			-- error msg가 있으면 단순 팝업 출력
            if error_msg then
                MakeSimplePopup(POPUP_TYPE.OK, error_msg)
			-- error info가 있으면 공용 오류처리 팝업 출력
			elseif (error_info) then
				PerpleSdkManager:makeErrorPopup(error_info)
            end
        end
        co:setCloseCB(coroutine_finidh_cb)

        local market, os = GetMarketAndOS()
        local sku = struct_product['sku']
        local product_id = struct_product['product_id']
        local price = struct_product['price'] -- struct_product:getPrice()
        local validation_key = nil
        local orderId = nil

        --------------------------------------------------------
        cclog('#1. validation_key 발행')
        do -- purchase token(validation_key) 발행
            co:work()
            local function cb_func(ret)
                validation_key = ret['validation_key']

                if (validation_key ~= nil) and (validation_key ~= '') then
                    co.NEXT() 
                else
                    local msg = '일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'
                    MakeSimplePopup(POPUP_TYPE.OK,  msg)
                    co.ESCAPE()
                end        
            end
            local function fail_cb(ret)
                error_msg = Str('결제를 준비하는 과정에서 알수없는 오류가 발생하였습니다.')
                co.ESCAPE()
            end
            g_shopDataNew:request_purchaseToken(market, sku, product_id, price, cb_func, fail_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#2. 결제 실행')
        do -- 일반형 상품 구매
            co:work()

            -- 페이로드 생성
            local payload_table = {}
            payload_table['uid'] = g_userData:get('uid')
            payload_table['validation_key'] = validation_key
            payload_table['product_id'] = product_id
            payload_table['price'] = price
            payload_table['sku'] = sku
            local payload = dkjson.encode(payload_table)

            cclog('## sku : ' .. sku)
            cclog('## payload : ' .. payload)

            -- @sku : 상품 아이디
            -- @payload : 영수증 검증에 필요한 부가 정보
            local function result_func(ret, info)
                cclog('#### ret : ')
                ccdump(ret)

                -- {"orderId":"GPA.3373-5309-9610-83371","payload":"{\"validation_key\":\"22e088cd-53df-435e-a263-0540ae5c3870\",\"price\":55000,\"uid\":\"8ZxuT9Mt9OebL6gQ22gzjVu8d1g2\",\"product_id\":81005}"}
                cclog('#### info : ')
                ccdump(info)

                if (ret == 'success') then
                    cclog('## 결제 성공')                    
					local info_json = dkjson.decode(info)
                    orderId = info_json and info_json['orderId']
                    co.NEXT()

                elseif (ret == 'fail') then
                    cclog('## 결제 실패')
                    error_info = info
                    co.ESCAPE()

                elseif (ret == 'cancel') then
                    cclog('## 결제 취소')
                    error_msg = Str('결제를 취소하였습니다.')
                    co.ESCAPE()

                else
                    cclog('## 결제 결과 (예외) : ' .. ret)
                    error_info = info
                    co.ESCAPE()
                end
            end

            PerpleSDK:billingPurchase(sku, payload, result_func)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#3. 영수증 확인 & 상품 지급')
        do -- 영수증 확인, 상품 지급
            co:work()
            local function finish_cb(ret)
                cclog('#### ret : ')
                ccdump(ret)

				local msg = Str('결제에 성공하였습니다.')
				MakeSimplePopup(POPUP_TYPE.OK, msg, function()
						cb_func(ret)
						co.NEXT()
					end)
            end

            local function fail_cb(ret)
                ccdump(ret)
                error_msg = Str('영수증 확인에 실패하였습니다.')
                co.ESCAPE()
            end

            
            -- 특정 리턴값 처리
            local function response_status_cb(ret)
                -- -3161 : already use receipt, -1161 : not exist receipt
                if (ret['status'] == -3161) or (ret['status'] == -1161) then
                    cclog('#### ret : ')
                    ccdump(ret)
                    cb_func(ret)
                    co.NEXT()
                    return true
                end
            end

            local iswin = false
            g_shopDataNew:request_checkReceiptValidation(struct_product, validation_key, sku, product_id, price, iswin, finish_cb, fail_cb, response_status_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#4. 결제 확인')
        do
            -- 구매 완료 성공 콜백을 받은 후 게임 서버에서 정상적으로 상품 지급을 한 다음 다시 이 함수를 호출해서 구매 프로세스를 완료시킴
            -- 이 함수를 호출하면 구글 결제 가방에서 해당 Purchase 를 Consume 처리함.
            if orderId then
                PerpleSDK:billingConfirm(orderId)
            end
        end
        --------------------------------------------------------

        co:close()
    end


    Coroutine(coroutine_function, '#PAYMENT 코루틴')
end

-------------------------------------
-- function payment_onestore
-- @brief 결제 상품 처리
-------------------------------------
function PaymentHelper.payment_onestore(struct_product, cb_func)
    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        -- 중간에 에러가 발생했을 경우 처리 (코루틴이 종료되는 시점에 무조건 호출되는 함수)
        local error_msg, error_info = nil
        local function coroutine_finidh_cb()
			-- error msg가 있으면 단순 팝업 출력
            if error_msg then
                MakeSimplePopup(POPUP_TYPE.OK, error_msg)
			-- error info가 있으면 공용 오류처리 팝업 출력
			elseif (error_info) then
				PerpleSdkManager:makeErrorPopup(error_info)
            end
        end
        co:setCloseCB(coroutine_finidh_cb)

        local market, os = GetMarketAndOS()
        local sku = struct_product['sku']
        local product_id = struct_product['product_id']
        local price = struct_product['price'] -- struct_product:getPrice()
        local validation_key = nil
        local orderId = nil

        --------------------------------------------------------
        cclog('#1. validation_key 발행')
        do -- purchase token(validation_key) 발행
            co:work()
            local function cb_func(ret)
                validation_key = ret['validation_key']
                if (validation_key ~= nil) and (validation_key ~= '') then
                    co.NEXT() 
                else
                    local msg = '일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'
                    MakeSimplePopup(POPUP_TYPE.OK,  msg)
                    co.ESCAPE()
                end     
            end
            local function fail_cb(ret)
                error_msg = Str('결제를 준비하는 과정에서 알수없는 오류가 발생하였습니다.')
                co.ESCAPE()
            end
            g_shopDataNew:request_purchaseToken(market, sku, product_id, price, cb_func, fail_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#2. 결제 실행')
        do -- 일반형 상품 구매
            co:work()

            -- 페이로드 생성
            local payload_table = {}
            payload_table['uid'] = g_userData:get('uid')
            payload_table['validation_key'] = validation_key
            payload_table['product_id'] = product_id
            payload_table['price'] = price
            payload_table['sku'] = sku
            local payload = dkjson.encode(payload_table)

            cclog('## sku : ' .. sku)
            cclog('## payload : ' .. payload)

            -- @sku : 상품 아이디
            -- @payload : 영수증 검증에 필요한 부가 정보
            local function result_func(ret, info)
                cclog('#### ret : ')
                ccdump(ret)

                -- {"orderId":"GPA.3373-5309-9610-83371","payload":"{\"validation_key\":\"22e088cd-53df-435e-a263-0540ae5c3870\",\"price\":55000,\"uid\":\"8ZxuT9Mt9OebL6gQ22gzjVu8d1g2\",\"product_id\":81005}"}
                cclog('#### info : ')
                ccdump(info)

                if (ret == 'success') then
                    cclog('## 결제 성공')                    
					local info_json = dkjson.decode(info)
                    orderId = info_json and info_json['orderId']
                    co.NEXT()

                elseif (ret == 'fail') then
                    cclog('## 결제 실패')
                    error_info = info
                    co.ESCAPE()

                elseif (ret == 'cancel') then
                    cclog('## 결제 취소')
                    error_msg = Str('결제를 취소하였습니다.')
                    co.ESCAPE()

                else
                    cclog('## 결제 결과 (예외) : ' .. ret)
                    error_info = info
                    co.ESCAPE()
                end
            end

            PerpleSDK:billingPurchaseForOnestore(sku, payload, result_func)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#3. 영수증 확인 & 상품 지급')
        do -- 영수증 확인, 상품 지급
            co:work()
            local function finish_cb(ret)
                cclog('#### ret : ')
                ccdump(ret)

				local msg = Str('결제에 성공하였습니다.')
				MakeSimplePopup(POPUP_TYPE.OK, msg, function()
						cb_func(ret)
						co.NEXT()
					end)
            end

            local function fail_cb(ret)
                ccdump(ret)
                error_msg = Str('영수증 확인에 실패하였습니다.')
                co.ESCAPE()
            end

            
            -- 특정 리턴값 처리
            local function response_status_cb(ret)
                -- -3161 : already use receipt, -1161 : not exist receipt
                if (ret['status'] == -3161) or (ret['status'] == -1161) then
                    cclog('#### ret : ')
                    ccdump(ret)
                    cb_func(ret)
                    co.NEXT()
                    return true
                end
            end

            local iswin = false
            g_shopDataNew:request_checkReceiptValidation(struct_product, validation_key, sku, product_id, price, iswin, finish_cb, fail_cb, response_status_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#4. 결제 확인')
        do
            -- 구매 완료 성공 콜백을 받은 후 게임 서버에서 정상적으로 상품 지급을 한 다음 다시 이 함수를 호출해서 구매 프로세스를 완료시킴
            -- 이 함수를 호출하면 원스토어 결제 목록에서 해당 Purchase 를 Consume 처리함.
            if orderId then
                if PerpleSDK.onestoreConsumeByOrderid then
                    local function consume_cb(ret, info)
                        co.NEXT()
                    end
                    PerpleSDK:onestoreConsumeByOrderid(orderId, consume_cb)
                    if co:waitWork() then return end
                end
            end
        end
        --------------------------------------------------------
        
        co:close()
    end


    Coroutine(coroutine_function, '#PAYMENT 코루틴')
end

-------------------------------------
-- function payment_xsolla
-- @brief 엑솔라 결제
-------------------------------------
function PaymentHelper.payment_xsolla(struct_product, cb_func)
local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()	

        -- 중간에 에러가 발생했을 경우 처리 (코루틴이 종료되는 시점에 무조건 호출되는 함수)
        local error_msg, error_info = nil
        local function coroutine_finidh_cb()
			-- error msg가 있으면 단순 팝업 출력
            if error_msg then
                MakeSimplePopup(POPUP_TYPE.OK, error_msg)
			-- error info가 있으면 공용 오류처리 팝업 출력
			elseif (error_info) then
				PerpleSdkManager:makeErrorPopup(error_info)
            end
        end
        co:setCloseCB(coroutine_finidh_cb)

        local market, os = GetMarketAndOS()
        local sku = struct_product['sku']
        local product_id = struct_product['product_id']
        local price = struct_product['xsolla_price_dollar']
        local validation_key = nil
        local orderId = nil

        --------------------------------------------------------
        cclog('#1. validation_key 발행')
        do -- purchase token(validation_key) 발행
            co:work()
            local function cb_func(ret)
                validation_key = ret['validation_key']
                if (validation_key ~= nil) and (validation_key ~= '') then
                    co.NEXT() 
                else
                    local msg = '일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'
                    MakeSimplePopup(POPUP_TYPE.OK,  msg)
                    co.ESCAPE()
                end     
            end
            local function fail_cb(ret)
                error_msg = Str('결제를 준비하는 과정에서 알수없는 오류가 발생하였습니다.')
                co.ESCAPE()
            end
            g_shopDataNew:request_purchaseToken(market, sku, product_id, price, cb_func, fail_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#2. 결제 실행')
        do -- 일반형 상품 구매
            co:work()
			
			ShowLoading("")

            -- 페이로드 생성
			local payload_table = {
				["uid"] = g_userData:get('uid'),
				["nick"] = 'Xsolla',
				['validation_key'] = validation_key,
				["product_id"] = product_id,
				
				['currency'] = 'USD',
				['price'] = price
			}
			local payload = dkjson.encode(payload_table)
			
            cclog('## sku : ' .. sku)
            cclog('## payload : ' .. payload)

			local function cb_func(ret, info)
				cclog('Xsolla Payment', ret, info)

				if (ret == 'success') then
                    cclog('## 결제 성공')                    
					local info_json = dkjson.decode(info)
                    orderId = info_json and info_json['orderId']
                    co.NEXT()

                elseif (ret == 'fail') then
                    cclog('## 결제 실패')
                    error_info = info
                    co.ESCAPE()

                elseif (ret == 'cancel') then
                    cclog('## 결제 취소')
                    error_msg = Str('결제를 취소하였습니다.')
                    co.ESCAPE()

                else
                    cclog('## 결제 결과 (예외) : ' .. ret)
                    error_info = info
                    co.ESCAPE()
                end
				
				HideLoading("")
			end
			PerpleSDK:xsollaOpenPaymentUI(payload, cb_func)

            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#3. 영수증 확인 & 상품 지급')
        do -- 영수증 확인, 상품 지급
            co:work()
            local function finish_cb(ret)
                cclog('#### ret : ')
                ccdump(ret)

				local msg = Str('결제에 성공하였습니다.')
				MakeSimplePopup(POPUP_TYPE.OK, msg, function()
						cb_func(ret)
						co.NEXT()
					end)
            end

            local function fail_cb(ret)
                ccdump(ret)
                error_msg = Str('영수증 확인에 실패하였습니다.')
                co.ESCAPE()
            end

            
            -- 특정 리턴값 처리
            local function response_status_cb(ret)
                -- -3161 : already use receipt, -1161 : not exist receipt
                if (ret['status'] == -3161) or (ret['status'] == -1161) then
                    cclog('#### ret : ')
                    ccdump(ret)
                    cb_func(ret)
                    co.NEXT()
                    return true
                end
            end

            local iswin = false
            g_shopDataNew:request_checkReceiptValidation(struct_product, validation_key, sku, product_id, price, iswin, finish_cb, fail_cb, response_status_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        co:close()
    end


    Coroutine(coroutine_function, '#PAYMENT_XSOLLA 코루틴')
end 

-------------------------------------
-- function payment_win
-- @brief 결제 상품 처리
-------------------------------------
function PaymentHelper.payment_win(struct_product, cb_func)

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        -- 중간에 에러가 발생했을 경우 처리 (코루틴이 종료되는 시점에 무조건 호출되는 함수)
        local error_msg = nil
        local function coroutine_finidh_cb()
            if error_msg then
                MakeSimplePopup(POPUP_TYPE.OK, error_msg)
            end
        end
        co:setCloseCB(coroutine_finidh_cb)

        local market, os = GetMarketAndOS()
        local sku = struct_product['sku']
        local product_id = struct_product['product_id']
        local price = struct_product['price'] -- struct_product:getPrice()
        local validation_key = nil
        local orderId = nil

        --------------------------------------------------------
        cclog('#1. validation_key 발행')
        do -- purchase token(validation_key) 발행
            co:work()
            local function cb_func(ret)
                validation_key = ret['validation_key']
                if (validation_key ~= nil) and (validation_key ~= '') then
                    co.NEXT() 
                else
                    local msg = '일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'
                    MakeSimplePopup(POPUP_TYPE.OK,  msg)
                    co.ESCAPE()
                end     
            end
            local function fail_cb(ret)
                error_msg = Str('결제를 준비하는 과정에서 알수없는 오류가 발생하였습니다.')
                co.ESCAPE()
            end
            g_shopDataNew:request_purchaseToken(market, sku, product_id, price, cb_func, fail_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#2. 영수증 확인 & 상품 지급')
        do -- 영수증 확인, 상품 지급
            co:work()
            local function finish_cb(ret)
                cclog('#### ret : ')
                ccdump(ret)

				local msg = Str('결제에 성공하였습니다.')
				MakeSimplePopup(POPUP_TYPE.OK, msg, function()
						cb_func(ret)
						co.NEXT()
					end)
            end

            local function fail_cb(ret)
                ccdump(ret)
                error_msg = Str('영수증 확인에 실패하였습니다.')
                co.ESCAPE()
            end
            local iswin = true
            g_shopDataNew:request_checkReceiptValidation(struct_product, validation_key, sku, product_id, price, iswin, finish_cb, fail_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------
        co:close()
    end


    Coroutine(coroutine_function, '#PAYMENT 코루틴')
end

-------------------------------------
-- function handlingMissingPayments
-- @brief 누락된 결제 상품 처리
-------------------------------------
function PaymentHelper.handlingMissingPayments(l_payload, result_cb, error_cb)
    if (l_payload == nil or table.count(l_payload) == 0) then
        -- @mskim 2020.11.18, 1.2.7 앱 업데이트 후에는 error_cb를 전달하지 않는 케이스가 있음
        if (error_cb) then
            error_cb()
        end
        return
    end

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        -- 중간에 에러가 발생했을 경우 처리 (코루틴이 종료되는 시점에 무조건 호출되는 함수)
        local error_msg = nil
        local function coroutine_finidh_cb()
            if error_msg then
                MakeSimplePopup(POPUP_TYPE.OK, error_msg)
            end
            -- @mskim 2020.11.18, 1.2.7 앱 업데이트 후에는 error_cb를 전달하지 않는 케이스가 있음
            if (error_cb) then
                error_cb()
            end
        end
        co:setCloseCB(coroutine_finidh_cb)

        for i,t_payment in ipairs(l_payload) do

            cclog('## t_payment ' .. i)
            ccdump(t_payment)

            -- payload
            local payload = dkjson.decode(t_payment['payload']) or {}
            cclog('## payload : ')
            ccdump(payload)
            local sku = payload['sku']
            local product_id = payload['product_id']
            local price = payload['price']
            local validation_key = payload['validation_key']

            -- orderId
            local orderId = t_payment['orderId']

            if sku then
                --------------------------------------------------------
                cclog('#1. 영수증 확인 & 상품 지급')
                do -- 영수증 확인, 상품 지급
                    co:work()

                    -- ret : added_item .. 일반 상품 수령 response
                    local function finish_cb(ret)
                        cclog('#### handlingMissingPayments ret : ')
                    
                        if result_cb then
                            result_cb(ret)
                        end

                        ccdump(ret)
                        co.NEXT()
                    end

                    local function fail_cb(ret)
                        ccdump(ret)
                        error_msg = Str('영수증 확인에 실패하였습니다.')
                        co.ESCAPE()
                    end

                    -- 특정 리턴값 처리
                    local function response_status_cb(ret)
                        -- -3161 : already use receipt, -1161 : not exist receipt
                        if (ret['status'] == -3161) or (ret['status'] == -1161) then
                            cclog('#### ret : ')
                    
                            if result_cb then
                                result_cb(ret)
                            end

                            ccdump(ret)
                            co.NEXT()
                            return true
                        end
                    end
                    

                    local iswin = false
                    g_shopDataNew:request_checkReceiptValidation(nil, validation_key, sku, product_id, price, iswin, finish_cb, fail_cb, response_status_cb)
                    if co:waitWork() then return end
                end
                --------------------------------------------------------

                --------------------------------------------------------
                cclog('#2. 결제 확인')
                do
                    -- 구매 완료 성공 콜백을 받은 후 게임 서버에서 정상적으로 상품 지급을 한 다음 다시 이 함수를 호출해서 구매 프로세스를 완료시킴
                    -- 이 함수를 호출하면 구글 결제 인벤토리에서 해당 Purchase 를 Consume 처리함.
                    if orderId then
                        PerpleSDK:billingConfirm(orderId)

                        -- @sgkim 2019.09.25
                        -- PerpleSDK:billingConfirm 함수에서 다른 쓰레드를 통해서 코드가 동작함
                        -- 이 상황에서 즉시 다음 상품에 대한 코드가 동작하면 크래시가 나는 경우가 있어서
                        -- 불가피하게 3초 딜레이를 주도록 함
                        co:waitTime(3)
                    end
                end
                --------------------------------------------------------
            end
        end

        co:close()
    end


    Coroutine(coroutine_function, '#handlingMissingPayments 코루틴')
end

-------------------------------------
-- function handlingMissingPayments_onestore
-- @brief 누락된 결제 상품 처리
-------------------------------------
function PaymentHelper.handlingMissingPayments_onestore(l_payload, cb_func, finish_cb)
    if (l_payload == nil or #l_payload == 0) then
        finish_cb()
        return
    end

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        -- 중간에 에러가 발생했을 경우 처리 (코루틴이 종료되는 시점에 무조건 호출되는 함수)
        local error_msg = nil
        local function coroutine_finidh_cb()
            if error_msg then
                MakeSimplePopup(POPUP_TYPE.OK, error_msg)
            end
            finish_cb()
        end
        co:setCloseCB(coroutine_finidh_cb)

        for i,t_payment in ipairs(l_payload) do

            cclog('## t_payment ' .. i)
            ccdump(t_payment)

            -- payload
            local payload = dkjson.decode(t_payment['payload']) or {}
            cclog('## payload : ')
            ccdump(payload)
            local sku = t_payment['productId']--payload['sku'] -- 원스토어(ONEstore)에서는 t_payment에서 productId에 Ia-App ID. 즉, sku값이 넘어온다.
            local product_id = payload['product_id']
            local price = nil--payload['price'] -- 원스토어(ONEstore)에서는 payload의 길이 문제로 price값을 가지고 있지 않으며, 이 값은 현재 사용되지 않는다.
            local validation_key = payload['validation_key']

            -- orderId
            local orderId = t_payment['orderId']

            if sku then
                --------------------------------------------------------
                cclog('#1. 영수증 확인 & 상품 지급')
                do -- 영수증 확인, 상품 지급
                    co:work()
                    local function finish_cb(ret)
                        cclog('#### ret : ')
                    
                        if cb_func then
                            cb_func(ret)
                        end

                        ccdump(ret)
                        co.NEXT()
                    end

                    local function fail_cb(ret)
                        ccdump(ret)
                        error_msg = Str('영수증 확인에 실패하였습니다.')
                        co.ESCAPE()
                    end

                    -- 특정 리턴값 처리
                    local function response_status_cb(ret)
                        -- -3161 : already use receipt, -1161 : not exist receipt
                        if (ret['status'] == -3161) or (ret['status'] == -1161) then
                            cclog('#### ret : ')
                    
                            if cb_func then
                                cb_func(ret)
                            end

                            ccdump(ret)
                            co.NEXT()
                            return true
                        end
                    end
                    

                    local iswin = false
                    g_shopDataNew:request_checkReceiptValidation(nil, validation_key, sku, product_id, price, iswin, finish_cb, fail_cb, response_status_cb)
                    if co:waitWork() then return end
                end
                --------------------------------------------------------

                --------------------------------------------------------
                cclog('#2. 결제 확인')
                do
                    -- 구매 완료 성공 콜백을 받은 후 게임 서버에서 정상적으로 상품 지급을 한 다음 다시 이 함수를 호출해서 구매 프로세스를 완료시킴
                    -- 이 함수를 호출하면 원스토어 결제 목록에서 해당 Purchase 를 Consume 처리함.
                    if orderId then
                        if PerpleSDK.onestoreConsumeByOrderid then
                            local function consume_cb(ret, info)
                                co.NEXT()
                            end
                            PerpleSDK:onestoreConsumeByOrderid(orderId, consume_cb)
                            if co:waitWork() then return end
                        end
                    end
                end
                --------------------------------------------------------
            end
        end

        co:close()
    end


    Coroutine(coroutine_function, '#handlingMissingPayments 코루틴')
end

