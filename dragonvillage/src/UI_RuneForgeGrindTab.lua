local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_RuneForgeGrindTab
-------------------------------------
UI_RuneForgeGrindTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeGrindTab:init(owner_ui)
    local vars = self:load('rune_forge_grind.ui')
    
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeGrindTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeGrindTab:onExitTab()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeGrindTab:initUI()
    local vars = self.vars

end