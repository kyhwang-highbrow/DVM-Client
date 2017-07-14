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
        g_shopDataNew:request_buy(self, finish_cb)
	end

    MakeSimplePopup_Confirm(self['price_type'], self['price'], nil, ok_cb, nil)
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
            --MakeSimplePopup(POPUP_TYPE.YES_NO, Str('다이아몬드가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup_cash)
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
            --MakeSimplePopup(POPUP_TYPE.YES_NO, Str('골드가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup_gold)
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