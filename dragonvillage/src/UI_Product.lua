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
    vars['itemNode']:addChild(icon)

	-- 가격
	local price
	if (struct_product:getTabCategory() == 'package') then
		price = Str('자세히 보기')
	else
		price = struct_product:getPriceStr()
	end
	ccdisplay(price)
    vars['priceLabel']:setString(price)

	-- 가격 아이콘
    local icon = struct_product:makePriceIcon()
    vars['priceNode']:addChild(icon)
	
	-- 가격 아이콘 및 라벨, 배경 조정
    do
        local str_width = vars['priceLabel']:getStringWidth()
        local icon_width = 70
        local total_width = str_width + icon_width

        local icon_x = -(total_width/2) + (icon_width/2)
        vars['priceNode']:setPositionX(icon_x)
        local label_x = (icon_width/2)
        vars['priceLabel']:setPositionX(label_x)

        local _, height = vars['priceBg']:getNormalSize()
        vars['priceBg']:setNormalSize(total_width + 10, height)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Product:initButton()
	local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Product:click_buyBtn()
	local struct_product = self.m_structProduct

	if (struct_product:getTabCategory() == 'package') then
		UI_Package()
	else
		struct_product:buy()
	end
end