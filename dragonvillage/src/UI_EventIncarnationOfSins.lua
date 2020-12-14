local PARENT = UI

-------------------------------------
-- class UI_EventIncarnationOfSins
-------------------------------------
UI_EventIncarnationOfSins = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSins:init()
    local vars = self:load('event_incarnation_of_sins.ui')
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSins:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSins:initButton()
    local vars = self.vars

    vars['eventBtn']:registerScriptTapHandler(function() self:click_eventBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSins:refresh()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventIncarnationOfSins:onEnterTab()
    local vars = self.vars
end

-------------------------------------
-- function click_eventBtn
-------------------------------------
function UI_EventIncarnationOfSins:click_eventBtn()
    local vars = self.vars

    local event_type = 'event_incarnation_of_sins'
    g_fullPopupManager:showFullPopup(event_type)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventIncarnationOfSins:click_rankBtn()
    local vars = self.vars

    local ui = UI_EventIncarnationOfSinsRankingPopup()
end