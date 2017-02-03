-------------------------------------
-- class ServerData_Shop
-------------------------------------
ServerData_Shop = class({
        m_serverData = 'ServerData',
		m_tableShop = 'TableShop',
		m_workedData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Shop:init(server_data)
    self.m_serverData = server_data
	self.m_tableShop = TableShop()
	self.m_workedData = {}
end

-------------------------------------
-- function getProductList
-- @brief product_type 으로 상품들을 가져온다
-------------------------------------
function ServerData_Shop:getProductList(product_type)
	return self.m_tableShop:filterList('product_type', product_type)
end

-------------------------------------
-- function canBuyProduct
-- @brief 구매 가능 여부 검사
-------------------------------------
function ServerData_Shop:canBuyProduct(t_product)
    local t_product = t_product

    local price_type = t_product['price_type']
    local price_value = t_product['price']
    local user_price = 0

    -- 지불 재화 개수 저장
    if (price_type == 'x') then
        user_price = 0

    elseif (price_type == 'cash') then
        user_price = g_userData:get('cash')

    elseif (price_type == 'gold') then
        user_price = g_userData:get('gold')

    else
        error('price_type : ' .. price_type)
    end

    -- 개수 확인
    if (price_value <= user_price) then
        local msg = '{@TAN}[' .. t_product['t_ui_info']['product_name'] .. ']{@BLACK}상품을 \n {@DEEPSKYBLUE}'
        msg = msg .. t_product['t_ui_info']['price_name'] .. '{@BLACK}를 소비하여 구매합니다.\n구매하시겠습니까?'
        return true, msg
    else
        local need_price_str = comma_value(price_value - user_price)
        local msg = ''
        if (price_type == 'cash') then
            msg = Str('루비 {1}개가 부족합니다.', comma_value(need_price_str))

        elseif (price_type == 'gold') then
            msg = Str('골드 {1}개가 부족합니다.', comma_value(need_price_str))

        else
            error('price_type : ' .. price_type)
        end
        return false, msg
    end
end

-------------------------------------
-- function tempBuy
-- @brief 임시 구매
-------------------------------------
function ServerData_Shop:tempBuy(t_product)
    local t_product = t_product
    local value_type = t_product['value_type']

    if (value_type == 'stamina') then
        UIManager:toastNotificationRed(Str('날개 구매는 상점 개편 후에 제공될 예정입니다.'))
        return
    end

    local func_pay
    local func_receive
    local func_show_result

    -- 상품 가격 지불
    func_pay = function()
        self:network_ProductPay(t_product, func_receive)
    end

    -- 상품 받기
    func_receive = function()
        self:network_ProductReceive(t_product, func_show_result)
    end

    -- 결과 팝업
    func_show_result = function(t_data)
        if string.find(value_type, 'dragon') then
            local l_dragon_list = t_data
            UI_DragonGachaResult(l_dragon_list)
        end
    end

	if (t_product['product_type'] == TableShop.GACHA) then
		self:request_gacha_dragons(value_type, t_product['value'], func_show_result)
	else
		func_pay()
	end
end

-------------------------------------
-- function applyQuestInfo
-- @breif 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_Shop:applyGoods(data, key)
    self.m_serverData:applyServerData(data, 'user', key)
end

-------------------------------------
-- function request_gacha_dragons
-- @brief 드래곤 가차를 요청한다
-------------------------------------
function ServerData_Shop:request_gacha_dragons(product_type, product_value, finish_cb)
	-- 파라미터 세팅
    local uid = g_userData:get('uid')
	local gacha_url
	if (product_type == 'dragon_normal') then
		gacha_url = '/shop/gacha/general_dragon'
	elseif (product_type == 'dragon_premium') then
		gacha_url = '/shop/gacha/unique_dragon'
	end
	local gacha_type
	if (product_value == 1) then 
		gacha_type = 'single'
	elseif (product_value == 11) then 
		gacha_type = 'bundle'
	end

	-- 성공 시 콜백
	local cb_func = function(ret)
		local isDirtyData = false

		-- 받은 정보 갱신
        if (ret and ret['added_dragons']) then
			for _, t_dragon in ipairs(ret['added_dragons']) do
				g_dragonsData:applyDragonData(t_dragon)
			end
        end

		-- @TODO 재화를 통일적으로 처리하는 방식 찾거나 만들어야함
		if (ret['gold']) then
			self:applyGoods(ret['gold'], 'gold')
			isDirtyData = true
		end
		if (ret['cash']) then
			self:applyGoods(ret['cash'], 'cash')
			isDirtyData = true
		end

		-- 데이터 변동시에 콜백 실행
		if (isDirtyData) then 
			finish_cb(ret['added_dragons'])
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl(gacha_url)
    ui_network:setParam('uid', uid)
	ui_network:setParam('type', gacha_type)
    ui_network:setSuccessCB(cb_func)
	ui_network:request()
end


----------------------------------------------------------------------------------------------------------------------------------------------------
-- 아래 코드들은 임시

-------------------------------------
-- function network_ProductPay
-- @brief 상품 가격 지불
-------------------------------------
function ServerData_Shop:network_ProductPay(t_product, finish_cb)
    local t_product = t_product

    local value_type = t_product['value_type']
    local value = t_product['value']

    local cash = g_userData:get('cash')
    local gold = g_userData:get('gold')

    do -- 재화 사용
        local price_type = t_product['price_type']
        local price_value = t_product['price']

        -- 지불
        if (price_type == 'x') then
            finish_cb()
            return

        elseif (price_type == 'cash') then
            cash = (cash - price_value)

        elseif (price_type == 'gold') then
            gold = (gold - price_value)

        else
            error('price_type : ' .. price_type)
        end
    end

    -- Network
    local b_revocable = true
    return self:network_updateGoldAndCash(gold, cash, finish_cb, b_revocable)
end

-------------------------------------
-- function network_ProductReceive
-- @brief 상품 받기
-------------------------------------
function ServerData_Shop:network_ProductReceive(t_product, finish_cb)
    local t_product = t_product

    local value_type = t_product['value_type']
    local value = t_product['value']

    local cash = g_userData:get('cash')
    local gold = g_userData:get('gold')

    -- 구매 상품 추가
    if (value_type == 'x') then

    elseif (value_type == 'cash') then
        cash = (cash + value)
        return self:network_updateGoldAndCash(gold, cash, finish_cb, false)

    elseif (value_type == 'gold') then
        gold = (gold + value)
        return self:network_updateGoldAndCash(gold, cash, finish_cb, false)

    elseif (value_type == 'stamina') then
        -- @TODO 스태미너 추가
        g_topUserInfo:refreshData()
        return

    else
        error('value_type : ' .. value_type)
    end
end

-------------------------------------
-- function network_updateGoldAndCash
-- @brief 골드, 캐시 동기화
-------------------------------------
function ServerData_Shop:network_updateGoldAndCash(gold, cash, finish_cb, b_revocable)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end
        g_topUserInfo:refreshData()
        finish_cb()
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/update')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'update')
    ui_network:setParam('gold', gold)
    ui_network:setParam('cash', cash)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:setRevocable(b_revocable)
    ui_network:request()
end
