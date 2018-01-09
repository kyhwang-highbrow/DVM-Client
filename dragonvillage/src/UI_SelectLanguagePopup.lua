local PARENT = UI

-------------------------------------
-- class UI_SelectLanguagePopup
-------------------------------------
UI_SelectLanguagePopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SelectLanguagePopup:init()
    local vars = self:load('select_server_popup.ui')
    UIManager:open(self, UIManager.SCENE)
	
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
function UI_SelectLanguagePopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SelectLanguagePopup:initButton()
    local vars = self.vars

	local l_server_locale_list = {'korea', 'japan', 'usa'}
	for _, locale in ipairs(l_server_locale_list) do
		vars[locale .. 'Btn']:registerScriptTapHandler(function() self:click_localeBtn(locale) end)
	end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SelectLanguagePopup:refresh()
    local vars = self.vars

end

-------------------------------------
-- function click_localeBtn
-------------------------------------
function UI_SelectLanguagePopup:click_localeBtn(locale)
	local msg = Str('{1} 서버를 선택합니다.', locale)
	local function cb_func()
		-- 해당 UI 콜백이 패치 시작하는 함수
		self:close()
	end
	MakeSimplePopup(POPUP_TYPE.YES_NO, msg, cb_func)
end

--@CHECK
UI:checkCompileError(UI_SelectLanguagePopup)
