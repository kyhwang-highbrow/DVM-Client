local PARENT = UI

-------------------------------------
-- class UI_BundlePopupNew
-------------------------------------
UI_BundlePopupNew = class(PARENT,{
        m_itemId = 'string',
        m_itemCnt = 'number',
        m_maxItemCnt = 'number',
        m_priceType = 'string',
        m_priceCnt = 'number',
        m_cbFunc = 'function',

        m_curCount = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BundlePopupNew:init(item_id, item_cnt, max_item_cnt, price_type, price_cnt, cb_func)
    local vars = self:load('shop_purchase.ui')
    UIManager:open(self, UIManager.POPUP)

	self.m_itemId = tonumber(item_id)
    self.m_itemCnt = tonumber(item_cnt)
    self.m_maxItemCnt = tonumber(max_item_cnt)
    self.m_priceType = price_type
    self.m_priceCnt = tonumber(price_cnt)
    self.m_cbFunc = cb_func
    self.m_curCount = 1

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BundlePopupNew')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BundlePopupNew:initUI()
	local vars = self.vars

    local item_id = tonumber(self.m_itemId)
    local item_cnt = tonumber(self.m_itemCnt) or 0
    local item_name = TableItem:getItemName(item_id)
    if (item_cnt > 1) then
        item_name = item_name .. ' ' .. Str('{1}개', comma_value(item_cnt))
    end

    -- 상품 이름
    vars['itemLabel']:setString(Str(item_name))

    local price = self.m_priceCnt
    vars['priceLabel']:setString(comma_value(price))

    -- 아이템 카드
    local ui_item_card = UI_ItemCard(item_id)
    ui_item_card:setSwallowTouch()
    vars['itemNode']:addChild(ui_item_card.root)

    -- 재화 아이콘
    if (self.m_priceType == 'event_illusion') then
        local price_sprite = cc.Sprite:create('res/ui/icons/inbox/inbox_staminas_event_illusion_01.png')
        price_sprite:setPosition(20, 30)
        vars['priceNode']:addChild(price_sprite)
    end

    vars['descLabel']:setString(Str('상품을 교환하시겠습니까?'))
    vars['cntLabel']:setString(Str('교환 수량'))
    vars['doLabel']:setString(Str('교환'))

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BundlePopupNew:initButton()
	local vars = self.vars

	vars['quantityBtn1']:registerScriptTapHandler(function() self:click_quantityBtn(false) end)
	vars['quantityBtn2']:registerScriptTapHandler(function() self:click_quantityBtn(true) end)

    vars['purchaseBtn']:registerScriptTapHandler(function() self:click_purchaseBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BundlePopupNew:refresh()
	local vars = self.vars

	-- 수량
	vars['quantityLabel']:setString(self.m_curCount)

	-- 가격
	local price = self.m_priceCnt
	local count = self.m_curCount
	local price_str = comma_value(price * count)
    vars['priceLabel']:setString(price_str)
end

-------------------------------------
-- function click_quantityBtn
-------------------------------------
function UI_BundlePopupNew:click_quantityBtn(is_add)
	local count = self.m_curCount
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
  
    -- 구매 한도 예외처리
    local max_buy_cnt = self.m_maxItemCnt
    local cur_buy_cnt = self.m_itemCnt
    if (max_buy_cnt) then
        if (count > (max_buy_cnt - cur_buy_cnt)) then
            return
        end
    end

	-- 재화 부족 예외처리	
	local price = self.m_priceCnt
	local price_type = self.m_priceType
	if (g_userData:get(price_type) < (price * count)) then
		return
	end

	self.m_curCount = count
	self:refresh()
end

-------------------------------------
-- function click_purchaseBtn
-------------------------------------
function UI_BundlePopupNew:click_purchaseBtn()
	self.m_cbFunc(self.m_curCount)
	self:close()
end

--@CHECK
UI:checkCompileError(UI_BundlePopupNew)
