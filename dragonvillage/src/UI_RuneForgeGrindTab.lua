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
        self:initButton()
    end

    self:refresh()
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

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgeGrindTab:initButton()
    local vars = self.vars

    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeGrindTab:refresh()
    local vars = self.vars

    -- 연마석 아이템 보유 수량
    do
        local cur_grind_stone_cnt = g_userData:get('grindstone')
        vars['itemLabel']:setString(comma_value(cur_grind_stone_cnt))
    end
end

-------------------------------------
-- function click_buyBtn
-- @brief 연마석 패키지 팝업을 띄움
-------------------------------------
function UI_RuneForgeGrindTab:click_buyBtn()
    local vars = self.vars
    
    -- 연마석 패키지 팝업 띄우기
    local pid = 110133
    local is_popup = true
    local package_name = TablePackageBundle:getPackageNameWithPid(pid)
    local ui = PackageManager:getTargetUI(package_name, is_popup)

    ui:setCloseCB(function() self:refresh() end) 
end