-------------------------------------
-- class ChatManager
-- @brief
-------------------------------------
ChatManager = class({
        m_chatClient = 'ChatClient',
        m_schedulerID = 'number',

        m_tempCB = '',

        m_lMessage = '',
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

    -- 채팅 socket의 상태 변화 콜백 등록
    self.m_chatClient = ChatClient(localeCode, uid, nick)
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

    local msg = {}
    msg['type'] = 'change_status'
    msg['status'] = status

    if self.m_tempCB then
        self.m_tempCB(msg)
    end
end

-------------------------------------
-- function msgQueueCB
-- @brief
-------------------------------------
function ChatManager:msgQueueCB(msg)
    --cclog('# ChatManager:msgQueueCB(msg) ' .. msg['message'])

    table.insert(self.m_lMessage, msg)

    if g_topUserInfo then
        g_topUserInfo:chatBroadcast(msg)
    end

    if self.m_tempCB then
        self.m_tempCB(msg)
    end
end

-------------------------------------
-- function onEnterChannel
-- @brief
-------------------------------------
function ChatManager:onEnterChannel(r)
    local ret = r['ret']
    local channelName = r['channelName']

    local msg = {}
    msg['type'] = 'enter_channel'
    msg['channelName'] = channelName

    if self.m_tempCB then
        self.m_tempCB(msg)
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
  
    self.m_chatClient:requestChangeChannel(t)
end