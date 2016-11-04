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

    -- @TEMP @TODO
    if (t_shop['product_type'] == 'card') then
        return false, '가챠 개편 예정입니다.'
    end

    local price_type = t_shop['price_type']
    local price_value = t_shop['price']
    local user_price = 0

    -- 지불 재화 개수 저장
    if (price_type == 'x') then
        user_price = 0

    elseif (price_type == 'cash') then
        user_price = g_userDataOld.m_userData['cash']

    elseif (price_type == 'gold') then
        user_price = g_userDataOld.m_userData['gold']

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
-- function tempBuy
-- @brief 임시 구매
-------------------------------------
function UI_ProductButton:tempBuy(product_id)
    local table_shop = TABLE:get('shop')
    local t_shop = table_shop[product_id]

    local value_type = t_shop['value_type']
    local value = t_shop['value']

    do -- 재화 사용
        local price_type = t_shop['price_type']
        local price_value = t_shop['price']

        -- 지불
        if (price_type == 'x') then

        elseif (price_type == 'cash') then
            g_userDataOld.m_userData['cash'] = g_userDataOld.m_userData['cash'] - price_value

        elseif (price_type == 'gold') then
            g_userDataOld.m_userData['gold'] = g_userDataOld.m_userData['gold'] - price_value

        else
            error('price_type : ' .. price_type)
        end
    end

    -- 구매 상품 추가
    if (value_type == 'x') then

    elseif (value_type == 'cash') then
        g_userDataOld.m_userData['cash'] = g_userDataOld.m_userData['cash'] + value
        g_userDataOld:addCumulativePurchasesLog('cash', value)

    elseif (value_type == 'gold') then
        g_userDataOld.m_userData['gold'] = g_userDataOld.m_userData['gold'] + value
        g_userDataOld:addCumulativePurchasesLog('gold', value)

    elseif (value_type == 'stamina') then
        g_userDataOld.m_staminaList['st_ad']:addStamina(value)
        g_userDataOld:addCumulativePurchasesLog('stamina', value)

    elseif (value_type == 'card') then
        self:tempGacha()
        g_userDataOld:addCumulativePurchasesLog('gacha', 5)

    else
        error('value_type : ' .. value_type)
    end

    -- 갱신
    g_userDataOld:setDirtyLocalSaveData()
    UIManager.m_topUserInfo:refreshData()
    self:refreshData()
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
end

-------------------------------------
-- function tempGacha
-- @brief
-------------------------------------
function UI_ProductButton:tempGacha()
    local table_dragon = TABLE:get('dragon')

    local t_random = {}
    for i,v in pairs(table_dragon) do
		if (v['test'] == 1) then 
	        table.insert(t_random, i)	
		end
    end

    local l_ret = {}
    for i=1, 5 do
        local rand_num = math_random(1, #t_random)
        local dragon_id = t_random[rand_num]
        table.insert(l_ret, dragon_id)

        local t_dragon_data = g_dragonListData:addDragon(dragon_id)
        --cclog(luadump(t_dragon_data))
    end


    local _showGachaResult = nil
    local function showGachaResult()
        if l_ret[1] then
            local dragon_id = l_ret[1]
            UI_DragonGachaResult(dragon_id, _showGachaResult)
            table.remove(l_ret, 1)
        end
    end
    _showGachaResult = showGachaResult

    showGachaResult()
end