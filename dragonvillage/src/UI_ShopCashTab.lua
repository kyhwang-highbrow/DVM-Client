local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ShopCashTab
-------------------------------------
UI_ShopCashTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopCashTab:init(owner_ui)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ShopCashTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ShopCashTab:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ShopCashTab:initUI()
    local vars = self.vars
end