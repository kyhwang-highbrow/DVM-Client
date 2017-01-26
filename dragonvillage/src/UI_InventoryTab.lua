-------------------------------------
-- class UI_InventoryTab
-------------------------------------
UI_InventoryTab = class({
        vars = 'table',
        m_inventoryUI = 'UI_Inventory',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTab:init(inventory_ui)
    self.m_inventoryUI = inventory_ui
    self.vars = self.m_inventoryUI.vars
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTab:onEnterInventoryTab(first)
end