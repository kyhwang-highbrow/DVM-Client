local PARENT = Structure

-------------------------------------
-- class StructProduct
-------------------------------------
StructProduct = class(PARENT, {
        product_id = 'number',
        t_name = 'string',
        t_desc = 'string',

        price_type = 'string',
        price = 'number',
        price_dollar = 'number',
        product_content = 'string',
        mail_content = 'string',
		bundle = 'number',
        icon = 'string',
        max_buy_count = 'number',
        max_buy_term = 'string',
        badge = 'string',
        lock = 'number',

		-- package 용
		banner_res = 'string',
		package_res = 'string',
		package_frame_type = 'number',

        -- subscription (구독 상품)
        subscription = 'string',

        m_tabCategory = 'string',
        m_startDate = 'pl.Date',
        m_endDate = 'pl.Date',
        m_dependency = 'product_id',
        m_uiPriority = 'number',

        -- Google 결제 시 상품 ID
        sku = 'stock keeping unit', -- product id
    })

local THIS = StructProduct

-------------------------------------
-- function init
-------------------------------------
function StructProduct:init(data)
    if (self.price_dollar == nil) then
        self.price_dollar = 0
    end  

    if (self.m_uiPriority == nil) then
        self.m_uiPriority = 0
    end

    if (self.mail_content == nil) then
        self.mail_content = ''
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructProduct:getClassName()
    return 'StructProduct'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructProduct:getThis()
    return THIS
end

-------------------------------------
-- function setTabCategory
-------------------------------------
function StructProduct:setTabCategory(tab_category)
    self.m_tabCategory = tab_category
end

-------------------------------------
-- function getTabCategory
-------------------------------------
function StructProduct:getTabCategory()
    return self.m_tabCategory
end

-------------------------------------
-- function setStartDate
-------------------------------------
function StructProduct:setStartDate(date)
    self.m_startDate = (date ~= '') and date or nil
end

-------------------------------------
-- function setEndDate
-------------------------------------
function StructProduct:setEndDate(date)
    self.m_endDate = (date ~= '') and date or nil
end

