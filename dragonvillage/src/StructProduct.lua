-------------------------------------
-- class StructProduct
-------------------------------------
StructProduct = class({
        product_id = 'number',
        t_name = 'string',
        t_desc = 'string',

        price_type = 'string',
        price = 'number',
        price_dollar = 'number',
        product_content = 'string',
        mail_content = 'string',
        icon = 'string',
        max_buy_count = 'number',
        max_buy_term = 'string',

		-- package 용
		banner_res = 'string',
		package_res = 'string',
		package_frame_type = 'number',

        m_tabCategory = 'string',
        m_startDate = 'pl.Date',
        m_endDate = 'pl.Date',
        m_dependency = 'product_id',
        m_uiPriority = 'number',

        -- Google 결제 시 상품 ID
        sku = 'stock keeping unit', -- product id
    })

-------------------------------------
-- function init
-------------------------------------
function StructProduct:init(data)
    self.price_dollar = 0
    self.m_uiPriority = 0
    self.mail_content = ''

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructProduct:applyTableData(data)
    for key,value in pairs(data) do
        self[key] = value
    end
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
    self.m_startDate = date
end

-------------------------------------
-- function setEndDate
-------------------------------------
function StructProduct:setEndDate(date)
    self.m_endDate = date
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
-- function needRenewAfterBuy
-- @brief 구매 후에 상점 정보 갱신이 필요한지 여부
-------------------------------------
function StructProduct:needRenewAfterBuy()
    -- 숫자가 아니라면 구매 횟수 제한이 없는 것
	if (not isNumber(self['max_buy_count'])) then
		return false
	end

    -- 구매 제한 횟수 체크 (판매 시간은 상품 리스트 구성 시 확인한다고 가정)
    local buy_cnt = g_shopDataNew:getBuyCount(self['product_id'])
    return (buy_cnt < self['max_buy_count'] + 1)
end


-------------------------------------
-- function getDesc
-------------------------------------
function StructProduct:getDesc()
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
-- function makeProductIcon
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

    if (price_type == 'money') then
        price_type = 'krw'
    end

    return IconHelper:getPriceIcon(price_type)
end

-------------------------------------
-- function getPriceStr
-------------------------------------
function StructProduct:getPriceStr()
    return comma_value(self['price'])
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
-- function buy
-------------------------------------
function StructProduct:buy(cb_func)
    if (not self:tryBuy()) then
        return
    end

	local function ok_cb()
        local function finish_cb(ret)
            if (cb_func) then
				cb_func(ret)
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
            g_shopDataNew:request_buy(self, finish_cb)
        end
	end

    MakeSimplePopup_Confirm(self['price_type'], self['price'], nil, ok_cb, nil)
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
        local price = self['price']
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
            payload_table['uid'] = g_serverData:get('local', 'uid')
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

                cb_func(ret)
                co.NEXT()
            end

            local function fail_cb(ret)
                ccdump(ret)
                error_msg = Str('영수증 확인에 실패하였습니다.')
                co.ESCAPE()
            end
            local iswin = false
            g_shopDataNew:request_checkReceiptValidation(self, validation_key, sku, product_id, iswin, finish_cb, fail_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#4. 결제 확인')
        do
            -- 구매 완료 성공 콜백을 받은 후 게임 서버에서 정상적으로 상품 지급을 한 다음 다시 이 함수를 호출해서 구매 프로세스를 완료시킴
            -- 이 함수를 호출하면 구글 결제 인벤토리에서 해당 Purchase 를 Consume 처리함.
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
        local price = self['price']
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

                cb_func(ret)
                co.NEXT()
            end

            local function fail_cb(ret)
                ccdump(ret)
                error_msg = Str('영수증 확인에 실패하였습니다.')
                co.ESCAPE()
            end
            local iswin = true
            g_shopDataNew:request_checkReceiptValidation(self, validation_key, sku, product_id, iswin, finish_cb, fail_cb)
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
                    local iswin = false
                    g_shopDataNew:request_checkReceiptValidation(nil, validation_key, sku, product_id, iswin, finish_cb, fail_cb)
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
    local price = self['price']

    if (price_type == 'money') then

    -- 다이아몬드 확인
    elseif (price_type == 'cash') then
        local cash = g_userData:get('cash')
        if (cash < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다이아몬드가 부족합니다.'))
            return false
        end

    -- 자수정 확인
    elseif (price_type == 'amethyst') then
        local amethyst = g_userData:get('amethyst')
        if (amethyst < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('자수정이 부족합니다.'))
            return false
        end

    -- 토파즈 확인
    elseif (price_type == 'topaz') then
        local topaz = g_userData:get('topaz')
        if (topaz < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('토파즈가 부족합니다.'))
            return false
        end

    -- 마일리지 확인
    elseif (price_type == 'mileage') then
        local mileage = g_userData:get('mileage')
        if (mileage < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('마일리지가 부족합니다.'))
            return false
        end

    -- 명예 확인
    elseif (price_type == 'honor') then
        local honor = g_userData:get('honor')
        if (honor < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('명예가 부족합니다.'))
            return false
        end

    -- 캡슐 확인
    elseif (price_type == 'capsule') then
        local capsule = g_userData:get('capsule')
        if (capsule < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('캡슐이 부족합니다.'))
            return false
        end

    -- 골드 확인
    elseif (price_type == 'gold') then
        local gold = g_userData:get('gold')
        if (gold < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('골드가 부족합니다.'))
            return false
        end

    else
        error('price_type : ' .. price_type)
    end

	return true
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