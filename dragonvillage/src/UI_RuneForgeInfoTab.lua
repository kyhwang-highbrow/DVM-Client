local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_RuneForgeInfoTab
-------------------------------------
UI_RuneForgeInfoTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeInfoTab:init(owner_ui)
    local vars = self:load('rune_forge_info.ui')
    
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeInfoTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeInfoTab:onExitTab()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeInfoTab:initUI()
    local vars = self.vars

end