-------------------------------------
-- function getEndDateStr
-------------------------------------
function StructProduct:getEndDateStr()
    if (not self.m_endDate) then
        return ''
    end

    if (type(self.m_endDate) ~= 'string') then
        return ''
    end

    local date_format = 'yyyy-mm-dd HH:MM:SS'
    local parser = pl.Date.Format(date_format)
    if (not parser) then
        return ''
    end

    local end_date = parser:parse(self.m_endDate)
    if (not end_date) then
        return ''
    end

    local cur_time =  Timer:getServerTime()
    local end_time = end_date['time']
    local time = (end_time - cur_time)
    local msg = Str('판매 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))

    return msg
end

-------------------------------------
-- function setDependency
-------------------------------------
function StructProduct:setDependency(product_id)
    if (product_id == '') then
        product_id = nil
    end
    self.m_dependency = product_id
end

-------------------------------------
-- function getDependency
-------------------------------------
function StructProduct:getDependency()
    return self.m_dependency
end

-------------------------------------
-- function setUIPriority
-------------------------------------
function StructProduct:setUIPriority(ui_priority)
    self.m_uiPriority = ui_priority
end

-------------------------------------
-- function getUIPriority
-------------------------------------
function StructProduct:getUIPriority()
    return self.m_uiPriority
end

-------------------------------------
-- function isItBuyable
-------------------------------------
function StructProduct:isItBuyable()
    -- 숫자가 아니라면 구매 횟수 제한이 없는 것
	if (not isNumber(self['max_buy_count'])) then
		return true
	end

    -- 구매 제한 횟수 체크 (판매 시간은 상품 리스트 구성 시 확인한다고 가정)
    local buy_cnt = g_shopDataNew:getBuyCount(self['product_id'])
    return (buy_cnt < self['max_buy_count'])
end

-------------------------------------
-- function isDisplayed
-- @brief 상품 노출 여부
-------------------------------------
function StructProduct:isDisplayed()
    local max_buy_term = self['max_buy_term']

    if (max_buy_term == 'weekly') then
        return true

    elseif (max_buy_term == 'monthly') then
        return true
   
    elseif (max_buy_term == 'permanent') then
        return self:isItBuyable()

    else
        return true
    end
end

-------------------------------------
-- function needRenewAfterBuy
-- @brief 구매 후에 상점 정보 갱신이 필요한지 여부
-------------------------------------
function StructProduct:needRenewAfterBuy()

	-- 2017-08-26 sgkim 이 함수가 불려지는 케이스는 해당 상품을 구매 후이므로
    -- 구매제한이 걸려있는 상품이라면 무조건 갱신하도록 변경함
	
    local max_buy_count = tonumber(self['max_buy_count'])
    if (max_buy_count and (0 < max_buy_count)) then
        -- 구매 횟수 제한이 지정되어 있을 경우
        return true
    end

    return false

    --[[
    -- 숫자가 아니라면 구매 횟수 제한이 없는 것
	if (not isNumber(self['max_buy_count'])) then
		return false
	end

    -- 구매 제한 횟수 체크 (판매 시간은 상품 리스트 구성 시 확인한다고 가정)
    local buy_cnt = g_shopDataNew:getBuyCount(self['product_id'])
    return (buy_cnt < self['max_buy_count'] + 1)
    --]]
end


-------------------------------------
-- function getDesc
-------------------------------------
function StructProduct:getDesc()

    -- 고대주화 관련 상품 내용을 출력하지 않음
    if (self['price_type'] == 'ancient') then
        return ''
    end

    -- 테이블에 blank라고 입력되면 내용을 출력하지 않음
    if (self['t_desc'] == 'blank') then
        return ''
    end

	-- t_desc가 있다면 출력
    if self['t_desc'] and (self['t_desc'] ~= '') and (self['t_desc'] ~= ' ') then
        return Str(self['t_desc'])
    end

	-- 상품 구매 제한이 있고 t_desc가 없다면 구매횟수 출력
	local max_buy_cnt = self['max_buy_count']
	if (isNumber(max_buy_cnt)) then
		return self:getBuyCountDesc()
	end
	
	-- 상품 구매 제한이 없고 t_desc도 없다면 첫번째 아이템 설명 출력...
	do
		local l_item_list = ServerData_Item:parsePackageItemStr(self['product_content'])
		if (not l_item_list) or (not l_item_list[1]) then
			l_item_list = ServerData_Item:parsePackageItemStr(self['mail_content'])
		end

        if (not l_item_list) then
            return ''
        end

		local first_item = l_item_list[1]
		if (not first_item) or (not first_item['item_id']) then
			return ''
		end

		-- 첫 번째 아이템의 설명을 사용
		local table_item = TableItem()
		local item_id = first_item['item_id']
		local t_desc = table_item:getValue(item_id, 't_desc')
		return Str(t_desc)
	end
end


-------------------------------------
-- function getBuyCountDesc
-------------------------------------
function StructProduct:getBuyCountDesc()
	local max_buy_cnt = self['max_buy_count']
	local buy_cnt = g_shopDataNew:getBuyCount(self['product_id'])
	local cnt_str = Str('구매 횟수 {1} / {2}', buy_cnt, max_buy_cnt)

	-- 구매 제한 term 체크
	local buy_term = self['max_buy_term']
	local term_str
	if (buy_term == 'weekly') then
		term_str = Str('주간')
	elseif (buy_term == 'monthly') then
		term_str = Str('월간')
	end

	-- 구메 제한 str 있으면 추가
	if (term_str) then
		return term_str .. ' ' .. cnt_str
	end

	return cnt_str
end

-------------------------------------
-- function makeProductIcon
-------------------------------------
function StructProduct:makeProductIcon()
    if self['icon'] and (self['icon'] ~= '') then
        local icon = IconHelper:getIcon(self['icon'])
        if (icon) then
            return icon
        else
            error(self['icon'] .. ' 없음')
        end
    end

    local l_item_list = ServerData_Item:parsePackageItemStr(self['product_content'])
    if (not l_item_list) or (not l_item_list[1]) then
        l_item_list = ServerData_Item:parsePackageItemStr(self['mail_content'])
    end

    if (not l_item_list) then
        return nil
    end

    local first_item = l_item_list[1]
    if (not first_item) or (not first_item['item_id']) then
        return nil
    end

    -- 첫 번째 아이템의 설명을 사용
    local table_item = TableItem()
    local item_id = first_item['item_id']
    return IconHelper:getItemIcon(item_id)
end

-------------------------------------
-- function makePackageSprite
-------------------------------------
function StructProduct:makePackageSprite()
    local package_res = self['banner_res']
    if package_res and (package_res ~= '') then
        local icon = IconHelper:getIcon(package_res)
        if (icon) then
            return icon
        else
            error(package_res .. ' 없음')
        end
    end
end

-------------------------------------
-- function makePriceIcon
-------------------------------------
function StructProduct:makePriceIcon()
    local price_type = self['price_type']

    if (price_type == 'advertising') then
        return nil
    end

    if (price_type == 'money') then
        if isIos() then
            price_type = 'usd'
        else
            price_type = 'krw'
        end
    end

    return IconHelper:getPriceIcon(price_type)
end

-------------------------------------
-- function getPriceStr
-------------------------------------
function StructProduct:getPriceStr()
    local price_type = self['price_type']

    if (price_type == 'advertising') then
        return Str('광고 보기')
    else
        local dicMarketPrice = g_shopDataNew.m_dicMarketPrice
        local sku = self['sku']

        -- 마켓에서 받은 가격이 있다면 표시
        if (sku) and (dicMarketPrice[sku]) then
            return dicMarketPrice[sku]
        else
            return comma_value(self:getPrice())
        end
    end
end

-------------------------------------
-- function makeBadgeIcon
-------------------------------------
function StructProduct:makeBadgeIcon()
	local badge = self['badge']

    if badge and (badge ~= '') then
		local path = string.format('res/ui/typo/ko/badge_%s.png', badge)
		path = Translate:getTranslatedPath(path)

        local icon, is_exist = IconHelper:getIcon(path)
        if (is_exist) then
            return icon
        end
    end

	return nil
end

-------------------------------------
-- function isPaymentProduct
-------------------------------------
function StructProduct:isPaymentProduct()
    if self['sku'] and (self['sku'] ~= '') then
        return true
    end

    return false
end

-------------------------------------
-- function isPackage
-------------------------------------
function StructProduct:isPackage()
	return (self:getTabCategory() == 'package')
end

-------------------------------------
-- function buy
-------------------------------------
function StructProduct:buy(cb_func)
    if (not self:tryBuy()) then
        return
    end

	-- 묶음 구매의 경우 count에 구매 수량을 넣어주고
	-- 단일 구매의 경우 nil로 처리하여 request_buy 내부에서 1로 치환
	local function ok_cb(count)
        local function finish_cb(ret)

            -- 상품 리스트 갱신이 필요할 경우
            if (g_shopDataNew.m_bDirty == true) then
                ret['need_refresh'] = true
                local function info_refresh_cb()
                    if (cb_func) then
				        cb_func(ret)
			        end
                end
                g_shopDataNew:request_shopInfo(info_refresh_cb)
            else
                ret['need_refresh'] = false
                if (cb_func) then
				    cb_func(ret)
			    end
            end
        end

        -- 마켓에서 구매하는 상품
        if self:isPaymentProduct() then
            if isWin32() then
                self:payment_win(finish_cb)
            else
                self:payment(finish_cb)
            end
        else
            g_shopDataNew:request_buy(self, count, finish_cb)
        end
	end

	-- 묶음 구매
	if (self:canBuyBundle()) then
		local ui = UI_BundlePopup(self, ok_cb)

	else
		-- 아이템 이름 두줄인 경우 한줄로 변경
		local name = string.gsub(self['t_name'], '\n', '')
		local msg = Str('{@item_name}"{1}"\n{@default}구매하시겠습니까?', Str(name))

		local price = self:getPrice()
		local ui = MakeSimplePopup_Confirm(self['price_type'], price, msg, ok_cb, nil)

		local platform_id = g_localData:get('local', 'platform_id') or 'firebase'
		if (platform_id == 'firebase') then
			if ui and ui.vars and ui.vars['subLabel'] then
				ui.vars['subLabel']:setString(Str('(게스트 계정으로 구매를 하면 게임 삭제, 기기변동,\n휴대폰 초기화시 구매 데이터가 사라질 수 있습니다.)'))
			end
		end
	end
end

-------------------------------------
-- function canBuyBundle
-- @brief 묶음 구매 가능 여부
-------------------------------------
function StructProduct:canBuyBundle()
	return (self['bundle'] == 1)
end

-------------------------------------
-- function buyBundle
-------------------------------------
function StructProduct:buyBundle(cb_func)

end

-------------------------------------
-- function payment
-- @brief 결제 상품 처리
-------------------------------------
function StructProduct:payment(cb_func)

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

        local sku = self['sku']
        local product_id = self['product_id']
        local price = self:getPrice()
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
                local info_json = dkjson.decode(info)
                local msg = nil

                if info_json then
                    msg = info_json['msg']
                end
                if (ret == 'success') then
                    cclog('## 결제 성공')                    
                    orderId = info_json and info_json['orderId']
                    co.NEXT()

                elseif (ret == 'fail') then
                    cclog('## 결제 실패')
                    error_msg = Str('결제에 실패하였습니다.')
                    if msg then
                        error_msg = error_msg .. '\n' .. msg
                    end
                    co.ESCAPE()

                elseif (ret == 'cancel') then
                    cclog('## 결제 취소')
                    error_msg = Str('결제를 취소하였습니다.')
                    co.ESCAPE()

                else
                    cclog('## 결제 결과 (예외) : ' .. ret)
                    error_msg = Str('알수없는 이유로 결제에 실패하였습니다.')
                    if msg then
                        error_msg = error_msg .. '\n' .. msg
                    end
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
            g_shopDataNew:request_checkReceiptValidation(self, validation_key, sku, product_id, price, iswin, finish_cb, fail_cb, response_status_cb)
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
-- function payment_win
-- @brief 결제 상품 처리
-------------------------------------
function StructProduct:payment_win(cb_func)

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

        local sku = self['sku']
        local product_id = self['product_id']
        local price = self:getPrice()
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
            g_shopDataNew:request_checkReceiptValidation(self, validation_key, sku, product_id, price, iswin, finish_cb, fail_cb)
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
function StructProduct:handlingMissingPayments(l_payload, cb_func, finish_cb)
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
-- function tryBuy
-------------------------------------
function StructProduct:tryBuy()
	-- 구매 횟수 확인
	if (not self:checkMaxBuyCount()) then
		return false
	end

	-- 재화 확인
	if (not self:checkPrice()) then
		return false
	end

    -- 구매 가능한 상태
    return true
end 

-------------------------------------
-- function checkMaxBuyCount
-------------------------------------
function StructProduct:checkMaxBuyCount()
	local max_buy_cnt = self['max_buy_count']

	-- 숫자가 아니라면 구매 횟수 제한이 없는 것
	if (not isNumber(max_buy_cnt)) then
		return true
	end
	
	local buy_cnt = g_shopDataNew:getBuyCount(self['product_id'])
	
	-- 구매 횟수 초과한 경우
	if (buy_cnt >= max_buy_cnt) then
		UIManager:toastNotificationRed(Str('구매 횟수를 초과했습니다.'))
		return false	
	end

	return true
end

-------------------------------------
-- function checkPrice
-------------------------------------
function StructProduct:checkPrice()
	local price_type = self['price_type']
    local price = self:getPrice()

    return UIHelper:checkPrice(price_type, price)
end

-------------------------------------
-- function isContain
-------------------------------------
function StructProduct:isContain(item_type)
    local l_item_list_product = ServerData_Item:parsePackageItemStr(self['product_content'])
    local l_item_list_mail = ServerData_Item:parsePackageItemStr(self['mail_content'])

    local l_item_list = table.merge(l_item_list_product, l_item_list_mail)

    local table_item = TableItem()

    local item_id = TableItem:getItemIDFromItemType(item_type) or item_type
    for i,v in ipairs(l_item_list) do
        if (v['item_id'] == item_id) then
            return true
        elseif table_item:getValue(v['item_id'], 'type') == item_type then
            return true
        end
    end

    return false
end

-------------------------------------
-- function getMaxBuyTermStr
-- @brief 구매 제한 설명 텍스트
-------------------------------------
function StructProduct:getMaxBuyTermStr()
    -- 구매 제한이 있지만 대체상품이 있는 경우 출력하지 않음
    if (self:getDependency()) then
        return ''
    end

    -- 구매 제한 횟수가 설정되지 않으면 return
    local max_buy_cnt = tonumber(self['max_buy_count'])
    if (not max_buy_cnt) or (max_buy_cnt <= 0) then
        return ''
    end

	local max_buy_term = self['max_buy_term']
    local product_id = self['product_id']
    local buy_cnt = g_shopDataNew:getBuyCount(product_id)    

    local str = ''
    if (max_buy_term == 'permanent') then
        str = Str('구매제한 {1}/{2}', buy_cnt, max_buy_cnt)

    elseif (max_buy_term == 'monthly') then
        str = Str('월간 구매제한 {1}/{2}', buy_cnt, max_buy_cnt)

    elseif (max_buy_term == 'weekly') then
        str = Str('주간 구매제한 {1}/{2}', buy_cnt, max_buy_cnt)

    end

    return str
end

-------------------------------------
-- function isBuyAll
-- @brief 구매 제한 해당 여부
-------------------------------------
function StructProduct:isBuyAll()
	local max_buy_cnt = tonumber(self['max_buy_count'])
	if (not max_buy_cnt) or (max_buy_cnt <= 0) then
        return false
    end

	local product_id = self['product_id']
    local buy_cnt = g_shopDataNew:getBuyCount(product_id)    

	return (buy_cnt >= max_buy_cnt)
end

-------------------------------------
-- function getMaxBuyCount
-- @brief 
-------------------------------------
function StructProduct:getMaxBuyCount()
	return tonumber(self['max_buy_count'])
end







-- get & set

-------------------------------------
-- function getPrice
-------------------------------------
function StructProduct:getPrice()
    if (self['price_type'] == 'money') then
        return '＄' .. self['price_dollar']
    end
    
    return self['price']
end

-------------------------------------
-- function getPrice
-------------------------------------
function StructProduct:getPriceType()
	return self['price_type']
end

-------------------------------------
-- function getProductID
-------------------------------------
function StructProduct:getProductID()
    return self['product_id']
end