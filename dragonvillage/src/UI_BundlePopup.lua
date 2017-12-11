local PARENT = UI

-------------------------------------
-- class UI_BundlePopup
-------------------------------------
UI_BundlePopup = class(PARENT,{
        m_structProduct = 'StructProduct',
        m_cbFunc = 'function',
		m_count = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BundlePopup:init(struct_product, cb_func)
	self.m_structProduct = struct_product
	self.m_cbFunc = cb_func
	self.m_count = 1

    local vars = self:load('shop_purchase.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BundlePopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BundlePopup:initUI()
	local vars = self.vars
    local struct_product = self.m_structProduct

	-- 상품 이름
    vars['itemLabel']:setString(Str(struct_product['t_name']))
	
	-- 상품 아이콘
    local icon = struct_product:makeProductIcon()
    if (icon) then
        -- 고대주화 상품만 scale, 위치 조절
        if (struct_product.price_type == 'ancient') then
            icon:setScale(0.8)
            icon:setPositionY(-20)
        end
        vars['itemNode']:addChild(icon)
    end

	-- 가격 아이콘
    local icon = struct_product:makePriceIcon()
    local price_node = vars['priceNode']
    if (icon) then
        price_node:addChild(icon)
	else
        price_node:setScale(0)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BundlePopup:initButton()
	local vars = self.vars

	vars['quantityBtn1']:registerScriptTapHandler(function() self:click_quantityBtn(false) end)
	vars['quantityBtn1']:registerScriptPressHandler(function() self:press_quantityBtn(false) end)
	vars['quantityBtn2']:registerScriptTapHandler(function() self:click_quantityBtn(true) end)
	vars['quantityBtn2']:registerScriptPressHandler(function() self:press_quantityBtn(true) end)

    vars['purchaseBtn']:registerScriptTapHandler(function() self:click_purchaseBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BundlePopup:refresh()
	local vars = self.vars
    local struct_product = self.m_structProduct

	-- 수량
	vars['quantityLabel']:setString(self.m_count)

	-- 가격
	local price = struct_product:getPrice()
	local count = self.m_count
	local price_str = comma_value(price * count)
    vars['priceLabel']:setString(price_str)
end

-------------------------------------
-- function click_quantityBtn
-------------------------------------
function UI_BundlePopup:click_quantityBtn(is_add)
	if (is_add) then
		self.m_count = self.m_count + 1
	else
		self.m_count = self.m_count - 1
	end

	if (self.m_count < 1) then
		self.m_count = 1
	end

	self:refresh()
end

-------------------------------------
-- function press_quantityBtn
-------------------------------------
function UI_BundlePopup:press_quantityBtn(is_add)

end

-------------------------------------
-- function click_purchaseBtn
-------------------------------------
function UI_BundlePopup:click_purchaseBtn()
	self.m_cbFunc(self.m_count)
	self:close()
end

--@CHECK
UI:checkCompileError(UI_BundlePopup)
