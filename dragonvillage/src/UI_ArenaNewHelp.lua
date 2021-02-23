local PARENT = UI

-------------------------------------
-- class UI_ArenaNewHelp
-- @brief 
-------------------------------------
UI_ArenaNewHelp = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewHelp:init()
	self.m_uiName = 'UI_ArenaNewHelp'

    local vars = self:load('arena_new_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewHelp')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewHelp:initUI()
    local vars = self.vars
end