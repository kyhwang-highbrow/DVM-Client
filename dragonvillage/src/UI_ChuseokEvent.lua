local PARENT = UI

-------------------------------------
-- class UI_ChuseokEvent
-------------------------------------
UI_ChuseokEvent = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChuseokEvent:init()
    local vars = self:load('event_chuseok.ui')

    self:initUI()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChuseokEvent:initUI()
    local vars = self.vars    
end

-------------------------------------
-- function initScrollView
-------------------------------------
function UI_ChuseokEvent:initScrollView()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChuseokEvent:refresh()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_ChuseokEvent:onEnterTab()
    local vars = self.vars
end