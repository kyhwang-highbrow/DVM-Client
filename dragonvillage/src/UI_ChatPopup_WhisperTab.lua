-------------------------------------
-- class UI_ChatPopup_WhisperTab
-------------------------------------
UI_ChatPopup_WhisperTab = class({
        vars = '',
        m_peerUserNickname = 'string',
        m_chatTableView = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatPopup_WhisperTab:init(ui)
    self.vars = ui.vars
    local vars = self.vars
    
    self.m_peerUserNickname = nil

    local list_table_node = vars['whisperChatNode']
    self.m_chatTableView = UIC_ChatView(list_table_node)

    vars['enterBtn_whisper']:registerScriptTapHandler(function() self:click_enterBtn() end)
    vars['whisperSetUserBtn']:registerScriptTapHandler(function() self:click_whisperSetUserBtn() end)

    do -- 채팅 EditBox에서 입력 완료 후 바로 전송하기
        local function editBoxTextEventHandle(strEventName,pSender)
            if (strEventName == "return") then
                self:click_enterBtn()
            end
        end
        vars['editBox_whisper']:registerScriptEditBoxHandler(editBoxTextEventHandle)
        vars['editBox_whisper']:setMaxLength(CHAT_MAX_MESSAGE_LENGTH) -- 글자 입력 제한 40자
    end
end

-------------------------------------
-- function onEnterTab
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
    if (not self.m_peerUserNickname) or (self.m_peerUserNickname == '') then
        UIManager:toastNotificationRed(Str('귓속말 상대방 닉네임을 입력하세요.'))
        return
    end

	local tab = 'whisper'
	local edit_box = self.vars['editBox_whisper']
    local msg = edit_box:getText()
    UI_ChatPopup.sendMsg(msg, tab, edit_box, self.m_peerUserNickname)
end

-------------------------------------
-- function click_whisperSetUserBtn
-------------------------------------
function UI_ChatPopup_WhisperTab:click_whisperSetUserBtn()
    local edit_box = UI_SimpleEditBoxPopup()
    edit_box:setPopupTitle(Str('귓속말 상대방 닉네임을 입력하세요.'))
    edit_box:setPopupDsc(Str('귓속말 상대방 닉네임을 입력하세요.'))
    edit_box:setPlaceHolder(Str('입력하세요.'))

    local function confirm_cb(str)
        return true
    end
    edit_box:setConfirmCB(confirm_cb)

    local function close_cb(str)
        if (edit_box.m_retType == 'ok') then
            local nickname = edit_box.m_str
            self.m_peerUserNickname = nickname

            if (not nickname) or (nickname == '') then
                self.vars['whisperSetUserLabel']:setString(Str('귓속말'))
            else
                self.vars['whisperSetUserLabel']:setString(nickname)
            end
        end
    end
    edit_box:setCloseCB(close_cb)
end

-------------------------------------
-- function msgQueueCB
-------------------------------------
function UI_ChatPopup_WhisperTab:msgQueueCB(chat_content)
    self.m_chatTableView:addChatContent(chat_content)
end

-------------------------------------
-- function setPeerUserNickname
-------------------------------------
function UI_ChatPopup_WhisperTab:setPeerUserNickname(nickname)
    self.m_peerUserNickname = nickname

    if (not nickname) or (nickname == '') then
        self.vars['whisperSetUserLabel']:setString(Str('귓속말'))
    else
        self.vars['whisperSetUserLabel']:setString(nickname)
    end
end