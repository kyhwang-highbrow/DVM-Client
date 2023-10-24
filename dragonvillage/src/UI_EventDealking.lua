local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventDealking
-------------------------------------
UI_EventDealking = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventDealking:init()
    local vars = self:load('event_dealking.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealking:initUI()
    local vars = self.vars
    local boss_type_list = {1}

    for _, type in ipairs(boss_type_list) do
        local ui = UI_EventDealkingTab(type)
        vars['contentNode']:addChild(ui.root)
        self:addTabWithTabUIAuto(type, vars, ui)
    end

    self:setTab(boss_type_list[1])
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventDealking:initButton()
    local vars = self.vars
    vars['2TabBtn']:setBlockMsg(Str('추후 오픈 예정입니다.'))
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventDealking:refresh()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventDealking:onEnterTab()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventDealking:onExitTab()
    local vars = self.vars
end