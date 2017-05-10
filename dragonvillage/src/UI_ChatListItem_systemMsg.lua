local PARENT = UI_ChatListItem

-------------------------------------
-- class UI_ChatListItem_systemMsg
-------------------------------------
UI_ChatListItem_systemMsg = class(PARENT, {
        m_chatContent = 'ChatContent',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatListItem_systemMsg:init(chat_content)
    self.m_chatContent = chat_content
    local vars = self:load('chat_item_system.ui')

    local content_type = chat_content:getContentType()
    local message = ''
    if (content_type == 'enter_channel') then
        local channel = chat_content:getMessage()
        message = Str('{1}채널에 입장 하였습니다.', channel)
    end


    -- 메세지
    vars['chatLabel']:setString(message)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChatListItem_systemMsg:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChatListItem_systemMsg:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChatListItem_systemMsg:refresh()
end

-------------------------------------
-- function getCellSize
-------------------------------------
function UI_ChatListItem_systemMsg:getCellSize()
    local width, height = self.root:getNormalSize()
    return cc.size(width, height)
end