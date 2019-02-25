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
    if (bg_type == 'dragon_ticket') then
        return UI_PurchasePointBg_DragonTicket(item_id, item_count)
    else
        return UI_PurchasePointBg_DragonTicket(item_id, item_count)
    end
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

    self:initUI(item_id, item_count)
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
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PurchasePointBg_DragonTicket:initButton()
   
end

