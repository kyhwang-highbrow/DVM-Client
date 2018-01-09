local PARENT = UI

-------------------------------------
-- class UI_SelectLanguagePopup
-------------------------------------
UI_SelectLanguagePopup = class(PARENT, {
		m_radioButton = 'UIC_RadioBtn',
		m_finishFunc = 'function',

     })

-- Translate에서 주관해야함
local t_lang_list = {
	['kr'] = Str('한국어'), 
	['en'] = Str('영어'), 
	['ja'] = Str('일본어'), 
	['zh'] = Str('중국어')
}

-------------------------------------
-- function init
-------------------------------------
function UI_SelectLanguagePopup:init(cb_func)
    local vars = self:load('popup_language.ui')
    UIManager:open(self, UIManager.POPUP)
	
    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	self.m_finishFunc = cb_func

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

	-- radio btn
	do

		local radio_button = UIC_RadioButton()

		for lang, text in pairs(t_lang_list) do
			radio_button:addButtonAuto(lang, vars)
		end
		radio_button:setSelectedButton('en')
		radio_button:setChangeCB(function() self:onChangeOption() end)

		self.m_radioButton = radio_button
	end

	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
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
function UI_SelectLanguagePopup:onChangeOption()
	local lang = self.m_radioButton.m_selectedButton
	local name = t_lang_list[lang]
	local msg = Str('{1}를 선택합니다.', name)
	local function cb_func()
		-- 언어 저장 및 언어 파일 불러옴
		g_localData:applyLocalData(lang, 'lang')
		Translate:load(lang)

		-- 해당 UI 콜백이 패치 시작하는 함수
		if (self.m_finishFunc) then
			self.m_finishFunc()
		end

		self:close()
	end
	MakeSimplePopup(POPUP_TYPE.YES_NO, msg, cb_func)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SelectLanguagePopup:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_SelectLanguagePopup)
