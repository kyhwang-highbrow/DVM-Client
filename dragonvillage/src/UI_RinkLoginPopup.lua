local PARENT = UI

-------------------------------------
-- class UI_RinkLoginPopup
-------------------------------------
UI_RinkLoginPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RinkLoginPopup:init(str)
    self:load('popup_cheers.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_RinkLoginPopup'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RinkLoginPopup')

	self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RinkLoginPopup:initUI()
    self:setLoginUI(true) -- is_login
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RinkLoginPopup:initButton()
    local vars = self.vars

	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:close() end)
    vars['connectBtn']:registerScriptTapHandler(function() self:click_connectBtn() end)
end

-------------------------------------
-- function setLoginUI
-------------------------------------
function UI_RinkLoginPopup:setLoginUI(is_login)
    local vars = self.vars

    -- 평점 권유 팝업_ver
    vars['cheersBtn']:setVisible(not is_login)
    vars['suggestBtn']:setVisible(not is_login)
    vars['goraNode1']:setVisible(not is_login)
    vars['dscLabel']:setVisible(not is_login)
    vars['dscLabel2']:setVisible(not is_login)

    -- 계정 연동 권유 팝업_ver
    vars['skipBtn']:setVisible(is_login)
    vars['connectBtn']:setVisible(is_login)
    vars['connectLabel']:setVisible(is_login)
    vars['goraNode2']:setVisible(is_login)
end

-------------------------------------
-- function click_connectBtn
-------------------------------------
function UI_RinkLoginPopup:click_connectBtn()
    UI_LoginPopup2()
end

