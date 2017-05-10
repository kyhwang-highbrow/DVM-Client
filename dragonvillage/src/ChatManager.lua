-------------------------------------
-- class ChatManager
-- @brief
-------------------------------------
ChatManager = class({
        m_chatClient = 'ChatClient',
        m_schedulerID = 'number',

        m_tempCB = '',

        m_lMessage = '',

        m_normalChatContentList = '',

        m_chatPopup = '',
    })

-------------------------------------
-- function initInstance
-- @brief
-------------------------------------
function ChatManager:initInstance()
    if g_chatManager then
        return
    end

    g_chatManager = ChatManager()
end

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function ChatManager:init()
    self:initChatClient()
    self.m_lMessage = {}
    self.m_normalChatContentList = {}
    local interval = 60
    self.m_schedulerID = scheduler.scheduleGlobal(function(dt) self:update(dt) end, interval)
end

-------------------------------------
-- function initChatClient
-- @brief
-------------------------------------
function ChatManager:initChatClient()
    local localeCode = 'KR'
    local uid = g_userData:get('uid')
    local nick = g_userData:get('nick')

    -- 드래곤 정보 (일단 did만)
    local leader_dragon = g_dragonsData:getLeaderDragon()
    local did = tostring(leader_dragon['did'])
    if leader_dragon['evolution'] then
        did = did .. ';' .. leader_dragon['evolution']
    end

    -- 채팅 socket의 상태 변화 콜백 등록
    self.m_chatClient = ChatClient(localeCode, uid, nick, did)
    self.m_chatClient:setChangeStatusCB(function(status) self:onChangeStatus(status) end)

    self.m_chatClient.m_changedMsgQueueCb = function(msg) self:msgQueueCB(msg) end
    self.m_chatClient.m_cbOnEnterChannel = function(r) self:onEnterChannel(r) end

    -- 연결을 시도 (성공 시 자동으로 채널 입장)
    local t = {}
    self.m_chatClient:connect(t)
end

-------------------------------------
-- function onChangeStatus
-- @brief
-------------------------------------
function ChatManager:onChangeStatus(status)
    --cclog('# ChatManager:onChangeStatus(status) ' .. status)

    local chat_content = ChatContent()
    chat_content['message'] = status
    chat_content:setContentCategory('change_status')

    if self.m_chatPopup then
        self.m_chatPopup:msgQueueCB(chat_content)
    end
end

-------------------------------------
-- function msgQueueCB
-- @brief
-------------------------------------
function ChatManager:msgQueueCB(msg)
    --cclog('# ChatManager:msgQueueCB(msg) ' .. msg['message'])

    local chat_content = ChatContent(msg)
    chat_content:setContentCategory('general')

    local uid = g_userData:get('uid')
    if (chat_content['uid'] == uid) then
        chat_content:setContentType('my_msg')
    else
        chat_content:setContentType('msg')
    end

    self.m_normalChatContentList[chat_content.m_uuid] = chat_content

    table.insert(self.m_lMessage, chat_content)

    if g_topUserInfo then
        g_topUserInfo:chatBroadcast(msg)
    end

    if self.m_chatPopup then
        self.m_chatPopup:msgQueueCB(chat_content)
    end
end

-------------------------------------
-- function onEnterChannel
-- @brief
-------------------------------------
function ChatManager:onEnterChannel(r)
    local ret = r['ret']
    local channelName = r['channelName']

    local chat_content = ChatContent()
    chat_content:setContentCategory('general')
    chat_content:setContentType('enter_channel')
    chat_content['message'] = channelName

    table.insert(self.m_lMessage, chat_content)

    if self.m_chatPopup then
        self.m_chatPopup:msgQueueCB(chat_content)
    end
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function ChatManager:update(dt)
    local msg = TableDragonPhrase:getRandomPhrase()
    self.m_chatClient:sendNormalMsg(msg)
end

-------------------------------------
-- function sendNormalMsg
-- @brief
-------------------------------------
function ChatManager:sendNormalMsg(msg)
    return self.m_chatClient:sendNormalMsg(msg)
end

-------------------------------------
-- function sendWhisperMsg
-- @brief
-------------------------------------
function ChatManager:sendWhisperMsg(peer_nickname, msg)
    return self.m_chatClient:sendWhisperMsg(peer_nickname, msg)
end

-------------------------------------
-- function getChannelName
-- @brief
-------------------------------------
function ChatManager:getChannelName()
    return self.m_chatClient.m_channelName
end

-------------------------------------
-- function requestChangeChannel
-- @brief
-------------------------------------
function ChatManager:requestChangeChannel(channel_num)
    local t = {}
    t['success'] = function(ret)
        cclog('성공!!')
    end
    t['channelName'] = channel_num
    t['channelType'] = CHAT_CLIENT_CHANNEL_TYPE_NORMAL
  
    return self.m_chatClient:requestChangeChannel(t)
end

-------------------------------------
-- function openChatPopup
-- @brief
-------------------------------------
function ChatManager:openChatPopup()
    if (not self.m_chatPopup) then
        self.m_chatPopup = UI_ChatPopup()
        self.m_chatPopup.root:retain()

        UIManager.m_cbUIOpen = function(ui)
            if (ui ~= self.m_chatPopup) and (not self.m_chatPopup.closed) then

                -- 채팅창을 닫지 않는 팝업 지정
                if (ui.m_uiName ~= 'UI_SimpleEditBoxPopup') then
                    self.m_chatPopup:close()
                end
            end
        end
    end

    local list = UIManager.m_uiList
    if table.find(list, self.m_chatPopup) then
        self.m_chatPopup:close()
    end

    UIManager:open(self.m_chatPopup, UIManager.NORMAL)
    self.m_chatPopup.closed = false

    -- @UI_ACTION
    self.m_chatPopup:doActionReset()
    self.m_chatPopup:doAction()
end

-------------------------------------
-- function closeChatPopup
-- @brief
-------------------------------------
function ChatManager:closeChatPopup()
    if self.m_chatPopup then
        self.m_chatPopup:close()
    end
end