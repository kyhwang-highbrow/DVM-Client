local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_RandomShopListItem
-------------------------------------
UI_RandomShopListItem = class(PARENT, {
        m_structItem = 'StructRandomShopItem',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_RandomShopListItem:init(data)
    self.m_structItem = data
    local vars = self:load('shop_random_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RandomShopListItem:initUI()
    local vars = self.vars
    local struct_item = self.m_structItem

    do -- 이름
        local name = struct_item:getName()
        vars['itemLabel']:setString(name)
    end

    do -- 아이템 카드
        local card = struct_item:getCard()
        vars['itemNode']:addChild(card.root)
    end

    -- 할인 마크
    local is_sale = struct_item:isSale()
    if (is_sale) then
        local sale_value = struct_item:getSaleValue()
        local path = string.format('ui/typo/ko/badge_discount_%d.png', sale_value)
        local badge = cc.Sprite:create('res/' .. Translate:getTranslatedPath(path))
        if (badge) then
            badge:setAnchorPoint(CENTER_POINT)
            badge:setDockPoint(CENTER_POINT)
            vars['badgeNode']:addChild(badge)
        end
    end

    -- 가격 정보
    local l_price_type, l_final_price, l_origin_price = struct_item:getPriceInofList()

    -- 구매 가능한 재화 한개일 경우
    if (#l_price_type == 1) then
        vars['buyBtn']:setVisible(true)

        -- 구매 재화 아이콘
        local icon = IconHelper:getPriceIcon(l_price_type[1])
        if (icon) then
            vars['priceNode']:addChild(icon)
        end
        -- 최종 가격
        local price = l_final_price[1]
        vars['priceLabel']:setString(comma_value(price))
        -- 가격 아이콘 및 라벨, 배경 조정
		UIHelper:makePriceNodeVariable(nil,  vars['priceNode'], vars['priceLabel'])

        -- 할인중이라면 원래 가격 표시
        if (is_sale) then
            local origin_price = l_origin_price[1]
            vars['saleNode']:setVisible(true)
            vars['saleLabel']:setString(comma_value(origin_price))
        end

    -- 구매 가능한 재화 여러개일 경우
    else
        vars['buyBtn']:setVisible(false)

        -- 구매 재화 아이콘
        for i, price_type in ipairs(l_price_type) do
            vars['buyBtn'..i]:setVisible(true)

            local icon = IconHelper:getPriceIcon(price_type)
            if (icon) then
                vars['priceNode'..i]:addChild(icon)
            end
        end
        -- 최종 가격
        for i, price in ipairs(l_final_price) do
            vars['priceLabel'..i]:setString(comma_value(price))
        end

        -- 할인중이라면 원래 가격 표시
        if (is_sale) then
            for i, price in ipairs(l_origin_price) do
                vars['saleNode'..i]:setVisible(true)
                vars['saleLabel'..i]:setString(comma_value(price))
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RandomShopListItem:initButton()
    local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn(1) end) -- 1번째 재화로 구매
    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn(1) end) -- 1번째 재화로 구매
    vars['buyBtn2']:registerScriptTapHandler(function() self:click_buyBtn(2) end) -- 2번째 재화로 구매
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RandomShopListItem:refresh()
    local vars = self.vars
    local struct_item = self.m_structItem

    -- 구매 완료 한 상태면 
    if (not struct_item:isBuyable()) then
        vars['completeNode']:setVisible(true)
        vars['blockBtn']:setVisible(true)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_RandomShopListItem:click_buyBtn(idx)
    local struct_item = self.m_structItem
    local l_price_type, l_final_price = struct_item:getPriceInofList()
    local product_idx = struct_item:getProductIdx()
    local price = l_final_price[idx]
    local price_type = l_price_type[idx]

    -- 재화 부족
    if (not ConfirmPrice(price_type, price)) then
        return
    end

    local function cb_func(ret)
        local data = ret['info']['products'][tostring(product_idx)]
        self.m_structItem = StructRandomShopItem(data)
        self.m_structItem['product_idx'] = product_idx
        self:refresh()
    end

    local function ok_btn_cb()
        -- 구매 api 호출
        g_randomShopData:request_buy(product_idx, price_type, cb_func)
    end

    local name = struct_item:getName()
    local cnt = struct_item:getCount()
    local msg = Str('{@item_name}"{1} x{2}"\n{@default}구매하시겠습니까?', name, cnt)
    UI_ConfirmPopup(price_type, price, msg, ok_btn_cb)
end