-------------------------------------
-- function openPackage_New_Dragon
-------------------------------------
function openPackage_New_Dragon(product_id)
    local struct_product = g_shopDataNew:getTargetProduct(tonumber(product_id))

    local ui_bg = UI_Package_New_DragonBg(struct_product)
    
    -- 타입별로 세팅
    if (bg_type == 'dragon_ticket') then
        ui_bg:setDragonTicket()
    elseif (bg_type == 'dragon') then
        ui_bg:setDragon()
    end

    return  ui_bg
end




local PARENT = UI

-------------------------------------
-- class UI_Package_New_DragonBg
-------------------------------------
UI_Package_New_DragonBg = class(PARENT,{
        m_struct_product = 'StructProduct',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_New_DragonBg:init(struct_product)
    self:load('package_new_dragon_item_01.ui')
    self.m_struct_product = struct_product

    self:doActionReset()
    self:doAction(nil, false)
    self:initProductUI()
end

function UI_Package_New_DragonBg:initProductUI()
    local vars = self.vars
    local struct_product = self.m_struct_product

    local l_item_list = ServerData_Item:parsePackageItemStr(struct_product['mail_content'])

    -- 구성품
    if (l_item_list) then
        local item_str = ''
        for idx, data in ipairs(l_item_list) do
            
            local name = TableItem:getItemName(data['item_id'])
            local cnt = data['count']

            item_str = item_str .. Str('{1}개', comma_value(cnt)) or Str('{1}\n{2}개', name, comma_value(cnt)) .. '\n'
        end

        local label = vars['itemLabel2']
        label:setString(str)
    end

    -- 구매 제한
    if vars['buyLabel2'] then
        local str = struct_product:getMaxBuyTermStr()
        -- 구매 가능/불가능 텍스트 컬러 변경
        local is_buy_all = struct_product:isBuyAll()
        local color_key = is_buy_all and '{@impossible}' or '{@available}'
        local rich_str = color_key .. str
        vars['buyLabel2']:setString(rich_str)
        
        -- 구매 불가능할 경우 '구매완료' 출력
        if (vars['completeNode2']) then
            vars['completeNode2']:setVisible(is_buy_all)
        end
    end
	
    -- 가격
    if vars['priceLabel2'] then
	    local price = struct_product:getPriceStr()
        vars['priceLabel2']:setString(price)
    end
end

function UI_Package_New_DragonBg:setDragonTicket()
    self:initUI_dragonTicket()
    self:initButton_dragonTicket()

end

function UI_Package_New_DragonBg:setDragon()
    self:initUI_dragon()
    self:initButton_dragon()
end




-------------------------------------
-- function initUI_dragonTicket
-- @breif 누적결제 최종 상품이 [드래곤 뽑기권]일 경우 세팅
-------------------------------------
function UI_Package_New_DragonBg:initUI_dragonTicket()
    local vars = self.vars

    --[[
    local ui_card = UI_ItemCard(item_id, 0)
    ui_card.root:setScale(0.66)
    vars['itemNode']:addChild(ui_card.root)

    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel']:setString(item_name)
    
    -- 드래곤 뽑기권에서 나올 드래곤들 출력
    local dragon_list_str = TablePickDragon:getCustomList(item_id)
    local dragon_list = plSplit(dragon_list_str, ',')

    for i, dragon_id in ipairs(dragon_list) do
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setDragonAnimator(tonumber(dragon_id), 3)
        dragon_animator:setTalkEnable(false)
        
        -- 2,3 번째 드래곤은 바라보는 방향이 다름        
        if (i >= 2) then
            dragon_animator.m_animator:setFlip(true)
        end

        if (vars['dragonNode'.. i]) then
            vars['dragonNode'.. i]:addChild(dragon_animator.m_node)
        end
    end

    local res = 'res/bg/ui/dragon_evolution_result/dragon_evolution_result.vrp'
    animator = MakeAnimator(res)    
    vars['bgNode']:addChild(animator.m_node)
    --]]
end

-------------------------------------
-- function initButton_dragonTicket
-------------------------------------
function UI_Package_New_DragonBg:initButton_dragonTicket()
   local vars = self.vars
   local item_id = self.m_item_id
   
   --vars['dragonInfoBtn']:registerScriptTapHandler(function() UI_SummonDrawInfo(item_id, false) end)
end





-------------------------------------
-- function initUI_dragon
-- @breif 누적결제 최종 상품이 [드래곤]일 경우 세팅
-------------------------------------
function UI_Package_New_DragonBg:initUI_dragon()
    local vars = self.vars
    --[[
    local item_id = self.m_item_id
    local did = TableItem:getDidByItemId(item_id)
    
    vars['productNode2']:setVisible(true)

    local table_dragon = TableDragon()

    -- 이름
    local dragon_name = table_dragon:getDragonName(did)
    vars['dragonNameLabel']:setString(Str(dragon_name))
    
    -- 속성 ex) dark
    local dragon_attr = table_dragon:getDragonAttr(did)
    local attr_icon = IconHelper:getAttributeIcon(dragon_attr)
    vars['attrNode']:addChild(attr_icon)
    vars['attrLabel']:setString(dragonAttributeName(dragon_attr))

    -- 역할 ex) healer
    local role_type = table_dragon:getDragonRole(did)
    local role_icon = IconHelper:getRoleIcon(role_type)
    vars['typeNode']:addChild(role_icon)
    vars['typeLabel']:setString(dragonRoleTypeName(role_type))

    -- 희귀도 ex) legend
    local rarity_icon = IconHelper:getRarityIcon('legend')
    vars['rarityNode']:addChild(rarity_icon)
    vars['rarityLabel']:setString(dragonRarityName('legend'))

    -- 진화도 by 별
    local res = string.format('res/ui/icons/star/star_%s_%02d%02d.png', 'yellow', 2, 5)
    local sprite = IconHelper:getIcon(res)
	vars['starNode']:addChild(sprite)

    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(did, 3)
    dragon_animator:setTalkEnable(false)
    vars['dragonNode4']:addChild(dragon_animator.m_node)

    
    -- 최종 상품이 드래곤일 경우 visual  세팅
    local animator
    local did = TableItem:getDidByItemId(item_id)
    local dragon_attr = TableDragon:getDragonAttr(did)
    animator = ResHelper:getUIDragonBG(dragon_attr, 'idle')
    vars['bgNode']:addChild(animator.m_node)
    --]]
end

-------------------------------------
-- function initButton_dragon
-------------------------------------
function UI_Package_New_DragonBg:initButton_dragon()
   local vars = self.vars
   local item_id = self.m_item_id
   
   --local did = TableItem:getDidByItemId(item_id)
   --vars['infoBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 3, 0.8, true) end)
end
