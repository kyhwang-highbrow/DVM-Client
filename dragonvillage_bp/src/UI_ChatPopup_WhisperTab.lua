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
    -- 채팅 비활성화 시
    if (g_chatIgnoreList:isGlobalIgnore()) then
        UIManager:toastNotificationRed(Str('채팅이 비활성화 상태입니다.'))
        return
    end

    local vars = self.vars

    if (not self.m_peerUserNickname) or (self.m_peerUserNickname == '') then
        UIManager:toastNotificationRed('귓속말 상대방 닉네임을 입력하세요.')
        return
    end
    
    local msg = vars['editBox_whisper']:getText()
    local len = string.len(msg)
    if (len <= 0) then
        UIManager:toastNotificationRed('메시지를 입력하세요.')
        return
    end

    -- 비속어 필터링
    if (not FilterMsg(msg)) then
        vars['editBox_whisper']:setText('')
        UIManager:toastNotificationRed('사용할 수 없는 표현이 포함되어 있습니다.')
        return
    end

    if g_chatManager:sendWhisperMsg(self.m_peerUserNickname, msg) then
        vars['editBox_whisper']:setText('')
    else
        local msg = Str('[{1}]유저를 찾을 수 없습니다.', self.m_peerUserNickname)
        UIManager:toastNotificationRed(msg)
    end
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
                self.vars['whisperSetUserLabel']:setString('귓속말')
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
        self.vars['whisperSetUserLabel']:setString('귓속말')
    else
        self.vars['whisperSetUserLabel']:setString(nickname)
    end
end