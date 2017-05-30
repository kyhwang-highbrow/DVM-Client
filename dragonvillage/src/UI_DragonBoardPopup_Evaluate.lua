local PARENT = UI

-------------------------------------
-- class UI_DragonBoardPopup_Evaluate
-------------------------------------
UI_DragonBoardPopup_Evaluate = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonBoardPopup_Evaluate:init()
    local vars = self:load('dragon_board_assess.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonBoardPopup_Evaluate')

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
function UI_DragonBoardPopup_Evaluate:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardPopup_Evaluate:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonBoardPopup_Evaluate:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonBoardPopup_Evaluate)
