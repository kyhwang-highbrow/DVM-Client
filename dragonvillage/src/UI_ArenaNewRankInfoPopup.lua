local PARENT = UI

-------------------------------------
-- class UI_ArenaNewRankInfoPopup
-------------------------------------
UI_ArenaNewRankInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewRankInfoPopup:init()
    self.m_uiName = 'UI_ArenaNewRankInfoPopup'
    local vars = self:load('arena_new_popup_tier_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewRankInfoPopup')

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewRankInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewRankInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewRankInfoPopup:refresh()
    local vars = self.vars

end

--@CHECK
UI:checkCompileError(UI_ArenaNewRankInfoPopup)
