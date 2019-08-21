local PARENT = UI

-------------------------------------
-- class UI_BundlePopup
-------------------------------------
UI_BundlePopup = class(PARENT,{
        m_structProduct = 'StructProduct',
        m_cbFunc = 'function',
		m_count = 'number',
		m_unitCnt = 'number',
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
            icon:setPositionY(20)
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

	-- 단위 수량 계산
	local content = struct_product['product_content']
	local l_str = plSplit(content, ';')
	local cnt = table.getLast(l_str)
	self.m_unitCnt = tonumber(cnt)

	if (self.m_unitCnt > 1) then
		vars['itemLabel2']:setVisible(true)
	end

	-- 게스트 계정
	if (g_localData:isGuestAccount()) then
		vars['guestLabel']:setVisible(false)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BundlePopup:initButton()
	local vars = self.vars

	vars['quantityBtn1']:registerScriptTapHandler(function() self:click_quantityBtn(false) end)
	vars['quantityBtn2']:registerScriptTapHandler(function() self:click_quantityBtn(true) end)

    vars['quantityBtn1']:setPressedCB(function() self:click_quantityBtn(false) end)
	vars['quantityBtn2']:setPressedCB(function() self:click_quantityBtn(true) end)

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

	-- 단위 수량이 1이상인 경우 총 수량을 계산해 준다. 완전 친절
	local unit_cnt = self.m_unitCnt
	if (unit_cnt > 1) then
		local total_cnt = unit_cnt * count
		vars['itemLabel2']:setString(Str('{1}개', comma_value(total_cnt)))
	end
end

-------------------------------------
-- function click_quantityBtn
-------------------------------------
function UI_BundlePopup:click_quantityBtn(is_add)
	local count = self.m_count
	if (is_add) then
		count = count + 1
	else
		count = count - 1
	end

	-- 1 이하 예외처리
	if (count < 1) then
		count = 1
		return
	end

    local struct_product = self.m_structProduct
    
    -- 구매 한도 예외처리
    local max_buy_cnt = tonumber(struct_product['max_buy_count'])
    local cur_buy_cnt = g_shopDataNew:getBuyCount(struct_product['product_id'])
    if (max_buy_cnt) then
        if (count > max_buy_cnt - cur_buy_cnt) then
            return
        end
    end

	-- 재화 부족 예외처리	
	local price = struct_product:getPrice()
	local price_type = struct_product:getPriceType()
	if (not UIHelper:checkPrice(price_type, price * count)) then
		return
	end

	self.m_count = count
	self:refresh()
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
