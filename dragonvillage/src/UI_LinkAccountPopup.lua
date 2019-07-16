local PARENT = UI

-------------------------------------
-- class UI_LinkAccountPopup
-------------------------------------
UI_LinkAccountPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LinkAccountPopup:init()
    self:load('popup_cheers.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_LinkAccountPopup'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_LinkAccountPopup')

	self:initUI()
	self:initButton()

    	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LinkAccountPopup:initUI()
    self:setLoginUI(true) -- is_login
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LinkAccountPopup:initButton()
    local vars = self.vars

	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:close() end)
    vars['connectBtn']:registerScriptTapHandler(function() self:click_connectBtn() end)
end

-------------------------------------
-- function setLoginUI
-------------------------------------
function UI_LinkAccountPopup:setLoginUI(is_login)
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
function UI_LinkAccountPopup:click_connectBtn()
    UI_LoginPopup2()
end

function UI_LinkAccountPopup.checkLinkAccountCondition()
    -- 1. 게스트 계정인가
    local is_guest = g_localData:isGuestAccount()
    if (not is_guest) then
        return false
    end

    local t_link_account = g_settingData:getLinkAccountStep()
    local lv = g_userData:get('lv')
    -- 2. 레벨이 8 이상
    if (lv >= 8) then
        if (not t_link_account['upper_lv_8']) then
            t_link_account['upper_lv_8'] = true
            t_link_account['clear_2_1'] = true
            g_settingData:setLinkAccountStep(t_link_account)
            return true 
        end
    end

    -- 3. 2-1을 클리어
    if (g_adventureData:isClearStage(1110201)) then
        if (not t_link_account['clear_2_1']) then
            t_link_account['clear_2_1'] = true
            g_settingData:setLinkAccountStep(t_link_account)
            return true 
        end
    end

    return false   
end


