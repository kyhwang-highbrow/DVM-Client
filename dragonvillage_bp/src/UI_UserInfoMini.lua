local PARENT = UI

-------------------------------------
-- class UI_UserInfoMini
-------------------------------------
UI_UserInfoMini = class(PARENT, {
        m_structUserInfo = 'StruntUserInfo',
    })

-------------------------------------
-- function init
-- @param struct_user_info StructUserInfo
-------------------------------------
function UI_UserInfoMini:init(struct_user_info)
    self.m_uiName = 'UI_UserInfoMini'
    self.m_structUserInfo = struct_user_info

    local vars = self:load('lobby_user_info_02.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_UserInfoMini')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function open
-- @param struct_user_info StructUserInfo
-------------------------------------
function UI_UserInfoMini:open(struct_user_info)
    if (g_userData:get('uid') == struct_user_info.m_uid) then
        return nil
    end

    local peer_uid = struct_user_info.m_uid
    RequestUserInfoDetailPopup(peer_uid, true) -- param : peer_uid, is_visit
    --return UI_UserInfoMini(struct_user_info)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_UserInfoMini:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_UserInfoMini:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoMini:initButton(t_user_info)
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['requestBtn']:registerScriptTapHandler(function() self:click_requestBtn() end)

    vars['whisperBtn']:registerScriptTapHandler(function() self:click_whisperBtn() end)
    vars['blockBtn']:registerScriptTapHandler(function() self:click_blockBtn() end)
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_UserInfoMini:refresh()
    local vars = self.vars

    local user_info = self.m_structUserInfo

    vars['guildLabel']:setString(user_info:getGuild())
    vars['nameLabel']:setString(user_info:getNickname())
    vars['lvLabel']:setString(Str('레벨 {1}', user_info:getLv()))

    local dragon_object = user_info:getLeaderDragonObject()
    if dragon_object then
        local dragon_card = UI_DragonCard(dragon_object)
        vars['dragonNode']:addChild(dragon_card.root)
    
        dragon_card.vars['clickBtn']:registerScriptTapHandler(function()
            local doid = dragon_object['id']
            if doid and (doid ~= '') then
                UI_SimpleDragonInfoPopup(dragon_object)
            end
        end)
    end
end

-------------------------------------
-- function click_infoBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_infoBtn()
    local uid = self.m_structUserInfo:getUid()
    local is_visit = true
    RequestUserInfoDetailPopup(uid, is_visit)
end

-------------------------------------
-- function click_requestBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_requestBtn()
    local nickname = self.m_structUserInfo:getNickname()
    local function finish_cb(ret)
        local msg = Str('[{1}]에게 친구 요청을 하였습니다.', nickname)
        UIManager:toastNotificationGreen(msg)
    end

    local friend_ui = self.m_structUserInfo:getUid()
    g_friendData:request_invite(friend_ui, finish_cb)
end

-------------------------------------
-- function click_whisperBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_whisperBtn()
   local nickname = self.m_structUserInfo:getNickname()
   g_chatManager:openChatPopup_whisper(nickname)
   self:close()
end

-------------------------------------
-- function click_blockBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_blockBtn()
    local uid = self.m_structUserInfo:getUid()
    local nickname = self.m_structUserInfo:getNickname()
    g_chatIgnoreList:addIgnore(uid, nickname)
end





--@CHECK
UI:checkCompileError(UI_UserInfoMini)
