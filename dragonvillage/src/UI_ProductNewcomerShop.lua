local PARENT = UI_Product

-------------------------------------
-- class UI_ProductNewcomerShop
-- @brief 초보자 선물(신규 유저 전용 상점)의 개별 상품 UI
-------------------------------------
UI_ProductNewcomerShop = class(PARENT, {
        m_structProduct = 'StructProduct',
        m_cbBuy = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ProductNewcomerShop:init(struct_product)
    local vars = self:load('shop_list_newcomer_shop.ui')

    self.m_structProduct = struct_product
    
    self:initItemNodePos()

    self:initUI()
	self:initButton()
	self:refresh()

    self:makeAllItemIconList()
end

-------------------------------------
-- function adjustLayout
-- @brief 상품명, 설명 등의 위치와 크기 조정
-------------------------------------
function UI_ProductNewcomerShop:adjustLayout()
    local vars = self.vars

    do -- 상품 이름 (시스템 폰트)
        local width = 330
        local str_width = vars['itemLabel']:getStringWidth()
        if (width < str_width) then
            local scale = (width / str_width)
            vars['itemLabel']:setScale(scale)
        end
    end
end


-------------------------------------
-- function makeAllItemIconList
-- @brief
-------------------------------------
function UI_ProductNewcomerShop:makeAllItemIconList()
    local vars = self.vars
    
    -- 자동 줍기 (보급소 상품)
    local struct_product = self.m_structProduct

    local l_item_card = {}

    -- 즉시 지급되는 상품
    local l_item_list = ServerData_Item:parsePackageItemStr(struct_product['product_content'])
    for i,v in ipairs(l_item_list) do
        local ui = UI_ItemCard(v['item_id'], v['count'])
        table.insert(l_item_card, ui)
    end

    -- 메일로 지급되는 상품
    local l_mail_item_list = ServerData_Item:parsePackageItemStr(struct_product['mail_content'])
    for i,v in ipairs(l_mail_item_list) do
        local ui = UI_ItemCard(v['item_id'], v['count'])
        table.insert(l_item_card, ui)
    end
    
    do -- 자동 줍기
        local product_id = struct_product['product_id']
        local day = TableSupply:getAutoPickupDataByProductID(product_id)
        if (0 < day) then
            local ui = UI_ItemCard(ITEM_ID_AUTO_PICK, day)
            ui:setNumberLabel(comma_value(day))
            ui.m_itemName = Str('{1}일 자동 줍기', day)
            table.insert(l_item_card, ui)    
        end
    end

    vars['itemNode']:removeAllChildren()

    local l_pos = getSortPosList(150 + 5, #l_item_card)
    for i,ui in ipairs(l_item_card) do
        ui.root:setSwallowTouch(false)
        vars['itemNode']:addChild(ui.root)
        ui.root:setPositionX(l_pos[i])
    end

end