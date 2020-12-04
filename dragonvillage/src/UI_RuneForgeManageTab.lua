local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_RuneForgeManageTab
-------------------------------------
UI_RuneForgeManageTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeManageTab:init(owner_ui)
    local vars = self:load('rune_forge_manage.ui')
    
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeManageTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeManageTab:onExitTab()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeManageTab:initUI()
    local vars = self.vars

end