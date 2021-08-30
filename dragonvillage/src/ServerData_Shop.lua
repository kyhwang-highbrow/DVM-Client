-------------------------------------
-- class ServerData_Shop
-------------------------------------
ServerData_Shop = class({
        m_serverData = 'ServerData',
        m_dicProduct = '[tab_category][struct_product]',
        m_expirationData = 'pl.Date', -- 서버 정보 만료 시간
        m_dicBuyCnt = '[product_id][count]', -- 구매 횟수
        m_ret = 'server response',
        m_dicMarketPrice = '', -- 마켓에서 받은 가격 (통화까지 표시)
        m_dicStructMarketProduct = '[sku][StructMarketProduct]', -- 마켓에서 받은 상품 정보
        m_bDirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Shop:init(server_data)
    self.m_serverData = server_data

    self.m_dicProduct = {}
    self.m_dicProduct['gold'] = {}
    self.m_dicProduct['st'] = {}
    self.m_dicProduct['money'] = {}
    self.m_dicProduct['cash'] = {}
    self.m_dicProduct['amethyst'] = {}
    self.m_dicProduct['topaz'] = {}
    self.m_dicProduct['mileage'] = {}
    self.m_dicProduct['honor'] = {}
    self.m_dicProduct['capsule'] = {}
    self.m_dicProduct['package'] = {}
    self.m_dicProduct['ancient'] = {}
    self.m_dicProduct['clancoin'] = {}
    self.m_dicProduct['clan_coin'] = {} -- 당장 클라이언트에서 에러가 나지 않도록 처리하기 위함 sgkim 2017-11-03
    self.m_dicProduct['valor'] = {}
    self.m_dicProduct['daily'] = {}
    self.m_dicProduct['reinforce'] = {}
    self.m_dicProduct['skillslime'] = {}
    self.m_dicProduct['etc'] = {}
    self.m_dicProduct['pass'] = {}
    self.m_dicBuyCnt = {}
    self.m_dicMarketPrice = {}
    self.m_dicStructMarketProduct = {}

    self:setDirty()
end

-------------------------------------
-- function clearProduct
-------------------------------------
function ServerData_Shop:clearProduct()
    for i,_ in pairs(self.m_dicProduct) do
        self.m_dicProduct[i] = {}
    end
end

-------------------------------------
-- function insertProduct
-------------------------------------
function ServerData_Shop:insertProduct(struct_product)
    local tab_category = struct_product:getTabCategory()

    if (not self.m_dicProduct[tab_category]) then
        error('지정되어있지 않은 상점 tab : ' .. tab_category)
    end

    table.insert(self.m_dicProduct[tab_category], struct_product)
end


-------------------------------------
-- function getProductList
-------------------------------------
function ServerData_Shop:getProductList(tab_category)
    local l_product = self.m_dicProduct[tab_category]
    
    return self:getProductList_(l_product)
end


-------------------------------------
-- function getProductList_
-------------------------------------
function ServerData_Shop:getProductList_(l_product)
    if (not l_product) then
        return {}
    end

    -- 리스트를 맵 형태로 변환 (key가 product_id가 되도록)
    local product_map = {}
    for i,v in pairs(l_product) do
        local product_id = v['product_id']

		-- 노출 가능한 상품만 추가
		local is_display = self:checkIsDisplay(v)
		if (is_display) then
			product_map[product_id] = v
		end
    end

    -- 의존성 검사
    local l_remove_product_id = {}
    for i,v in pairs(product_map) do

        -- 상품의 의존관계 체크
        local dependency = v:getDependency()
        if dependency then

            -- 해당 상품이 구매가 가능한 상태면 의존 상품을 제거
            if v:isItBuyable() then
                table.insert(l_remove_product_id, dependency)
            -- 그렇지 않을 경우 해당 상품 제거
            else
                table.insert(l_remove_product_id, v['product_id'])
            end
        end
    end

    -- 의존성에 의해 노출되지 말아야 하는 상품 제거
    while l_remove_product_id[1] do
        local product_id = l_remove_product_id[1]
        product_map[product_id] = nil
        table.remove(l_remove_product_id, 1)
    end

    return product_map
end

-------------------------------------
-- function checkIsDisplay
-------------------------------------
function ServerData_Shop:checkIsDisplay(struct_product)
	if (not struct_product) then
		return false
	end
    
	-- Role1 : weekly, montly 등 기간이 있으면 구매해도 무조건 display 해줌
	-- Role2 : permenent 상품의 경우 한 번 사면 display를 해주지 않음

	if struct_product:isDisplayed() then
        
		-- Role1 을 따르지 않는 예외처리
		-- @jhakim 20191212 한정 단계별 패키지가 생김
		-- 한정 단계별 패키지의 경우 monthly라는 제한이 있지만 한 번 사면 display 해주지 말아야함
		if (struct_product['product_id'] >= 110291) and (struct_product['product_id'] <= 110293) then
			return struct_product:isItBuyable()
		end
		
		return true
	end

	return false
end

-------------------------------------
-- function getProductList_byItemType
-------------------------------------
function ServerData_Shop:getProductList_byItemType(item_type)
    local l_product = {}
    
    for i,v in pairs(self.m_dicProduct) do
        for _,product in pairs(v) do
            if product:isContain(item_type) then
                table.insert(l_product, product)
            end
        end
    end

    return l_product
end

-------------------------------------
-- function request_shopInfo
-------------------------------------
function ServerData_Shop:request_shopInfo(cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_shopInfo(ret, cb_func)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/list')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function listToDic
-------------------------------------
function ServerData_Shop:listToDic(l_data, key)
    local t_ret = {}

    for i,v in pairs(l_data) do
        local _key = v[key]
        t_ret[_key] = v
    end

    return t_ret
end

-------------------------------------
-- function response_shopInfo
-------------------------------------
function ServerData_Shop:response_shopInfo(ret, cb_func)
    if (ret['status'] and ret['status'] ~= 0) then
        return
    end

    self.m_ret = ret
    self:clearProduct()

    local table_shop_cash = self:listToDic(ret['table_shop_cash'], 'product_id')
    local table_shop_basic = self:listToDic(ret['table_shop_basic'], 'product_id')
    local table_shop_list = self:listToDic(ret['table_shop_list'], 'list_id')
    
    for i,v in pairs(table_shop_list) do
        local tab_category = v['tab_category']
        local product_id = v['product_id']
        local start_date = v['start_date']
        local end_date = v['end_date']
        local dependency = v['dependency']
        local ui_priority = v['ui_priority'] and tonumber(v['ui_priority'])
        if (not ui_priority) then
            ui_priority = 0
        end
        local t_product = nil

        t_product = table_shop_cash[product_id] or table_shop_basic[product_id]
        if t_product then
            local struct_product = StructProduct(t_product)
           

            struct_product:setTabCategory(tab_category)
            struct_product:setStartDate(start_date) -- 판매 시작 시간
            struct_product:setEndDate(end_date) -- 판매 종료 시간
            struct_product:setDependency(dependency) -- 상품 의존성 (대체 상품)
            struct_product:setUIPriority(ui_priority) -- UI정렬 순선 (높으면 앞쪽에 노출)
            
            -- 2018.01.30 - klee 상품별 UI 포지션, 스케일 정보 추가 
            local t_basic_info = table_shop_basic[product_id]
            
            if (t_basic_info) then
                local ui_pos = t_basic_info['ui_pos']
                local ui_scale = t_basic_info['ui_scale']
                struct_product:setUIPos(ui_pos) 
                struct_product:setUIScale(ui_scale) 
            end
            -- if g_eventData:checkEventTime(start_date, end_date) then    
            --     if g_adventureClearPackageData03:isProduct(product_id) 
            --         and  g_adventureClearPackageData03:isVisibleAtBattlePassShop() then
            --             self:insertProduct(struct_product)
            --     elseif g_levelUpPackageData:isProduct(product_id) 
            --         and g_levelUpPackageData:isVisibleAtBattlePassShop(product_id) then
            --             self:insertProduct(struct_product)
            --     elseif g_battlePassData:isProduct(product_id) then
            --         --self:insertProduct(struct_product)
            --     else

            --     end
            
            if(tab_category == 'pass') then
                --
                if g_eventData:checkEventTime(start_date, end_date) then
                    self:insertProduct(struct_product)
                end
               
            else
                self:insertProduct(struct_product)
            end

        end
    end

    -- 상품별 구매 횟수 정보 갱신
    if (ret['buycnt']) then
        self.m_dicBuyCnt = ret['buycnt']
    end

    self.m_bDirty = false

	g_advertisingData:networkCommonRespone(ret)

    if (cb_func) then
		cb_func(ret)
	end
end

-------------------------------------
-- function openShopPopup
-- @brief
--        1. 상점 리스트를 서버에서 받아옴
--           (리스트를 받아오지 못하였을 경우 종료)
--        2. 상점 UI를 생성
--        3. 지정된 상점 tab이 있을 경우 경우 tab 설정
-------------------------------------
function ServerData_Shop:openShopPopup(tab_type, close_cb)
    self:checkDirty()

    local function cb_func()
        local ui_shop_popup = UI_Shop()

        if tab_type then
            -- sgkim 2017-11-03 골드는 "소모품, 골드"탭에서 팔도록 변경되어서 강제로 이동시킴
            -- klee 2018-01-29 골드 다시 탭 분리
            --[[if (tab_type == 'gold') then
                tab_type = 'st'
            end]]--
            ui_shop_popup:setTab(tab_type)
        end

        if close_cb then
            ui_shop_popup:setCloseCB(close_cb)
        end
    end

    if (not self.m_bDirty) then
        cb_func()
        return
    end

    -- 서버에 상품정보 요청
	self:request_shopInfo(cb_func)
end

-------------------------------------
-- function getBuyCount
-------------------------------------
function ServerData_Shop:getBuyCount(product_id)
    local product_id = tostring(product_id)
    local buy_cnt = self.m_dicBuyCnt[product_id] or 0
    return buy_cnt
end

-------------------------------------
-- function checkDirty
-- @brief
-------------------------------------
function ServerData_Shop:checkDirty()
    if self.m_bDirty then
        return
    end

    -- 만료 시간 체크 할 것!
    --self.m_expirationData
    self:setDirty()
end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_Shop:setDirty()
    self.m_bDirty = true
end

-------------------------------------
-- function isDirty
-------------------------------------
function ServerData_Shop:isDirty()
    return self.m_bDirty
end

-------------------------------------
-- function isExistCashSale
-------------------------------------
function ServerData_Shop:isExistCashSale()
    local shop_list = self:getProductList('cash')
	local is_event = false
	for i, v in pairs(shop_list) do
		-- 해당 sku가 있다면 true!
		if (v['badge'] == 'plus_one') then 
			return true
		end
	end

	return false
end

-------------------------------------
-- function isExist
-------------------------------------
function ServerData_Shop:isExist(category, product_id)
    local shop_list = self:getProductList(category)
    return shop_list[product_id] and true or false
end

-------------------------------------
-- function getProduct
-- param product_id number
-------------------------------------
function ServerData_Shop:getProduct(category, product_id)
    local shop_list = self:getProductList(category)

    return shop_list[product_id]
end

-------------------------------------
-- function request_buy
-- @brief 상품 구매
-------------------------------------
function ServerData_Shop:request_buy(struct_product, count, finish_cb, fail_cb)
    local product_id = struct_product['product_id']
	local count = count or 1

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- @analytics
        do
            local category = struct_product:getTabCategory()
            local t_product = self:getProductList(category)
            local t_info = t_product[product_id]

            if (t_info) then
                local str_product = t_info['product_content']
                local l_product = TableExchange:makeProductList(str_product)
                
                local gold = tonumber(l_product['gold'] or 0)
                if (gold > 0) then
                    Analytics:trackEvent(CUS_CATEGORY.GOLD, CUS_EVENT.GET_GOLD, gold, string.format('상품 구매 : %d', product_id))
                    Analytics:trackUseGoodsWithRet(ret, '골드 구매')
                end
                
                local staminas = tonumber(l_product['staminas_st'] or 0)
                if (staminas > 0) then
                    Analytics:trackEvent(CUS_CATEGORY.STAMINA, CUS_EVENT.GET_STAMINA, staminas, string.format('상품 구매 : %d', product_id))
                    Analytics:trackUseGoodsWithRet(ret, '날개 구매')
                end

                local rune = tonumber(l_product['rune'] or 0)
                if (rune > 0) then
                    local name = TableItem:getItemName(rune)
                    Analytics:trackUseGoodsWithRet(ret, string.format('룬 구매 (%s)', name))
                end

                local egg = tonumber(l_product['egg'] or 0)
                if (egg > 0) then
                    local name = TableItem:getItemName(egg)
                    Analytics:trackUseGoodsWithRet(ret, string.format('알 구매 (%s)', name))
                end
            end
        end

        -- 상품별 구매 횟수 정보 갱신
        if (ret['buycnt']) then
            self.m_dicBuyCnt = ret['buycnt']
        end

        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 상품 구매 후 갱신이 필요한지 여부 체크
        if struct_product:needRenewAfterBuy() then
            self:setDirty()
        end

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/buying')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', product_id)
	ui_network:setParam('count', count)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_purchaseToken
-------------------------------------
function ServerData_Shop:request_purchaseToken(market, sku, product_id, price, cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    -- @kwkang 20-11-30 기존에 IOS 유저의 결제 후 상품 수령 실패한 경우 
    -- 어떠한 상품을 구매했는지 파악하기 어려웠기에 파라미터로 추가
    local market = market
    local sku = sku
    local product_id = product_id
    local price = price

    -- 콜백 함수
    local function success_cb(ret)
		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/purchase_token')
    ui_network:setParam('uid', uid)
    ui_network:setParam('market', market)
    ui_network:setParam('sku', sku)
    ui_network:setParam('product_id', product_id)
    ui_network:setParam('price', price)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_checkReceiptValidation
-- @breif 마켓에서 구매 후
-------------------------------------
function ServerData_Shop:request_checkReceiptValidation(struct_product, validation_key, sku, product_id, price, iswin, cb_func, fail_cb, response_status_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        
        -- 누락된 지급건을 처리하는 경우 struct_product가 nil일 수 있다. 이 경우 product_id로 조회한다.
        if (struct_product == nil) then
            struct_product = self:getTargetProduct(tonumber(product_id))
        end

        -- @analytics
        if (struct_product) then
            local krw_price = struct_product['price'] -- getPrice() 함수 나중에 수정하기
            local usd_price = struct_product['price_dollar']
            local first_buy = ret['first_buy']  --첫번째 결제인지

            Analytics:purchase(product_id, sku, krw_price, usd_price, first_buy)
            Analytics:trackGetGoodsWithRet(ret, string.format('상품 구매 : %d', product_id))

            if (ret['ustats']) then
                -- 누적 결제 금액 증가로 갱신
                UserStatusAnalyser:analyzeUserStat(ret['ustats'])

                local sum_money = ret['ustats']['sum_money']
                --adjust 누적 금액
                Adjust:trackEventSumPrice(sum_money)
            end
        end
        
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 누적 결제 보상 이벤트 관련 데이터 갱신
        g_purchasePointData:response_purchasePointInfo(ret, nil) -- param : ret, finish_cb
        -- 일일 결제 보상 에빈트 관련 데이터 갱신
        g_purchaseDailyData:applyPurchaseDailyInfo(ret['purchase_daily_info'])

        -- 상품 구매 후 갱신이 필요한지 여부 체크
        if struct_product and struct_product:needRenewAfterBuy() then
            self:setDirty()
        end

        -- 깜짝 세일 상품 정보 받는 중
		if (ret['spot_sale']) then
			g_spotSaleData:applySpotSaleInfo(ret['spot_sale'])
		end

        -- 구매한 아이템 중 코스튬이 있다면 dirty 갱신
        if (ret['added_items']) then
            if (self:isContainCostume(ret['added_items'])) then
                g_tamerCostumeData.m_bDirtyCostumeInfo = true
            end
        end

        -- 상품별 구매 횟수 정보 갱신
        if (ret['buycnt']) then
            self.m_dicBuyCnt = ret['buycnt']
        end

        -- 첫 충전 선물(첫 결제 보상)
        if ret['first_purchase_event_info'] then
            g_firstPurchaseEventData:applyFirstPurchaseEvent(ret['first_purchase_event_info'])
        end

        -- 보급소(정액제)
        g_supply:applySupplyList_fromRet(ret)
        
        -- 자동 줍기으로 획득한 누적 아이템 수량 갱신
        g_subscriptionData:response_ingameDropInfo(ret)

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/check_receipt_validation')
    ui_network:setParam('uid', uid)
    ui_network:setParam('validation_key', validation_key)
    ui_network:setParam('sku', sku)
    ui_network:setParam('product_id', product_id)
    ui_network:setParam('iswin', iswin)
	ui_network:setParam('route', g_errorTracker:getUIStackForPayRoute())

    local market, os_ = GetMarketAndOS()

	if (IS_LIVE_SERVER()) then
		local os = getTargetOSName()
		local game_lang = Translate:getGameLang()
		local device_lang = Translate:getDeviceLang()
		local auth = g_localData:getAuth()

		ui_network:setParam('os', os)
		ui_network:setParam('glang', game_lang)
		ui_network:setParam('dlang', device_lang)
		ui_network:setParam('auth', auth)
        ui_network:setParam('market', market)
	else
		ui_network:setParam('os', 'test')
		ui_network:setParam('glang', 'test')
		ui_network:setParam('dlang', 'test')
		ui_network:setParam('auth', 'test')
        ui_network:setParam('market', market)
	end

    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end


-------------------------------------
-- function isContainCostume
-- @breif 구매한 제품 중 아이템이 하나라도 코스튬이면 true 반환
-------------------------------------
function ServerData_Shop:isContainCostume(added_items)
    if (not added_items['items_list']) then
        return false
    end

    local items_list = added_items['items_list']
    local table_item = TableItem()
    for _, t_item in pairs(items_list) do
        if (t_item['item_id']) then
            if (table_item:getItemType(t_item['item_id']) == 'costume') then
                return true
            end
        end
    end
    return false
end

-------------------------------------
-- function request_useCoupon
-- @breif 쿠폰 사용
-------------------------------------
function ServerData_Shop:request_useCoupon(coupon, success_cb, result_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/coupon_use')
    ui_network:setParam('uid', uid)
    ui_network:setParam('coupon', coupon)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(result_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_delCoupon
-- @breif 쿠폰 삭제
-------------------------------------
function ServerData_Shop:request_delCoupon(coupon_id, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if (cb_func) then
            cb_func()
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/coupon_del')
    ui_network:setParam('uid', uid)
    ui_network:setParam('couponid', coupon_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end


-------------------------------------
-- function request_couponList
-- @breif 쿠폰 리스트 받음
-------------------------------------
function ServerData_Shop:request_couponList(cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if (cb_func) then
            cb_func(ret['coupons_list'])
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/coupon_list')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_randomBoxInfo
-- @breif 랜덤 박스에서 나올 수 있는 아이템 리스트
-------------------------------------
function ServerData_Shop:request_randomBoxInfo(cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if cb_func then
            cb_func(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/randombox_info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getTargetProduct
-- @brief product_id를 통해 StructProduct를 획득한다.
-- @param product_id (number)
-------------------------------------
function ServerData_Shop:getTargetProduct(product_id)
    if (not self.m_dicProduct) then
        return nil
    end

    local l_product_list = {}
    for _,v in pairs(self.m_dicProduct) do
        for _,struct_product in pairs(v) do
            table.insert(l_product_list, struct_product)
        end
    end

    for _,struct_product in ipairs(l_product_list) do
        if (struct_product['product_id'] == product_id) then
            return struct_product
        end
    end
    
    return nil
end



-------------------------------------
-- function getLevelUpPackageProduct
-- @brief 레벨업 패키지 상품 정보
-------------------------------------
function ServerData_Shop:getLevelUpPackageProduct()
    local product_id = 90037
    return self:getTargetProduct(product_id)
end

-------------------------------------
-- function getAdventureClearProduct
-- @brief 모험돌파 패키지 상품 정보
-------------------------------------
function ServerData_Shop:getAdventureClearProduct()
    local product_id = 90057
    return self:getTargetProduct(product_id)
end

-------------------------------------
-- function getAdventureClearProduct02
-- @brief 모험돌파 패키지 상품 정보
-------------------------------------
function ServerData_Shop:getAdventureClearProduct02()
    local product_id = 110281
    return self:getTargetProduct(product_id)
end

-------------------------------------
-- function getAdventureClearProduct03
-- @brief 모험돌파 패키지 상품 정보
-------------------------------------
function ServerData_Shop:getAdventureClearProduct03()
    local product_id = 110282
    return self:getTargetProduct(product_id)
end

-------------------------------------
-- function getDailyCapsulePackage
-- @brief 일일 캡슐코인 패키지 (5 + 1) 상품 정보
-------------------------------------
function ServerData_Shop:getDailyCapsulePackage()
    local product_id = 90094
    return self:getTargetProduct(product_id)
end

-------------------------------------
-- function getSpecialOfferProduct
-- @brief 특별 할인
-- @return StructProduct
-------------------------------------
function ServerData_Shop:getSpecialOfferProduct()

    -- 특별 할인 상품 product_id (하드코딩)
    local l_product_id = {}
    table.insert(l_product_id, {110311, 800}) -- 800% 이상의 혜택
    table.insert(l_product_id, {110312, 1000}) -- 1000% 이상의 혜택
    table.insert(l_product_id, {110313, 1100}) -- 1100% 이상의 혜택
    table.insert(l_product_id, {110314, 1200}) -- 1200% 이상의 혜택

    -- 상품의 순서대로 구매가능하면 리턴
    for i,t_data in ipairs(l_product_id) do
        local product_id = t_data[1]
        local bonus_num = t_data[2]
        local struct_product = self:getTargetProduct(product_id)

        if struct_product and
            struct_product:checkIsSale() and -- 판매중인 상품인지 확인
            struct_product:isItBuyable() then -- 구매 횟수 제한 확인
            return struct_product, i, bonus_num
        end
    end
    
    return nil, 0, 0
end

-------------------------------------
-- function getSpecialOfferProductGold
-- @brief 특별 할인 골드
-- @return StructProduct
-------------------------------------
function ServerData_Shop:getSpecialOfferProductGold()

    -- 특별 할인 상품 product_id (하드코딩)
    local l_product_id = {}
    table.insert(l_product_id, {120701, 800}) -- 800% 이상의 혜택
    table.insert(l_product_id, {120702, 1000}) -- 1000% 이상의 혜택
    table.insert(l_product_id, {120703, 1100}) -- 1100% 이상의 혜택
    table.insert(l_product_id, {120704, 1200}) -- 1200% 이상의 혜택

    -- 상품의 순서대로 구매가능하면 리턴
    for i,t_data in ipairs(l_product_id) do
        local product_id = t_data[1]
        local bonus_num = t_data[2]
        local struct_product = self:getTargetProduct(product_id)

        if struct_product and
            struct_product:checkIsSale() and -- 판매중인 상품인지 확인
            struct_product:isItBuyable() then -- 구매 횟수 제한 확인
            return struct_product, i, bonus_num
        end
    end
    
    return nil, 0, 0
end

-------------------------------------
-- function getSpecialOfferProductNurture
-- @brief 특별 할인 골드
-- @return StructProduct
-------------------------------------
function ServerData_Shop:getSpecialOfferProductNurture()

    -- 특별 할인 상품 product_id (하드코딩)
    local l_product_id = {}
    table.insert(l_product_id, {121501, 800}) -- 800% 이상의 혜택
    table.insert(l_product_id, {121502, 1000}) -- 1000% 이상의 혜택
    table.insert(l_product_id, {121503, 1100}) -- 1100% 이상의 혜택
    table.insert(l_product_id, {121504, 1200}) -- 1200% 이상의 혜택

    -- 상품의 순서대로 구매가능하면 리턴
    for i,t_data in ipairs(l_product_id) do
        local product_id = t_data[1]
        local bonus_num = t_data[2]
        local struct_product = self:getTargetProduct(product_id)

        if struct_product and
            struct_product:checkIsSale() and -- 판매중인 상품인지 확인
            struct_product:isItBuyable() then -- 구매 횟수 제한 확인
            return struct_product, i, bonus_num
        end
    end
    
    return nil, 0, 0
end

-------------------------------------
-- function getSpecialOfferProductNurture
-- @brief 특별 할인 골드
-- @return StructProduct
-------------------------------------
function ServerData_Shop:getSpecialOfferProductWeidel()

    -- 바이델 축제 패키지 상품 product_id (하드코딩)
    local l_product_id = {}
    table.insert(l_product_id, {122401, 800}) -- 800% 이상의 혜택
    table.insert(l_product_id, {122402, 1000}) -- 1000% 이상의 혜택

    -- 상품의 순서대로 구매가능하면 리턴
    for i,t_data in ipairs(l_product_id) do
        local product_id = t_data[1]
        local bonus_num = t_data[2]
        local struct_product = self:getTargetProduct(product_id)

        if struct_product and
            struct_product:checkIsSale() and -- 판매중인 상품인지 확인
            struct_product:isItBuyable() then -- 구매 횟수 제한 확인
            return struct_product, i, bonus_num
        end
    end
    
    return nil, 0, 0
end

-------------------------------------
-- function canBuyWeidelPackage
-- @brief 바이델 축제상품 당일 노출 여부
-------------------------------------
function ServerData_Shop:shouldShowWeidelOfferPopup()
    local str_uid = g_userData:get('uid') and tostring(g_userData:get('uid')) or ''
    local weidel_offer_save_key = 'lobby_weidel_package_notice_' .. str_uid

    local saved_timestamp = g_settingData:get(weidel_offer_save_key) or -1

    --날짜값이 의미없는 값이면 공지 확인!
    if (not saved_timestamp) or (not tonumber(saved_timestamp)) or (tonumber(saved_timestamp) < 0) then return true end

    local year_month, t_time = Timer:getGameServerDate()
    local day = t_time['day']

    local date = TimeLib:convertToServerDate(tonumber(saved_timestamp))
    if (not date) or (not date['tab']) then
        g_settingData:applySettingData(-1, weidel_offer_save_key)
        return false 
    end

    local saved_day = date:day()

    -- 더 작은 날짜로 저장되어 있으니 새 공지가 있음
    return day ~= saved_day
end

-------------------------------------
-- function getSkuList_Monthly
-- @brief 인앱상품 프러덕트 아이들을 'x;x;x;'형태로 반환 - 월정액 상품
-------------------------------------
function ServerData_Shop:getSkuList_Monthly()
	return 'dvm_2weekpack01_5k;dvm_2weekpack02_3k;dvm_2weekpack03_1k;dvm_2weekpack11_30k;dvm_2weekpack12_10k;dvm_2weekpack13_5k'
end

-------------------------------------
-- function getSkuList
-- @brief 인앱상품 프러덕트 아이들을 'x;x;x;'형태로 반환
-------------------------------------
function ServerData_Shop:getSkuList()
    if (not self.m_dicProduct) then
        return nil
    end

    local tTemp = {}
    for _,v in pairs(self.m_dicProduct) do
        for _,struct_product in pairs(v) do
            if struct_product['sku'] then
                if tTemp[ struct_product['sku'] ] == nil then
                    tTemp[ struct_product['sku'] ] = 1
                end                
            end
        end
    end

    -- 가격별 sku
    local t_pricing_matrix = self:getPricingMatrix()
    for price,v in pairs(t_pricing_matrix) do
        local _sku = v[2]
        tTemp[_sku] = 1
    end

    local ret = ''
    for sku, _ in pairs( tTemp ) do
        ret = ret .. ';' .. sku
    end

    return ret
end

-------------------------------------
-- function getPricingMatrix
-- @brief 가격별 sku
-------------------------------------
function ServerData_Shop:getPricingMatrix()
    local l_list = {}
    -- price (krw), sku
    table.insert(l_list, {1100, 'dvm_daily_exp_1k'})  -- 경험치 부스터 패키지
    table.insert(l_list, {3300, 'dvm_cash_3k'})  -- 다이아 300개
    table.insert(l_list, {5500, 'dvm_cash_5k'})  -- 다이아 530개
    table.insert(l_list, {9900, 'dvm_giftpack01_10k'})  -- 유리아의 랜덤 박스
    table.insert(l_list, {11000, 'dvm_cash_10k'}) -- 다이아 1,100개

    table.insert(l_list, {22000, 'dvm_weekendpack02_20k'}) -- 주말 패키지
    table.insert(l_list, {33000, 'dvm_cash_30k'}) -- 다이아 3,400개
    table.insert(l_list, {55000, 'dvm_cash_50k'}) -- 다이아 5,900개
    table.insert(l_list, {110000, 'dvm_cash_100k'})-- 다이아 12,600개

    return l_list
end

-------------------------------------
-- function getStructMarketProduct
-- @param sku (string)
-- @return StructMarketProduct
-------------------------------------
function ServerData_Shop:getStructMarketProduct(sku)
    return self.m_dicStructMarketProduct[sku]
end

-------------------------------------
-- function getPriceStrBySku
-------------------------------------
function ServerData_Shop:getPriceStrBySku(sku)
    if (self.m_dicMarketPrice and self.m_dicMarketPrice[sku]) then
        return self.m_dicMarketPrice[sku]
    else
        local t_matrix = self:getPricingMatrix()
        for i,v in pairs(t_matrix) do
            if (v[2] == sku) then
                return '￦ ' .. comma_value(v[1])
            end
        end
    end

    return ''
end

-------------------------------------
-- function setMarketPrice
-- @brief 마켓에서 받은 가격 string (통화까지 표시)
-------------------------------------
function ServerData_Shop:setMarketPrice(market_data)
    -- sku로 구분함 
    for _, v in pairs(market_data) do
        local sku = tostring(v.productId)
        local price = v.price

        self.m_dicMarketPrice[sku] = price
        self.m_dicStructMarketProduct[sku] = StructMarketProduct(clone(v))
    end
end

-------------------------------------
-- function setMarketPriceForOnestore
-- @brief 마켓에서 받은 가격 string
-------------------------------------
function ServerData_Shop:setMarketPriceForOnestore(market_data)
    if (not market_data) then
        return
    end
    for sku, price in pairs(market_data) do
        self.m_dicMarketPrice[sku] = price
    end
end

-------------------------------------
-- function getValidStepPackage
-- @brief 단계별 패키지가 2개 이상 동시에 판매되면서 우선 순위 확인
-- @sgkim 2018-05-29
-------------------------------------
function ServerData_Shop:getValidStepPackage()
    -- 단계별 패키지 product id
    local l_step_pids_new = g_shopDataNew:getPakcageStepPidList('package_step_02')
    local l_step_pids_old = g_shopDataNew:getPakcageStepPidList('package_step')

    -- 신버젼 단계별 패키지 상품 판매 중인지 확인
    do
        if (#l_step_pids_new ~= 4) then
            return nil
        end

        -- 신버젼 상품이 다 없다면 구 버젼 상품 출
        local is_sale = false
        for i = 1, 4 do
            if (self:isExist('package', l_step_pids_new[i])) then
                is_sale = true
            end
        end

        if (not is_sale) then
            return 'package_step'
        end
    end
    

    -- 구버젼 단계별 패키지 상품 판매 중인지 확인
    do    
        if (#l_step_pids_old ~= 4) then
            return nil
        end

        -- 구버젼 상품이 다 없다면 신버젼 상품 출력
        local is_sale = false
        for i = 1, 4 do
            if (self:isExist('package', l_step_pids_old[i])) then
                is_sale = true
            end
        end
        if (not is_sale) then
            return 'package_step_02'
        end
    end

    -- 둘 다 상품 판매중인 경우=
    do 
        -- 구버젼 1단계도 구매를 안했을 경우 (아예 살 의지가 없음) 그렇다면 신규를 보여줌
        if (self:getBuyCount(l_step_pids_old[1]) == 0) then
            return 'package_step_02'
        end

        -- 구버젼 4단계까지 모두 구매했을 경우 (다 샀음) 그렇다면 신규를 보여줌
        if (self:getBuyCount(l_step_pids_old[4]) > 0) then
            return 'package_step_02'
        end
    end

    return 'package_step'
end

-------------------------------------
-- function getPakcageStepPidList
-- @brief 단계별 패키지 product_id list
-- package_step_name : 'package_step_02', 'package_step'
-------------------------------------
function ServerData_Shop:getPakcageStepPidList(package_step_name)
    local l_pids = TablePackageBundle:getPidsWithName(package_step_name)
    if (not l_pids) then
        l_pids = {}
    end
    
    for i,v in ipairs(l_pids) do
        l_pids[i] = tonumber(v)
    end
    return l_pids
end

-------------------------------------
-- function checkDiaSale
-- @brief 다이아 할인상품 한개라도 판매중인지 확인
-------------------------------------
function ServerData_Shop:checkDiaSale()
    local l_cash_product = self:getProductList('cash')
    for pid, data in pairs(l_cash_product) do
        local pid = tonumber(pid)
        -- @jhakim 190422 다이아할인상품 목록을 하드코딩
        if (82011 <= pid) and (pid <= 82036) then
            if (data:checkIsSale()) then
                return true
            end
        end
    end

    return false
end

-------------------------------------
-- function isBuyablePackage
-- @brief 패키지 중 하나라도 구매 가능이이라면 true를 리
-------------------------------------
function ServerData_Shop:isBuyablePackage(l_pid)
	local is_package_buyable = false
	if (not l_pid) then
		return false
	end

    for i, pid in ipairs(l_pid) do
	    local struct_product = g_shopDataNew:getProduct('package', pid)
        if (struct_product) then
            if (struct_product:checkMaxBuyCount()) then
                is_package_buyable = true
                break
            end
        end
    end

	return is_package_buyable
end

-------------------------------------
-- function isBuyablePackage
-- @brief 패키지 중 하나라도 시간 안이면 true를 리
-------------------------------------
function ServerData_Shop:isOnTimePackage(pid_list)
    if(not pid_list) then return false end
    
    local is_on_time = false

    for i, pid in ipairs(pid_list) do
        local struct_product = g_shopDataNew:getProduct('package', tonumber(pid))

        if struct_product then
            if struct_product:isItOnTime() then
                is_on_time = true
                break
            end
        end
    end
    return is_on_time   
end


-------------------------------------
-- function getActivatedPackageList
-- @brief 구매 가능한 상품 리스트
-------------------------------------
function ServerData_Shop:getActivatedPackageList()
    local packages = TABLE:get('table_package_bundle')
    local package_list = {}

    -- csv 파일의 하단에 오는 상품이 제일 위에 노출되도록 reverse order
    for index = #packages, 1, -1 do
        local struct_product_group = StructProductGroup(packages[index])
        
        local is_buyable = struct_product_group:isBuyable()
 
        if is_buyable then
            table.insert(package_list, struct_product_group)
        end
    end

    return package_list
end


-------------------------------------
-- function setPackageUI
-------------------------------------
function ServerData_Shop:setPackageUI(package_bundle_data, parent_node, buy_callback, is_refresh_dependency)
    if (not parent_node) or (not package_bundle_data) then
        return 
    end
    
    local product_list = package_bundle_data:getProductList()
    local package_type = package_bundle_data['type']

    for index, struct_product in pairs(product_list) do
        local ui

        if (package_type == '') then            
            local package_name = TablePackageBundle:getPackageNameWithPid(struct_product['product_id'])
 
            ui = PackageManager:getTargetUI(package_name, false)
        else
            local package_class

            if struct_product['package_class'] and (struct_product['package_class'] ~= '')then
                if (not _G[struct_product['package_class']]) then
                    require(struct_product['package_class'])
                end
                package_class = _G[struct_product['package_class']]
            end
            
            if (not package_class) then
                package_class = UI_Package
            end

            if (package_type == 'bundle') then
                ui = package_class(product_list, false, package_bundle_data['t_name'])
            else
                local list = {}
                table.insert(list, struct_product)
                ui = package_class(list, false, package_bundle_data['t_name'])
            end
        end

        if ui then
            if checkMemberInMetatable(ui, 'setBuyCB') then
                ui:setBuyCB(function()
                    buy_callback()
                end)
            end

            if is_refresh_dependency and checkMemberInMetatable(ui, 'setRefreshDependency') then
                ui:setRefreshDependency()
            end

            parent_node:addChild(ui.root)
        end

        if (package_type == '') or (package_type == 'bundle') then
            break
        end
    end
end

-------------------------------------
-- function getTargetPackage
-- @brief table_package_bundle의 t_name과 같은 패키지 정보를 찾아 리턴
-------------------------------------
function ServerData_Shop:getTargetPackage(package_name)
    if (not package_name) then return nil end

    local packages = self:getActivatedPackageList()

    for _, data in pairs(packages) do
        if (data['t_name'] == package_name) then
            return data
        end
    end

    return nil
end




