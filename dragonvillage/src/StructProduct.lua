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
		xsolla_price_dollar = 'number',
        purchase_point = 'number',

        product_content = 'string',
        mail_content = 'string',
		bundle = 'number',
        icon = 'string',
        max_buy_count = 'number',
        max_buy_term = 'string',
        max_buy_display = 'string',
        badge = 'string',
        lock = 'number',
        token = 'string',

		-- package 용
		banner_res = 'string',
		package_res = 'string',
		package_frame_type = 'number',

        -- shop ui pos, scale
        ui_pos = 'number',
        ui_scale = 'number',

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
function StructProduct:getEndDateStr(new_line)
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

    if (end_time == nil) then
        return ''
    end
    local time = (end_time - cur_time)

    local msg
    if (new_line) then
        msg = Str('판매 종료까지\n{1} 남음', datetime.makeTimeDesc(time, false))
    else
        msg = Str('판매 종료까지 {1} 남음', datetime.makeTimeDesc(time, false))
    end

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
-- function setUIPos
-------------------------------------
function StructProduct:setUIPos(pos)
    self['ui_pos'] = pos
end

-------------------------------------
-- function getUIPos
-------------------------------------
function StructProduct:getUIPos()
    return self['ui_pos']
end

-------------------------------------
-- function setUIScale
-------------------------------------
function StructProduct:setUIScale(scale)
    self['ui_scale'] = scale
end

-------------------------------------
-- function getUIScale
-------------------------------------
function StructProduct:getUIScale()
    return self['ui_scale']
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

    -- 내부적으로 월간 상품이어도 유저에게 계정당 구매 제한으로 보였으면 하는 경우가 있다.
    -- 유저에게 상품을 노출하는 기준은 내부적인 구매 제한보다 display기준을 따르는 것이 맞다.
    -- max_buy_diplay값을 우선하도록 변경한다.
    if (self['max_buy_display'] and (self['max_buy_display'] ~= '')) then
        max_buy_term = self['max_buy_display']
    end

    if (max_buy_term == 'weekly') then
        return true

    elseif (max_buy_term == 'monthly') then
        return true

    elseif (buy_term == 'daily') then
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
    local buy_display = self['max_buy_display']

    -- 구매 제한 표시 값이 존재하는 경우 그 값으로 치환
    if (buy_display) and (buy_display ~= '') then
        buy_term = buy_display
    end

	local term_str
	if (buy_term == 'weekly') then
		term_str = Str('주간')
	elseif (buy_term == 'monthly') then
		term_str = Str('월간')
    elseif (buy_term == 'daily') then
		term_str = Str('일일')
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
        if (price_type == 'money') then
			local sku = self['sku']
			local dicMarketPrice = g_shopDataNew.m_dicMarketPrice

			-- 엑솔라 가격
			if (PerpleSdkManager:xsollaIsAvailable()) then
				return '$' .. comma_value(self['xsolla_price_dollar'])
            -- 원스토어 가격
            elseif (PerpleSdkManager:onestoreIsAvailable()) then
                if (sku) and (dicMarketPrice[sku]) then
                    return '￦' .. comma_value(dicMarketPrice[sku])
                else
                    return '$ ' .. comma_value(self['price_dollar'])
                end
            -- 마켓에서 받은 가격이 있다면 표시
            elseif (sku) and (dicMarketPrice[sku]) then
                return dicMarketPrice[sku]
            -- 없다면 기본 달러 표시
            else
                -- 원스토어 빌드에서는 원화로 표시
                if (PerpleSdkManager:onestoreIsAvailable()) then
                    return '￦ ' .. comma_value(self:getPrice())
                else
                    return '$ ' .. comma_value(self['price_dollar'])
                    --return '￦ ' .. comma_value(self:getPrice())
                end
            end

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
		local path = string.format('ui/typo/ko/badge_%s.png', badge)
		path = 'res/' .. Translate:getTranslatedPath(path)

        local icon, is_exist = IconHelper:getIcon(path)
        if (is_exist) then
            return icon
        end
    end

	return nil
end

