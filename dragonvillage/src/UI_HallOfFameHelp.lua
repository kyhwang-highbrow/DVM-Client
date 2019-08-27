local PARENT = UI

-------------------------------------
-- class UI_HallOfFameHelp
-------------------------------------
UI_HallOfFameHelp = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameHelp:init()
    local vars = self:load('help_hall_of_fame.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HallOfFameHelp')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameHelp:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameHelp:initButton()
    local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end
