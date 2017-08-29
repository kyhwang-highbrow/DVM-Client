local PARENT = UI

-------------------------------------
-- class UI_CheersPopup
-- @brief 에러를 화면에 찍어준다.
-------------------------------------
UI_CheersPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CheersPopup:init(str)
    self:load('popup_cheers.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_CheersPopup'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_CheersPopup')

	self:initUI()
	self:initButton()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CheersPopup:initButton()
    local vars = self.vars

    vars['cheersBtn']:registerScriptTapHandler(function() self:click_cheersBtn() end)
    vars['suggestBtn']:registerScriptTapHandler(function() self:click_suggestBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function click_cheersBtn
-- @brief 응원하기 - 구글 평점 으로 보냄
-------------------------------------
function UI_CheersPopup:click_cheersBtn()
    SDKManager:goToAppStore()
    self:close()
end

-------------------------------------
-- function click_suggestBtn
-- @brief 건의하기 - 드빌 커뮤니티로 보냄
-------------------------------------
function UI_CheersPopup:click_suggestBtn()
    local url = URL['DVM_COMMUNITY']
    SDKManager:goToWeb(url)
    self:close()
end
