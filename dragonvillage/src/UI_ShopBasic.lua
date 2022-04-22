local PARENT = UI

-------------------------------------
-- class UI_ShopBasic
-------------------------------------
UI_ShopBasic = class(PARENT,{
        m_cbBuy = 'function',
        m_data = 'table',
        m_isPopup = 'boolean',

        m_productList = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopBasic:init(is_popup)
    self.m_isPopup = is_popup or false
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ShopBasic:initUI()    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ShopBasic:initButton()
    local vars = self.vars

    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    else
        vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    end

    vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function checkPopupUI
-------------------------------------
function UI_ShopBasic:checkPopupUI()
    if (not self.m_isPopup) then return end

    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ShopBooster')
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ShopBasic:refresh()

    local vars = self.vars
    local l_item_list = self.m_productList
    
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
function UI_ShopBasic:click_buyBtn(struct_product)
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
function UI_ShopBasic:click_infoBtn()
    GoToAgreeMentUrl()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ShopBasic:click_closeBtn()
    self:close()
end

-------------------------------------
-- function setBuyCB
-------------------------------------
function UI_ShopBasic:setBuyCB(func)
    self.m_cbBuy = func
end








-------------------------------------
-- class UI_ShopDaily ##일일 상점
-------------------------------------
UI_ShopDaily = class(UI_ShopBasic,{})

-------------------------------------
-- function init
-------------------------------------
function UI_ShopDaily:init(is_popup)
    local vars = self:load('package_daily_shop.ui')
	self.m_uiName = 'UI_ShopDaily'
    self:checkPopupUI()

    local map_product = g_shopData:getProductList('daily')
    local l_product = table.MapToList(map_product)
    table.sort(l_product, function(a, b) 
        return a['product_id'] < b['product_id']
    end)

    -- 경험치 부스터, 골드 부스터, 고급 소환권, 골드 패키지 순서여야함
    -- 정렬 후 product_id 검사 - 맞지 않으면 에러 처리
    local check_list = {90084, 90085, 90086, 90090}
    for i, v in ipairs(l_product) do
        local pid = v['product_id']
        if (pid ~= check_list[i]) then
            error('일일 상점 product_id 순서 확인 필요함')
        end
    end

    self.m_productList = l_product
    self:initUI()
	self:initButton()
    self:refresh()
end


-------------------------------------
-- class UI_ShopBooster ##부스터 상점
-------------------------------------
UI_ShopBooster = class(UI_ShopBasic,{})

-------------------------------------
-- function init
-------------------------------------
function UI_ShopBooster:init(is_popup)
    local vars = self:load('shop_booster_01.ui')
	self.m_uiName = 'UI_ShopBooster'
    self:checkPopupUI()
    
    local l_exp_booster = g_shopData:getProductList_byItemType('exp_booster')
    local l_gold_booster = g_shopData:getProductList_byItemType('gold_booster')
    local l_ret = table.merge(l_exp_booster, l_gold_booster)
    table.sort(l_ret, function(a, b) 
        return a['product_id'] < b['product_id']
    end)
    
    -- 경험치 부스터 1일, 골드 부스터 1일, 경험치 부스터 7일, 골드 부스터 7일 순서여야함
    -- 정렬 후 product_id 검사 - 맞지 않으면 에러 처리
    local check_list = {90084, 90085, 90091, 90092}
    local _l_ret = {}

    for i, v in ipairs(l_ret) do
        local pid = v['product_id']
        if (pid == check_list[i]) then
            table.insert(_l_ret, v)
        end
    end

    self.m_productList = _l_ret
    self:initUI()
	self:initButton()
    self:refresh()
end