local PARENT = class(IEventListener:getCloneClass(), IEventDispatcher:getCloneTable())

local function log(...)
    cclog(...)
end

local function dump(...)
    ccdump(...)
end

-------------------------------------
-- class LobbyManager_Clan
-- @brief
-------------------------------------
LobbyManager_Clan = class(PARENT, {
        m_chatClientSocket = 'ChatClientSocket',

        m_lobbyChannelName = 'string',
        m_playerUserInfo = 'StructUserInfo',
        m_userInfoList = 'StructUserInfo(List)',

        -- 접속 여부에 따라 달라지는 침대 (위, 아래 20명)
        m_bedResList = 'list',
        m_mapMemberBedRes = 'map',
    })

-------------------------------------
-- function initInstance
-- @brief
-------------------------------------
function LobbyManager_Clan:initInstance()
    if g_clanLobbyManager then
        return
    end

    g_clanLobbyManager = LobbyManager_Clan()
end

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function LobbyManager_Clan:init()
    
end

-------------------------------------
-- function setChatClientSocket
-- @brief
-------------------------------------
function LobbyManager_Clan:setChatClientSocket(chat_client_socket)
    self.m_chatClientSocket = chat_client_socket
end





-----------------------------------------------------------------------------------------------------------------------
-- public functions
-- 아래 코드는 외부에서 호출되는 함수들
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function changeLobbyChannel
-- @brief 채널 변경 요청
-------------------------------------
function LobbyManager_Clan:changeLobbyChannel(channel_name)
    local ccs = self.m_chatClientSocket
    
    local p = ccs.m_protobufChat.CChatChangeChannel()
    p['channelName'] = tostring(channel_name)
    self:write(ccs.m_protocolCode.C_LOBBY_CHANGE_CHANNEL, p)
end

-------------------------------------
-- function requestRecommendLobbyChannel
-- @brief 추천 로비 채널 접속 요청
-------------------------------------
function LobbyManager_Clan:requestRecommendLobbyChannel()
    local ccs = self.m_chatClientSocket
    local p = ccs.m_protobufProtocol.StringMessage()
    p['string'] = ''

    ccs:write(ccs.m_protocolCode.C_LOBBY_RECOMMEND_CHANNEL, p)
end

-------------------------------------
-- function requestLobbyUserList
-- @brief
-------------------------------------
function LobbyManager_Clan:requestLobbyUserList()
end

-------------------------------------
-- function sendNormalMsg
-- @brief 일반 메세지 보내기
-------------------------------------
function LobbyManager_Clan:sendNormalMsg(msg)
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
    p['message'] = msg
    p['nickname'] = ''
    self:write(self:getProtocolCode().C_CHAT_NORMAL_MSG, p)
    return true
end

-------------------------------------
-- function requestCharacterMove
-- @brief 캐릭터 이동
-------------------------------------
function LobbyManager_Clan:requestCharacterMove(x, y)
    -- 서버와 연결이 끊어진 상태
    if (self:getStatus() ~= 'Success') then
        --log('서버와 연결이 끊어진 상태')
        return false
    end

    -- 채널에 접속되지 않음
    if (self.m_lobbyChannelName == nil) then
        --log('채널에 접속되지 않음')
        return false
    end

    -- 플레이어 위치 정보 저장
    self.m_chatClientSocket.m_user['x'] = x
    self.m_chatClientSocket.m_user['y'] = y

    local p = self:getProtobuf('protocol').CharacterMove()
    --p['uid'] = 'string' -- 서버에서 session정보로 추가됨
    p['x'] = x
    p['y'] = y
    self:write(self:getProtocolCode().C_CHARACTER_MOVE, p)
    return true
end


-------------------------------------
-- function clearBedRes
-- @brief 침대 리소스 제어를 위해 리스트로 관리
-------------------------------------
function LobbyManager_Clan:clearBedRes()
    self.m_bedResList = {}
end

-------------------------------------
-- function addBedRes
-- @brief 침대 리소스 제어를 위해 리스트로 관리
-------------------------------------
function LobbyManager_Clan:addBedRes(res)
    table.insert(self.m_bedResList, res)
