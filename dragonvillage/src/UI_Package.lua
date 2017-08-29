local PARENT = UI

-------------------------------------
-- class UI_Package
-------------------------------------
UI_Package = class(PARENT, {
        m_structProduct = 'StructProduct',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Package:init(struct_product, is_popup)
    local ui_name = struct_product['package_res']
    if (not ui_name) then return end

    local vars = self:load(ui_name)
    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
    end
	
	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_structProduct = struct_product

    self:initUI()
	self:initButton(is_popup)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package:initUI()
    local vars = self.vars
	local struct_product = self.m_structProduct

    local l_item_list = ServerData_Item:parsePackageItemStr(struct_product['product_content'])

    -- 성장 패키지는 개수만 표시
    local is_only_cnt = string.find(struct_product['sku'], 'growthpack')

    -- 구성품
    if (l_item_list) then
        for idx, data in ipairs(l_item_list) do
            
            local name = TableItem:getItemName(data['item_id'])
            local cnt = data['count']

            local str = (is_only_cnt) and Str('{1}개', comma_value(cnt)) or Str('{1}\n{2}개', name, comma_value(cnt))

            local label = vars['itemLabel'..idx]
            if (label) then
                label:setString(str)
            end
        end
    end

    -- 구매 제한
    if vars['buyLabel'] then
        local limit = struct_product:getMaxBuyTermStr()
        vars['buyLabel']:setString(limit)
    end

	-- 가격
    if vars['priceLabel'] then
	    local price = struct_product:getPriceStr()
        vars['priceLabel']:setString(price)
    end

	-- 가격 아이콘
    if vars['priceNode'] then
        local icon = struct_product:makePriceIcon()
        vars['priceNode']:addChild(icon)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package:initButton(is_popup)
	local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    if vars['contractBtn'] then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    end

    if (not is_popup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package:click_buyBtn()
	local struct_product = self.m_structProduct
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
function UI_Package:click_infoBtn()
    local url = URL['PERPLELAB_AGREEMENT']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package:click_closeBtn()
    self:closeWithAction()
end