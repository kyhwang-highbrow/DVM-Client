local PARENT = UI

-------------------------------------
-- class UI_ErrorPopup_Live
-- @brief 에러를 화면에 찍어준다.
-------------------------------------
UI_ErrorPopup_Live = class(PARENT, {
		m_errorStr = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ErrorPopup_Live:init(str)
    self:load('popup_error_report.ui')
    UIManager:open(self, UIManager.ERROR_POPUP)

    self.m_uiName = 'UI_ErrorPopup_Live'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ErrorPopup_Live')

	self:initUI()
	self:initButton()

	self:setErrorStr(str)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ErrorPopup_Live:initButton()
    local vars = self.vars

    vars['reportBtn']:registerScriptTapHandler(function() self:click_reportBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function setErrorStr
-------------------------------------
function UI_ErrorPopup_Live:setErrorStr(str)
    self.m_errorStr = str
end

-------------------------------------
-- function click_reportBtn
-------------------------------------
function UI_ErrorPopup_Live:click_reportBtn()
    local error_str = self.m_errorStr
    UIManager:toastNotificationGreen('전송이 완료되었다고라. 고맙다고라.')
    self:close()
end
