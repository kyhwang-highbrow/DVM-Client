local PARENT = UI

-------------------------------------
-- class UI_UserInfoDetailPopup
-------------------------------------
UI_UserInfoDetailPopup = class(PARENT, {
	m_tUserInfo = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function UI_UserInfoDetailPopup:init(t_user_info)
    self.m_uiName = 'UI_UserInfoDetailPopup'

    local vars = self:load('user_info.ui.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_UserInfoDetailPopup')

    self.m_tUserInfo = t_user_info

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserInfoDetailPopup:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoDetailPopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_UserInfoDetailPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_infoBtn
-- @brief
-------------------------------------
function UI_UserInfoDetailPopup:click_infoBtn()
end

-------------------------------------
-- function RequestUserDeckInfoPopup
-------------------------------------
function RequestUserInfoDetailPopup(peer_uid)
	-- 유저 ID
    local uid = g_userData:get('uid')
	local peer_uid = peer_uid

    local function success_cb(ret)
		local t_user_info = ret['user_info']
        UI_UserInfoDetailPopup(t_user_info)
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/users/get/user_info')
	ui_network:setParam('uid', uid)
    ui_network:setParam('peer', peer_uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()    
end

--@CHECK
UI:checkCompileError(UI_UserInfoDetailPopup)
