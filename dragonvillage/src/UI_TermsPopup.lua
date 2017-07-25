local PARENT = UI

-------------------------------------
-- class UI_TermsPopup
-------------------------------------
UI_TermsPopup = class(PARENT,{
        m_agree1 = 'num',
        m_agree2 = 'num',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TermsPopup:init()
    local vars = self:load('agreement.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_TermsPopup')

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
function UI_TermsPopup:initUI()
    local vars = self.vars
	--vars['agreeLabel1'] -- LabelTTF
	--vars['agreeLabel2'] -- LabelTTF
	--vars['agreeBtn2'] -- Button
	--vars['agreeBtn2'] -- Button
	--vars['agreeSprite1'] -- Sprite
	--vars['agreeSprite2'] -- Sprite
	--vars['agreeBtn'] -- Button
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TermsPopup:initButton()
    local vars = self.vars
    vars['agreeBtn1']:registerScriptTapHandler(function() self:click_agreeBtn1() end)
    vars['agreeBtn2']:registerScriptTapHandler(function() self:click_agreeBtn2() end)
    vars['agreeBtn']:registerScriptTapHandler(function() self:click_agreeBtn() end)

    self.m_agree1 = 0
    self.m_agree2 = 0
    self:updateAgreeButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TermsPopup:refresh()
end

-------------------------------------
-- function click_agreeBtn1
-------------------------------------
function UI_TermsPopup:click_agreeBtn1()
    self.m_agree1 = 1 - self.m_agree1
    self.vars['agreeSprite1']:setVisible(self.m_agree1 == 1)
    self:updateAgreeButton()
end

-------------------------------------
-- function click_agreeBtn2
-------------------------------------
function UI_TermsPopup:click_agreeBtn2()
    self.m_agree2 = 1 - self.m_agree2
    self.vars['agreeSprite2']:setVisible(self.m_agree2 == 1)
    self:updateAgreeButton()
end

-------------------------------------
-- function click_agreeBtn
-------------------------------------
function UI_TermsPopup:click_agreeBtn()
    self:close()
end

-------------------------------------
-- function updateAgreeButton
-------------------------------------
function UI_TermsPopup:updateAgreeButton()
    if self.m_agree1 == 1 and self.m_agree2 == 1 then
        -- agreeBtn 을 활성화
        self.vars['agreeBtn']:setEnabled(true)
    else
        -- agreeBtn 을 비활성화
        self.vars['agreeBtn']:setEnabled(false)
    end
end

--@CHECK
UI:checkCompileError(UI_TermsPopup)
