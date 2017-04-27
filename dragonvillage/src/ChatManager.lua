-------------------------------------
-- class ChatManager
-- @brief
-------------------------------------
ChatManager = class({
        m_chatClient = 'ChatClient',
        m_schedulerID = 'number',

        m_tempCB = '',
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

    local interval = 5
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
end

-------------------------------------
-- function msgQueueCB
-- @brief
-------------------------------------
function ChatManager:msgQueueCB(msg)
    --cclog('# ChatManager:msgQueueCB(msg) ' .. msg['message'])

    if g_topUserInfo then
        g_topUserInfo:chatBroadcast(msg)
    end

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