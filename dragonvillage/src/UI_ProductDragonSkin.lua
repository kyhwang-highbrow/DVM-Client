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
    local item_id = self.m_structSkinSale:getDragonSkinSaleSkinId()

    do
        vars['eventSprite']:setVisible(false)
        vars['limitNoti']:setVisible(false)
        vars['maxBuyTermLabel']:setVisible(false)
        vars['dscLabel']:setVisible(false)
    end

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
        local is_valid_purchase =  self.m_structSkinSale:checkDragonSkinPurchaseValidation()
        vars['priceNode']:removeAllChildren()

        if is_skin_owned == true then
            vars['priceLabel']:setString(Str('보유 중'))
            vars['buyBtn']:setEnabled(false)
        elseif is_valid_purchase == false then
            vars['priceLabel']:setString(Str('구매 불가'))
            vars['buyBtn']:setEnabled(false)
        else
            vars['priceLabel']:setString(Str('구매하기'))
            vars['buyBtn']:setEnabled(true)
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
