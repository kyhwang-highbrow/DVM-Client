local PARENT = UI

-------------------------------------
-- class UI_CapsuleBox
-------------------------------------
UI_CapsuleBox = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBox:init()
    local vars = self:load('capsule_box.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CapsuleBox')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBox:initUI()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBox:initButton()
	local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBox:refresh()
	local vars = self.vars
end

-------------------------------------
-- function click_purchaseBtn
-------------------------------------
function UI_CapsuleBox:click_purchaseBtn()
end

--@CHECK
UI:checkCompileError(UI_CapsuleBox)
