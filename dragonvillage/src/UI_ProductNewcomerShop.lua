local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ProductNewcomerShop
-- @brief 초보자 선물(신규 유저 전용 상점)의 개별 상품 UI
-------------------------------------
UI_ProductNewcomerShop = class(PARENT, {
        m_structProduct = 'StructProduct',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ProductNewcomerShop:init(struct_product)
    local vars = self:load('shop_list_newcomer_shop.ui')

    self.m_structProduct = struct_product
    
    self:initUI()
	self:initButton()
	self:refresh()
end


-------------------------------------
-- function initUI
-- @brief
-------------------------------------
function UI_ProductNewcomerShop:initUI()
    local vars = self.vars
    local struct_product = self.m_structProduct

	-- 상품 이름
	local product_name = Str(struct_product['t_name'])
    vars['itemLabel']:setString(product_name)

    -- 상품 아이콘
	local icon = struct_product:makeProductIcon()
	if (icon) then
		vars['itemNode']:addChild(icon)
	end

    -- 상품 설명
    local product_desc = struct_product:getDesc()
    vars['dscLabel']:setString(product_desc)

    -- 상품 가격
    local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, struct_product, idx)
    local is_sale_price_written = false
    if (is_tag_attached == true) then
        is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, idx)
    end

    if (is_sale_price_written == false) then
        vars['moneyLabel']:setString(struct_product:getPriceStr())
    end
end

-------------------------------------
-- function initButton
-- @brief
-------------------------------------
function UI_ProductNewcomerShop:initButton()
    local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_ProductNewcomerShop:refresh()
    local vars = self.vars
    local struct_product = self.m_structProduct
    local is_buy_all = struct_product:isBuyAll()

    do-- 구매 제한 텍스트
        local buy_term_str = struct_product:getMaxBuyTermStr()
        if buy_term_str and (buy_term_str ~= '') then

            -- 구매 가능/불가능 텍스트 컬러 변경
            local color_key = is_buy_all and '{@impossible}' or '{@available}'

            buy_term_str = color_key .. buy_term_str
        end
        vars['maxBuyTermLabel']:setString(buy_term_str)
    end

    -- 구매 완료 여부
    vars['completeNode']:setVisible(is_buy_all)
    vars['buyBtn']:setEnabled(not is_buy_all)  
end

-------------------------------
-- function click_buyBtn
-------------------------------------
function UI_ProductNewcomerShop:click_buyBtn()
	local struct_product = self.m_structProduct

    local function cb_func(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
        
        self:refresh()
    end
        
	struct_product:buy(cb_func)
end

-------------------------------
-- function click_infoBtn
-------------------------------------
function UI_ProductNewcomerShop:click_infoBtn()
    local struct_product = self.m_structProduct
    local str = struct_product:getToolTipStr()
    local tooltip = UI_Tooltip_Skill(0, 0, str)
    local btn = self.vars['infoBtn']

    if (tooltip and btn) then
        tooltip:autoPositioning(btn)
    end
end