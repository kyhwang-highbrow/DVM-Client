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
-- @brief 가방 탭에 진입하였을 때 호출
-------------------------------------
function UI_InventoryTab:onEnterInventoryTab(first)
    self:setSortAscending(self.m_bAscending)
    
    -- 공용으로 사용하지 않는 UI 숨김
    local vars = self.vars
    vars['bulkSellBtn']:setVisible(false)
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
    cclog('자식 UI class 에서 구현하세요. onChangeSortAscending')
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_InventoryTab:onChangeSelectedItem(ui, data)
    cclog('자식 UI class 에서 구현하세요. onChangeSelectedItem')
end

-------------------------------------
-- function refresh_tableView
-------------------------------------
function UI_InventoryTab:refresh_tableView()
    cclog('자식 UI class 에서 구현하세요. refresh_tableView')
end

-------------------------------------
-- function openAcuisitionRegionInformation
-- @brief 획득 장소 안내 팝업
-------------------------------------
function UI_InventoryTab:openAcuisitionRegionInformation(item_id)
    UI_AcquisitionRegionInformation:create(item_id)
end