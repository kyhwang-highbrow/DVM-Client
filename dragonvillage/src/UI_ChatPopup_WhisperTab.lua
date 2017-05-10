-------------------------------------
-- class UI_ChatPopup_WhisperTab
-------------------------------------
UI_ChatPopup_WhisperTab = class({
        vars = '',
        m_chatList = 'UI_ChatList',
        m_peerUserNickname = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatPopup_WhisperTab:init(ui)
    self.vars = ui.vars
    local vars = self.vars
    
    self.m_peerUserNickname = nil

    local list_table_node = vars['whisperChatNode']
    local size = list_table_node:getContentSize()
    self.m_chatList = UI_ChatList(list_table_node, size['width'], size['height'], 50)

    vars['enterBtn_whisper']:registerScriptTapHandler(function() self:click_enterBtn() end)
    vars['whisperSetUserBtn']:registerScriptTapHandler(function() self:click_whisperSetUserBtn() end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ChatPopup_WhisperTab:onEnterTab(first)
    local vars = self.vars

    if first then

    end
end

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_ChatPopup_WhisperTab:click_enterBtn()
    local vars = self.vars

    if (not self.m_peerUserNickname) or (self.m_peerUserNickname == '') then
        UIManager:toastNotificationRed('귓속말 보낼 사용자의 닉네임을 입력하세요.')
        return
    end
    
    local msg = vars['editBox_whisper']:getText()
    if (string.len(msg) <= 0) then
        return
    end

    if g_chatManager:sendWhisperMsg(self.m_peerUserNickname, msg) then
        vars['editBox_whisper']:setText('')
    end
end

-------------------------------------
-- function click_whisperSetUserBtn
-------------------------------------
function UI_ChatPopup_WhisperTab:click_whisperSetUserBtn()
    local edit_box = UI_SimpleEditBoxPopup()
    edit_box:setPopupTitle(Str('귓속말 보낼 사용자의 닉네임을 입력하세요.'))
    edit_box:setPopupDsc(Str('귓속말 보낼 사용자의 닉네임을 입력하세요.'))
    edit_box:setPlaceHolder(Str('입력하세요.'))

    local function confirm_cb(str)
        return true
    end
    edit_box:setConfirmCB(confirm_cb)

    local function close_cb(str)
        local nickname = edit_box.vars['editBox']:getText()
        self.m_peerUserNickname = nickname

        if (not nickname) or (nickname == '') then
            self.vars['whisperSetUserLabel']:setString('귓속말')
        else
            self.vars['whisperSetUserLabel']:setString(nickname)
        end
        
    end
    edit_box:setCloseCB(close_cb)
end

-------------------------------------
-- function msgQueueCB
-------------------------------------
function UI_ChatPopup_WhisperTab:msgQueueCB(msg)
    --[[
    local content = UI_ChatListItem(msg)
    content.root:setAnchorPoint(0.5, 0)
    local height = content:getItemHeight()
    self.m_chatList:addContent(content.root, height, 'type')
    --]]

    --self.m_chatTableView:addChatContent(chat_content)
end