local PARENT = UI

-------------------------------------
-- class UI_Forest_ExtensionBoard
-------------------------------------
UI_Forest_ExtensionBoard = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_ExtensionBoard:init()
    local vars = self:load('dragon_forest_level.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_ExtensionBoard:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest_ExtensionBoard:initButton()
    local vars = self.vars


    --vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
    --vars['changeBtn']:registerScriptTapHandler(function() self:click_changeBtn() end)
    --vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest_ExtensionBoard:refresh()
end