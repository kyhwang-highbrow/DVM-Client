local PARENT = UI

-------------------------------------
-- class UI_UserInfoDetailPopup_SetProfile
-------------------------------------
UI_UserInfoDetailPopup_SetProfile = class(PARENT, {
	m_tUserInfo = 'table',
	m_isVisit = 'bool',
})

-------------------------------------
-- function init
-------------------------------------
function UI_UserInfoDetailPopup_SetProfile:init(t_user_info, is_visit)
    self.m_uiName = 'UI_UserInfoDetailPopup_SetProfile'

    local vars = self:load('user_info_profile.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_UserInfoDetailPopup_SetProfile')


    self:initUI()
    self:initButton()
    self:refresh()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserInfoDetailPopup_SetProfile:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoDetailPopup_SetProfile:initButton()
    local vars = self.vars
	vars['profileBtn']:registerScriptTapHandler(function() self:click_profileBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserInfoDetailPopup_SetProfile:refresh()
    local vars = self.vars

end


--@CHECK
UI:checkCompileError(UI_UserInfoDetailPopup_SetProfile)
