local PARENT = UI

-------------------------------------
-- class UI_ContentOpenPopup
-------------------------------------
UI_ContentOpenPopup = class(PARENT,{
        m_content_type = 'string',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ContentOpenPopup:init(content_type)
    self.m_content_type = content_type

    local vars = self:load('popup_contents_open.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ContentOpenPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ContentOpenPopup:initUI()
    local vars = self.vars
    local content_type = self.m_content_type
    vars['contentsVisual']:changeAni('open_'..content_type, true)
    vars['contentsLabel']:setString(getContentName(content_type))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ContentOpenPopup:initButton()
    local vars = self.vars
    self.vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ContentOpenPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_ContentOpenPopup)
