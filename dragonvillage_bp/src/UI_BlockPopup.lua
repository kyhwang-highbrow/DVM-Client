local PARENT = UI

-------------------------------------
-- class UI_BlockPopup
-------------------------------------
UI_BlockPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BlockPopup:init()
    self:load('empty.ui')
    UIManager:open(self, UIManager.POPUP, true)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_BlockPopup')
end