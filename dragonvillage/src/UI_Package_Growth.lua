local PARENT = UI

-------------------------------------
-- class UI_Package_Growth
-------------------------------------
UI_Package_Growth = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_Growth:init()
    local vars = self:load('package_weekly.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_Growth')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_Growth:initUI()
    local vars = self.vars

    local l_item_list = g_shopDataNew:getProductList('package')
    local target_product = {90013, 90014}

    for idx, pid in ipairs(target_product) do
        local struct_product = l_item_list[pid]
        local l_item_list = ServerData_Item:parsePackageItemStr(struct_product['product_content'])

        -- 구성품
        if (l_item_list) then
            local str = ''
            for _idx, data in ipairs(l_item_list) do
                local name = TableItem:getItemName(data['item_id'])
                local cnt = data['count']
                local msg = Str('\n{1} {2}개', name, cnt)

                str =  str ~= '' and str .. msg or msg
            end

            local label = vars['itemLabel'..idx]
            if (label) then
                label:setString(str)
            end
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
function UI_Package_Growth:initButton()
	local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_Growth:click_buyBtn(struct_product)

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
function UI_Package_Growth:click_infoBtn()
    local url = URL['PERPLELAB_AGREEMENT']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package_Growth:click_closeBtn()
    self:closeWithAction()
end