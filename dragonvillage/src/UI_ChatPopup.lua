local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ChatPopup
-------------------------------------
UI_ChatPopup = class(PARENT, {
        m_mTabUI = '',
        m_chatList = '',

        m_chatTableView = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatPopup:init()
    local vars = self:load('chat_new.ui')
    --UIManager:open(self, UIManager.NORMAL)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ChatPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    for i,msg in ipairs(g_chatManager.m_lMessage) do
        self:msgQueueCB(msg)
    end

    self:refresh_connectStatus(g_chatManager.m_chatClient.m_status)
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_ChatPopup:initUI()
    local vars = self.vars
    
    --[[
    local list_table_node = vars['chatNode']
    local size = list_table_node:getContentSize()
    self.m_chatList = UI_ChatList(list_table_node, size['width'], size['height'], 50)
    --]]

    self:init_tableView()

    self:initTab()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_ChatPopup:init_tableView()
    local vars = self.vars
    local node = vars['chatNode']

    self.m_chatTableView = UIC_ChatView(node)
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_ChatPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChatPopup:refresh()
    local vars = self.vars
end


-------------------------------------
-- function closeBtn
-------------------------------------
function UI_ChatPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_ChatPopup:click_enterBtn()
    local vars = self.vars

    local msg = vars['editBox']:getText()
    local len = string.len(msg)
    if (len <= 0) then
        UIManager:toastNotificationRed('메시지를 입력하세요.')
        return
    end

    if g_chatManager:sendNormalMsg(msg) then
        vars['editBox']:setText('')
    else
        UIManager:toastNotificationRed('메시지 전송에 실패하였습니다.')
    end
end


-------------------------------------
-- function msgQueueCB
-------------------------------------
function UI_ChatPopup:msgQueueCB(chat_content)
    local category = chat_content:getContentCategory()    

    -- 서버와의 연결 상태
    if (category == 'change_status') then
        local status = chat_content['message']
        self:refresh_connectStatus(status)

    elseif (category == 'general') then
        self.m_chatTableView:addChatContent(chat_content)

        local content_type = chat_content:getContentType()
        if (content_type == 'enter_channel') then
            local channel = chat_content['message']
            local str = Str('채널 {1}', channel)
            self.vars['sortOrderLabel']:setString(str)
        end

    elseif (category == 'whisper') then
        self.m_mTabUI['whisper_chat']:msgQueueCB(chat_content)
    end
end

-------------------------------------
-- function refresh_connectStatus
-------------------------------------
function UI_ChatPopup:refresh_connectStatus(status)
    local vars = self.vars

    if (status == 'Success') then
        vars['connectLabel']:setString(Str('연결됨'))
        vars['connectSprite']:stopAllActions()
        vars['connectSprite']:runAction(cc.TintTo:create(0.2, 119, 255, 0))

    elseif (status == 'Connecting') then
        vars['connectLabel']:setString(Str('연결 중'))
        vars['connectSprite']:stopAllActions()
        vars['connectSprite']:runAction(cc.TintTo:create(0.2, 255, 255, 18))

    elseif (status == 'Disconnected') then
        vars['connectLabel']:setString(Str('연결 해제됨'))
        vars['connectSprite']:stopAllActions()
        vars['connectSprite']:runAction(cc.TintTo:create(0.2, 255, 35, 18))

    elseif (status == 'Closed') then
        vars['connectLabel']:setString(Str('연결 해제됨'))
        vars['connectSprite']:stopAllActions()
        vars['connectSprite']:runAction(cc.TintTo:create(0.2, 255, 35, 18))

    end
end

-------------------------------------
-- function onDestroyUI
-------------------------------------
function UI_ChatPopup:onDestroyUI()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ChatPopup:initTab()
    self.m_mTabUI = {}
    self.m_mTabUI['whisper_chat'] = UI_ChatPopup_WhisperTab(self)

    local vars = self.vars
    self:addTab('general_chat', vars['generalTabBtn'], vars['generalMenu'])
    --self:addTab('guild_chat', vars['guildTabBtn'], vars['guildChatNode'])
    self:addTab('whisper_chat', vars['whisperTapBtn'], vars['whisperMenu'])
    self:setTab('general_chat')

    vars['guildTabBtn']:registerScriptTapHandler(function()
            UIManager:toastNotificationRed('"길드"는 준비 중입니다.')
        end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ChatPopup:onChangeTab(tab, first)
    local vars = self.vars

    if (tab == 'general_chat') then
        local channel_name = g_chatManager:getChannelName()
        local str = Str('채널 {1}', channel_name or '')
        vars['sortOrderLabel']:setString(str)
        vars['sortBtn']:registerScriptTapHandler(function() self:click_changeChannelBtn() end)
    end

    if self.m_mTabUI[tab] then
        self.m_mTabUI[tab]:onEnterTab(first)
    end
end

-------------------------------------
-- function click_changeChannelBtn
-------------------------------------
function UI_ChatPopup:click_changeChannelBtn()
    local edit_box = UI_SimpleEditBoxPopup()
    edit_box:setPopupTitle(Str('이동할 채널 번호를 입력해주세요. (1~999)'))
    edit_box:setPopupDsc(Str('이동할 채널 번호를 입력해주세요. (1~999)'))
    edit_box:setPlaceHolder(Str('입력하세요.'))

    local function confirm_cb(str)
        local channel_num = tonumber(str)

        if (not channel_num) then
            UIManager:toastNotificationRed('1~999 사이의 숫자를 입력해주세요.')
            return false
        end

        if (channel_num < 0 or 999 < channel_num) then
            UIManager:toastNotificationRed('1~999 사이의 숫자를 입력해주세요.')
            return false
        end
        return true
    end
    edit_box:setConfirmCB(confirm_cb)

    local function close_cb(str)
        local channel_name = edit_box.vars['editBox']:getText()
        --g_serverData:applyServerData(text, 'local', 'idfa')
        --self:doNextWork()
        if (not g_chatManager:requestChangeChannel(channel_name)) then
            UIManager:toastNotificationRed('채널 이동 요청을 실패하였습니다.')
        end
    end
    edit_box:setCloseCB(close_cb)
end

-------------------------------------
-- function setWhisperUser
-------------------------------------
function UI_ChatPopup:setWhisperUser(nickname)
    self:setTab('whisper_chat')
    self.m_mTabUI['whisper_chat']:setPeerUserNickname(nickname)
end