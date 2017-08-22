local PARENT = UI

-------------------------------------
-- class UI_SubscriptionPopup
-------------------------------------
UI_SubscriptionPopup = class(PARENT, {
        m_basicProduct = 'StructProductSubscription',
        m_premiumProduct = 'StructProductSubscription',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SubscriptionPopup:init()
    local vars = self:load('shop_package_daily_dia_01.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SubscriptionPopup')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SubscriptionPopup:initUI()
    local vars = self.vars

    do -- 월정액 패키지 (basic)
        local struct_product = g_subscriptionData:getBasicSubscriptionProductInfo()
        self.m_basicProduct = struct_product

        -- 가격
	    local price = struct_product:getPriceStr()
        vars['priceLabel1']:setString(price)

        	-- 가격 아이콘
        local icon = struct_product:makePriceIcon()
        vars['priceNode1']:addChild(icon)

        -- 가격 아이콘 및 라벨, 배경 조정
        UIHelper:makePriceNodeVariable(vars['priceBg1'],  vars['priceNode1'], vars['priceLabel1'])
    end

    do -- Premium 월정액 패키지 (premium)
        local struct_product = g_subscriptionData:getPremiumSubscriptionProductInfo()
        self.m_premiumProduct = struct_product

        -- 가격
	    local price = struct_product:getPriceStr()
        vars['priceLabel2']:setString(price)

        	-- 가격 아이콘
        local icon = struct_product:makePriceIcon()
        vars['priceNode2']:addChild(icon)

        -- 가격 아이콘 및 라벨, 배경 조정
        UIHelper:makePriceNodeVariable(vars['priceBg2'],  vars['priceNode2'], vars['priceLabel2'])
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SubscriptionPopup:initButton()
	local vars = self.vars
    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn(self.m_basicProduct) end)
    vars['buyBtn2']:registerScriptTapHandler(function() self:click_buyBtn(self.m_premiumProduct) end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    
    if vars['infoBtn'] then
        vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    end
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_SubscriptionPopup:click_infoBtn()
    local url = URL['PERPLELAB_AGREEMENT']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_SubscriptionPopup:click_buyBtn(struct_product)
	local function cb_func(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)

        local function func()
            g_subscriptionData:setDirty()
            g_subscriptionData:openSubscriptionPopup()
            self:close()
        end
        self:doActionReverse(func, 0.5, false)
	end
	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SubscriptionPopup:click_closeBtn()
    self:closeWithAction()
end