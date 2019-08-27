local PARENT = UI

-------------------------------------
-- class UI_HallOfFameRank
-------------------------------------
UI_HallOfFameRank = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameRank:init()
    local vars = self:load('hall_of_fame_rank_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HallOfFameRank')

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
function UI_HallOfFameRank:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameRank:initButton()
    local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end