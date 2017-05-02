local PARENT = UI

-------------------------------------
-- class UI_LobbyUserInfoPopup
-------------------------------------
UI_LobbyUserInfoPopup = class(PARENT, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyUserInfoPopup:init(t_user_info)
    local vars = self:load('lobby_user_info_02.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_LobbyUserInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton(t_user_info)
    self:refresh(t_user_info)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_LobbyUserInfoPopup:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyUserInfoPopup:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LobbyUserInfoPopup:initButton(t_user_info)
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn(t_user_info) end)
    vars['requestBtn']:registerScriptTapHandler(function() self:click_requestBtn(t_user_info) end)
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_LobbyUserInfoPopup:refresh(t_user_info)
    local vars = self.vars

    vars['guildLabel']:setString(t_user_info['guild'])
    vars['nameLabel']:setString(t_user_info['nick'])
    vars['lvLabel']:setString(Str('레벨 {1}', t_user_info['lv']))

    local t_dragon_data = t_user_info['leader']
    local dragon_card = UI_DragonCard(t_dragon_data)
    vars['dragonNode']:addChild(dragon_card.root)
    
    dragon_card.vars['clickBtn']:registerScriptTapHandler(function()
        local doid = t_dragon_data['id']
        if doid and (doid ~= '') then
            UI_SimpleDragonInfoPopup(t_dragon_data)
        end
    end)

    local uid = t_user_info['uid']
    vars['requestBtn']:setVisible(not g_friendData.m_mInvitedUerList[uid])
end

-------------------------------------
-- function click_infoBtn
-- @brief
-------------------------------------
function UI_LobbyUserInfoPopup:click_infoBtn(t_user_info)
    local uid = t_user_info['uid']
    RequestUserDeckInfoPopup(uid)
end

-------------------------------------
-- function click_requestBtn
-- @brief 친구 요청
-------------------------------------
function UI_LobbyUserInfoPopup:click_requestBtn(t_user_info)
    local t_friend_info = t_user_info

    local function finish_cb(ret)
        self.vars['requestBtn']:setVisible(false)
        local msg = Str('[{1}]에게 친구 요청을 하였습니다.', t_friend_info['nick'])
        UIManager:toastNotificationGreen(msg)
    end

    local friend_ui = t_friend_info['uid']
    g_friendData:request_invite(friend_ui, finish_cb)
end

-------------------------------------
-- function RequestUserDeckInfoPopup
-------------------------------------
function RequestUserInfoPopup(peer_uid)
	-- 유저 ID
    local uid = g_userData:get('uid')
	local peer_uid = peer_uid

    local function success_cb(ret)
		local t_user_info = ret['user_info']
        UI_LobbyUserInfoPopup(t_user_info)
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
UI:checkCompileError(UI_LobbyUserInfoPopup)
