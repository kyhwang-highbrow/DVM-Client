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
    local vars = self:load('shop_random_item_new.ui')

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

        -- 구매 재화 아이콘
        local icon = IconHelper:getPriceIcon(l_price_type[1])
        if (icon) then
            vars['priceNode1']:addChild(icon)
        end
        -- 최종 가격
        local price = l_final_price[1]
        vars['priceLabel1']:setString(comma_value(price))

    -- 구매 가능한 재화 여러개일 경우
    else
        -- 구매 재화 아이콘
        for i, price_type in ipairs(l_price_type) do
            vars['priceSprite'..i]:setVisible(true)

            local icon = IconHelper:getPriceIcon(price_type)
            if (icon) then
                vars['priceNode'..i]:addChild(icon)
            end
        end
        -- 최종 가격
        for i, price in ipairs(l_final_price) do
            vars['priceLabel'..i]:setString(comma_value(price))
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RandomShopListItem:initButton()
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
    end
end