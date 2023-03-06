local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonSkinListItem
-------------------------------------
UI_DragonSkinListItem = class(PARENT, {
    m_skinData = 'StructDragonSkin',
    m_structDragon = 'StructDragonObject',
    m_dragonAnimator = 'UIC_DragonAnimator',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkinListItem:init(skin_data, struct_dragon)
    local vars = self:load('dragon_skin_item.ui')
    self.m_skinData = skin_data
    self.m_structDragon = struct_dragon

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_cellSize = cc.size(221, 393)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkinListItem:initUI()
    local vars = self.vars
    local skin_data = self.m_skinData
    local is_skin_on = self.m_structDragon:isSkinOn(skin_data:getSkinID())
    local evolution = self.m_structDragon:getEvolution()

    -- 이름
    vars['skinLabel']:setString(skin_data:getName())

    -- 이미지
    local img = skin_data:getDragonSkinRes()
    if (img) then
        local animator = AnimatorHelper:makeDragonAnimator(img, evolution)
        animator.m_node:setScale(0.75)
        animator.m_node:setDockPoint(cc.p(0.4, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.4, 0.5))
        animator:setAnimationPause(true)
        vars['dragonNode']:addChild(animator.m_node)
    end

    vars['selectSprite']:setVisible(is_skin_on)
    vars['skinMenu']:setSwallowTouch(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSkinListItem:initButton()
    local vars = self.vars
    vars['gotoBtn']:setVisible(false)
    vars['gotoBtn']:setEnabled(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkinListItem:refresh()
    local vars = self.vars

    -- StructDragonSkin
    local skin_data = self.m_skinData

    local is_skin_on = self.m_structDragon:isSkinOn(skin_data:getSkinID())
    vars['useSprite']:setVisible(is_skin_on)

    local is_open = skin_data:isDragonSkinOwned()
    -- local is_open = true
    local is_default = skin_data:isDefaultSkin()
    if is_default then
        is_open = true
    end
    local is_valid_purchase =  skin_data:checkDragonSkinPurchaseValidation()

    cclog('---------------------------------')
    cclog('is_default : '..tostring(is_default))
    cclog('is_open : '..tostring(is_open))
    cclog('---------------------------------')

    local badge_node = vars['badgeNode']
    badge_node:removeAllChildren()

    local badge
    if (not is_open) then
        local is_end = skin_data:isEnd()
    
        if (is_end) then
            vars['finishBtn']:setVisible(true)
        -- 판매중
        else
            vars['finishBtn']:setVisible(false)
            self:setPriceData()
        end
    end

    if (badge) then
        badge:setDockPoint(CENTER_POINT)
        badge:setAnchorPoint(CENTER_POINT)
        badge_node:addChild(badge)
    end

    -- 선택 버튼
    vars['selectBtn']:setVisible(not is_skin_on and is_open)

    -- 사용 버튼
    vars['useBtn']:setVisible(is_skin_on)

    -- 스킨 잠금이 아니라 오픈 여부로 변경
    vars['lockSprite']:setVisible(not is_open)

    do -- 버튼 처리
        if is_valid_purchase == false then
            vars['priceLabel']:setString(Str('{@red}구매 불가{@}'))
            vars['buyBtn']:setEnabled(false)
        else
            vars['priceLabel']:setString(Str('구매하기'))
            vars['buyBtn']:setEnabled(true)
        end
    end
end

-------------------------------------
-- function setSelected
-------------------------------------
function UI_DragonSkinListItem:setSelected(selected_skin_id)
    local vars = self.vars
    local skin_data = self.m_skinData
    local skin_id = skin_data:getSkinID()

    vars['selectSprite']:setVisible(skin_id == selected_skin_id)
end

-------------------------------------
-- function isInShop
-- @brief 상점에서 팔고 있는지 확인(토파즈/용맹훈장) 상점에서 판다면 상점으로 보내주기 위해 사용
-------------------------------------
function UI_DragonSkinListItem:isInShop(price_type)
    local vars = self.vars
    -- local costume_data = self.m_skinData
    -- local cid = costume_data:getCid()
    local l_product = g_shopDataNew:getProductList(price_type)

    -- for i, struct_product in pairs(l_product) do
    --     local product_str = struct_product['product_content'] or ''
    --     if (string.match(product_str, tostring(cid))) then
    --         return true
    --     end
    -- end

    return false
end

-------------------------------------
-- function setPriceData
-------------------------------------
function UI_DragonSkinListItem:setPriceData(is_sale)
    -- local vars = self.vars
    -- local is_sale = is_sale or false
    -- local skin_data = self.m_skinData

    -- -- 가격 정보
    -- local skin_id = skin_data:getSkinID()
    -- local shop_info = g_dragonSkinData:getShopInfo(skin_id)
    -- local origin_price = shop_info['origin_price'] 
    -- local price = is_sale and shop_info['sale_price'] or shop_info['origin_price'] 
    -- local price_type = shop_info['price_type']
    -- local price_icon = IconHelper:getPriceIcon(price_type)

    -- if (is_sale) then
    --     vars['saleNode']:setVisible(true)
    --     vars['salePriceLabel1']:setString(comma_value(origin_price))
    --     vars['salePriceLabel2']:setString(comma_value(price))
    --     vars['priceLabel']:setString('')
    --     vars['saleTimeLabel']:setString(msg)
    --     vars['salePriceNode']:addChild(price_icon)
    -- else
    --     -- 가격 정보가 있을 경우
    --     if (type(price) == 'number') then
    --         vars['priceLabel']:setString(comma_value(price))
    --         vars['priceNode']:removeAllChildren()
    --         vars['priceNode']:addChild(price_icon)
    --     -- 가격 정보가 없을 경우 '구매 불가'
    --     else
    --         vars['finishBtn']:setVisible(true)
    --         vars['finishBtn']:setEnabled(false)
    --         vars['buyBtn']:setEnabled(false)
    --         vars['selectBtn']:setEnabled(false)
    --     end
    -- end
end