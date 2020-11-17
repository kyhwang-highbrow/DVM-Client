local PARENT = UI

-------------------------------------
-- class UI_DragonGoodbyeSelectInfoPopup
-------------------------------------
UI_DragonGoodbyeSelectInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyeSelectInfoPopup:init()
    local vars = self:load('dragon_goodbye_select_popup_new_info.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyeSelectInfoPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbyeSelectInfoPopup:initUI()
	local vars = self.vars

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbyeSelectInfoPopup:initButton()
    local vars = self.vars

	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeSelectInfoPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbyeSelectInfoPopup)
