local PARENT = IEventListener:getCloneClass()

local llog = function(...)
    print('#[LobbyManager] : ', ...)
end
local ldump = function(...)
    ccdump('#[LobbyManager] : ', ...)
end

-------------------------------------
-- class LobbyManager
-- @brief
-------------------------------------
LobbyManager = class(PARENT, {
        m_chatClientSocket = 'ChatClientSocket',

        m_lobbyChannelName = 'string',
    })

-------------------------------------
-- function initInstance
-- @brief
-------------------------------------
function LobbyManager:initInstance()
    if g_lobbyManager then
        return
    end

    g_lobbyManager = LobbyManager()
end

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function LobbyManager:init()
end

-------------------------------------
-- function setChatClientSocket
-- @brief
-------------------------------------
function LobbyManager:setChatClientSocket(chat_client_socket)
    self.m_chatClientSocket = chat_client_socket
end

-------------------------------------
-- function changeLobbyChannel
-- @brief
-------------------------------------
function LobbyManager:changeLobbyChannel(channel_name)
end

-------------------------------------
-- function requestRecommendLobbyChannel
-- @brief 추천 로비 채널 접속 요청
-------------------------------------
function LobbyManager:requestRecommendLobbyChannel()
    cclog('###### requestRecommendLobbyChannel()')

    local ccs = self.m_chatClientSocket
    local p = ccs.m_protobufProtocol.StringMessage()
    p['string'] = ''

    ccs:write(ccs.m_protocolCode.C_LOBBY_RECOMMEND_CHANNEL, p)
end

-------------------------------------
-- function requestLobbyUserList
-- @brief
-------------------------------------
function LobbyManager:requestLobbyUserList()
end

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyManager:onEvent(event_name, t_event, ...)

    if (event_name == 'CHANGE_STATUS') then
        self:onEvent_CHANGE_STATUS(t_event)

    elseif (event_name == 'RECEIVE_DATA') then
        self:onEvent_RECEIVE_DATA(t_event)

    end
end

-------------------------------------
-- function onEvent_CHANGE_STATUS
-------------------------------------
function LobbyManager:onEvent_CHANGE_STATUS(t_event)
    local status = t_event
    cclog(' ########### ' .. status)
    if (status == 'Success') then
        self:requestRecommendLobbyChannel()
    else
        self:reset()
    end
end

-------------------------------------
-- function onEvent_RECEIVE_DATA
-- @brief 채팅 서버로부터 오는 데이터 처리
-------------------------------------
function LobbyManager:onEvent_RECEIVE_DATA(t_event)
    local msg = t_event['msg']

    local pcode = msg['pcode']

    if (pcode == 'S_LOBBY_CHANGE_CHANNEL') then
        self:receiveData_S_LOBBY_CHANGE_CHANNEL(msg)
        
    end
end

-------------------------------------
-- function receiveData_S_LOBBY_CHANGE_CHANNEL
-- @brief 채널 변경 서버 응답
-------------------------------------
function LobbyManager:receiveData_S_LOBBY_CHANGE_CHANNEL(msg)
    local ccs = self.m_chatClientSocket
    local payload = msg['payload']
    local r = ccs.m_protobufChat.SChatChangeChannel():Parse(payload)

    if (r['ret'] == 'Success') then
        ccdump(r)
    else

    end
end

-------------------------------------
-- function reset
-------------------------------------
function LobbyManager:reset()
    self.m_lobbyChannelName = nil
end