-------------------------------------
-- function getBonusRate
-- @breif 20190109 풀팝업 다이아 보너스율 표기에만 사용
-- @brief 보너스율 정보가 테이블에 없어서 table_shop_cash의 badge에서 얻어옴 ex) bonus_30 의 숫자만 추출
-- @warring 확실한 방법은 아니기 때문에 정확히 보너스율 얻을 수 있는 방법 필요
-------------------------------------
function StructProduct:getBonusRate()
	local badge = self['badge']
    local badge_value

    -- 뱃지 텍스트에서 숫자 추출
    if badge and (badge ~= '') then
        badge_value = string.match(badge, '%d+')
    end

    if (badge_value) then
        return badge_value
    else
    -- 뱃지에 숫자가 없다면 임의의 값 00을 반환(오류 방지)
        return '00'
    end
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
function StructProduct:buy(cb_func, sub_msg, no_popup)
    if (not self:isBuyable()) then
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

                    -- 로비 노티 갱신
			        g_highlightData:setDirty(true)
                end
                g_shopDataNew:request_shopInfo(info_refresh_cb)
            else
                ret['need_refresh'] = false
                if (cb_func) then
				    cb_func(ret)
			    end

                -- 로비 노티 갱신
			    g_highlightData:setDirty(true)
            end
        end

        -- 마켓에서 구매하는 상품
        if self:isPaymentProduct() then
            if isWin32() then
                self:payment_win(finish_cb)
			else
				-- 엑솔라 or 원스토어 or 구글
				if (PerpleSdkManager:xsollaIsAvailable()) then
					self:payment_xsolla(finish_cb)
				elseif (PerpleSdkManager:onestoreIsAvailable()) then
                    self:payment_onestore(finish_cb)
                else
					self:payment(finish_cb)
				end
            end
        else
            g_shopDataNew:request_buy(self, count, finish_cb)
        end
	end

    -- 2018-11-23 구매 팝업 안뜨는 옵션 추가
    -- 여러개 고르는 기능을 제공하는 팝업이 없으니 해당 옵션은 묶음 구매 아닌 상품만 이용
    if (no_popup) then
        ok_cb()
        return
    end

	-- 묶음 구매
	if (self:canBuyBundle()) then
		local ui = UI_BundlePopup(self, ok_cb)

	else
		-- 아이템 이름 두줄인 경우 한줄로 변경
		local name = string.gsub(self['t_name'], '\n', '')
		local msg = Str('{@item_name}"{1}"\n{@default}구매하시겠습니까?', Str(name))
        if sub_msg then
            msg = (msg .. '\n{@sub_msg}' .. sub_msg)
        end

		local price = (self['price_type'] == 'money') and self:getPriceStr() or self:getPrice()
		local ui = MakeSimplePopup_Confirm(self['price_type'], price, msg, ok_cb, nil)

		local platform_id = g_localData:get('local', 'platform_id') or 'firebase'
		if (platform_id == 'firebase') then
			if ui and ui.vars and ui.vars['subLabel'] then
				ui.vars['subLabel']:setString('{@sub_msg}' .. Str('(게스트 계정으로 구매를 하면 게임 삭제, 기기변동,\n휴대폰 초기화시 구매 데이터가 사라질 수 있습니다.)'))
			    ui.vars['guestBtn']:setVisible(true)
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
-- function isBuyable
-------------------------------------
function StructProduct:isBuyable()
	-- 구매 횟수 확인
	if (not self:checkMaxBuyCount()) then
		UIManager:toastNotificationRed(Str('구매 횟수를 초과했습니다.'))
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
        -- 만원의 행복처럼 특수한 상품은 item_id가 오지 않음
        if (v['item_id'] == nil) then
            return false
        end

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
    -- 구매 제한이 있다면 대체상품이 있더라도 출력으로 변경
--    if (self:getDependency()) then
--        return ''
--    end

    -- 구매 제한 횟수가 설정되지 않으면 return
    local max_buy_cnt = tonumber(self['max_buy_count'])
    if (not max_buy_cnt) or (max_buy_cnt <= 0) then
        return ''
    end

	local max_buy_term = self['max_buy_term']
    local max_buy_display = self['max_buy_display']
    -- 구매 제한 표시 값이 존재하는 경우 그 값으로 치환
    if (max_buy_display) and (max_buy_display ~= '') then
        max_buy_term = max_buy_display
    end

    local product_id = self['product_id']
    local buy_cnt = g_shopDataNew:getBuyCount(product_id)    

    local str = ''
    if (max_buy_term == 'permanent') then
        str = Str('구매 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)

    elseif (max_buy_term == 'monthly') then
        str = Str('월간 구매 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)

    elseif (max_buy_term == 'weekly') then
        str = Str('주간 구매 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)

    elseif (max_buy_term == 'daily') then
        str = Str('일일 구매 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)

    end

    return str
end

-------------------------------------
-- function getTimeRemainingForEndOfSale
-- @brief 판매 종료까지 남은 시간 (단위:초)
-------------------------------------
function StructProduct:getTimeRemainingForEndOfSale()
    if (not self.m_endDate) then
        return 0
    end

    if (type(self.m_endDate) ~= 'string') then
        return 0
    end

    local date_format = 'yyyy-mm-dd HH:MM:SS'
    local parser = pl.Date.Format(date_format)
    if (not parser) then
        return 0
    end
    
    local end_date = parser:parse(self.m_endDate)
    if (not end_date) then
        return 0
    end

    local cur_time =  Timer:getServerTime()
    local end_time = end_date['time']
    if (end_time == nil) then
		return 0
    end

    local time = (end_time - cur_time)
    return time
end

-------------------------------------
-- function checkIsSale
-- @brief 판매중인 상품인지 확인
-- @brief 서버 title 통신에서 판매중인 상품만 던져주고 있긴하지만 end_date까지 검사
-------------------------------------
function StructProduct:checkIsSale()
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
    if (end_time == nil) then
		return false
    end

    local time = (end_time - cur_time)
    if (time < 0) then
        return false
    end

    return true
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

-------------------------------------
-- function getProductName
-------------------------------------
function StructProduct:getProductName()
    return self['t_name']
end





-- payment helper

-------------------------------------
-- function payment
-- @brief 결제 상품 처리
-------------------------------------
function StructProduct:payment(cb_func)
	PaymentHelper.payment(self, cb_func)
end

-------------------------------------
-- function payment_xsolla
-- @brief 결제 상품 처리 (엑솔라)
-------------------------------------
function StructProduct:payment_xsolla(cb_func)
	PaymentHelper.payment_xsolla(self, cb_func)
end

-------------------------------------
-- function payment_onestore
-- @brief 결제 상품 처리 (원스토어)
-------------------------------------
function StructProduct:payment_onestore(cb_func)
    PaymentHelper.payment_onestore(self, cb_func)
end

-------------------------------------
-- function payment_win
-- @brief 결제 상품 처리 (window test)
-------------------------------------
function StructProduct:payment_win(cb_func)
	PaymentHelper.payment_win(self, cb_func)
end

-------------------------------------
-- function handlingMissingPayments
-- @brief 누락된 결제 상품 처리
-------------------------------------
function StructProduct:handlingMissingPayments(l_payload, cb_func, finish_cb)
    PaymentHelper.handlingMissingPayments(l_payload, cb_func, finish_cb)
end

