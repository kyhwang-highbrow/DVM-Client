local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonBoardPopup
-------------------------------------
UI_DragonBoardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonBoardPopup:init()
    local vars = self:load('dragon_board.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonBoardPopup')

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
function UI_DragonBoardPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonBoardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonBoardPopup)
