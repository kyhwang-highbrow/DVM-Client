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
    local vars = self:load('package_daily_dia.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SubscriptionPopup')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SubscriptionPopup:initUI()
    local vars = self.vars

    do -- 월정액 패키지 (basic)
        local struct_product = g_subscriptionData:getBasicSubscriptionProductInfo()
        self.m_basicProduct = struct_product

        -- 구성품
        local full_str = struct_product:getDesc()
        vars['itemLabel1']:setString(full_str)

        -- 가격
	    local price = struct_product:getPriceStr()
        vars['priceLabel1']:setString(price)

        -- 가격 아이콘
        local icon = struct_product:makePriceIcon()
        vars['priceNode1']:addChild(icon)
    end

    do -- Premium 월정액 패키지 (premium)
        local struct_product = g_subscriptionData:getPremiumSubscriptionProductInfo()
        self.m_premiumProduct = struct_product

        -- 구성품
        local full_str = struct_product:getDesc()
        vars['itemLabel2']:setString(full_str)

        -- 가격
	    local price = struct_product:getPriceStr()
        vars['priceLabel2']:setString(price)

        	-- 가격 아이콘
        local icon = struct_product:makePriceIcon()
        vars['priceNode2']:addChild(icon)

    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SubscriptionPopup:initButton()
	local vars = self.vars
    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn(self.m_basicProduct) end)
    vars['buyBtn2']:registerScriptTapHandler(function() self:click_buyBtn(self.m_premiumProduct) end)
    vars['adBtn']:registerScriptTapHandler(function() self:click_adBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    
    vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UI_SubscriptionPopup:update(dt)
    -- 광고 (자동재화, 선물상자 정보)
    do
        local vars = self.vars
        local msg1, enable1 = g_advertisingData:getCoolTimeStatus(AD_TYPE.AUTO_ITEM_PICK)
        vars['adBtn']:setEnabled(enable1)
    end
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_SubscriptionPopup:click_contractBtn()
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
-- function click_adBtn
-------------------------------------
function UI_SubscriptionPopup:click_adBtn()
    local ad_type = AD_TYPE.AUTO_ITEM_PICK

    local function finish_cb()
        self:close()
    end

    g_advertisingData:showAdv(ad_type, finish_cb)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SubscriptionPopup:click_closeBtn()
    self:close()
end