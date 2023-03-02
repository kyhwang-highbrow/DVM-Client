local PARENT = UI

-------------------------------------
-- class UI_DragonSkinSaleConfirmPopup
-------------------------------------
UI_DragonSkinSaleConfirmPopup = class(PARENT, {
    m_structDragonSkinSale = 'StructDragonSkinSale',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:init(struct_dragon_skin_sale)
    local vars = self:load('shop_purchase_dragon_skin.ui')
    self.m_structDragonSkinSale = struct_dragon_skin_sale
    UIManager:open(self, UIManager.POPUP)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonSkinSaleConfirmPopup')

    self:initUI()
    self:initButton()
    self:refresh()

    self:doActionReset()
    self:doAction()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:initUI()
    local vars = self.vars
    local struct_product = self.m_structDragonSkinSale:getDragonSkinProduct('money')

	-- 상품 이름
	local product_name = Str(struct_product['t_name'])
    vars['titleLabel']:setString(product_name)

	-- 상품 아이콘
    do
        local icon = struct_product:makeProductIcon()
        if (icon) then
            -- 고대주화 상품만 scale, 위치 조절
            if (struct_product.price_type == 'ancient') then
                icon:setScale(0.8)
                icon:setPositionY(-20)
            end
            if vars['itemNode'] ~= nil then
                vars['itemNode']:addChild(icon)
            end
        end
    end

    do -- 현금 결제
        local price = struct_product:getPriceStr()
		vars['priceLabel']:setString(price)
    end

    do -- 다이아 결제
        local struct_product_cash = self.m_structDragonSkinSale:getDragonSkinProduct('cash')
		-- 가격 아이콘
		local icon = struct_product_cash:makePriceIcon()
		local price_node = vars['diaNode']
		if (icon) then
			price_node:addChild(icon)
		else
			price_node:setScale(0)
		end

		-- 가격
        vars['diaLabel']:setString(struct_product_cash:getPriceStr())
		-- 가격 아이콘 및 라벨, 배경 조정
		--UIHelper:makePriceNodeVariable(vars['diaBtn'],  vars['diaNode'], vars['diaLabel'])
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:initButton()
    local vars = self.vars
    -- '닫기' 버튼
	if vars['closeBtn'] then
	    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:refresh()   
end

-------------------------------------
-- function open
-------------------------------------
function UI_DragonSkinSaleConfirmPopup.open(struct_dragon_skin_sale)
    return UI_DragonSkinSaleConfirmPopup(struct_dragon_skin_sale)
end

--@CHECK
UI:checkCompileError(UI_DragonSkinSaleConfirmPopup)