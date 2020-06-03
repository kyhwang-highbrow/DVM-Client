local PARENT = class(IEventListener:getCloneClass(), IEventDispatcher:getCloneTable())

local function log(...)
    cclog(...)
end

local function dump(...)
    ccdump(...)
end

-------------------------------------
-- class ChatManagerClan
-- @brief
-------------------------------------
ChatManagerClan = class(PARENT, {
        m_chatClientSocket = 'ChatClientSocket',

        m_lobbyChannelName = 'string',

        m_lMessage = '',

        -- 노티 뱃지
        m_notiGeneral = 'boolean',
    })

-------------------------------------
-- function getInstance
-- @brief
-------------------------------------
function ChatManagerClan:getInstance()
    if (not g_clanChatManager) then
        g_clanChatManager = ChatManagerClan()
    end

    return g_clanChatManager
end

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function ChatManagerClan:init()
    self.m_lMessage = {}
end

-------------------------------------
-- function getChatPopup
-- @brief 채팅 팝업 UI 리턴
-------------------------------------
function ChatManagerClan:getChatPopup()
    return ChatManager:getInstance().m_chatPopup
end


-------------------------------------
-- function checkRetryClanChat
-- @brief 클랜 채팅 다시 연결 확인
-------------------------------------
function ChatManagerClan:checkRetryClanChat()
    if self.m_chatClientSocket then
        self.m_chatClientSocket:checkRetryConnect()
    end
end

-------------------------------------
-- function checkClanChannel
-- @brief 채널 변경 확인
-------------------------------------
function ChatManagerClan:checkClanChannel()
    if (self:getStatus() ~= 'Success') then
        return
    end

    local struct_clan = g_clanData.m_structClan

    -- 채널에 접속되어 있는 경우
    if self.m_lobbyChannelName then
        if (not struct_clan) then
            self.m_lobbyChannelName = nil
            self.m_chatClientSocket:disconnect()
            self.m_chatClientSocket:checkRetryConnect()

        elseif (self.m_lobbyChannelName ~= struct_clan:getClanName()) then
            local clan_name = struct_clan:getClanName()
            self:requestChangeChannel(clan_name)
        end
    else
        if struct_clan then
            local clan_name = struct_clan:getClanName()
            self:requestChangeChannel(clan_name)
        end
    end
end

















-----------------------------------------------------------------------------------------------------------------------
-- public functions
-- 아래 코드는 외부에서 호출되는 함수들
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function setChatClientSocket
-- @brief
-------------------------------------
function ChatManagerClan:setChatClientSocket(chat_client_socket)
    self.m_chatClientSocket = chat_client_socket
end

-------------------------------------
-- function getChannelName
-- @brief
-------------------------------------
function ChatManagerClan:getChannelName()
    return self.m_lobbyChannelName or ''
end

-------------------------------------
-- function sendNormalMsg
-- @brief 일반 메세지 보내기
-------------------------------------
function ChatManagerClan:sendNormalMsg(msg)
    -- 소속된 클랜이 없음
    if (not g_clanData.m_structClan) then
        UIManager:toastNotificationRed(Str('클랜 가입 후 이용이 가능합니다.'))
        return false
    end

    -- 서버와 연결이 끊어진 상태
    if (self:getStatus() ~= 'Success') then
        log('서버와 연결이 끊어진 상태')
        return false
    end

    -- 채널에 접속되지 않음
    if (self.m_lobbyChannelName == nil) then
        log('채널에 접속되지 않음')
        return false
    end

    
    local p = self:getProtobuf('chat').CChatNormalMsg()
    p['message'] = utf8_sub(msg, CHAT_MAX_MESSAGE_LENGTH) -- 글자 수 제한
    p['nickname'] = ''
    return self:write(self:getProtocolCode().C_CHAT_NORMAL_MSG, p)
end

-------------------------------------
-- function requestChangeChannel
-- @brief
-------------------------------------
function ChatManagerClan:requestChangeChannel(clan_name)
    -- 서버와 연결이 끊어진 상태
    if (self:getStatus() ~= 'Success') then
        log('서버와 연결이 끊어진 상태')
        return false
    end
    
    local p = self:getProtobuf('chat').CChatChangeChannel()
    p['channelName'] = clan_name
    return self:write(self:getProtocolCode().C_LOBBY_CHANGE_CHANNEL, p)
end





















-----------------------------------------------------------------------------------------------------------------------
-- protected functions
-- 아래 코드는 내부에서만 사용하는 함수
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function onEvent
-------------------------------------
function ChatManagerClan:onEvent(event_name, t_event, ...)

    --cclog('## ChatManagerClan : ' .. event_name)

    if (event_name == 'CHANGE_STATUS') then
        self:onEvent_CHANGE_STATUS(t_event)

    elseif (event_name == 'RECEIVE_DATA') then
        self:onEvent_RECEIVE_DATA(t_event)

    elseif (event_name == 'CHANGE_USER_INFO') then
     -- ChatManagerClan에선 아무일을 하지 않음

    end
