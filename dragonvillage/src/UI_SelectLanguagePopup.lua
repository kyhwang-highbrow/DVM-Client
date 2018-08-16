local PARENT = UI

-------------------------------------
-- class UI_SelectLanguagePopup
-------------------------------------
UI_SelectLanguagePopup = class(PARENT, {
		m_radioButton = 'UIC_RadioBtn',
		m_finishFunc = 'function',

     })

-------------------------------------
-- function init
-------------------------------------
function UI_SelectLanguagePopup:init(cb_func)
    local vars = self:load('popup_language.ui')
    UIManager:open(self, UIManager.POPUP)

	self.m_uiName = 'UI_SelectLanguagePopup'

	-- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_PickDragon')

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

		-- Translate에서 텍스트 참조하기 위해 가져옴
		local t_lang_list = Translate:getLangStrTable()

		-- 언어별로 버튼 등록
		for lang, text in pairs(t_lang_list) do
			radio_button:addButtonAuto(lang, vars)

			-- 한국어 번역되어서 클라에서 찍음
			vars[lang .. 'Label']:setString(text)
		end

		-- 현재 언어가 있는 경우에만 선택
		local curr_lang = Translate:getGameLang()
		if (curr_lang) then
			radio_button:setSelectedButton(curr_lang)
		end

		radio_button:setChangeCB(function() self:onChangeOption() end)
		self.m_radioButton = radio_button
	end

	vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SelectLanguagePopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function onChangeOption
-------------------------------------
function UI_SelectLanguagePopup:onChangeOption()

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SelectLanguagePopup:click_okBtn()
	local lang = self.m_radioButton.m_selectedButton
	if (lang == Translate:getGameLang()) then
		self:close()
		return
	end

	-- 언어 저장 및 언어 파일 불러옴
	g_localData:setLang(lang)
	Translate:load(lang)

    local ui = UI_Network()
	ui:setLoadingMsg('')

    local function onFinish()
        -- 해당 UI 콜백이 패치 시작하는 함수
	    if (self.m_finishFunc) then
		    self.m_finishFunc()
	    end
        ui:close()
	    self:close()
    end

    local function onFail()
        ui:close()
    end

    Network_platform_changeLang( onFinish, onFail )

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SelectLanguagePopup:click_closeBtn()
	local curr_lang = Translate:getGameLang()
	if (not curr_lang) then
		local msg = Str('언어를 선택하지 않으셨습니다!')
		MakeSimplePopup(POPUP_TYPE.OK, msg)
		return
	end

    self:close()
end

--@CHECK
UI:checkCompileError(UI_SelectLanguagePopup)
