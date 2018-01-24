local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_Product
-------------------------------------
UI_Product = class(PARENT, {
        m_structProduct = 'StructProduct',
        m_cbBuy = 'function',
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
	local product_name = Str(struct_product['t_name'])
    vars['itemLabel']:setString(product_name)

	-- 상품 설명
	local product_desc = struct_product:getDesc()
    vars['dscLabel']:setString(product_desc)

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

	-- 예외처리
	-- 패키지
	if (struct_product:isPackage()) then
		vars['priceLabel']:setString(Str('상세보기'))

	-- 그외 현금 상품 (다이아)
	elseif (struct_product:isPaymentProduct()) then
		-- 가격
		local price = struct_product:getPriceStr()
		vars['moneyLabel']:setString(price)

	-- 일반 재화 상품
	else
		-- 가격 아이콘
		local icon = struct_product:makePriceIcon()
		local price_node = vars['priceNode']
		if (icon) then
			price_node:addChild(icon)
		else
			price_node:setScale(0)
		end

		-- 가격
		local price = struct_product:getPriceStr()
		vars['priceLabel']:setString(price)

		-- 가격 아이콘 및 라벨, 배경 조정
		UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])
	end
    
    -- 다이아 상점 (토파즈 추가)
    if (struct_product:getTabCategory() == 'cash') then
        local l_topaz_list = ServerData_Item:parsePackageItemStr(struct_product['mail_content'])
        if (l_topaz_list) then
            local topaz_item_id = TableItem:getItemIDFromItemType('topaz')
            vars['topazNode']:setVisible(true)
            for idx, data in ipairs(l_topaz_list) do

                -- 토파즈 아이템 아이디만
                if (topaz_item_id == data['item_id']) then
                    local cnt = data['count']
                    local str = Str('+{1}', comma_value(cnt))
                    vars['topazLabel']:setString(str)
                end
            end
        end
    end

    -- 뱃지 아이콘 추가
    local badge = struct_product:makeBadgeIcon()
    if (badge) then
		vars['badgeNode']:addChild(badge)
    end

    -- 광고
    if (struct_product.price_type == 'advertising') then
        local function update(dt)
            local msg, enable = g_advertisingData:getCoolTimeStatus(AD_TYPE.RANDOM_BOX_SHOP)
            local visible = (not enable)
            vars['timeNode']:setVisible(visible)
            vars['timeLabel']:setVisible(visible)
            vars['timeLabel']:setString(msg)
            vars['buyBtn']:setEnabled(enable)
        end
        self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
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
-- function refresh
-------------------------------------
function UI_Product:refresh()
	local vars = self.vars
	local struct_product = self.m_structProduct

	-- package 예외처리
	if (struct_product:isPackage()) then
		vars['maxBuyTermLabel']:setString('')
		--vars['dscLabel']:setString('')
		vars['buyBtn']:setEnabled(true)
		return
	end

    -- 구매 제한 설명 텍스트
    local node = vars['maxBuyTermLabel']
    local str = struct_product:getMaxBuyTermStr()
    node:setString(str)

    -- 구매 제한 설명이 있는 경우 기본 설명 라벨 안보이게 (포지션 겹침)
    if (node:getString() ~= '') then
        vars['dscLabel']:setString('')
    end

    -- 판매 가능 여부
    if (struct_product['lock'] == 1) then
        vars['buyBtn']:setEnabled(false)
    else
        vars['buyBtn']:setEnabled(true)
    end
end

-------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Product:click_buyBtn()
	local struct_product = self.m_structProduct    

	if (struct_product:getTabCategory() == 'package') then
        local is_popup = true
		local ui = PackageManager:getTargetUI(struct_product, is_popup)
        ui:setCloseCB(function() self:refresh() end)
        ui:setBuyCB(self.m_cbBuy)

    -- 광고 시청
    elseif (struct_product.price_type == 'advertising') then
        if (not g_advertisingData:getEnableShopAdv()) then
            return
        end
        g_advertisingData:showAdvPopup(AD_TYPE.RANDOM_BOX_SHOP, function() self:refresh() end)

	else
        local function cb_func(ret)
            if (self.m_cbBuy) then
                self.m_cbBuy(ret)
            end

            -- 아이템 획득 결과창
            ItemObtainResult_Shop(ret)
        end
        
		struct_product:buy(cb_func)
	end
end

-------------------------------------
-- function setBuyCB
-------------------------------------
function UI_Product:setBuyCB(func)
    self.m_cbBuy = func
end
