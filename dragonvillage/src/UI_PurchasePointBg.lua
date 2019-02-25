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
        ui_bg = UI_PurchasePointBg_DragonTicket(item_id, item_count)
    else
        ui_bg = UI_PurchasePointBg_DragonTicket(item_id, item_count)
    end

    return  ui_bg
end




local PARENT = UI

-------------------------------------
-- class UI_PurchasePointBg_DragonTicket
-------------------------------------
UI_PurchasePointBg_DragonTicket = class(PARENT,{

    })

-------------------------------------
-- function init
-------------------------------------
function UI_PurchasePointBg_DragonTicket:init(item_id, item_count)
    self:load('event_purchase_point_item_new_02.ui')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(700602, item_count)
    self:initButton()
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_PurchasePointBg_DragonTicket:initUI(item_id, item_count)
    local vars = self.vars
    local ui_card = UI_ItemCard(item_id, item_count)
    local item_name = TableItem:getItemName(item_id)
    vars['productNode1']:addChild(ui_card.root)
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
   
end

