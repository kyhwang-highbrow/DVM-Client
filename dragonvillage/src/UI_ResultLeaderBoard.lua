local PARENT = UI

-------------------------------------
-- class UI_ResultLeaderBoard
-------------------------------------
UI_ResultLeaderBoard = class(PARENT, {

    })


-------------------------------------
-- function init
-------------------------------------
function UI_ResultLeaderBoard:init()
    local vars = self:load('rank_ladder.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ResultLeaderBoard')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ResultLeaderBoard:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ResultLeaderBoard:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ResultLeaderBoard:refresh()
end

--@CHECK
UI:checkCompileError(UI_ResultLeaderBoard)
