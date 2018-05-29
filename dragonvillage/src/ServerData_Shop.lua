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
    self.m_dicProduct['daily'] = {}
    self.m_dicBuyCnt = {}
    self.m_dicMarketPrice = {}

    self:setDirty()
end

-------------------------------------
-- function localTableTest
-------------------------------------
function ServerData_Shop:localTableTest()
    
    local table_shop_cash = TABLE:loadCSVTable('table_shop_cash', nil, 'product_id')
    local table_shop_basic = TABLE:loadCSVTable('table_shop_basic', nil, 'product_id')
    local table_shop_list = TABLE:loadCSVTable('table_shop_list', nil, 'list_id')
    
    local date_format = 'yyyy-mm-dd HH:MM:SS'
    local parser = pl.Date.Format(date_format)
    
    local date_str = '2017-06-23 00:00:00'


    local date = parser:parse(date_str)
    --ccdump(date)

    --local 
    for i,v in pairs(table_shop_list) do
        --v['start_date'] = '2017-06-01 00:00:00'
        --v['end_date'] = '2017-06-27 00:00:00'

        local start_date = parser:parse(v['start_date'])
        local end_date = parser:parse(v['end_date'])

        local active = false

        -- 시작 시간이 없거나 시작 시간 이후이면 true
        if (not start_date) or (start_date < date) then
            active = true
        end

        -- 시작 조건을 충족한 상태
        if active then
            -- 종료 시간이 명시되어있고 현재 시간이 종료시간보다 이전일 경우
            if end_date and (end_date < date) then
                active = false
            end
        end

        if active then
            --cclog(v['list_id'])

            local tab_category = v['tab_category']
            local product_id = v['product_id']
            local dependency = v['dependency']
            local ui_priority = v['ui_priority'] and tonumber(v['ui_priority'])
            if (not ui_priority) then
                ui_priority = 0
            end
            local t_product = nil

            if (tab_category == 'money') then
                t_product = table_shop_cash[product_id]
            else
                t_product = table_shop_basic[product_id]
            end

            local struct_product = StructProduct(t_product)
            struct_product:setTabCategory(tab_category)
            struct_product:setStartDate(start_date)
            struct_product:setEndDate(end_date)
            struct_product:setDependency(dependency)
            struct_product:setUIPriority(ui_priority)
            self:insertProduct(struct_product)
        end
    end
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
        if v:isDisplayed() then
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

            self:insertProduct(struct_product)
        end
    end

    self.m_dicBuyCnt = ret['buycnt']

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
    self:ckechDirty()

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
-- function ckechDirty
-- @brief
-------------------------------------
function ServerData_Shop:ckechDirty()
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
function ServerData_Shop:request_purchaseToken(cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

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
        
        -- @analytics
        -- 탭조이 매출은 모두 krw 가격으로 보냄
        if (struct_product) then
            local krw_price = struct_product['price'] -- getPrice() 함수 나중에 수정하기
            local token = struct_product['token']   --adjust용 토큰
            local first_buy = ret['first_buy']  --첫번째 결제인지
            local sum_money = ret['sum_money'] or 0   --누적 결제 금액

            Analytics:purchase(product_id, sku, krw_price, token, first_buy)
            Analytics:trackGetGoodsWithRet(ret, string.format('상품 구매 : %d', product_id))
            --adjust 누적 금액
            Adjust:trackEventSumPrice(sum_money)
        end
        
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
    
        -- 상품 구매 후 갱신이 필요한지 여부 체크
        if struct_product and struct_product:needRenewAfterBuy() then
            self:setDirty()
        end

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
	
	if (IS_LIVE_SERVER()) then
		local os = getTargetOSName()
		local game_lang = Translate:getGameLang()
		local device_lang = Translate:getDeviceLang()
		local auth = g_localData:getAuth()

		ui_network:setParam('os', os)
		ui_network:setParam('glang', game_lang)
		ui_network:setParam('dlang', device_lang)
		ui_network:setParam('auth', auth)
	else
		ui_network:setParam('os', 'test')
		ui_network:setParam('glang', 'test')
		ui_network:setParam('dlang', 'test')
		ui_network:setParam('auth', 'test')
	end

    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
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
-- function getDailyCapsulePackage
-- @brief 일일 캡슐코인 패키지 (5 + 1) 상품 정보
-------------------------------------
function ServerData_Shop:getDailyCapsulePackage()
    local product_id = 90094
    return self:getTargetProduct(product_id)
end

-------------------------------------
-- function getSkuList
-- @brief 인앱상품 프러덕트 아이들을 'x;x;x;'형태로 반환
-------------------------------------
function ServerData_Shop:getSkuList()
    if (not self.m_dicProduct) then
        return nil
    end

    local ret
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

    -- 월정액 상품 (매일매일 다이아) - 서버에서 shop 정보 주지 않음
    -- 하드 코딩 - sku 바뀐다면 수정해야함

    -- 일반 월정액 sku
    local sku_normal = 'dvm_2weekpack01_5k;dvm_2weekpack02_3k;dvm_2weekpack03_1k;'

    -- 프리미엄 월정액 sku
    local sku_premium = 'dvm_2weekpack11_30k;dvm_2weekpack12_10k;dvm_2weekpack13_5k;'

    ret = sku_normal .. sku_premium

    for sku, _ in pairs( tTemp ) do
        ret = ret .. ';' .. sku
    end

    return ret
end

-------------------------------------
-- function setMarketPrice
-- @brief 마켓에서 받은 가격 string (통화까지 표시)
-------------------------------------
function ServerData_Shop:setMarketPrice(market_data)
    self.m_dicMarketPrice = {}
    
    cclog('## 마켓에서 받은 가격 로그')
    ccdump(market_data)

    -- sku로 구분함 
    for _, v in pairs(market_data) do
        local sku = tostring(v.productId)
        local price = v.price

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
    local t_step_pids = {90077, 90078, 90079, 90080}

    -- 1단계도 구매를 안했을 경우
    if (self:getBuyCount(90077) == 0) then
        return 'package_step_02'
    end

    -- 4단계까지 모두 구매했을 경우
    if (self:getBuyCount(90080) > 0) then
        return 'package_step_02'
    end

    return 'package_step'
end