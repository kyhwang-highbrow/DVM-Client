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
-- function onEnterTab
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
	local tab = 'clan'
	local edit_box = self.vars['clanEditBox']
    local msg = edit_box:getText()
    UI_ChatPopup.sendMsg(msg, tab, edit_box)
end

-------------------------------------
-- function msgQueueCB
-------------------------------------
function UI_ChatPopup_ClanTab:msgQueueCB(chat_content)
    self.m_chatTableView:addChatContent(chat_content)
end