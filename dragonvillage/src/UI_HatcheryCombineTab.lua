local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcheryCombineTab
-------------------------------------
UI_HatcheryCombineTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryCombineTab:init(owner_ui)
    local vars = self:load('hatchery_combine.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcheryCombineTab:onEnterTab(first)
    cclog('## UI_HatcheryCombineTab:onEnterTab(first)')
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcheryCombineTab:onExitTab()
    cclog('## UI_HatcheryCombineTab:onExitTab()')
end