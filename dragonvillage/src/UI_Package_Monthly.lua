local PARENT = UI

-------------------------------------
-- class UI_Package_Monthly
-------------------------------------
UI_Package_Monthly = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_Monthly:init(is_popup)
    local vars = self:load('package_monthly.ui')
	if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
    end

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_Monthly')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton(is_popup)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_Monthly:initUI()
    local vars = self.vars

    local l_item_list = g_shopDataNew:getProductList('package')
    local target_product = {90007, 90008, 90009}

    for idx, pid in ipairs(target_product) do
        local struct_product = l_item_list[pid]

        -- 구성품
        local full_str = ServerData_Item:getPackageItemFullStr(struct_product['product_content'])
        local label = vars['itemLabel'..idx]
        if (label) then
            label:setString(full_str)
        end

        -- 구매 제한
        local limit = struct_product:getMaxBuyTermStr()
        vars['buyLabel'..idx]:setString(limit)

	    -- 가격
	    local price = struct_product:getPriceStr()
        vars['priceLabel'..idx]:setString(price)

	    -- 가격 아이콘
        local icon = struct_product:makePriceIcon()
        vars['priceNode'..idx]:addChild(icon)

        vars['buyBtn'..idx]:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Monthly:initButton(is_popup)
	local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)

    if (not is_popup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_Monthly:click_buyBtn(struct_product)

	local function cb_func(ret)
		self:closeWithAction()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
	end
	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_Package_Monthly:click_infoBtn()
    local url = URL['PERPLELAB_AGREEMENT']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package_Monthly:click_closeBtn()
    self:closeWithAction()
end