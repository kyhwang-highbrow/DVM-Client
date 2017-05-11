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

    if vars['requestBtn'] then
        vars['requestBtn']:setVisible(false)
    end

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
    local dragon_card = UI_DragonCard(dragon_object)
    vars['dragonNode']:addChild(dragon_card.root)
    
    dragon_card.vars['clickBtn']:registerScriptTapHandler(function()
        local doid = dragon_object['id']
        if doid and (doid ~= '') then
            UI_SimpleDragonInfoPopup(dragon_object)
        end
    end)
end

-------------------------------------
-- function click_infoBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_infoBtn()
    local uid = self.m_structUserInfo:getUid()
    RequestUserDeckInfoPopup(uid)
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
