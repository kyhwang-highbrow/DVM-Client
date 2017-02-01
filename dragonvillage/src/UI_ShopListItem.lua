local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ShopListItem
-------------------------------------
UI_ShopListItem = class(PARENT, {
        m_productData = 'table',		-- 하나의 상품 정보
		m_isGachaProd = 'bool',			-- 가차 상품인지 여부
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopListItem:init(t_product)
	-- 멤버변수
	self.m_isGachaProd = (t_product['product_type'] == TableShop.GACHA)
	self.m_productData = t_product
	
	-- UI load
	local ui_name
	if (self.m_isGachaProd) then
		ui_name = 'shop_list_01.ui'
	else
		ui_name = 'shop_list_02.ui'
	end
    self:load(ui_name)	

	-- initialize
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ShopListItem:initUI()
    local vars = self.vars
    local t_product = self.m_productData

    do -- 상품 아이콘
        local sprite = cc.Sprite:create(t_product['icon'])
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        vars['itemNode']:addChild(sprite)
    end
    
    do -- 지불 타입 아이콘
        local price_icon = cc.Sprite:create(t_product['t_ui_info']['price_icon_res'])
		if price_icon then
			price_icon:setDockPoint(cc.p(0.5, 0.5))
			price_icon:setAnchorPoint(cc.p(0.5, 0.5))
			vars['priceNode']:addChild(price_icon)
		end
    end

    -- 상품 개수 label
    vars['itemLabel']:setString(t_product['t_ui_info']['product_name'])

	-- 가격 label
    vars['priceLabel']:setString(t_product['t_ui_info']['price_name'])

	if (self.m_isGachaProd) then
		vars['gachaLabel']:setString(Str('{1} 회', t_product['value']))
	end
end                                              

-------------------------------------
-- function initButton
-------------------------------------
function UI_ShopListItem:initButton()
	local vars = self.vars
		
    -- 구매 버튼
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ShopListItem:refresh()
end

-------------------------------------
-- function click_mainBtn
-- @brief 상품 버튼 클릭
-------------------------------------
function UI_ShopListItem:click_buyBtn()
	local t_product = self.m_productData
    local can_buy, msg = g_shopData:canBuyProduct(t_product)

    if can_buy then
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, function() g_shopData:tempBuy(t_product) end)
    else
        UIManager:toastNotificationRed(msg)
        self:nagativeAction()
    end
end

-------------------------------------
-- function nagativeAction
-------------------------------------
function UI_ShopListItem:nagativeAction()
    local node = self.vars['buyBtn']

    local start_action = cc.MoveTo:create(0.05, cc.p(-20, 0))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(0, 0)), 0.2)
    node:runAction(cc.Sequence:create(start_action, end_action))
end