local PARENT = IEventDispatcher:getCloneClass()

require 'lib/scheduler'
require 'lib/SocketTCP'
require 'lib/pb'

cclogf = function(...)
	print(string.format(...))
end

-------------------------------------
-- class ChatClientSocket
-- @brief 채팅 클라이언트
-------------------------------------
ChatClientSocket = class(PARENT, {
    -- 소켓
    m_socket = '',

    -- 연결 상태
    m_status = 'Closed',
        -- 'Success'
        -- 'Connecting'
        -- 'Closed'
        -- 'Disconnected'

    --m_sendCounter = '',
    --m_recvCounter = '',
    -- m_encKey = '', -- 보안 키 (현재 사용하지 않음)

    -- 프로토버프
    m_protobufProtocol = 'protobuf',
    m_protobufSession = 'protobuf',
    m_protobufChat = 'protobuf',

    m_protocolCode = '',

    m_user = 'SUser(protobuff)',
})

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function ChatClientSocket:init(ip, port)
    self.m_status = 'Closed'

    do -- 테이블 밖에 있던 변수들
        self.m_protobufProtocol = protobuf.require('protocol.proto')
        self.m_protobufSession = protobuf.require('session.proto')
        self.m_protobufChat = protobuf.require('chat.proto')
        self.m_protocolCode = self.m_protobufProtocol.ProtocolCode
        --ccdump(self.m_protocolCode)
    end

    local ip = (ip or 'dv-test.perplelab.com')
    local port = (port or '9013')
    local retry_connect = false
    
    self.m_socket = SocketTCP(ip, port, retry_connect)

    local function dispatchEvent(socket, t)
        return self:dispatchEvent(socket, t)
    end
    self.m_socket.dispatchEvent = dispatchEvent

    self.m_socket:connect()

    -- 유저 정보
    self.m_user = self.m_protobufSession.SUser()
end

-------------------------------------
-- function dispatchEvent
-- @brief
-------------------------------------
function ChatClientSocket:dispatchEvent(_socket, t)

    local name = t['name']
    --cclogf("dispatch event : name=%s", name)
    --ccdump(t)
    if (name == SocketTCP.EVENT_CONNECTED) then
        self:setStatus('Connecting')
        --ccdump(t)
        --session 접속을 요청
        --return self:requestLogin()
        return self:requestLogin()

    elseif (name == SocketTCP.EVENT_CONNECT_FAILURE) then
        self:setStatus('Connecting')
        return 0

    elseif (name == SocketTCP.EVENT_RECONNECT_FAILURE) then
        self:setStatus('Connecting')
        return 0

    elseif (name == SocketTCP.EVENT_CLOSE) then
        self:setStatus('Closed')
        return 0

    elseif (name == SocketTCP.EVENT_CLOSED) then
        UIManager:toastNotificationRed(Str('채팅 서버와 연결이 끊어졌습니다.'))
        self:setStatus('Disconnected')
        return 0

    elseif (name == SocketTCP.EVENT_DATA) then
        
        local msg = self.m_protobufProtocol.ServerMessage():Parse(t['data'])
        --cclogf('got pcode=%s', msg['pcode'])

        -- 로그인 체크 프로토콜인지 체크
        if (msg['pcode'] == 'S_LOGIN_RES') then
            local r = self.m_protobufSession.SLoginRes():Parse(msg['payload'])
            if (r['ret'] == 'Success') then
                self:setStatus('Success')
                return 0
            else

                cclog('1 여기ㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣ')
                self:disconnect()
                return -1
            end
        end

        local t_event = {}
        t_event['is_handled'] = false
        t_event['msg'] = msg
        t_event['return'] = 0

        self:dispatch('RECEIVE_DATA', t_event)

        if (t_event['is_handled']) then
            return t_event['return']
        end

        return 0

	end

    return 0;
end

-------------------------------------
-- function setStatus
-- @brief 서버와의 연결 상태
-------------------------------------
function ChatClientSocket:setStatus(status)
    self.m_status = status

    self:dispatch('CHANGE_STATUS', status)
end

-------------------------------------
-- function getStatus
-- @brief
-------------------------------------
function ChatClientSocket:getStatus()
    return self.m_status
end

