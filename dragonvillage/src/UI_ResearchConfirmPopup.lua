local PARENT = UI
-------------------------------------
--- @class UI_ResearchConfirmPopup
-------------------------------------
UI_ResearchConfirmPopup = class(PARENT,{
    m_researchId = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ResearchConfirmPopup:init(research_id)
    self.m_researchId = research_id
    self.m_uiName = 'UI_ResearchConfirmPopup'
    local vars = self:load('research_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ResearchConfirmPopup')

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
function UI_ResearchConfirmPopup:initUI()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ResearchConfirmPopup:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() 
        self:close()
    end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ResearchConfirmPopup:refresh()
end


--@CHECK
UI:checkCompileError(UI_ResearchConfirmPopup)
