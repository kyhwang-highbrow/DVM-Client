local PARENT = UI

-------------------------------------
-- class UI_BattlePassInfoPopup
-- @brief 
-------------------------------------
UI_BattlePassInfoPopup = class(PARENT,{
    })
 
-------------------------------------
-- function init
-------------------------------------
function UI_BattlePassInfoPopup:init(ui_res)
	self.m_uiName = 'UI_BattlePassInfoPopup'

    local vars = self:load(ui_res or 'battle_pass_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BattlePassInfoPopup')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattlePassInfoPopup:initUI()
    local vars = self.vars
end