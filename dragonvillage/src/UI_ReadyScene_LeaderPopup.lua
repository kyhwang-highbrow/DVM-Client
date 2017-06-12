local PARENT = UI

-------------------------------------
-- class UI_ReadyScene_LeaderPopup
-------------------------------------
UI_ReadyScene_LeaderPopup = class(PARENT,{

    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadyScene_LeaderPopup:init(did, my_rate, reveiw_func)
    local vars = self:load('battle_ready_leader_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:closeWithAction() end, 'UI_ReadyScene_LeaderPopup')

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
function UI_ReadyScene_LeaderPopup:initUI()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadyScene_LeaderPopup:initButton()
	local vars = self.vars

	vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:closeWithAction() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ReadyScene_LeaderPopup:refresh()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ReadyScene_LeaderPopup:click_okBtn()

end


--@CHECK
UI:checkCompileError(UI_ReadyScene_LeaderPopup)
