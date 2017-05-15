local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ShopListItem
-------------------------------------
UI_ShopListItem = class(PARENT, {
        m_productData = 'table',		-- 하나의 상품 정보

		-- @ TODO 상점 이외에서도 필요하다면 ProductData class를 만들자
		------------------------------------------------------------------------------
		m_pid = '',						-- 상품의 아이디
		m_productRes = '',				-- 상품의 아이콘

		m_gruopType = 'str',			-- 상품 그룹 = 탭위치
		m_slotType = '',				-- 사용할 UI 종류
		
		m_priceType = 'str',			-- 상품 가격의 종류
		m_priceValue = 'num',			-- 상품의 가격
		
		m_lProductList = '',			-- 지급 상품 리스트

		m_maxBuyCount = '',				-- 최대 구매 횟수
		m_maxBuyDue = '',				-- 최대 구매 갱신 날짜?

		m_eventType = '',				-- 이벤트 종류
		m_eventForm = '',				-- 이벤트 적용 횟수?
		m_eventStartDate = '',			-- 이벤트 시작 시간
		m_eventEndDate = '',			-- 이벤트 종료 시간
		m_eventPriceValue = '',			-- 이벤트로 변경될 상품의 가격
		m_lEventProductList = '',		-- 이벤트로 변경될 지급 상품 리스트
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopListItem:init(t_product)
	-- 멤버변수
	self.m_productData = t_product
	self:makeProductData(t_product)

	-- UI load
	if (self.m_slotType == 'normal') then
		self:load('shop_list_01.ui')
	elseif (self.m_slotType == 'special') then
		self:load('shop_list_02.ui')
	end

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

    do -- 상품 아이콘
        local sprite = cc.Sprite:create(self.m_productRes)
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        vars['itemNode']:addChild(sprite)
    end
    
    do -- 지불 타입 아이콘
		local icon_res = TableShop:makePriceIconRes(self.m_priceType)
        local price_icon = cc.Sprite:create(icon_res)
		if price_icon then
			price_icon:setDockPoint(cc.p(0.5, 0.5))
			price_icon:setAnchorPoint(cc.p(0.5, 0.5))
			vars['priceNode']:addChild(price_icon)
		end
    end

    -- 상품 이름
	local product_name = TableShop:makeProductName(self.m_lProductList)
    vars['itemLabel']:setString(product_name)

	-- 가격 label
	local price_str = TableShop:makePriceDesc(self.m_priceType, self.m_priceValue)
    vars['priceLabel']:setString(price_str)

	-- 상품 상세 설명
	local product_desc = TableShop:makeProductDesc(self.m_lProductList)
	vars['dscLabel']:setString(product_desc)

	-- 현금 화폐 종류 (아니면 디폴트값 '구매')
	local bill_type = TableShop:makeBillName(self.m_priceType)
	vars['purchaseLabel']:setString(bill_type)
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
	if (self.m_gruopType == 'recommend') or (self.m_gruopType == 'honor') then 
		UIManager:toastNotificationRed('해당 상품은 준비 중입니다.')
		return
	end

	local t_product = self.m_productData
    local can_buy, msg = g_shopData:canBuyProduct(self.m_priceType, self.m_priceValue)

    if can_buy then
		local function ok_cb()
			--g_shopData:tempBuy(self.m_lProductList, self.m_priceType, self.m_priceValue)
            g_shopData:request_buy(self.m_pid, function() self:refresh() end)
		end

		if (t_product['price_value'] > 0) then
			MakeSimplePopup_Confirm(self.m_priceType, self.m_priceValue, nil, ok_cb, nil)
		else
			ok_cb()
		end
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

-------------------------------------
-- function makeProductData
-------------------------------------
function UI_ShopListItem:makeProductData(t_product)
	local t_product = t_product or {}

	self.m_pid = t_product['product_id']
	self.m_productRes = t_product['icon']
	self.m_gruopType = t_product['group_type']
	self.m_slotType = t_product['slot_type']
	self.m_priceType = t_product['price_type']
	self.m_priceValue = t_product['price_value']
	self.m_lProductList = TableShop:makeProductList(t_product['product_content'])
	self.m_maxBuyCount = t_product['mbuy_count']
	self.m_maxBuyDue = t_product['mbuy_due']
	self.m_eventType = t_product['event_type']
	self.m_eventForm = t_product['event_form']
	self.m_eventStartDate = t_product['event_start_date']
	self.m_eventEndDate = t_product['event_end_date']
	self.m_eventPriceValue = t_product['event_price']
	self.m_lEventProductList = t_product['event_product_content']
end