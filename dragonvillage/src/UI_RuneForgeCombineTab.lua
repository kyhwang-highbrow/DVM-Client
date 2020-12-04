local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_RuneForgeCombineTab
-------------------------------------
UI_RuneForgeCombineTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeCombineTab:init(owner_ui)
    local vars = self:load('rune_forge_combine.ui')
    
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeCombineTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeCombineTab:onExitTab()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeCombineTab:initUI()
    local vars = self.vars

end