-------------------------------------
-- function addRegularListener
-- @brief
-------------------------------------
function ChatClientSocket:addRegularListener(listener)
    self:addListener('CHANGE_STATUS', listener)     -- 서버와의 연결 상태 변경
    self:addListener('RECEIVE_DATA', listener)      -- 서버로부터 데이터를 받음
    self:addListener('CHANGE_USER_INFO', listener)  -- 플레이어 유저 정보 변경

    -- 즉시 데이터가 필요한 부분
    listener:onEvent('CHANGE_STATUS', self.m_status)
    listener:onEvent('CHANGE_USER_INFO', self.m_user)
end

-------------------------------------
-- function setUserInfo
-- @brief
-------------------------------------
function ChatClientSocket:setUserInfo(t_data)
    self.m_user['uid'] = t_data['uid'] or self.m_user['uid'] or ''
    self.m_user['tamer'] = t_data['tamer'] or self.m_user['tamer'] or ''
    self.m_user['nickname'] = t_data['nickname'] or self.m_user['nickname'] or ''
    self.m_user['did'] = t_data['did'] or self.m_user['did'] or ''
    self.m_user['level'] = t_data['level'] or self.m_user['level'] or 1

    -- 테이머 위치
    self.m_user['x'] = t_data['x'] or self.m_user['x'] or 0
    self.m_user['y'] = t_data['y'] or self.m_user['y'] or 0
    self.m_user['tamerTitleID'] = t_data['tamerTitleID'] or self.m_user['tamerTitleID'] or 0

    -- json 스트링 처리
    if t_data['json'] then
        local json_str = self.m_user['json'] or '{}'
        local t_json = dkjson.decode(json_str)
        if (not t_json) then
            t_json = {}
        end
        
        -- 변경된 key 적용
        for i,v in pairs(t_data['json']) do
            t_json[i] = clone(v)
        end

        -- 사라진 key 삭제
        for i,v in pairs(t_json) do
            if (not t_data['json'][i]) then
                t_json[i] = nil
            end
        end

        self.m_user['json'] = dkjson.encode(t_json, {indent=false})
    end

    self:dispatch('CHANGE_USER_INFO', self.m_user)
end

-------------------------------------
-- function changeUserInfo
-- @brief
-------------------------------------
function ChatClientSocket:changeUserInfo(t_data)
    local need_sync = false

    for _,key in ipairs({'tamer', 'nickname', 'did', 'level', 'tamerTitleID'}) do
        if self:_checkNeedSync(t_data, key) then
            need_sync = true
            break
        end
    end

    do -- 클랜 정보 변경 여부
        local new_clan_name = nil
        if (t_data['json'] and t_data['json']['clan']) then
            new_clan_name = t_data['json']['clan']['name']
        end

        -- 기존에 가지고 있던 클랜명 정보
        local old_clan_name = nil
        local json_str = self.m_user['json'] or '{}'
        local t_old_json = dkjson.decode(json_str)
        if (t_old_json and t_old_json['clan']) then
            old_clan_name = t_old_json['clan']['name']
        end

        if (new_clan_name ~= old_clan_name) then
            need_sync = true
        end
    end

    self:setUserInfo(t_data)

    if need_sync then
        self:requestUpdateUserInfo()
    end
end

-------------------------------------
-- function _checkNeedSync
-- @brief 유저 정보가 변경되었을 때 서버와 동기화를 해야하는지 여부 체크
-------------------------------------
function ChatClientSocket:_checkNeedSync(t_data, key)
    if t_data[key] and (self.m_user[key] ~= t_data[key]) then
        return true
    end

    return false
end

-------------------------------------
-- function requestLogin
-- @brief
-------------------------------------
function ChatClientSocket:requestLogin()
    local p = self.m_user

    if (self:write(self.m_protocolCode.C_LOGIN_REQ, p) == false) then
        -- 소켓 라이팅 실패, 로그인 실패로 처리

        cclog('2 여기ㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣ')

        self:disconnect()
        --self.m_cbConnectFail({ret = 'Socket Writing Fail'})
        return -1
    end

    return 0
end

-------------------------------------
-- function requestUpdateUserInfo
-- @brief
-------------------------------------
function ChatClientSocket:requestUpdateUserInfo()
    if (self.m_status ~= 'Success') then
        return
    end

    local p = self.m_user
    self:write(self.m_protocolCode.C_UPDATE_USER_INFO, p)
end

