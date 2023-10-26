local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventDealking
-------------------------------------
UI_EventDealking = class(PARENT,{
    m_ownerUI = 'UI_EventPopup',
    m_structEvent = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventDealking:init(owner_ui, struct_event)
    self.vars = self:load('event_dealking.ui')
    self.m_ownerUI = owner_ui
    self.m_structEvent = struct_event
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealking:initUI()
    local vars = self.vars
    local boss_map = g_eventDealkingData:getBossMap()

    for type, t_data in pairs(boss_map) do
        local ui = UI_EventDealkingTab(type)
        vars['contentNode']:addChild(ui.root)
        self:addTabWithTabUIAuto(type, vars, ui)

        local str =  string.format('%dTabLabel', type)
        if vars[str] ~= nil then
            vars[str]:setString(t_data['name'])
        end
    end

    self:setTab(1)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventDealking:initButton()
    local vars = self.vars
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