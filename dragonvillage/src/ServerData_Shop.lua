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

    elseif string.find(value_type, 'dragon') then
        local count = value
        local l_dragon_list = self:tempGacha(count)
        return self:network_gacha_AddDragons(l_dragon_list, finish_cb)

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

-------------------------------------
-- function network_gacha_AddDragons
-- @brief 드래곤들 추가
-------------------------------------
function ServerData_Shop:network_gacha_AddDragons(l_dragon_id, finish_cb)
    local uid = g_userData:get('uid')
    local table_dragon = TABLE:get('dragon')
    local t_list = clone(l_dragon_id)
    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/dragons/add')
    ui_network:setParam('uid', uid)

    do_work = function(ret)
        if (ret and ret['dragons']) then
            for _,t_dragon in pairs(ret['dragons']) do
                g_dragonsData:applyDragonData(t_dragon)
            end
        end

        local t_dragon = t_list[1]
        
        if t_dragon then
            table.remove(t_list, 1)
            local did = t_dragon['did']
            local evolution = t_dragon['evolution']
            --local msg = '"' .. table_dragon[did]['t_name'] .. '"드래곤 추가 중...'
            --ui_network:setLoadingMsg(msg)
            ui_network:setParam('did', did)
            ui_network:setParam('evolution', evolution or 1)
            ui_network:request()
        else
            ui_network:close()
            finish_cb(l_dragon_id)
        end
    end
    ui_network:setSuccessCB(do_work)
    do_work()
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

    func_pay()
end

-------------------------------------
-- function tempGacha
-- @brief
-------------------------------------
function ServerData_Shop:tempGacha(count)
    local table_gacha = TABLE:get('gacha')
    local t_ret = {}

    -- 랜덤 클래스 생성
    local sum_random = SumRandom()
    for i,v in pairs(table_gacha) do
        if (v['test'] == 1) then
            --local did = v['did']
            local table_idx = i
            local rate = v['rate']
            sum_random:addItem(rate, table_idx)
        end
    end

    -- 뽑힌 드래곤 저장
    local l_dragon_gatch = {} -- {did, evolution}
    for i=1, count do
        -- 드래곤 ID
        local table_idx = sum_random:getRandomValue()
        local t_gacha = table_gacha[table_idx]
        local did = t_gacha['did']

        -- 진화도 랜덤
        local evolution
        do
            local sum_random_evolution = SumRandom()
            sum_random_evolution:addItem(t_gacha['hatch_rate'], 1)
            sum_random_evolution:addItem(t_gacha['hatcling_rate'], 2)
            sum_random_evolution:addItem(t_gacha['adult_rate'], 3)
            evolution = sum_random_evolution:getRandomValue()     
        end

        -- 테이블에 추가
        table.insert(t_ret, {did=did, evolution=evolution})
    end

    return t_ret
end