-------------------------------------
-- function write
-- @brief
-------------------------------------
function ChatClientSocket:write(pcode, msg)
    local p = self.m_protobufProtocol.ClientMessage()
    local errMsg

    p['pcode'] = pcode
    p['payload'], errMsg = msg and msg:Serialize() or 'error on writing'
    p['packetId'] = 0
    p['recvCounter'] = 0
    if errMsg then
        cclogf(errMsg)
        return false
    end

    local pkt
    if (pcode ~= self.m_protobufProtocol.C_LOGIN_REQ) then
        --local sc = self.m_sendCounter + 1
		--p['packetId'] = sc
		--p['recvCounter'] = self.m_recvCounter
		pkt, errMsg = p:Serialize()

		----self.successCallbackMap[sc] = successCallback
		----self.failCallbackMap[sc] = failCallback
		----self.sentPacketMap[sc] = pkt

		--self.m_sendCounter = sc
        ----if (self.m_status ~= 'Success') then
		----	return
		----end
    else
        --p['packetId'] = 0
		pkt, errMsg = p:Serialize()
    end
    
    if errMsg then
        cclogf(errMsg)
        return false
    end

    self:send(pkt)--, p['packetId'])
    return true
end

-------------------------------------
-- function send
-- @brief
-------------------------------------
function ChatClientSocket:send(p, packetId)
    local sent, err
	--if self.m_encKey then
	--	local key, encrypted = PacketEncrypt(self.m_encKey, p)
	--	self.m_encKey = key
	--	sent, err = self.m_socket:send(struct.pack('>i4', #p + 1) .. struct.pack('>I1', key) .. encrypted)
	--else
		sent, err = self.m_socket:send(struct.pack('>i4', #p) .. p)
	--end

	if err then
		cclogf(tostring(sent) .. ' ' .. err)
	else
		--if packetId > 0 then
		--	self.sentTimeStamp[packetId] = PatiFriends.GetTimeOfDay()
		--end
	end
end

-------------------------------------
-- function disconnect
-- @brief
-------------------------------------
function ChatClientSocket:disconnect()
    self.m_socket:disconnect()
    self:setStatus('Disconnected')
end

-------------------------------------
-- function close
-- @brief
-------------------------------------
function ChatClientSocket:close()
    self.m_socket:close()
end

-------------------------------------
-- function checkRetryConnect
-- @brief
-------------------------------------
function ChatClientSocket:checkRetryConnect()
    if (self.m_socket.isConnected == false) then
        self.m_socket:connect()
    end
end





-------------------------------------
-- function globalUpdatePlayerUserInfo
-- @brief 로비에서 표현되는 유저의 정보가 변경되었을 경우 채팅서버에 알리기 위함
-------------------------------------
function ChatClientSocket:globalUpdatePlayerUserInfo()
    local tamer_id = g_userData:get('tamer')
    local nickname = g_userData:get('nick')
    local lv = g_userData:get('lv')
    local tamer_title_id = g_userData:getTitleID()

    -- 리더 드래곤
    local leader_dragon = g_dragonsData:getLeaderDragon()
    local did = leader_dragon and tostring(leader_dragon['did']) or ''
    if (did ~= '') then
        did = did .. ';' .. leader_dragon['evolution']
        did = did .. ';' .. (leader_dragon['dragon_skin'] or 0)
        -- 외형 변환 존재하는 경우에 추가 
        local transform = leader_dragon['transform']
        if (transform) then
            did = did .. ';' .. transform
        end
    end

    local t_data = {}
    t_data['tamer'] = tostring(tamer_id)
    t_data['nickname'] = nickname
    t_data['did'] = did
    t_data['level'] = lv
    t_data['tamerTitleID'] = tamer_title_id

    do -- 테이머 코스츔 적용
        local struct_tamer_costume = g_tamerCostumeData:getCostumeDataWithTamerID(tamer_id)
        if (struct_tamer_costume:isDefaultCostume() == false) then
            local costume_id = struct_tamer_costume:getCid()
            t_data['tamer'] = t_data['tamer'] .. ';' .. tostring(costume_id)
        end
    end

    t_data['json'] = {}
    do -- 클랜 정보
        local clan_struct = g_clanData:getClanStruct()
        if clan_struct then
            local t_clan = {}
            t_clan['name'] = clan_struct['name']
            t_clan['mark'] = clan_struct['mark']
            t_clan['id'] = clan_struct['id']
            t_data['json']['clan'] = t_clan
        end
    end

    self:changeUserInfo(t_data)
end