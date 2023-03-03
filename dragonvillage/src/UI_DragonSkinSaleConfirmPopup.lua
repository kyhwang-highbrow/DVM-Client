local PARENT = UI

-------------------------------------
-- class UI_DragonSkinSaleConfirmPopup
-------------------------------------
UI_DragonSkinSaleConfirmPopup = class(PARENT, {
    m_structDragonSkinSale = 'StructDragonSkinSale',
    m_finishCB = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:init(struct_dragon_skin_sale, finish_cb)
    local vars = self:load('shop_purchase_dragon_skin.ui')
    self.m_structDragonSkinSale = struct_dragon_skin_sale
    self.m_finishCB = finish_cb
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
    local struct_product_cash = self.m_structDragonSkinSale:getDragonSkinProduct('cash')
    local skin_id = self.m_structDragonSkinSale:getDragonSkinSaleSkinId()
    

	-- 상품 이름
	local product_name = Str(struct_product['t_name'])
    vars['titleLabel']:setString(product_name)

	-- 상품 아이콘
    do
        local icon = IconHelper:getItemIcon(skin_id)
        if (icon) then
            if vars['itemNode'] ~= nil then
                vars['itemNode']:addChild(icon)
            end
        end
    end

    do -- 현금 결제
        local price = struct_product:getPriceStr()
        local sale_str, origin_price = self.m_structDragonSkinSale:getDragonSkinProductOriginalPriceStr('money')
        local percent = (origin_price - struct_product:getPrice()) * 100/origin_price
        local is_sale = percent > 0

		vars['priceLabel']:setString(price)
        vars['money1PriceLabel']:setString(price)
        vars['money2PriceLabel']:setString(sale_str)

        if is_sale == true then
            vars['saleLabel']:setStringArg(string.format('%0.f',percent))
        end

        vars['saleSprite']:setVisible(is_sale)
        vars['promotionSprite']:setVisible(is_sale)
    end

    do -- 다이아 결제
		local icon = struct_product_cash:makePriceIcon()
		local price_node = vars['diaNode']
		if (icon) then
            price_node:removeAllChildren()
			price_node:addChild(icon)
		end

		-- 가격
        local str = struct_product_cash:getPriceStr()
        local sale_str, origin_price = self.m_structDragonSkinSale:getDragonSkinProductOriginalPriceStr('cash')
        local percent = (origin_price - struct_product_cash:getPrice()) * 100/origin_price
        local is_sale = percent > 0

        vars['diaLabel']:setString(str)
        vars['cash1PriceLabel']:setString(str)
        vars['cash2PriceLabel']:setString(sale_str)

        if is_sale == true then
            vars['diaSaleLabel']:setStringArg(string.format('%0.f',percent))
        end

        vars['diaSaleSprite']:setVisible(is_sale)
        vars['diaPromotionSprite']:setVisible(is_sale)
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

    if vars['diaBtn'] ~= nil then
        vars['diaBtn']:registerScriptTapHandler(function() self:click_purchaseBtn('cash') end)
    end

    if vars['purchaseBtn'] ~= nil then
        vars['purchaseBtn']:registerScriptTapHandler(function() self:click_purchaseBtn('money') end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:refresh()   
end

-------------------------------------
-- function click_purchaseBtn
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:click_purchaseBtn(price_type)
    local success_cb = function (ret)
        if self.m_finishCB ~= nil then
            self.m_finishCB()
            self:close()
        end
    end

    success_cb()

--[[     local struct_product = self.m_structDragonSkinSale:getDragonSkinProduct(price_type)
    if struct_product ~= nil then    
        struct_product:buy(nil)
    end ]]
end

-------------------------------------
-- function open
-------------------------------------
function UI_DragonSkinSaleConfirmPopup.open(struct_dragon_skin_sale, finish_cb)
    if struct_dragon_skin_sale:checkDragonSkinPurchaseValidation() == false then
        local skin_id = struct_dragon_skin_sale:getDragonSkinSaleSkinId()
        error(string.format('스킨 상품의 테이블 세팅이 잘못되었습니다. 유료/재화 아이템 모두 입력해주세요. [%d]'), skin_id)
        return
    end

    return UI_DragonSkinSaleConfirmPopup(struct_dragon_skin_sale, finish_cb)
end

--@CHECK
UI:checkCompileError(UI_DragonSkinSaleConfirmPopup)