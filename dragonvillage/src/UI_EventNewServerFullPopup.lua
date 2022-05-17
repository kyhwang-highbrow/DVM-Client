local PARENT = UI

-------------------------------------
-- class UI_EventNewServerFullPopup
-------------------------------------
UI_EventNewServerFullPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventNewServerFullPopup:init()
    local vars = self:load('event_reward.ui')
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventNewServerFullPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventNewServerFullPopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventNewServerFullPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventNewServerFullPopup:onEnterTab()
end