-------------------------------------
-- class UI_ChatPopup_ClanTab
-------------------------------------
UI_ChatPopup_ClanTab = class({
        vars = '',
        m_chatTableView = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatPopup_ClanTab:init(ui)
    self.vars = ui.vars
    local vars = self.vars
    
    local list_table_node = vars['clanChatNode']
    self.m_chatTableView = UIC_ChatView(list_table_node)

    vars['clanEnterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end)

    do -- 채팅 EditBox에서 입력 완료 후 바로 전송하기
        local function editBoxTextEventHandle(strEventName,pSender)
            if (strEventName == "return") then
                self:click_enterBtn()
            end
        end
        vars['clanEditBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
        vars['clanEditBox']:setMaxLength(CHAT_MAX_MESSAGE_LENGTH) -- 글자 입력 제한 40자
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ChatPopup_ClanTab:onEnterTab(first)
    local vars = self.vars

    if first then

    end
end

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_ChatPopup_ClanTab:click_enterBtn()
    -- 채팅 비활성화 시
    if (g_chatIgnoreList:isGlobalIgnore()) then
        UIManager:toastNotificationRed(Str('채팅이 비활성화 상태입니다.'))
        return
    end

    local vars = self.vars

    local msg = vars['clanEditBox']:getText()
    msg = utf8_sub(msg, CHAT_MAX_MESSAGE_LENGTH)

    local len = string.len(msg)
    if (len <= 0) then
        UIManager:toastNotificationRed(Str('메시지를 입력하세요.'))
        return
    end

    -- 비속어 필터링
    local function proceed_func()
        if g_chatManager:sendNormalMsg(msg) then
            vars['clanEditBox']:setText('')
        else
            UIManager:toastNotificationRed(Str('메시지 전송에 실패하였습니다.'))
        end
    end
    local function cancel_func()
        vars['clanEditBox']:setText('')
    end
    CheckBlockStr(msg, proceed_func, cancel_func)
end

-------------------------------------
-- function msgQueueCB
-------------------------------------
function UI_ChatPopup_ClanTab:msgQueueCB(chat_content)
    self.m_chatTableView:addChatContent(chat_content)
end