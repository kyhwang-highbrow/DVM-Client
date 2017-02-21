-------------------------------------
-- class UI_CollectionTabDragon
-------------------------------------
UI_CollectionTabDragon = class({
        vars = 'table',
        m_ownerUI = 'UI',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionTabDragon:init(owner_ui)
    self.m_ownerUI = owner_ui
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_CollectionTabDragon:onEnterTab(first)
end