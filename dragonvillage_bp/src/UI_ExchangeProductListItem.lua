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
        local price_type_count = 0

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

                vars['frameNode' .. i]:setVisible(true)

                price_type_count = price_type_count + 1
            else
                vars['frameNode' .. i]:setVisible(false)
            end
        end

        -- 재료 수에 따라 ui 위치 및 크기 조정
        if (price_type_count == 1) then
            vars['frameNode1']:setPosition(0, 114)
            vars['frameNode1']:setContentSize(368, 64)
        elseif (price_type_count == 2) then
            vars['frameNode1']:setPosition(-94, 114)
            vars['frameNode1']:setContentSize(180, 64)
            vars['frameNode2']:setPosition(94, 114)
            vars['frameNode2']:setContentSize(180, 64)
        end
    end

    -- 상품 이름
	local product_name = self:makeProductName(struct_data.m_lProductList)
    vars['titleLabel']:setString(product_name)

    -- 남은 시간
    vars['timeLabel']:setString('')
end

-------------------------------------
-- function makeProductName
-------------------------------------
function UI_ExchangeProductListItem:makeProductName(l_item_list)
    if (not l_item_list) then
        return ''
    end

    if (table.count(l_item_list) <= 0) then
        return ''
    end

    -- 리스트에서 첫 번째 아이템의 id를 얻어옴(첫 번째라고 볼순 없지만 하나의 아이템 ID를 얻어옴)
    local item_id
    for i,_ in pairs(l_item_list) do
        item_id = tonumber(i)
        break
    end

	-- 첫 번째 아이템의 설명을 사용
	local table_item = TableItem()
	local t_desc = table_item:getValue(item_id, 't_desc')
	return Str(t_desc)
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
    local struct_data = self.m_structExchangeProductData

    local function failNoti(msg)
        UIManager:toastNotificationRed(msg)
        self:nagativeAction()
    end

    if (struct_data.m_buyCount >= struct_data.m_maxBuyCount) then
        failNoti(Str('더이상 구매할 수 없는 상품입니다.'))
        return
    end
    
    for i = 1, 3 do
        local price_type = struct_data['m_priceType' .. i]
        local price_value = struct_data['m_priceValue' .. i]

        if (price_type and price_value) then
            local can_buy, msg = g_exchangeData:canBuyProduct(price_type, price_value)
            if (not can_buy) then
                failNoti(msg)
                return
            end
        end
    end

    local product_id = struct_data.m_pid
    local product_name = self:makeProductName(struct_data.m_lProductList)

    local function ok_btn_cb()
        g_exchangeData:request_exchange(product_id, function() self:refresh() end)
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('[{1}] 상품을 교환하시겠습니까?', product_name), ok_btn_cb)
end

-------------------------------------
-- function nagativeAction
-------------------------------------
function UI_ExchangeProductListItem:nagativeAction()
    local node = self.vars['exchangeBtn']

    local start_action = cc.MoveTo:create(0.05, cc.p(-20, 44))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(0, 44)), 0.2)
    node:runAction(cc.Sequence:create(start_action, end_action))
end