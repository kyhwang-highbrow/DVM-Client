local PARENT = UI

-------------------------------------
-- class UI_EventDealkingFullpopup
-------------------------------------
UI_EventDealkingFullpopup = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventDealkingFullpopup:init()
    local vars = self:load('event_dealking_popup.ui')

    self:initUI()
    self:initButton()
    self:refresh()

    self:scheduleUpdate(function(dt) self:update(dt) end, 1, true)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealkingFullpopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventDealkingFullpopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventDealkingFullpopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function update
-------------------------------------
function UI_EventDealkingFullpopup:update(dt)
    local vars = self.vars
    local str = g_eventDealkingData:getRemainTimeString()
    vars['timeLabel']:setString(str)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventDealkingFullpopup:onEnterTab()
end