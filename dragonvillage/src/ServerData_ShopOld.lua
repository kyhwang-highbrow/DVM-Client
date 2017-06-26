-------------------------------------
-- class ServerData_ShopOld
-------------------------------------
ServerData_ShopOld = class({
        m_serverData = 'ServerData',
		m_productTable = 'TableShop',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ShopOld:init(server_data)
    self.m_serverData = server_data
	self.m_productTable = nil
end

-------------------------------------
-- function getProductList
-- @brief group_type 으로 상품들을 가져온다
-------------------------------------
function ServerData_ShopOld:getProductList(group_type)
	return self.m_productTable:filterList('group_type', group_type)
end

-------------------------------------
-- function canBuyProduct
-- @brief 구매 가능 여부 검사
-------------------------------------
function ServerData_ShopOld:canBuyProduct(price_type, price_value)
    local user_price = 0

    -- 지불 재화 개수 저장
    if (price_type == 'x') then
        user_price = 0

    elseif (price_type == 'cash') then
        user_price = g_userData:get('cash')

    elseif (price_type == 'amethyst') then
        user_price = g_userData:get('amethyst')

    elseif (price_type == 'gold') then
        user_price = g_userData:get('gold')
	
	elseif (price_type == 'money') then
		user_price = 9999999

	elseif (price_type == 'honor') then
		user_price = g_userData:get('hornor')

    else
        error('price_type : ' .. price_type)
    end

    -- 개수 확인
    if (price_value <= user_price) then
        local msg = TableShop:makePriceDesc(price_type, price_value) .. '{@BLACK}를 소비하여 구매합니다.\n구매하시겠습니까?'
        return true, msg
    else
        local need_price_str = comma_value(price_value - user_price)
        local msg = ''
        if (price_type == 'cash') then
            msg = Str('다이아몬드 {1}개가 부족합니다.', comma_value(need_price_str))

        elseif (price_type == 'amethyst') then
            msg = Str('자수정 {1}개가 부족합니다.', comma_value(need_price_str))

        elseif (price_type == 'gold') then
            msg = Str('골드 {1}개가 부족합니다.', comma_value(need_price_str))

        else
            error('price_type : ' .. price_type)
        end
        return false, msg
    end
end

-------------------------------------
-- function applyQuestInfo
-- @breif 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_ShopOld:applyGoods(data, key)
    self.m_serverData:applyServerData(data, 'user', key)
end

-------------------------------------
-- function request_shopInfo
-------------------------------------
function ServerData_ShopOld:request_shopInfo(cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_productTable = TableShop(ret['shop_table'])
		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/info')
    ui_network:setParam('uid', uid)
	ui_network:setParam('tid', tid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_buy
-- @brief 상품 구매
-------------------------------------
function ServerData_ShopOld:request_buy(product_id, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)        
        g_serverData:networkCommonRespone_addedItems(ret)

        g_topUserInfo:refreshData()

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/buy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', product_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function openShopPopup
-- @brief
--        1. 상점 리스트를 서버에서 받아옴
--           (리스트를 받아오지 못하였을 경우 종료)
--        2. 상점 UI를 생성
--        3. 지정된 상점 tab이 있을 경우 경우 tab 설정
-------------------------------------
function ServerData_ShopOld:openShopPopup(tab_type)
    local function cb_func()
        local ui_shop_popup = UI_ShopPopup()

        if tab_type then
            ui_shop_popup:setTab(tab_type)
        end
    end

    -- 서버에 상품정보 요청
	g_shopData:request_shopInfo(cb_func)
end

----------------------------------------------------------------------------------------------------------------------------------------------------
-- 아래 코드들은 임시

-------------------------------------
-- function tempBuy
-- @brief 임시 구매
-------------------------------------
function ServerData_ShopOld:tempBuy(l_Product_table, price_type, price_value)
	local func_pay
	local func_receive

	-- 상품 가격 지불
	func_pay = function()
		self:network_ProductPay(price_type, price_value, func_receive)
	end

	-- 상품 받기
	func_receive = function()
		for product_type, product_value in pairs(l_Product_table) do 
			self:network_ProductReceive(product_type, product_value)
		end
	end

	func_pay()
end

-------------------------------------
-- function network_ProductPay
-- @brief 상품 가격 지불
-------------------------------------
function ServerData_ShopOld:network_ProductPay(price_type, price_value, finish_cb)
    local cash = g_userData:get('cash')
    local amethyst = g_userData:get('amethyst')
    local gold = g_userData:get('gold')
    local honor = g_userData:get('honor')

    do -- 재화 사용
        -- 지불
        if (price_type == 'x') then
            finish_cb()
            return

        elseif (price_type == 'cash') then
            cash = (cash - price_value)

        elseif (price_type == 'amethyst') then
            amethyst = (amethyst - price_value)

        elseif (price_type == 'gold') then
            gold = (gold - price_value)

        elseif (price_type == 'money') then

		elseif (price_type == 'honor') then
            honor = (honor - price_value)

        else
            error('price_type : ' .. price_type)
        end
    end

    -- Network
    local b_revocable = true
    return self:network_updateGoldAndCash(gold, cash, amethyst, honor, finish_cb, b_revocable)
end

-------------------------------------
-- function network_ProductReceive
-- @brief 상품 받기
-------------------------------------
function ServerData_ShopOld:network_ProductReceive(product_type, product_value, finish_cb)
    local cash = g_userData:get('cash')
    local amethyst = g_userData:get('amethyst')
    local gold = g_userData:get('gold')
    local honor = g_userData:get('honor')
    local staminas_st = g_staminasData:getStaminaCount('st')

    -- 구매 상품 추가
    if (product_type == 'x') then

    elseif (product_type == 'cash') then
        cash = (cash + product_value)
        return self:network_updateGoldAndCash(gold, cash, amethyst, honor, finish_cb, false)

    elseif (product_type == 'amethyst') then
        amethyst = (amethyst + product_value)
        return self:network_updateGoldAndCash(gold, cash, amethyst, honor, finish_cb, false)

    elseif (product_type == 'gold') then
        gold = (gold + product_value)
        return self:network_updateGoldAndCash(gold, cash, amethyst, honor, finish_cb, false)

    elseif (product_type == 'stamina') then
        staminas_st = (staminas_st + product_value)
        return self:network_updateStaminas_st(staminas_st, finish_cb, b_revocable)

    else
        error('product_type : ' .. product_type)
    end
end

-------------------------------------
-- function network_updateGoldAndCash
-- @brief 골드, 캐시 동기화
-------------------------------------
function ServerData_ShopOld:network_updateGoldAndCash(gold, cash, amethyst, honor, finish_cb, b_revocable)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end
        g_topUserInfo:refreshData()
		if (finish_cb) then
			finish_cb()
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/update')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'update')
    ui_network:setParam('gold', gold)
    ui_network:setParam('cash', cash)
    ui_network:setParam('amethyst', amethyst)
    ui_network:setParam('honor', honor)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:setRevocable(b_revocable)
    ui_network:request()
end

-------------------------------------
-- function network_updateStaminas_st
-- @brief 모험모드 활동력
-------------------------------------
function ServerData_ShopOld:network_updateStaminas_st(staminas_st, finish_cb, b_revocable)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end
        g_topUserInfo:refreshData()
		if (finish_cb) then
			finish_cb()
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/update')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'update')
    ui_network:setParam('staminas', 'st,' .. staminas_st)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:setRevocable(b_revocable)
    ui_network:request()
end
