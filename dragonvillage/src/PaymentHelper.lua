PaymentHelper = {}

-------------------------------------
-- function payment
-- @brief 결제 상품 처리
-------------------------------------
function PaymentHelper.payment(struct_product, cb_func)

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
                co.NEXT()
            end
            local function fail_cb(ret)
                error_msg = Str('결제를 준비하는 과정에서 알수없는 오류가 발생하였습니다.')
                co.ESCAPE()
            end
            g_shopDataNew:request_purchaseToken(cb_func, fail_cb)
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
                co.NEXT()
            end
            local function fail_cb(ret)
                error_msg = Str('결제를 준비하는 과정에서 알수없는 오류가 발생하였습니다.')
                co.ESCAPE()
            end
            g_shopDataNew:request_purchaseToken(cb_func, fail_cb)
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
                co.NEXT()
            end
            local function fail_cb(ret)
                error_msg = Str('결제를 준비하는 과정에서 알수없는 오류가 발생하였습니다.')
                co.ESCAPE()
            end
            g_shopDataNew:request_purchaseToken(cb_func, fail_cb)
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
                co.NEXT()
            end
            local function fail_cb(ret)
                error_msg = Str('결제를 준비하는 과정에서 알수없는 오류가 발생하였습니다.')
                co.ESCAPE()
            end
            g_shopDataNew:request_purchaseToken(cb_func, fail_cb)
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
function PaymentHelper.handlingMissingPayments(l_payload, cb_func, finish_cb)
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

