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

    self.m_socket = SocketTCP(ip, port, true)

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
-- @brief
-------------------------------------
function ChatClientSocket:setStatus(status)
    self.m_status = status

    self:dispatch('CHANGE_STATUS', status)
end

-------------------------------------
-- function addRegularListener
-- @brief
-------------------------------------
function ChatClientSocket:addRegularListener(listener)
    self:addListener('CHANGE_STATUS', listener)     -- 서버와의 연결 상태 변경
    self:addListener('RECEIVE_DATA', listener)      -- 서버로부터 데이터를 받음

    -- 즉시 데이터가 필요한 부분
    listener:onEvent('CHANGE_STATUS', self.m_status)
end

-------------------------------------
-- function setUserInfo
-- @brief
-------------------------------------
function ChatClientSocket:setUserInfo(t_data)
    self.m_user['uid'] = t_data['uid'] or self.m_user['uid'] or ''
    self.m_user['nickname'] = t_data['nickname'] or self.m_user['nickname'] or ''
    self.m_user['did'] = t_data['did'] or self.m_user['did'] or ''
    self.m_user['level'] = t_data['level'] or self.m_user['level'] or 1
end

-------------------------------------
-- function requestLogin
-- @brief
-------------------------------------
function ChatClientSocket:requestLogin()
    local p = self.m_user

    cclog("######################################")
    if (self:write(self.m_protocolCode.C_LOGIN_REQ, p) == false) then
        -- 소켓 라이팅 실패, 로그인 실패로 처리
        self:disconnect()
        --self.m_cbConnectFail({ret = 'Socket Writing Fail'})
        return -1
    end

    return 0
end

-------------------------------------
-- function write
-- @brief
-------------------------------------
function ChatClientSocket:write(pcode, msg)
    local p = self.m_protobufProtocol.ClientMessage()
    local errMsg

    p['pcode'] = pcode
    p['payload'], errMsg = msg:Serialize()
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