end

-------------------------------------
-- function applyBedRes
-- @brief 클랜원들에게 침대 리소스 할당
-------------------------------------
function LobbyManager_Clan:applyBedRes()
    self.m_mapMemberBedRes = {}

    local struct_clan = g_clanData.m_structClan
    if (not struct_clan) then
        return
    end

    local map_member = struct_clan.m_memberList
    if (not map_member) then
        return
    end

    local l_member = table.MapToList(map_member)
    table.sort(l_member, function(a, b)
        return a.m_lastActiveTime > b.m_lastActiveTime
    end)

    for i, res in ipairs(self.m_bedResList) do
        for _i, member in ipairs(l_member) do
            local uid = member.m_uid
            if (not self.m_mapMemberBedRes[uid]) then
                self.m_mapMemberBedRes[uid] = res
                break
            end
        end
    end

    self:changeBedRes()
end
    
-------------------------------------
-- function changeBedRes
-- @brief 클랜원 접속을 체크하여 침대 리소스 변경
-------------------------------------
function LobbyManager_Clan:changeBedRes()
    local struct_clan = g_clanData.m_structClan
    if (not struct_clan) then
        return
    end

    local map_member = struct_clan.m_memberList
    if (not map_member) then
        return
    end
    
    local l_connect_user = self.m_userInfoList
    local player_uid = g_userData:get('uid')
    for uid, member in pairs(map_member) do
        local is_connect = false
        -- 채팅서버 접속 체크
        for _uid, user in pairs(l_connect_user) do
            if (uid == _uid) then 
                is_connect = true
            end
        end
        -- 본인은 항상 접속해있음
        if (uid == player_uid) then
            is_connect = true
        end

        local tar_res = self.m_mapMemberBedRes[uid]
        if (not tar_res) then
            break
        end

        -- 접속중이면 빈침대 
        if (is_connect) then 
            tar_res:changeAni('blank', true)

        -- 미접속시 대표 테이머 누워있음
        else 
            local tid = member.m_tamerID
            local tamer_type = TableTamer:getTamerType(tid)
            if (tamer_type) then
                tar_res:changeAni(tamer_type, true)
            end
        end
    end
end








-----------------------------------------------------------------------------------------------------------------------
-- protected functions
-- 아래 코드는 내부에서만 사용하는 함수
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyManager_Clan:onEvent(event_name, t_event, ...)

    if (event_name == 'CHANGE_STATUS') then
        self:onEvent_CHANGE_STATUS(t_event)

    elseif (event_name == 'CHANGE_USER_INFO') then
        self:onEvent_CHANGE_USER_INFO(t_event)

    elseif (event_name == 'RECEIVE_DATA') then
        self:onEvent_RECEIVE_DATA(t_event)

    end
end

-------------------------------------
-- function onEvent_CHANGE_STATUS
-------------------------------------
function LobbyManager_Clan:onEvent_CHANGE_STATUS(t_event)
    local status = t_event
    if (status == 'Success') then
        --self:changeLobbyChannel('클랜이름!!!!!')
    else
        self:reset()
    end
end

-------------------------------------
-- function onEvent_CHANGE_USER_INFO
-- @brief 플레이어 유저 정보 변경
-------------------------------------
function LobbyManager_Clan:onEvent_CHANGE_USER_INFO(t_event)
    local server_user = t_event

    -- Struct가 없으면 새로 생성
    if (not self.m_playerUserInfo) then
        self.m_playerUserInfo = StructUserInfo:createSUser(server_user)
    else
        self.m_playerUserInfo:syncSUser(server_user)
    end

    self:dispatch('LobbyManager_UPDATE_USER', self.m_playerUserInfo)
end