end

-------------------------------------
-- function onEvent_CHANGE_STATUS
-------------------------------------
function ChatManagerClan:onEvent_CHANGE_STATUS(t_event)
    local status = t_event
    if (status == 'Success') then
        self:checkClanChannel()
    end
end

-------------------------------------
-- function onEvent_RECEIVE_DATA
-- @brief 채팅 서버로부터 오는 데이터 처리
-------------------------------------
function ChatManagerClan:onEvent_RECEIVE_DATA(t_event)
    local msg = t_event['msg']

    local pcode = msg['pcode']

    -- skip
    if (pcode == 'S_LOBBY_USER_ENTER') then
    elseif (pcode == 'S_LOBBY_USER_LEAVE') then
    elseif (pcode == 'S_CHARACTER_MOVE') then
    elseif (pcode == 'S_UPDATE_USER_INFO') then

    -- 채널 변경
    elseif (pcode == 'S_LOBBY_CHANGE_CHANNEL') then
        self:receiveData_S_LOBBY_CHANGE_CHANNEL(msg)

    -- 일반 메세지 받음 (내가 보낸 메세지도 받음)
    elseif (pcode == 'S_CHAT_NORMAL_MSG') then
        -- 채팅 활성화 시에만 동작
        if (not g_chatIgnoreList:isGlobalIgnore()) then
            self:receiveData_S_CHAT_NORMAL_MSG(msg)
        end

    -- 귓속말 메세지 받음 (내가 보낸 메세지도 받음)
    elseif (pcode == 'S_WHISPER_RESPONSE') then
        -- 채팅 활성화 시에만 동작
        if (not g_chatIgnoreList:isGlobalIgnore()) then
            self:receiveData_S_WHISPER_RESPONSE(msg)
        end

    else
        log('# ChatManagerClan:onEvent_RECEIVE_DATA() pcode : ' .. pcode)    
    end
end

-------------------------------------
-- function receiveData_S_LOBBY_CHANGE_CHANNEL
-- @brief 채널 변경 서버 응답
-------------------------------------
function ChatManagerClan:receiveData_S_LOBBY_CHANGE_CHANNEL(msg)
    local ccs = self.m_chatClientSocket
    local payload = msg['payload']
    local r = ccs.m_protobufChat.SChatChangeChannel():Parse(payload)

    -- 채널 변경 성공 (입장 성공)
    local ret = r['ret']
    if (ret == 'Success') then
        self.m_lobbyChannelName = r['channelName']
        
        -- 채팅 팝업에 정보 갱신
        if (self:getChatPopup()) then
            self:getChatPopup():refresh_clanName(self.m_lobbyChannelName)
        end

        -- 채널 변경 컨텐츠 생성
        local chat_content = ChatContent()
        chat_content:setContentCategory('clan')
        chat_content:setContentType('enter_channel')
        chat_content:setChannelName(r['channelName'])
        self:chatContentQueue(chat_content)
        

    -- 채널이 가득 참
    elseif (ret == 'NoVacancy') then
        local msg = Str('[{1}]번 채널에 인원이 가득 차 더 이상 입장할 수 없습니다.', r['channelName'])
        UIManager:toastNotificationRed(msg)
        
    -- 채널이 존재하지 않음
    elseif (ret == 'NotExist') then
        local msg = Str('[{1}]번 채널에 입장할 수 없습니다.')
        UIManager:toastNotificationRed(msg)
    end
end

-------------------------------------
-- function receiveData_S_CHAT_NORMAL_MSG
-- @brief 일반 메세지 받음 (내가 보낸 메세지도 받음)
-------------------------------------
function ChatManagerClan:receiveData_S_CHAT_NORMAL_MSG(msg)
    local payload = msg['payload']
    local r = self:getProtobuf('chat').SChatResponse():Parse(payload)

    -- 채팅 내용은 json문자열로 받음
    local raw = r['json']
    if (not raw) or (type(raw) ~= 'string') then
        return
    end

    local json = dkjson.decode(raw)
    if (not json) then
        return
    end

    local chat_content = ChatContent(json)
    chat_content:setContentCategory('clan')

    local uid = g_userData:get('uid')
    if (chat_content['uid'] == tostring(uid)) then
        chat_content:setContentType('my_msg')
    else
        chat_content:setContentType('msg')
    end

    self:chatContentQueue(chat_content)       
end

