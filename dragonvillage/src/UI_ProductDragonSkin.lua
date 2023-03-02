local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ProductDragonSkin
-------------------------------------
UI_ProductDragonSkin = class(PARENT, {
    m_structSkinSale = 'StructProduct',
    m_structProduct = 'StructProduct',
    m_cbBuy = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ProductDragonSkin:init(dragon_skin_sale)
    -- shop_package_list_02.ui 복사
    local vars = self:load('package_dargon_skin_item.ui')    
    self.m_structProduct = dragon_skin_sale:getDragonSkinProduct('money')
    self.m_structSkinSale = dragon_skin_sale
    self:initItemNodePos()
    self:initUI()
	self:initButton()
	self:refresh()
end

-- -------------------------------------
-- -- function initItemNodePos
-- -- @brief 상품명, 설명 등의 위치와 크기 조정
-- -------------------------------------
function UI_ProductDragonSkin:initItemNodePos()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ProductDragonSkin:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ProductDragonSkin:initUI()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ProductDragonSkin:refresh()
    local vars = self.vars
    local struct_product = self.m_structProduct

    do
        vars['eventSprite']:setVisible(false)
        vars['limitNoti']:setVisible(false)
        vars['maxBuyTermLabel']:setVisible(false)
        vars['dscLabel']:setVisible(false)
    end

    --local t_item =  {['item_id'] = self.m_structSkinSale:getDragonSkinSaleSkinId(), ['count'] = 1}
    local item_id = self.m_structSkinSale:getDragonSkinSaleSkinId()

    -- 스킨 이름
    do
	    local item_name = TableItem:getItemName(item_id)
        vars['itemLabel']:setString(item_name)
    end

	-- 스킨 아이콘
    do
        local icon = IconHelper:getItemIcon(item_id)
        if (icon) then
            if vars['itemNode'] ~= nil then
                vars['itemNode']:addChild(icon)
            end
        end
    end

    do -- 버튼 처리
        local is_skin_owned = self.m_structSkinSale:isDragonSkinOwned()
        vars['buyBtn']:setEnabled(not is_skin_owned)
        vars['priceNode']:removeAllChildren()

        if is_skin_owned == true then
            vars['priceLabel']:setString(Str('보유 중'))
        else
            vars['priceLabel']:setString(Str('구매하기'))
        end
    end

    do -- 판매할 경우 정보 처리
        self:refreshProduct(struct_product)
    end
    
    -- 가격 아이콘 및 라벨, 배경 조정
    --UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])
end


-------------------------------------
-- function refreshProduct
-------------------------------------
function UI_ProductDragonSkin:refreshProduct(struct_product)
    local vars = self.vars
    if struct_product == nil then
        return
    end

    vars['dscLabel']:setVisible(true)
    do -- 구매 제한 설명 텍스트
        local full_str = ''

        -- 상품 설명
	    local product_desc = struct_product:getDesc()

        -- 기간 한정 텍스트
        local new_line = false
        local simple = true
        local period_str = struct_product:getEndDateStr(new_line, simple)
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

    -- 뱃지 아이콘 추가
    local badge = struct_product:makeBadgeIcon()
    if (badge) then
        vars['badgeNode']:removeAllChildren()
        vars['badgeNode']:addChild(badge)
    end
end

-------------------------------
-- function click_buyBtn
-------------------------------------
function UI_ProductDragonSkin:click_buyBtn()
	local struct_product = self.m_structProduct

--[[     -- @jhakim 190701
    -- 닉네임 변경권 구입전에 (신규유저라면 무료 변경 가능하다는) 팝업 띄워줘야 해서 구매 전 조건 체크 함수 추가
    -- 원래는 struct_product:buy 함수에서 일괄적으로 체크하는 것이 맞으나, 작은 일로 buy함수 건들기 위험해서 이쪽에 추가, 후에 구매 전 조건 체크가 필요하다면 함수 옮기는 것을 추천 
    local product_id = struct_product:getProductID()
    if (self:canNotBuy(product_id)) then
        return
    end


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
                -- 코스튬 상점 구매 결과창
                if (self:isCostumeInStore()) then
                    self:obtainResultPopup_costume()
                else
                    -- 아이템 획득 결과창
                    ItemObtainResult_Shop(ret)
                end
            end
        end
        
		struct_product:buy(cb_func)
	end ]]
end

--[[ -------------------------------------
-- function adjustLayout
-- @brief 상품명, 설명 등의 위치와 크기 조정
-------------------------------------
function UI_ProductDragonSkin:adjustLayout()
    local vars = self.vars

    do -- 상품 이름 (시스템 폰트)
        local width = 244
        local str_width = vars['itemLabel']:getStringWidth()
        if (width < str_width) then
            local scale = (width / str_width)

            -- 상점에서 번역텍스트가 매우 길 때 두줄로 나올 때가 있는데
            -- 비율로 맞추기만 하면 기한 텏스트랑 겹쳐서
            -- 0.6 싸이즈로 했더니 딱 맞아서 일단 급해서 이렇게 함...
            if (g_localData:getLang() == 'es') then
                scale = 0.6
            end

            vars['itemLabel']:setScale(scale)
        end
    end
end ]]