--[[
    *누적결제 최종 상품 타입에 따라 다른 BackGround를 사용
    * 파일명은 UI_PurchasePointBg이고 두 개의 클래스를 포함함
    UI_PurchasePointBg
        - UI_PurchasePointBg_DragonTicket  ex) 상품 : 드래곤 뽑기권
        - UI_PurchasePointBg_Dragon        ex) 상품 : 미트라
--]]

-------------------------------------
-- function openPurchasePointBgByType
-------------------------------------
function openPurchasePointBgByType(bg_type, item_id, item_count)
    local ui_bg = nil

    if (bg_type == 'dragon_ticket') then
        ui_bg = UI_PurchasePointBg_DragonTicket(item_id)
    elseif (bg_type == 'dragon') then
        ui_bg = UI_PurchasePointBg_Dragon(item_id)
    end

    return  ui_bg
end




local PARENT = UI

-------------------------------------
-- class UI_PurchasePointBg_DragonTicket
-------------------------------------
UI_PurchasePointBg_DragonTicket = class(PARENT,{
        m_item_id = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PurchasePointBg_DragonTicket:init(item_id)
    self:load('event_purchase_point_item_new_02.ui')
    self.m_item_id = item_id

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_PurchasePointBg_DragonTicket:initUI()
    local vars = self.vars
    local item_id = self.m_item_id

    vars['productNode1']:setVisible(true)
    vars['productNode2']:setVisible(false)

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

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PurchasePointBg_DragonTicket:initButton()
   local vars = self.vars
   local item_id = self.m_item_id
   
   vars['dragonInfoBtn']:registerScriptTapHandler(function() UI_SummonDrawInfo(item_id, false) end)
end






local PARENT = UI

-------------------------------------
-- class UI_PurchasePointBg_Dragon
-------------------------------------
UI_PurchasePointBg_Dragon = class(PARENT,{
        m_item_id = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PurchasePointBg_Dragon:init(item_id)
    self:load('event_purchase_point_item_new_02.ui')
    self.m_item_id = item_id

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_PurchasePointBg_Dragon:initUI()
    local vars = self.vars
    local item_id = self.m_item_id
    local did = TableItem:getDidByItemId(item_id)
    
    vars['productNode1']:setVisible(false)
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
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PurchasePointBg_Dragon:initButton()
   local vars = self.vars
   local item_id = self.m_item_id
   
   local did = TableItem:getDidByItemId(item_id)
   vars['infoBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 3, 0.8, true) end)
end

