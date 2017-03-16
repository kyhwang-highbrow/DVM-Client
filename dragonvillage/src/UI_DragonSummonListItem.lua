local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonSummonListItem
-------------------------------------
UI_DragonSummonListItem = class(PARENT, {
        m_tItemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSummonListItem:init(t_item_data)
    self.m_tItemData = t_item_data

    local vars = self:load('dragon_summon_list_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSummonListItem:initUI()
    local vars = self.vars
    local t_item_data = self.m_tItemData

    local ui_type = t_item_data['ui_type']

    -- 상품 배경 이미지
    local res = string.format('res/ui/dragon_gacha/dragon_gacha_%s.png', ui_type)
    local sprite = cc.Sprite:create(res)
    if sprite then
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        vars['bgNode']:addChild(sprite)
    end

    -- 텍스트 이미지
    local res = string.format('res/ui/typo/kr/dragon_gacha_%s.png', ui_type)
    local sprite = cc.Sprite:create(res)
    if sprite then
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        vars['textNode']:addChild(sprite)
    end
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSummonListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSummonListItem:refresh()
    self:refresh_priceInfo()
end

-------------------------------------
-- function refresh_priceInfo
-------------------------------------
function UI_DragonSummonListItem:refresh_priceInfo()
    local vars = self.vars
    local t_item_data = self.m_tItemData

    
    local price_type = t_item_data['price_type']
    local price_icon
    local price_icon2
    if (price_type == 'cash') then
        price_icon = cc.Sprite:create('res/ui/icon/item/cash.png')
        price_icon2 = cc.Sprite:create('res/ui/icon/item/cash.png')
    elseif (price_type == 'gold') then
        price_icon = cc.Sprite:create('res/ui/icon/item/gold.png')
        price_icon2 = cc.Sprite:create('res/ui/icon/item/gold.png')
    end

    price_icon:setDockPoint(cc.p(0.5, 0.5))
    price_icon:setAnchorPoint(cc.p(0.5, 0.5))
    price_icon:setScale(0.5)

    price_icon2:setDockPoint(cc.p(0.5, 0.5))
    price_icon2:setAnchorPoint(cc.p(0.5, 0.5))
    price_icon2:setScale(0.5)

    vars['priceNode1']:addChild(price_icon)
    vars['priceNode2']:addChild(price_icon2)

    -- 할인 이벤트 중
    if (t_item_data['disc_event_active'] == true) then
        vars['priceLabel1']:setString(comma_value(t_item_data['disc_price_value']))
        vars['priceLabel2']:setString(comma_value(t_item_data['disc_11th_price_value']))
    else
        vars['priceLabel1']:setString(comma_value(t_item_data['price_value']))
        vars['priceLabel2']:setString(comma_value(t_item_data['11th_price_value']))
    end
end