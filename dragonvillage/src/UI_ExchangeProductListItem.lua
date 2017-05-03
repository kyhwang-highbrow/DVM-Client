local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ExchangeProductListItem
-------------------------------------
UI_ExchangeProductListItem = class(PARENT, {
        m_structExchangeProductData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ExchangeProductListItem:init(struct_data)
    self.m_structExchangeProductData = struct_data

    local vars = self:load('event_exchange_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExchangeProductListItem:initUI()
    local vars = self.vars

    local struct_data = self.m_structExchangeProductData

    do -- 상품 아이콘
        local sprite = cc.Sprite:create(struct_data.m_productRes)
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        vars['iconNode']:addChild(sprite)
    end

    do -- 지불 타입 아이콘
        for i = 1, 3 do
            local price_type = struct_data['m_priceType' .. i]
            local price_value = struct_data['m_priceValue' .. i]

            if (price_type and price_value) then
                local icon_res = TableExchange:makePriceIconRes(price_type)
                local price_icon = cc.Sprite:create(icon_res)
		        if price_icon then
			        price_icon:setDockPoint(cc.p(0.5, 0.5))
			        price_icon:setAnchorPoint(cc.p(0.5, 0.5))
			        vars['priceNode' .. i]:addChild(price_icon)
		        end

                local price_str = TableExchange:makePriceDesc(price_type, price_value)
                vars['priceLabel' .. i]:setString(price_str)
            else
                vars['priceLabel' .. i]:setString('')
            end
        end
    end

    -- 상품 이름
	local product_name = TableShop:makeProductName(struct_data.m_lProductList)
    vars['titleLabel']:setString(product_name)

    -- 남은 시간
    vars['timeLabel']:setString('')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExchangeProductListItem:initButton()
    local vars = self.vars
    if vars['exchangeBtn'] then
        vars['exchangeBtn']:registerScriptTapHandler(function() self:click_exchangeBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExchangeProductListItem:refresh()
    local vars = self.vars

    local struct_data = self.m_structExchangeProductData

    -- 구매 횟수
    if (struct_data.m_maxBuyCount > 0) then
        vars['numberLabel']:setString(Str('{1}/{2}', struct_data.m_buyCount, struct_data.m_maxBuyCount))
    else
        vars['numberLabel']:setString(Str('무제한'))
    end
end

-------------------------------------
-- function click_exchangeBtn
-------------------------------------
function UI_ExchangeProductListItem:click_exchangeBtn()
    -- TODO: 교환처리

end