-------------------------------------
-- function onEvent_RECEIVE_DATA
-- @brief 채팅 서버로부터 오는 데이터 처리
-------------------------------------
function LobbyManager_Clan:onEvent_RECEIVE_DATA(t_event)
    local msg = t_event['msg']

    local pcode = msg['pcode']

    -- skip
    if (pcode == 'S_WHISPER_RESPONSE') then

    -- 채널 변경
    elseif (pcode == 'S_LOBBY_CHANGE_CHANNEL') then
        self:receiveData_S_LOBBY_CHANGE_CHANNEL(msg)

    -- 일반 메세지 받음 (내가 보낸 메세지도 받음)
    elseif (pcode == 'S_CHAT_NORMAL_MSG') then
        -- 채팅 활성화 시에만 동작
        if (not g_chatIgnoreList:isGlobalIgnore()) then
            self:receiveData_S_CHAT_NORMAL_MSG(msg)
        end

    -- 캐릭터 이동
    elseif (pcode == 'S_CHARACTER_MOVE') then
        self:receiveData_S_CHARACTER_MOVE(msg)

    -- 다른 유저 입장
    elseif (pcode == 'S_LOBBY_USER_ENTER') then
        self:receiveData_S_LOBBY_USER_ENTER(msg)

    -- 다른 유저 퇴장
    elseif (pcode == 'S_LOBBY_USER_LEAVE') then
        self:receiveData_S_LOBBY_USER_LEAVE(msg)

    -- 다른 유저 정보 변경
    elseif (pcode == 'S_UPDATE_USER_INFO') then
        self:receiveData_S_UPDATE_USER_INFO(msg)

    else
        log('# LobbyManager_Clan:onEvent_RECEIVE_DATA() pcode : ' .. pcode)    
    end
end

-------------------------------------
-- function receiveData_S_LOBBY_CHANGE_CHANNEL
-- @brief 채널 변경 서버 응답
-------------------------------------
function LobbyManager_Clan:receiveData_S_LOBBY_CHANGE_CHANNEL(msg)
    local ccs = self.m_chatClientSocket
    local payload = msg['payload']
    local r = ccs.m_protobufChat.SChatChangeChannel():Parse(payload)

    -- 채널 변경 성공 (입장 성공)
    if (r['ret'] == 'Success') then
        self.m_lobbyChannelName = r['channelName']
        
        local user_list = self:getProtobuf('session').SLobbyUserList():Parse(r['user'])
        self:setUserList(user_list['user'] or {})
    else

    end
end

-------------------------------------
-- function receiveData_S_CHAT_NORMAL_MSG
-- @brief 일반 메세지 받음 (내가 보낸 메세지도 받음)
-------------------------------------
function LobbyManager_Clan:receiveData_S_CHAT_NORMAL_MSG(msg)
    local payload = msg['payload']
    local r = self:getProtobuf('chat').SChatResponse():Parse(payload)

    -- 채팅 내용은 json문자열로 받음
    local raw = r['json']
    if raw and (type(raw) == 'string') then
        local json = dkjson.decode(raw)
        if json then
            --cclogf('from:%s(%s), msg = %s', json['uid'], json['nickname'], json['message'])

            self:dispatch('LobbyManager_CHAT_NORMAL_MSG', json)
        end
    end
end

-------------------------------------
-- function receiveData_S_CHARACTER_MOVE
-- @brief 캐릭터 이동
-------------------------------------
function LobbyManager_Clan:receiveData_S_CHARACTER_MOVE(msg)
    local payload = msg['payload']
    local r = self:getProtobuf('protocol').CharacterMove():Parse(payload)

    local uid = r['uid']
    local x = r['x']
    local y = r['y']

    -- 내 위치는 통신 전에 동기화
    local struct_user_info = self:getAnotherUserInfo(uid)
    if struct_user_info then
        struct_user_info.m_tamerPosX = x
        struct_user_info.m_tamerPosY = y
        
        -- 이벤트
        self:dispatch('LobbyManager_CHARACTER_MOVE', struct_user_info)
    end
end

-------------------------------------
-- function receiveData_S_LOBBY_USER_ENTER
-- @brief 캐릭터 입장
-------------------------------------
function LobbyManager_Clan:receiveData_S_LOBBY_USER_ENTER(msg)
    local payload = msg['payload']
    local server_user = self:getProtobuf('session').SUser():Parse(payload)

    -- 유저 리스트에 추가
    self:addUser(server_user)
end

