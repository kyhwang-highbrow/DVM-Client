local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonRunesBulkEquipDragonTab
-------------------------------------
UI_DragonRunesBulkEquipDragonTab = class(PARENT,{
        m_ownerUI = 'UI_DragonRunesBulkEquip',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:init(owner_ui)
    local vars = self:load('dragon_rune_popup_dragon.ui')

    self.m_ownerUI = owner_ui

    self:initUI()

    self:initTableView()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:initUI()
    local vars = self.vars

   
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:initTableView()
    local vars = self.vars

   
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:refresh()
    local vars = self.vars


end
