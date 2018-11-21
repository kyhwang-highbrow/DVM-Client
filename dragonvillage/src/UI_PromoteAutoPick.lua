local PARENT = UI

-------------------------------------
-- class UI_PromoteAutoPick
-------------------------------------
UI_PromoteAutoPick = class(PARENT,{
        m_okCb = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PromoteAutoPick:init(ok_cb)
    self.m_uiName = 'UI_PromoteAutoPick'
    local vars = self:load('promote_auto_pick.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_okCb = ok_cb

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_PromoteAutoPick')

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
function UI_PromoteAutoPick:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PromoteAutoPick:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okay() end)
    vars['cancleBtn']:registerScriptTapHandler(function() self:click_cancle() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PromoteAutoPick:refresh()
end

-------------------------------------
-- function click_okay
-------------------------------------
function UI_PromoteAutoPick:click_okay()
    self.m_okCb()
    self:close()
end

-------------------------------------
-- function click_okay
-------------------------------------
function UI_PromoteAutoPick:click_cancle()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_PromoteAutoPick)
