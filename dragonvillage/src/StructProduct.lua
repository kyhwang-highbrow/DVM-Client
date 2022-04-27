local PARENT = Structure

-------------------------------------
-- class StructProduct
-------------------------------------
StructProduct = class(PARENT, {
        product_id = 'number',
        sku = 'string',
        sale_id = 'number',
        t_name = 'string',
        t_desc = 'string',
        use_desc = 'number', -- '' or 1

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
        package_res_2 = 'string',
		package_frame_type = 'number',

        package_class = 'string',

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


        -- 차원문 상점
        medal = 'number', -- item id in table_item

        m_priceItemID = 'number',
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
-- function applyTableData
-------------------------------------
function StructProduct:applyTableData(data)
    PARENT.applyTableData(self, data)

    if (self.price_type ~= 'money') then
        local item_id = TableItem:getItemIDFromItemType(self.price_type)
        self.m_priceItemID = item_id
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
function StructProduct:getEndDateStr(new_line, simple)
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
    elseif (simple) then
        msg = Str('{1} 남음', datetime.makeTimeDesc(time, false))
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
-- function isItOnTime
-- param
-- local server_timestamp = Timer:getServerTime()
-- local date = TimeLib:convertToServerDate(server_timestamp)
-------------------------------------
function StructProduct:isItOnTime()
    --m_startDate = 'pl.Date' = '2021-03-24 00:00:00'
    --m_endDate = 'pl.Date'  = '2021-03-24 00:00:00'
    local start_time = nil
    local end_time = nil
    if self.m_startDate ~= nil and self.m_startDate ~= '' then
        start_time = tonumber(TimeLib:strToTimeStamp(self.m_startDate))
    end

    if self.m_endDate ~= nil and self.m_endDate ~= '' then
        end_time = tonumber(TimeLib:strToTimeStamp(self.m_endDate))
    end

    
    local server_timestamp = Timer:getServerTime()
    local time_table = TimeLib:convertToServerDate(server_timestamp)
    local curr_time = time_table['time']

    if start_time and end_time then   
        if (start_time <= curr_time) and (curr_time <= end_time) then
            return true
        end
    elseif start_time and (not end_time) then
        if (start_time <= curr_time) then
            return true
        end
    elseif (not start_time) and end_time then
        if (curr_time <= end_time) then
            return true
        end
    elseif (not start_time) and (not end_time) then
        return true
    end

     return false
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
    local buy_cnt
    local price_type = self:getPriceType()

	if rawget(self, price_type) then
        if (self[price_type] ~= nil) then
	        buy_cnt = g_dmgateData:getProductCount(self['product_id'])
        else
            -- 
            if IS_DEV_SERVER() then error('') end
            return false
        end
    else
        buy_cnt = g_shopDataNew:getBuyCount(self['product_id'])
    end 

    return (buy_cnt < self['max_buy_count'])
end

-------------------------------------
-- function isDisplayed
-- @brief 상품 노출 여부
-------------------------------------
function StructProduct:isDisplayed()

    if self.m_tabCategory == 'pass' then return true end

    local sku = self['sku']

    -- 원스토어에서만 노출되어야 하는 상품 필터
    -- 개발의 용이성을 위해 windows에서는 상품 노출
    if (PerpleSdkManager:onestoreIsAvailable() == false) and (CppFunctions:isWin32() == false) then
        local l_check_sku = {}
        table.insert(l_check_sku, 'dvm_ost_launch_10k')
        table.insert(l_check_sku, 'dvm_ost_launch_100k')

        for i,v in ipairs(l_check_sku) do
            if (sku == v) then
                return false
            end
        end
    end
    

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

    elseif (max_buy_term == 'daily') then
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
-- function getFirstItemNameWithCount
-------------------------------------
function StructProduct:getFirstItemNameWithCount()
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
    local t_name = table_item:getItemName(item_id)
    local count = first_item['count']
	return Str('{1} {2}개', t_name, count)
end

-------------------------------------
-- function getItemNameWithCount
-------------------------------------
function StructProduct:getItemNameWithCount()
    local item_list = ServerData_Item:parsePackageItemStr(self['product_content'])
	if (not item_list) or (not item_list[1]) then
		item_list = ServerData_Item:parsePackageItemStr(self['mail_content'])
	end

    if (not item_list) then
        return ''
    end

    local item_table = TableItem()
    local result = ''
    for _, item in pairs(item_list) do
        if (result ~= '') then
            result = result .. '\n'
        end
        if item['item_id'] == ITEM_ID_CLEAR_TICKET then
            result = result .. Str('{1} {2}일', item_table:getItemName(item['item_id']), comma_value(item['count']))
        else
            result = result .. Str('{1} {2}개', item_table:getItemName(item['item_id']), comma_value(item['count']))
        end
    end

    return result
end

-------------------------------------
-- function getItemNameWithCountByIndex
-------------------------------------
function StructProduct:getItemNameWithCountByIndex(index)
    local item_list = ServerData_Item:parsePackageItemStr(self['product_content'])
	if (not item_list) or (not item_list[1]) then
		item_list = ServerData_Item:parsePackageItemStr(self['mail_content'])
	end

    if (not item_list) then
        return ''
    end

    local item_table = TableItem()
    local result = ''

    local item = item_list[index]

    if item then
        result = Str('{1} {2}개', item_table:getItemName(item['item_id']), comma_value(item['count']))
    end

    return result
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
    
    -- 테이블에 blank라고 입력되면 내용을 출력하지 않음
    elseif (self['t_desc'] == 'name') then
        return self:getFirstItemNameWithCount()
    
	-- t_desc가 있다면 출력
    elseif self['t_desc'] and (self['t_desc'] ~= '') and (self['t_desc'] ~= ' ') then
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
    local buy_cnt
    local price_type = self:getPriceType()
    if (rawget(self, price_type)) then
        if (self[price_type] ~= nil) then
	        buy_cnt = g_dmgateData:getProductCount(self['product_id'])
        else
            -- 
            if IS_DEV_SERVER() then error('') end
            return ''
        end
    else
        buy_cnt = g_shopDataNew:getBuyCount(self['product_id'])
    end
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

    if (rawget(self, price_type)) then
        local price_type_id = self[price_type]
        if(price_type_id ~= nil) then
            local item_data = TABLE:get('item')[tonumber(price_type_id)]
            price_type = item_data['full_type']
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
        if (self:getPrice() == 0) then 
            return Str('무료')
        end

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
                    return '￦ ' .. comma_value(self:getPrice())
                end
            -- 마켓에서 받은 가격이 있다면 표시
            elseif (sku) and (dicMarketPrice[sku]) then
                return dicMarketPrice[sku]
            -- 없다면 기본 달러 표시
            else
                -- 윈도우에서는 원화로 표시
                if (CppFunctions:isWin32()) then
                    return '￦ ' .. comma_value(self:getPrice())
                -- 원스토어 빌드에서는 원화로 표시
                elseif (PerpleSdkManager:onestoreIsAvailable()) then
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
    if self['sku'] and (self['sku'] ~= '') and self:getPrice() > 0 then
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
    local price_type = self:getPriceType()
	-- 묶음 구매의 경우 count에 구매 수량을 넣어주고
	-- 단일 구매의 경우 nil로 처리하여 request_buy 내부에서 1로 치환
    local ok_cb
    -- 차원문 상품인 경우
    if (rawget(self, price_type)) then
        if self[price_type] ~= nil then
            ok_cb = function(count)
                local function finish_cb(ret)

                    if(cb_func) then
                        cb_func(ret)
                    end
                end
                if count == nil then count = 1 end
                g_dmgateData:request_buy(self, count, finish_cb)
            end
        else
            return
        end
    -- 차원문 상품이 아닌 경우
    else
        ok_cb =  function(count)
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
                    --self:payment(finish_cb)
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
    end
    -- 2018-11-23 구매 팝업 안뜨는 옵션 추가
    -- 여러개 고르는 기능을 제공하는 팝업이 없으니 해당 옵션은 묶음 구매 아닌 상품만 이용
    if no_popup or (self:getPrice() == 0) then
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

        local price_type = self:getPriceType()

        if (price_type == 'money') then
            price = ServerData_IAP.getInstance():getGooglePlayPromotionPriceStr(self)
            --price = self:getPriceStr()
        else
            price = self:getPrice()
        end
        local ui
        if (rawget(self, price_type)) then
            if (self[price_type] ~= nil) then    
                local item_data = TABLE:get('item')[tonumber(self[price_type])]

                -- type : medal // full_type : medal_angra
                price_type = item_data['full_type']
                --ui = MakeSimplePopup_Confirm(price_type, price, msg, ok_cb, nil)
                ui = UI_ConfirmPopup(price_type, price, msg, ok_cb)
                return
            else
                -- 
                if IS_DEV_SERVER() then error('') end
            end            
        end

        ui = MakeSimplePopup_Confirm(price_type, price, msg, ok_cb, nil)

        -- @sgkim 2020.06.24 게스트 계정으로 구매 시도 시 경고 문구와, 계정 연동 안내 버튼이 구매 심리를 축소한다고 판단하여 제거함.
        --                   드빌M 출시 전에 큐로드 QA팀으로부터 ios정책상 문제가 될 수 있으니 게스트 계정의 경우 경고 문구를 띄우라는 권고를 받았었다.
        --                   조사를 해본 결과 해당 정책 문서를 찾을 수 없었고 최근 서비스 되고 있는 게임들에서 이를 적용하지 않고있었다.
		--local platform_id = g_localData:get('local', 'platform_id') or 'firebase'
		--if (platform_id == 'firebase') then
		--	if ui and ui.vars and ui.vars['subLabel'] then
        --      -- 여기서 해당하는 ui는 popup_confirm.ui 이다.
		--		ui.vars['subLabel']:setString('{@sub_msg}' .. Str('(게스트 계정으로 구매를 하면 게임 삭제, 기기변동,\n휴대폰 초기화시 구매 데이터가 사라질 수 있습니다.)'))
		--	    ui.vars['guestBtn']:setVisible(true)
        --    end
		--end
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
    local price_type = self:getPriceType()
	-- 숫자가 아니라면 구매 횟수 제한이 없는 것
	if (not isNumber(max_buy_cnt)) then
		return true
	end
    local buy_cnt

    if (rawget(self, price_type)) then
	    if (self[price_type] ~= nil) then
	        buy_cnt = g_dmgateData:getProductCount(self['product_id'])
        else
            -- 
            if IS_DEV_SERVER() then error('') end
            return true
        end
    else
        buy_cnt = g_shopDataNew:getBuyCount(self['product_id'])
    end
    
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
	local price_type = self:getPriceType()
    local price = self:getPrice()
    local price_type_id
    if (rawget( self, price_type)) then
        price_type_id = self[price_type]
    else
        price_type_id = self.m_priceItemID
    end

    return UIHelper:checkPrice(price_type, price, price_type_id)
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
-- function isOnlyContain
-------------------------------------
function StructProduct:isOnlyContain(item_type)
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

        if (v['item_id'] ~= item_id) then
            return false
        elseif table_item:getValue(v['item_id'], 'type') ~= item_type then
            return false
        end
    end

    return true
end
-------------------------------------
-- function getMaxBuyTermStr
-- @brief 구매 제한 설명 텍스트
-------------------------------------
function StructProduct:getMaxBuyTermStr(use_rich)
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
    local price_type = self:getPriceType()
    local buy_cnt
    
    if (rawget(self, price_type)) then
        if (self[price_type] ~= nil) then
            buy_cnt = g_dmgateData:getProductCount(product_id)
        else
            -- 
            if IS_DEV_SERVER() then error('') end
            return ''
        end
    else
	    buy_cnt = g_shopDataNew:getBuyCount(product_id)
    end 

    local str = ''
    if (max_buy_term == 'permanent') then
        str = Str('구매 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)

    elseif (max_buy_term == 'yearly') then
        str = Str('연간 구매 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)

    elseif (max_buy_term == 'monthly') then
        str = Str('월간 구매 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)

    elseif (max_buy_term == 'weekly') then
        str = Str('주간 구매 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)

    elseif (max_buy_term == 'daily') then
        str = Str('일일 구매 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)

    end

    -- 구매 가능/불가능 텍스트 컬러 변경
    if (use_rich) then
        local is_buy_all = buy_cnt >= max_buy_cnt
        local color_key = is_buy_all and '{@impossible}' or '{@available}'
        str = color_key .. str
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
    local price_type = self:getPriceType()
    local buy_cnt
	if rawget(self, price_type) then
        if (self[price_type] ~= nil) then
            buy_cnt = g_dmgateData:getProductCount(product_id)
        else
            -- 
            if IS_DEV_SERVER() then error('') end
            return false
        end
    else
        buy_cnt = g_shopDataNew:getBuyCount(product_id)
    end 

	return (buy_cnt >= max_buy_cnt)
end

-------------------------------------
-- function getMaxBuyCount
-- @brief 
-------------------------------------
function StructProduct:getMaxBuyCount()
	return tonumber(self['max_buy_count']) or 0
end


-------------------------------------
-- function getToolTipStr
-- @brief 
-- @return string
-------------------------------------
function StructProduct:getToolTipStr()
	local l_item_list_product = ServerData_Item:parsePackageItemStr(self['product_content'])
    local l_item_list_mail = ServerData_Item:parsePackageItemStr(self['mail_content'])

    local l_item_list = {}
    table.addList(l_item_list, l_item_list_product)
    table.addList(l_item_list, l_item_list_mail)
    
    -- 보급소 자동 줍기 아이템 확인
    local product_id = self:getProductID()
    local autopick_days = TableSupply:getAutoPickupDataByProductID(product_id)
    if (0 < autopick_days) then
        table.insert(l_item_list, {item_id=ITEM_ID_AUTO_PICK, count=autopick_days *24})
    end

    local item_id_map = {}
    for i,v in pairs(l_item_list) do
        local item_id = v['item_id']
        local count = v['count']
        if (item_id_map[item_id] == nil) then
            local t_data = {}
            t_data['item_id'] = item_id
            t_data['count'] = 0
            t_data['idx'] = i
            item_id_map[item_id]  = t_data
        end

        local t_data = item_id_map[item_id]
        t_data['count'] = (t_data['count'] + count)
    end

    local new_item_list = table.MapToList(item_id_map)
    table.sort(new_item_list, function(a, b)
        return a['idx'] < b['idx']
    end)

    local ret_str = ''
    for i,v in ipairs(new_item_list) do
        local item_id = v['item_id']
        local table_item = TABLE:get('item')
        local t_item = table_item[item_id]
        if t_item then
            local name = t_item['t_name']
            local desc = t_item['t_desc']
            local str = Str('{@SKILL_NAME}{1}\n{@DEFAULT}{2}', Str(name), Str(desc))
            if (ret_str == '') then
                ret_str = str
            else
                ret_str = ret_str .. '\n\n' .. str
            end
        end
    end
    
    if (product_id == 120207) then
        ret_str = ret_str .. '\n\n' .. Str('{@SKILL_NAME}{1}\n{@DEFAULT}{2}', Str('7일 소탕'), Str('모험에서 전투 과정을 생략하고 전투 결과를 바로 확인할 수 있습니다.'))
    end


    return ret_str
end


-------------------------------------
-- function getStructIAPProduct
-- @brief sku에 해당하는 StructIAPProduct 리턴
-- @return struct_iap_product(StructIAPProduct) nil이 리턴될 수 있음
-------------------------------------
function StructProduct:getStructIAPProduct()
    local sku = self:getProductSku()
    if (sku == nil) or (sku == '') then
        return nil
    end

    local struct_iap_product = ServerData_IAP:getInstance():getStructIAPProduct(sku)
    return struct_iap_product
end




-- get & set

-------------------------------------
-- function getPrice
-------------------------------------
function StructProduct:getPrice()
	return self['price']
end

-------------------------------------
-- function getPriceType
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
-- function getProductSaleId
-- @return id(number) nil 리턴 가능
-------------------------------------
function StructProduct:getProductSaleID()
    return tonumber(self.sale_id)
end

-------------------------------------
-- function getProductSku
-- @return sku(string)
-------------------------------------
function StructProduct:getProductSku()
    return self['sku']
end

-------------------------------------
-- function getProductName
-------------------------------------
function StructProduct:getProductName()
    return Str(self['t_name'])
end

-------------------------------------
-- function getProductDesc
-------------------------------------
function StructProduct:getProductDesc()
    return Str(self['t_desc'])
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



-------------------------------------
-- function getPackageUI
-------------------------------------
function StructProduct:getPackageUI(is_popup)
    local package_class_name = self['package_class']
    local package_class
    
    if package_class_name and (package_class_name ~= '') then
        if (not _G[package_class_name]) then
            require(package_class_name)
        end

        package_class = _G[package_class_name]
    else
        package_class = UI_Package
    end

    return package_class({self}, is_popup)
end
