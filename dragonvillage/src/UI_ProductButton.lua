local PARENT = UI

-------------------------------------
-- class UI_ProductButton
-------------------------------------
UI_ProductButton = class(PARENT, {
        m_ownerUI = 'UI',
        m_productID = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ProductButton:init(owner_ui, product_id)
    self.m_ownerUI = owner_ui
    self.m_productID = product_id

    local vars = self:load('product_button.ui')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ProductButton:initUI()
    local vars = self.vars
    local product_id = self.m_productID

    local table_shop = TABLE:get('shop')
    local t_shop = table_shop[product_id]

    -- 버튼 핸들러 등록
    vars['mainBtn']:registerScriptTapHandler(function() self:click_mainBtn() end)

    do -- 상품 아이콘 생성
        local sprite = cc.Sprite:create(t_shop['icon'])
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        vars['iconDock']:addChild(sprite)
    end

    -- 상품 개수 지정
    vars['valueLabel']:setString(self:makeValueName(t_shop))
    vars['priceLabel']:setString(self:makePriceName(t_shop))
    
    do -- 지불 타입
        local price_icon = self:makePriceIcon(t_shop)
        if price_icon then
            vars['priceIconDock']:addChild(price_icon)
        end
    end

end

-------------------------------------
-- function makeValueName
-- @breif 상품 이름 생성
-- @param t_shop table
-- @return str string
-------------------------------------
function UI_ProductButton:makeValueName(t_shop)
    local value_type = t_shop['value_type']
    local value = t_shop['value']
    local value_str = comma_value(value)
    local str = ''

    if (value_type == 'x') then

    elseif (value_type == 'cash') then
        str = Str('{1} 캐시', value_str)

    elseif (value_type == 'gold') then
        str = Str('{1} 골드', value_str)

    elseif (value_type == 'stamina') then
        str = Str('날개 {1}개', value_str)

    elseif (value_type == 'card') then
        str = Str('드래곤 카드 {1}팩', value_str)

    else
        error('value_type : ' .. value_type)
    end

    return str
end

-------------------------------------
-- function makePriceName
-- @breif 지불 재화 이름 생성
-- @param t_shop table
-- @return str string
-------------------------------------
function UI_ProductButton:makePriceName(t_shop)
    local price_type = t_shop['price_type']
    local price = t_shop['price']
    local price_str = comma_value(price)
    local str = ''

    if (price_type == 'x') then
        str = Str('[무료]')

    elseif (price_type == 'cash') then
        str = Str('{1} 캐시', price_str)

    elseif (price_type == 'gold') then
        str = Str('{1} 골드', price_str)

    elseif (price_type == 'stamina') then
        str = Str('날개 {1}개', price_str)

    elseif (price_type == 'card') then
        str = Str('드래곤카드 {1}팩', price_str)

    else
        error('price_str : ' .. price_str)
    end

    return str
end

-------------------------------------
-- function makePriceIcon
-- @brief 지불 재화 아이콘 생성
-------------------------------------
function UI_ProductButton:makePriceIcon(t_shop)
    local price_type = t_shop['price_type']

    local res = nil

    if (price_type == 'x') then

    elseif (price_type == 'cash') then
        res = 'res/ui/icon_ruby.png'

    elseif (price_type == 'gold') then
        res = 'res/ui/icon_gold.png'

    elseif (price_type == 'stamina') then
        res = 'res/ui/icon_actingpower.png'

    elseif (price_type == 'card') then

    else
        error('price_type : ' .. price_type)
    end

    if res then
        local sprite = cc.Sprite:create(res)
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        return sprite
    end

    return nil
end


-------------------------------------
-- function click_mainBtn
-- @brief 상품 버튼 클릭
-------------------------------------
function UI_ProductButton:click_mainBtn()
    local can_buy, msg =  self:canBuyProduct(self.m_productID)

    if can_buy then
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, function() self:tempBuy(self.m_productID) end)
    else
        UIManager:toastNotificationRed(msg)
        self:nagativeAction()
    end
end

-------------------------------------
-- function canBuyProduct
-- @brief 구매 가능 여부 검사
-------------------------------------
function UI_ProductButton:canBuyProduct(product_id)
    local table_shop = TABLE:get('shop')
    local t_shop = table_shop[product_id]

    local price_type = t_shop['price_type']
    local price_value = t_shop['price']
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
        local msg = '{@TAN}[' .. self:makeValueName(t_shop) .. ']{@BLACK}상품을 \n {@DEEPSKYBLUE}'
        msg = msg .. self:makePriceName(t_shop) .. '{@BLACK}를 소비하여 구매합니다.\n구매하시겠습니까?'
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
function UI_ProductButton:network_ProductPay(product_id, finish_cb)
    local table_shop = TABLE:get('shop')
    local t_shop = table_shop[product_id]

    local value_type = t_shop['value_type']
    local value = t_shop['value']

    local cash = g_userData:get('cash')
    local gold = g_userData:get('gold')

    do -- 재화 사용
        local price_type = t_shop['price_type']
        local price_value = t_shop['price']

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
function UI_ProductButton:network_ProductReceive(product_id, finish_cb)
    local table_shop = TABLE:get('shop')
    local t_shop = table_shop[product_id]

    local value_type = t_shop['value_type']
    local value = t_shop['value']

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
        g_userDataOld.m_staminaList['st_ad']:addStamina(value)
        self:refreshData()
        return

    elseif (value_type == 'card') then
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
function UI_ProductButton:network_updateGoldAndCash(gold, cash, finish_cb, b_revocable)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end
        self:refreshData()
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
function UI_ProductButton:network_gacha_AddDragons(l_dragon_id, finish_cb)
    local uid = g_userData:get('uid')
    local table_dragon = TABLE:get('dragon')
    local t_list = l_dragon_id or {}
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
function UI_ProductButton:tempBuy(product_id)
    local table_shop = TABLE:get('shop')
    local t_shop = table_shop[product_id]
    local value_type = t_shop['value_type']


    local func_pay
    local func_receive
    local func_show_result

    -- 상품 가격 지불
    func_pay = function()
        self:network_ProductPay(product_id, func_receive)
    end

    -- 상품 받기
    func_receive = function()
        self:network_ProductReceive(product_id, func_show_result)
    end

    -- 결과 팝업
    func_show_result = function(t_data)

        if (value_type == 'card') then
            UIManager:toastNotificationGreen('드래곤이 인벤에 추가되었습니다.')
            UIManager:toastNotificationGreen('가챠 연출은 구현 예정입니다.')
        end
    end

    func_pay()
end

-------------------------------------
-- function nagativeAction
-------------------------------------
function UI_ProductButton:nagativeAction()
    local node = self.vars['mainBtn']

    local start_action = cc.MoveTo:create(0.05, cc.p(-20, 0))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(0, 0)), 0.2)
    node:runAction(cc.Sequence:create(start_action, end_action))
end

-------------------------------------
-- function refreshData
-------------------------------------
function UI_ProductButton:refreshData()
    if self.m_ownerUI then
        if self.m_ownerUI.refreshData then
            self.m_ownerUI:refreshData()
        end
    end
    g_topUserInfo:refreshData()
end

-------------------------------------
-- function tempGacha
-- @brief
-------------------------------------
function UI_ProductButton:tempGacha(count)
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