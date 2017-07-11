local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_Product
-------------------------------------
UI_Product = class(PARENT, {
        m_structProduct = 'StructProduct',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Product:init(struct_product)
    local vars = self:load('shop_list_01.ui')

    self.m_structProduct = struct_product
    self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Product:initUI()
    local vars = self.vars
    local struct_product = self.m_structProduct

	-- 상품 이름
    vars['itemLabel']:setString(Str(struct_product['t_name']))

	-- 상품 설명
    vars['dscLabel']:setString(struct_product:getDesc())

	-- 상품 아이콘
    local icon = struct_product:makeProductIcon()
    if (icon) then
        vars['itemNode']:addChild(icon)
    end

	-- 가격
	local price = struct_product:getPriceStr()
    vars['priceLabel']:setString(price)

	-- 가격 아이콘
    local icon = struct_product:makePriceIcon()
    vars['priceNode']:addChild(icon)
	
	-- 가격 아이콘 및 라벨, 배경 조정
	UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Product:initButton()
	local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Product:refresh()
	local vars = self.vars
	local struct_product = self.m_structProduct
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Product:click_buyBtn()
	local struct_product = self.m_structProduct

	if (struct_product:getTabCategory() == 'package') then
		UI_Package(struct_product)
	else
		struct_product:buy()
	end
end