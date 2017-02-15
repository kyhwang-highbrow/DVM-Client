local PARENT = UI

-------------------------------------
-- class UI_ClassForm
-------------------------------------
UI_ClassForm = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClassForm:init()
    local vars = self:load('uiName.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClassForm')

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
function UI_ClassForm:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClassForm:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClassForm:refresh()
end

--@CHECK
UI:checkCompileError(UI_ClassForm)
