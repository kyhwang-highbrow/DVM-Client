local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TamerCostumeListItem
-------------------------------------
UI_TamerCostumeListItem = class(PARENT, {
        m_costumeData = 'StructTamerCostume',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerCostumeListItem:init(costume_data)
    local vars = self:load('tamer_costume_item.ui')
    self.m_costumeData = costume_data

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_cellSize = cc.size(200, 250)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerCostumeListItem:initUI()
    local vars = self.vars
    local costume_data = self.m_costumeData

    -- 이름
    vars['costumeTitleLabel']:setString(costume_data:getName())

    -- 이미지
    local img = costume_data:getTamerSDIcon()
    if (img) then
        vars['tamerNode']:addChild(img)
    end
    
    -- 생성시에는 사용중인 코스튬 선택처리
    local is_used = costume_data:isUsed()
    vars['selectSprite']:setVisible(is_used)

    vars['costumeMenu']:setSwallowTouch(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerCostumeListItem:initButton()
    local vars = self.vars
    vars['gotoBtn']:setVisible(false)
    vars['gotoBtn']:setEnabled(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TamerCostumeListItem:refresh()
    local vars = self.vars

    -- StructTamerCostume
    local costume_data = self.m_costumeData

    local is_used = costume_data:isUsed()
    vars['useSprite']:setVisible(is_used)

    local is_open = costume_data:isOpen()
    local badge_node = vars['badgeNode']
    badge_node:removeAllChildren()
    
    local badge
    if (not is_open) then
        local is_sale, msg_sale = costume_data:isSale()
        local is_limit, msg_limit = costume_data:isLimit()
        local is_end = costume_data:isEnd()
        
        -- 할인
        if (is_sale) then            
            badge = cc.Sprite:create('res/' .. Translate:getTranslatedPath('ui/typo/ko/costume_badge_discount.png'))
            self:setPriceData(is_sale)

        -- 기간한정
        elseif (is_limit) then
            badge = cc.Sprite:create('res/' .. Translate:getTranslatedPath('ui/typo/ko/costume_badge_period.png'))

            --vars['limitNode']:setVisible(true)
            --vars['limitLabel']:setString(msg_limit)
            self:setPriceData()

        -- 판매종료
        elseif (is_end) then
            -- 용맹코스튬은 table_tamer_costume_info에서 판매일이 지정되지 않아 판매종료 판정이 났지만 
            -- 용맹 상점에서 구매 가능하기 때문에 판매종료 뱃지,버튼 적용x
            if (not costume_data:isValorCostume()) then
                badge = cc.Sprite:create('res/' .. Translate:getTranslatedPath('ui/typo/ko/costume_badge_finish.png'))
                vars['finishBtn']:setVisible(true)
                vars['finishBtn']:setEnabled(false)
            end
        -- 판매중
        else        
            self:setPriceData()
        end

        -- 판매 종료여부 상관없이 상품이 닫힌 상태면 바로가기 버튼 활성화 
        if (costume_data:isValorCostume()) then
            vars['gotoLabel']:setString(Str('용맹훈장 상점에서 구매'))
            vars['gotoBtn']:setVisible(true)
            vars['gotoBtn']:setEnabled(true)

        elseif (costume_data:isTopazCostume()) then
            -- 상점에서 팔고 있다면 상점으로 이동/없다면 구매 불가
            if (self:isInShop('topaz')) then
                vars['gotoLabel']:setString(Str('토파즈 상점에서 구매'))
                vars['gotoBtn']:setVisible(true)
                vars['gotoBtn']:setEnabled(true)
            end
        end
    
    end

    if (badge) then
        badge:setDockPoint(CENTER_POINT)
        badge:setAnchorPoint(CENTER_POINT)
        badge_node:addChild(badge)
    end

    -- 선택 버튼
    vars['selectBtn']:setVisible(not is_used and is_open)

    -- 사용 버튼
    vars['useBtn']:setVisible(is_used)

    -- 테이머 잠금이 아니라 오픈 여부로 변경
    vars['lockSprite']:setVisible(not is_open)
end

-------------------------------------
-- function setSelected
-------------------------------------
function UI_TamerCostumeListItem:setSelected(sel_id)
    local vars = self.vars
    local costume_data = self.m_costumeData
    local cid = costume_data:getCid()

    vars['selectSprite']:setVisible(cid == sel_id)
end

-------------------------------------
-- function isInShop
-- @brief 상점에서 팔고 있는지 확인(토파즈/용맹훈장) 상점에서 판다면 상점으로 보내주기 위해 사용
-------------------------------------
function UI_TamerCostumeListItem:isInShop(price_type)
    local vars = self.vars
    local costume_data = self.m_costumeData
    local cid = costume_data:getCid()
    local l_product = g_shopDataNew:getProductList(price_type)

    for i, struct_product in pairs(l_product) do
        local product_str = struct_product['product_content'] or ''
        if (string.match(product_str, tostring(cid))) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function setPriceData
-------------------------------------
function UI_TamerCostumeListItem:setPriceData(is_sale)
    local vars = self.vars
    local is_sale = is_sale or false
    local costume_data = self.m_costumeData

    -- 가격 정보
    local costume_id = costume_data:getCid()
    local shop_info = g_tamerCostumeData:getShopInfo(costume_id)
    local origin_price = shop_info['origin_price'] 
    local price = is_sale and shop_info['sale_price'] or shop_info['origin_price'] 
    local price_type = shop_info['price_type']
    local price_icon = IconHelper:getPriceIcon(price_type)

    if (is_sale) then
        vars['saleNode']:setVisible(true)
        vars['salePriceLabel1']:setString(comma_value(origin_price))
        vars['salePriceLabel2']:setString(comma_value(price))
        vars['priceLabel']:setString('')
        vars['saleTimeLabel']:setString(msg)
        vars['salePriceNode']:addChild(price_icon)
    else
        -- 가격 정보가 있을 경우
        if (type(price) == 'number') then
            vars['priceLabel']:setString(comma_value(price))
            vars['priceNode']:removeAllChildren()
            vars['priceNode']:addChild(price_icon)
        -- 가격 정보가 없을 경우 '구매 불가'
        else
            vars['finishBtn']:setVisible(true)
            vars['finishBtn']:setEnabled(false)
            vars['buyBtn']:setEnabled(false)
            vars['selectBtn']:setEnabled(false)
        end
    end
end