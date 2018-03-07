local PARENT = UI

-------------------------------------
-- class UI_ShopDaily
-------------------------------------
UI_ShopDaily = class(PARENT,{
        m_cbBuy = 'function',
        m_data = 'table',
        m_isPopup = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopDaily:init(is_popup)
    local vars = self:load('package_daily_shop.ui')
    self.m_isPopup = is_popup or false
	self.m_uiName = 'UI_ShopDaily'

    if (self.m_isPopup) then
        UIManager:open(self, UIManager.POPUP)
            -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ShopDaily')
    end
    
    self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ShopDaily:initUI()
    local vars = self.vars
    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ShopDaily:initButton()
    local vars = self.vars
    vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ShopDaily:refresh()
    local vars = self.vars
    local l_item_list = g_shopDataNew:getProductList('daily')
    
    local idx = 0
    for pid, struct_product in pairs(l_item_list) do
        idx = idx + 1

        -- 상품 정보가 없다면 구매제한을 넘겨 서버에서 준 정보가 없는 경우라 판단
        if (not struct_product) then
            vars['priceNode'..idx]:setVisible(false)
            vars['priceLabel'..idx]:setVisible(false)
            vars['buyLabel'..idx]:setVisible(false)
            vars['buyBtn'..idx]:setVisible(false)

            vars['completeNode'..idx]:setVisible(true)
        else
            -- 구매 제한
            local str = struct_product:getMaxBuyTermStr()

            -- 구매 가능/불가능 텍스트 컬러 변경
            local is_buy_all = struct_product:isBuyAll()
            local color_key = is_buy_all and '{@impossible}' or '{@available}'
            local rich_str = color_key .. str
            vars['buyLabel'..idx]:setString(rich_str)

	        -- 가격
	        local price = struct_product:getPriceStr()
            vars['priceLabel'..idx]:setString(price)

			-- 구매 완료 표시
            local buy_all = struct_product:isBuyAll()
			vars['completeNode' .. idx]:setVisible(buy_all)

            vars['buyBtn' .. idx]:setEnabled(not buy_all)
            vars['buyBtn' .. idx]:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)
        end
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_ShopDaily:click_buyBtn(struct_product)
	local function cb_func(ret)
        if (self.m_cbBuy) then
            self.m_cbBuy()
        end

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
        
        self:refresh()
        g_highlightData:setHighlightMail()
	end

	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_ShopDaily:click_infoBtn()
    GoToAgreeMentUrl()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ShopDaily:click_closeBtn()
    self:close()
end

-------------------------------------
-- function setBuyCB
-------------------------------------
function UI_ShopDaily:setBuyCB(func)
    self.m_cbBuy = func
end