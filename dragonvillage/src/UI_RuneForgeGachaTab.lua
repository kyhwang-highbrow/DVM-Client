local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_RuneForgeGachaTab
-------------------------------------
UI_RuneForgeGachaTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeGachaTab:init(owner_ui)
    local vars = self:load('rune_forge_gacha.ui')
    
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeGachaTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeGachaTab:onExitTab()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeGachaTab:initUI()
    local vars = self.vars

end