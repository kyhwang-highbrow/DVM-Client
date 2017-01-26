-------------------------------------
-- class UI_InventoryTab
-------------------------------------
UI_InventoryTab = class({
        vars = 'table',
        m_inventoryUI = 'UI_Inventory',
        m_bAscending = 'boolean', -- 오름차순
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTab:init(inventory_ui)
    self.m_inventoryUI = inventory_ui
    self.vars = self.m_inventoryUI.vars
    self.m_bAscending = false
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTab:onEnterInventoryTab(first)
    self:setSortAscending(self.m_bAscending)
end

-------------------------------------
-- function click_sortBtn
-------------------------------------
function UI_InventoryTab:click_sortBtn()
    self:setSortAscending(not self.m_bAscending)
end

-------------------------------------
-- function setSortAscending
-------------------------------------
function UI_InventoryTab:setSortAscending(ascending)
    local prev = self.m_bAscending
    self.m_bAscending = ascending

    local str
    if ascending then
        str = Str('정렬 ▲')
    else
        str = Str('정렬 ▼')
    end
    self.vars['sortLabel']:setString(str)

    if (prev ~= self.m_bAscending) then
        self:onChangeSortAscending(self.m_bAscending)
    end
end

-------------------------------------
-- function onChangeSortAscending
-------------------------------------
function UI_InventoryTab:onChangeSortAscending(ascending)

end