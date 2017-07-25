local PARENT = UI

-------------------------------------
-- class UI_Help
-------------------------------------
UI_Help = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Help:init()
    local vars = self:load('help_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Help')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Help:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Help:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Help:refresh()
end