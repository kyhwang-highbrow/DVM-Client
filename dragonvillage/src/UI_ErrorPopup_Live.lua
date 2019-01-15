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
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ErrorPopup_Live')

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
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
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
	-- @mskim 간혹.. 같은 에러가 3~4번씩 오는 경우가 있어 통신 지연시 터치가 여러번 되는 것을 의심
	UI_BlockPopup()

    local error_str = self.m_errorStr
    local function cb_func()
        local toast_str = Str('전송이 완료되었다고라.')
        UIManager:toastNotificationGreen(toast_str)
        self:click_closeBtn()
    end
    g_errorTracker:sendErrorLog(error_str, cb_func)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ErrorPopup_Live:click_closeBtn()
    local function cb_func()
        CppFunctions:restart()
    end
    UI_SimplePopup(POPUP_TYPE.OK, Str('앱을 재시작합니다.'), cb_func, nil, UIManager.TOP_POPUP)
end
