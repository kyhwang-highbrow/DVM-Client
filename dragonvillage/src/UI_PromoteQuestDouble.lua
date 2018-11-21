local PARENT = UI

-------------------------------------
-- class UI_PromoteQuestDouble
-------------------------------------
UI_PromoteQuestDouble = class(PARENT,{
        m_buyCb = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PromoteQuestDouble:init(buy_cb)
    self.m_uiName = 'UI_PromoteQuestDouble'
    local vars = self:load('promote_quest_double.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_buyCb = buy_cb

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
function UI_PromoteQuestDouble:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PromoteQuestDouble:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['buyBtn']:registerScriptTapHandler(function() self:click_okay() end)
    vars['cancleBtn']:registerScriptTapHandler(function() self:click_cancle() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PromoteQuestDouble:refresh()
end

-------------------------------------
-- function click_okay
-------------------------------------
function UI_PromoteQuestDouble:click_okay()
    self.m_buyCb()
    self:close()
end

-------------------------------------
-- function click_okay
-------------------------------------
function UI_PromoteQuestDouble:click_cancle()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_PromoteQuestDouble)
