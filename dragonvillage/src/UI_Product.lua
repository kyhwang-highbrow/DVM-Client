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
    local price_node = vars['priceNode']
    if (icon) then
        price_node:addChild(icon)
	else
        price_node:setScale(0)
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
    local badge = struct_product['badge']
    if (badge) then
        local img = cc.Sprite:create(string.format('res/ui/package/badge_%s.png', badge))
        if (img) then
            img:setDockPoint(cc.p(0.5, 0.5))
            img:setAnchorPoint(cc.p(0.5, 0.5))
            vars['badgeNode']:addChild(img)
        end
    end

	-- 가격 아이콘 및 라벨, 배경 조정
	UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])

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

    -- 구매 제한 설명 텍스트
    local node = vars['maxBuyTermLabel']
    local str = struct_product:getMaxBuyTermStr()
    node:setString(str)

    -- 구매 제한 설명이 있는 경우 기본 설명 라벨 안보이게 (포지션 겹침)
    if (node:getString() ~= '') then
        vars['dscLabel']:setString('')
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
