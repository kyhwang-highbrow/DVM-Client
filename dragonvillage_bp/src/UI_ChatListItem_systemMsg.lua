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
        local channel = chat_content:getChannelName()
        local start_ch, end_ch = self:getBroadcastChannelRange(channel)
        message = Str('{@C}{1}번 채널{@default}에 입장하였습니다.\n{@C}{2}~{3}번 채널{@default}의 유저와 대화를 나눌 수 있습니다.', channel, start_ch, end_ch)
    end

    -- 메세지
    vars['chatLabel']:setString(message)

    -- 메세지의 높이를 참조
    local width, height = self.root:getNormalSize()
    height = vars['chatLabel']:getStringHeight()
    self.root:setNormalSize(width, height + 20)
end

-------------------------------------
-- function getBroadcastChannelRange
-- @brief 채팅 내용이 공유되는 채널 range를 리턴
-------------------------------------
function UI_ChatListItem_systemMsg:getBroadcastChannelRange(channel_name)
    local channel_num = tonumber(channel_name)
    if (not channel_num) then
        return 1, 10
    end

    -- 채널이 양수 값이어야 함 (10개 채널을 하나의 채팅 그룹으로 처리 1~10, 11~20)
    local start_idx = channel_num
    local end_idx = channel_num

    if (0 < channel_num) then
        if ((channel_num % 10) == 0) then
            start_idx = (channel_num - 9)
            end_idx = channel_num
        else
            start_idx = (channel_num - (channel_num % 10) + 1)
            end_idx = (start_idx + 9);
        end
    end

    start_idx = math_clamp(start_idx, 1, 9999)
    end_idx = math_clamp(end_idx, 1, 9999)

    return start_idx, end_idx
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