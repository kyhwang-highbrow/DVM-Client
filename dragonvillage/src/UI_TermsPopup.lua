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
    local vars = self:load('agreement_popup.ui')
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
	--vars['viewBtn1'] -- Button
	--vars['viewBtn2'] -- Button
	--vars['agreeSprite1'] -- Sprite
	--vars['agreeSprite2'] -- Sprite
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TermsPopup:initButton()
    local vars = self.vars
    vars['agreeBtn1']:registerScriptTapHandler(function() self:click_agreeBtn1() end)
    vars['agreeBtn2']:registerScriptTapHandler(function() self:click_agreeBtn2() end)
    vars['viewBtn1']:registerScriptTapHandler(function() self:click_viewBtn1() end)
    vars['viewBtn2']:registerScriptTapHandler(function() self:click_viewBtn2() end)

    self.m_agree1 = 0
    self.m_agree2 = 0
    self:checkAgreeState()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TermsPopup:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_TermsPopup:click_closeBtn()
    g_localData:applyLocalData(0, 'local', 'agree_terms')
    self:close()
end

-------------------------------------
-- function click_viewBtn1
-------------------------------------
function UI_TermsPopup:click_viewBtn1()
    local url = URL['PERPLELAB_AGREEMENT']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function click_viewBtn2
-------------------------------------
function UI_TermsPopup:click_viewBtn2()
    local url = URL['PERPLELAB_PI']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function click_agreeBtn1
-------------------------------------
function UI_TermsPopup:click_agreeBtn1()
    self.m_agree1 = 1 - self.m_agree1
    self.vars['agreeSprite1']:setVisible(self.m_agree1 == 1)
    self:checkAgreeState()
end

-------------------------------------
-- function click_agreeBtn2
-------------------------------------
function UI_TermsPopup:click_agreeBtn2()
    self.m_agree2 = 1 - self.m_agree2
    self.vars['agreeSprite2']:setVisible(self.m_agree2 == 1)
    self:checkAgreeState()
end

-------------------------------------
-- function updateAgreeButton
-------------------------------------
function UI_TermsPopup:checkAgreeState()
    if self.m_agree1 == 1 and self.m_agree2 == 1 then
        local success_cb = function(ret)
            g_localData:applyLocalData(1, 'local', 'agree_terms')
            self:close()
        end
        local fail_cb = function(ret)
            ccdump(ret)
            g_localData:applyLocalData(1, 'local', 'agree_terms')
            self:close()
        end
        local game_id = 1003
        local uid = g_localData:get('local', 'uid')
        local terms = 1
        Network_platform_updateTerms(game_id, uid, terms, success_cb, fail_cb)
    end
end

--@CHECK
UI:checkCompileError(UI_TermsPopup)