-------------------------------------
-- function receiveData_S_WHISPER_RESPONSE
-- @brief 귓속말 메세지 받음 (내가 보낸 메세지도 받음)
-------------------------------------
function ChatManagerClan:receiveData_S_WHISPER_RESPONSE(msg)
    local payload = msg['payload']
    local r = self:getProtobuf('chat').SChatResponse():Parse(payload)

    -- 채팅 내용은 json문자열로 받음
    local raw = r['json']
    if (not raw) or (type(raw) ~= 'string') then
        return
    end

    local json = dkjson.decode(raw)
    if (not json) then
        return
    end

    -- 귓속말 전송 or 수신 성공
    if (json['status'] == 0) then
        local chat_content = ChatContent(json)
        chat_content:setContentCategory('whisper')

        local uid = g_userData:get('uid')
        if (chat_content['uid'] == tostring(uid)) then
            chat_content:setContentType('my_msg')
        else
            chat_content:setContentType('msg')
        end

        self:chatContentQueue(chat_content)

    -- 귓속말 전송 실패
    else
        local msg = Str('[{1}]유저를 찾을 수 없습니다.', json['to'])
        UIManager:toastNotificationRed(msg)
    end
end

-------------------------------------
-- function getStatus
-- @brief 서버와의 연결 상태
-------------------------------------
function ChatManagerClan:getStatus()
    if self.m_chatClientSocket then
        local status = self.m_chatClientSocket:getStatus()
        return status
    end

    return 'Disconnected'
end

-------------------------------------
-- function getProtobuf
-- @brief
-------------------------------------
function ChatManagerClan:getProtobuf(name)
    if (name == 'session') then
        return self.m_chatClientSocket.m_protobufSession

    elseif (name == 'protocol') then
        return self.m_chatClientSocket.m_protobufProtocol

    elseif (name == 'chat') then
        return self.m_chatClientSocket.m_protobufChat

    else
        error('name : ' .. name)
    end
end

-------------------------------------
-- function getProtocolCode
-- @brief
-------------------------------------
function ChatManagerClan:getProtocolCode()
    return self.m_chatClientSocket.m_protocolCode
end

-------------------------------------
-- function write
-- @brief
-- @return boolean
-------------------------------------
function ChatManagerClan:write(pcode, msg)
    return self.m_chatClientSocket:write(pcode, msg)
end

ChatManager:getInstance()









----------------------------------------------------------------------------------
-- 채팅 UI 관련 코드


-------------------------------------
-- function chatContentQueue
-- @brief
-------------------------------------
function ChatManagerClan:chatContentQueue(chat_content)
    -- 차단 처리
    if (chat_content['uid'] and g_chatIgnoreList:isIgnore(chat_content['uid'])) then
        return
    end

    self:setNoti(chat_content)

    table.insert(self.m_lMessage, chat_content)

    -- 100개가 넘어가면 삭제
    while (100 < #self.m_lMessage) do
        table.remove(self.m_lMessage, 1)
    end

    --[[
    local is_broadcast = false
    -- 인게임에서도 추가 (먼저 검사, 한쪽만 방송해줘야함)
    if (g_currScene) then
        if (isExistValue(g_currScene.m_sceneName, 'SceneGame', 'SceneGameColosseum', 'SceneGameArena')) then
            if (g_currScene.m_inGameUI) then
                is_broadcast = true
                g_currScene.m_inGameUI:chatBroadcast(chat_content)
            end
        end 
    end

    if (g_topUserInfo) and (not is_broadcast) then
        g_topUserInfo:chatBroadcast(chat_content)
    end
    --]]
    if self:getChatPopup() then
        self:getChatPopup():msgQueueCB_clan(chat_content)
    end
end


-----------------------------------------------------------------------------------------------------------
-- 노티 관련 UI start
-----------------------------------------------------------------------------------------------------------

-------------------------------------
-- function setNoti
-- @brief
-------------------------------------
function ChatManagerClan:setNoti(chat_content)
    -- 채팅 비활성화 시 동작하지 않음
    if (g_chatIgnoreList:isGlobalIgnore()) then
        return
    end

    if (not self:getChatPopup()) or (not self:getChatPopup():isVisibleCategory('clan')) then
        self.m_notiGeneral = true
        self:onChangeNotiInfo()
    end
    
end

-------------------------------------
-- function removeNoti
-- @brief
-------------------------------------
function ChatManagerClan:removeNoti()
    self.m_notiGeneral = false
    self:onChangeNotiInfo()
end

-------------------------------------
-- function onChangeNotiInfo
-- @brief
-------------------------------------
function ChatManagerClan:onChangeNotiInfo()
    if g_topUserInfo then
        g_topUserInfo:refreshChatNotiInfo()
    end

    if self:getChatPopup() then
        self:getChatPopup().vars['clanNotiSprite']:setVisible(self.m_notiGeneral)
    end
end

-----------------------------------------------------------------------------------------------------------
-- 노티 관련 UI end
-----------------------------------------------------------------------------------------------------------