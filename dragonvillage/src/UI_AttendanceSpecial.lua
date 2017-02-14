local PARENT = UI

-------------------------------------
-- class UI_AttendanceSpecial
-------------------------------------
UI_AttendanceSpecial = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecial:init()
    local vars = self:load('attendance_special.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AttendanceSpecial')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    --self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceSpecial:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceSpecial:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceSpecial:refresh()
end

--@CHECK
UI:checkCompileError(UI_AttendanceSpecial)
