local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_RuneForgeReinforceTab
-------------------------------------
UI_RuneForgeReinforceTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeReinforceTab:init(owner_ui)
    local vars = self:load('rune_forge_reinforce.ui')
    
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeReinforceTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeReinforceTab:onExitTab()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeReinforceTab:initUI()
    local vars = self.vars

end