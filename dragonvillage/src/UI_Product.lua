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
    
    self:initItemNodePos()

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
		vars['priceLabel']:setString(Str('상품 자세히 보기'))
		vars['priceLabel']:setScale(0.8)

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
            local is_exsit_topaz = false
            for idx, data in ipairs(l_topaz_list) do
                -- 토파즈 아이템 아이디만
                if (topaz_item_id == data['item_id']) then
                    local cnt = data['count']
                    local str = Str('+{1}', comma_value(cnt))
                    vars['topazLabel']:setString(str)
                    is_exsit_topaz = true
                end
            end

            vars['topazNode']:setVisible(is_exsit_topaz)
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
            local msg, enable = g_advertisingData:getCoolTimeStatus(AD_TYPE.RANDOM_BOX_LOBBY)
            local visible = (not enable)
            vars['timeNode']:setVisible(visible)
            vars['timeLabel']:setVisible(visible)
            vars['timeLabel']:setString(msg)
            vars['buyBtn']:setEnabled(enable)
        end
        self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
    end 

    -- 상품명, 설명 등의 위치와 크기 조정
    self:adjustLayout()
end

-------------------------------------
-- function initItemNodePos
-- @brief 상점 타입별 아이템 포지션, 스케일 변경
-------------------------------------
function UI_Product:initItemNodePos()
    local vars = self.vars
    local struct_product = self.m_structProduct
    local type = struct_product:getTabCategory()

    local ui_pos = struct_product:getUIPos()
    local ui_scale = struct_product:getUIScale()
    
    local node = vars['itemNode']
    if (ui_pos) and (ui_pos ~= '') then
        local l_str = seperate(ui_pos, ',')
        local x = l_str[1] or 0
        local y = l_str[2] or 0
        node:setPosition(x, y)
    end

    if (ui_scale) and (ui_scale ~= '') then
        node:setScale(ui_scale)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Product:initButton()
	local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)

    if self:isValorCostume() then
        vars['valorCostumeBtn']:setVisible(true)
        vars['valorCostumeBtn']:registerScriptTapHandler(function() self:click_valorCostumeBtn() end)
    end
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
		vars['buyBtn']:setEnabled(true)
		return
	end

    do -- 구매 제한 설명 텍스트
        vars['maxBuyTermLabel']:setVisible(false)

        local full_str = ''

        -- 상품 설명
	    local product_desc = struct_product:getDesc()

        -- 기간 한정 텍스트
        local new_line = true
        local period_str = struct_product:getEndDateStr(new_line)
        if period_str and (period_str ~= '') then
            if full_str == '' then
                full_str = product_desc
            end

            if full_str and (full_str ~= '') then
                full_str = full_str .. '\n'
            end

            -- 기간한정 텍스트 컬러 변경
            local color_key = '{@yellow}'

            full_str = full_str .. color_key .. period_str
        end

        -- 구매 제한 텍스트
        local buy_term_str = struct_product:getMaxBuyTermStr()
        if buy_term_str and (buy_term_str ~= '') then
            if full_str == '' then
                full_str = product_desc
            end

            if full_str and (full_str ~= '') then
                full_str = full_str .. '\n'
            end

            -- 구매 가능/불가능 텍스트 컬러 변경
            local is_buy_all = struct_product:isBuyAll()
            local color_key = is_buy_all and '{@impossible}' or '{@available}'

            full_str = full_str .. color_key .. buy_term_str
        end

        if full_str == '' then
            full_str = product_desc
        end

        vars['dscLabel']:setString(full_str)
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
        g_advertisingData:showAdvPopup(AD_TYPE.RANDOM_BOX_LOBBY, function() self:refresh() end)

	else
        local function cb_func(ret)
            if (self.m_cbBuy) then
                self.m_cbBuy(ret)
            end

            -- 다이아 상품인 경우는 구매후 우편함 바로 보여줌
            if (struct_product:getTabCategory() == 'cash') then
                UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.GOODS)

            else
                -- 용맹 훈장 코스튬 상품은 별도 처리 
                if self:isValorCostume() then
                    g_tamerCostumeData.m_bDirtyValorCostumeInfo = true
                    local msg = Str('용맹 코스튬 세트 구매가 완료되었습니다.\n테이머 관리에서 코스튬을 선택할 수 있습니다.')
                    MakeSimplePopup(POPUP_TYPE.OK, msg)
                else
                    -- 아이템 획득 결과창
                    ItemObtainResult_Shop(ret)
                end
            end
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


-------------------------------------
-- function adjustLayout
-- @brief 상품명, 설명 등의 위치와 크기 조정
-------------------------------------
function UI_Product:adjustLayout()
    local vars = self.vars

    do -- 상품 이름 (시스템 폰트)
        local width = 328
        local str_width = vars['itemLabel']:getStringWidth()
        if (width < str_width) then
            local scale = (width / str_width)
            vars['itemLabel']:setScale(scale)
        end
    end
end



-------------------------------------
-- function isValorCostume
-- @brief 용맹 훈장 상품인지
-------------------------------------
function UI_Product:isValorCostume()
    local struct_product = self.m_structProduct
    local product_id = struct_product:getProductID()

    -- table_shop_basic에서 product_id 값
    if (product_id == 80006) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function click_valorCostumeBtn
-- @brief 용맹 훈장 상품 안내
-------------------------------------
function UI_Product:click_valorCostumeBtn()
    local function buy_btn_func()
        self:click_buyBtn()
    end
    local ui = UI_ValorCostumeInfoPopup(buy_btn_func)
end
