-------------------------------------
-- class UI_CollectionTabUnit
-------------------------------------
UI_CollectionTabUnit = class({
        vars = 'table',
        m_ownerUI = 'UI',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionTabUnit:init(owner_ui)
    self.m_ownerUI = owner_ui
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_CollectionTabUnit:onEnterTab(first)
end