-------------------------------------
-- function receiveData_S_LOBBY_USER_LEAVE
-- @brief 캐릭터 퇴장
-------------------------------------
function LobbyManager_Clan:receiveData_S_LOBBY_USER_LEAVE(msg)
    local payload = msg['payload']
    local server_user = self:getProtobuf('session').SUser():Parse(payload)
    local uid = server_user['uid']

    -- 유저 리스트에 삭제
    self:removeUser(uid)
end

-------------------------------------
-- function receiveData_S_UPDATE_USER_INFO
-- @brief 다른 유저 정보 변경
-------------------------------------
function LobbyManager_Clan:receiveData_S_UPDATE_USER_INFO(msg)
    local payload = msg['payload']
    local server_user = self:getProtobuf('session').SUser():Parse(payload)
    local uid = server_user['uid']

    -- 유저 갱신
    self:updateUser(uid, server_user)
end

-------------------------------------
-- function getStatus
-- @brief 서버와의 연결 상태
-------------------------------------
function LobbyManager_Clan:getStatus()
    local status = self.m_chatClientSocket:getStatus()
    return status
end

-------------------------------------
-- function getProtobuf
-- @brief
-------------------------------------
function LobbyManager_Clan:getProtobuf(name)
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
function LobbyManager_Clan:getProtocolCode()
    return self.m_chatClientSocket.m_protocolCode
end

-------------------------------------
-- function write
-- @brief
-- @return boolean
-------------------------------------
function LobbyManager_Clan:write(pcode, msg)
    return self.m_chatClientSocket:write(pcode, msg)
end

-------------------------------------
-- function setUserList
-- @brief
-------------------------------------
function LobbyManager_Clan:setUserList(user_list)
    -- 기존 유저 삭제
    if self.m_userInfoList then
        for i,v in pairs(self.m_userInfoList) do
            self:removeUser(v:getUid())
        end
    end

    self.m_userInfoList = {}

    local player_uid = g_userData:get('uid')
    player_uid = tostring(player_uid)

    for i,v in pairs(user_list) do
        local uid = v['uid']
        
        -- 플레이어 유저는 추가하지 않음
        if (player_uid ~= uid) then
            self:addUser(v)
        end
    end
end

-------------------------------------
-- function addUser
-- @brief 유저 추가
-------------------------------------
function LobbyManager_Clan:addUser(server_user)
    local uid = server_user['uid']
    local is_new_user = (self.m_userInfoList[uid] == nil)

    -- 유저 정보 생성
    local struct_user_info = StructUserInfo:createSUser(server_user)
    self.m_userInfoList[uid] = struct_user_info

    -- 새로운 유저
    if is_new_user then
        self:dispatch('LobbyManager_ADD_USER', struct_user_info)
    end
end

-------------------------------------
-- function removeUser
-- @brief 유저 삭제
-------------------------------------
function LobbyManager_Clan:removeUser(uid)
    local struct_user_info = self.m_userInfoList[uid]

    if struct_user_info then
        self.m_userInfoList[uid] = nil
        self:dispatch('LobbyManager_REMOVE_USER', struct_user_info)
    end
end

-------------------------------------
-- function updateUser
-- @brief 유저 삭제
-------------------------------------
function LobbyManager_Clan:updateUser(uid, server_user)
    local struct_user_info = self.m_userInfoList[uid]

    if struct_user_info then
        struct_user_info:syncSUser(server_user)
        self:dispatch('LobbyManager_UPDATE_USER', struct_user_info)
    end
end

-------------------------------------
-- function getAnotherUserInfo
-- @brief
-------------------------------------
function LobbyManager_Clan:getAnotherUserInfo(uid)
    return self.m_userInfoList[uid]
end

-------------------------------------
-- function reset
-------------------------------------
function LobbyManager_Clan:reset()

    -- 기존 유저 삭제
    if self.m_userInfoList then
        for i,v in pairs(self.m_userInfoList) do
            self:removeUser(v:getUid())
        end
    end

    self.m_lobbyChannelName = nil
    self.m_userInfoList = nil

    -- 플레이어 정보는 초기화하지 않음
    --self.m_playerUserInfo = nil
end