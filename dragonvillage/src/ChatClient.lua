require 'lib/scheduler'
require 'lib/SocketTCP'
require 'lib/pb'

local NormalChatChannelRange = { min = 1, max = 999, unit = 1000 }

CHAT_CLIENT_CHANNEL_TYPE_NORMAL = 0 -- 일반 채널
CHAT_CLIENT_CHANNEL_TYPE_GUILD = 1  -- 길드 채널(채널 offset을 적용하지 않음)

cclogf = function(...)
	--print(string.format(...))
end

-------------------------------------
-- class ChatClient
-- @brief 채팅 클라이언트
-------------------------------------
ChatClient = class({
    -- 새로 추가된 변수들
    m_socket = '',
    m_uid = '',
    m_nickname = '',
    m_dragonInfo = '',

    -- ChatChannel에 있던 변수들
    m_status = '',
        -- 'Success'
        -- 'Connecting'
        -- 'Closed'
        -- 'Disconnected'
    m_sendCounter = '',
    m_recvCounter = '',
    m_encKey = '',
    m_msgQueue = '',
    m_cbConnectSuccess = '',
    m_cbConnectFail = '',
    m_cbChangeChannelSuccess = '',
    m_cbOnEnterChannel = '',
    m_cbChangeChannelFail = '',
    m_cbChangeStatus = 'function',
    m_channelName = '',
    m_channelType = '',
    m_requestedChannelType = '',
    m_channelOffset = '',
    m_changedMsgQueueCb = '', -- 메세지 큐 상태 변경 알림 콜백

    -- 테이블 밖에 있던 변수들
    m_protocol = '',
    m_session = '',
    m_chat = '',
    m_Protocol = '',
})

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function ChatClient:init(localeCode, uid, nickname, did)
    do -- 변수 초기화
        self.m_status = nil
        self.m_sendCounter = nil
        self.m_recvCounter = nil
        self.m_encKey = nil
        self.m_msgQueue = nil
        self.m_cbConnectSuccess = nil
        self.m_cbConnectFail = nil
        self.m_cbChangeChannelSuccess = nil
        self.m_cbOnEnterChannel = function() end
        self.m_cbChangeChannelFail = nil
        self.m_channelName = nil
        self.m_channelType = CHAT_CLIENT_CHANNEL_TYPE_NORMAL
        self.m_requestedChannelType = CHAT_CLIENT_CHANNEL_TYPE_NORMAL
        self.m_channelOffset = 0
        self.m_changedMsgQueueCb = nil -- 메세지 큐 상태 변경 알림 콜백
    end

    do -- 테이블 밖에 있던 변수들
        self.m_protocol = protobuf.require('protocol.proto')
        self.m_session = protobuf.require('session.proto')
        self.m_chat = protobuf.require('chat.proto')
        self.m_Protocol = self.m_protocol.ProtocolCode
        ccdump(self.m_Protocol)
    end

    self.m_channelOffset = self:getChannelOffset(localeCode)

    local ip = '1.234.82.62'
    ip = 'dv-test.perplelab.com'
    local port = '3927'
    port = '9013'
    --self.m_socket = SocketTCP(Network:getChatServerIP(), Network:getChatServerPort(), true)
    self.m_socket = SocketTCP(ip, port, true)
    self.m_socket.dispatchEvent = function(socket, t) return self:dispatchEvent(socket, t) end

    --self.m_uid = uid or UserData.m_user['uid']
    --self.m_nickname = nickname or UserData.m_user['nickname']

    self.m_uid = uid
    self.m_nickname = nickname
    self.m_dragonInfo = did
end

-------------------------------------
-- function getChannelOffset
-- @brief
-------------------------------------
function ChatClient:getChannelOffset(localeCode)
    local offsetNumber = 0

    if localeCode == 'KR' then
        -- 한국어
        offsetNumber = 0
    elseif localeCode == 'JP' then
        -- 일본어
        offsetNumber = 1
    elseif (localeCode == 'TW') or (localeCode == 'HK') or (localeCode == 'MO') then
        -- 중국어(번체)
        offsetNumber = 2
    elseif localeCode == 'CN' then
        -- 중국어(간체)
        offsetNumber = 3
    elseif localeCode == 'TH' then
        -- 태국어
        offsetNumber = 4
    else
        -- 영어
        offsetNumber = 5
    end

    return offsetNumber * NormalChatChannelRange['unit']
end

-------------------------------------
-- function dispatchEvent
-- @brief
-------------------------------------
function ChatClient:dispatchEvent(_socket, t)
    local name = t['name']
    cclogf("dispatch event : name=%s", name)

    if (name == SocketTCP.EVENT_CONNECTED) then
        --session 접속을 요청
        return self:requestLogin()

    elseif (name == SocketTCP.EVENT_CONNECT_FAILURE) then
        self.m_cbConnectFail({ret = 'Connect Failure'})
        return 0

    elseif (name == SocketTCP.EVENT_RECONNECT_FAILURE) then
        self.m_cbConnectFail({ret = 'Reconnect Timeout'})
        return 0

	elseif (name == SocketTCP.EVENT_DATA) then
        local msg = self.m_protocol.ServerMessage():Parse(t['data'])
        cclogf('got pcode=%s', msg['pcode'])
        if (msg['pcode'] == 'S_LOGIN_RES') then
            local r = self.m_session.SLoginRes():Parse(msg['payload'])
            cclogf('login result = %s, channel = %s', r['ret'], r['channelName'])

            -- @chatting for GSP
            r['channelName'] = self:virtualChannelName(r['channelName'])

            if r.ret == 'Success' then
                -- 접속 완료, 채팅 주고받을 준비를 하자
                self:setStatus('Success')
                self.m_sendCounter = r['sentCounter'] or 0
                self.m_channelName = r['channelName']
                self.m_channelType = self.m_requestedChannelType
                self.m_msgQueue = {}
                self.m_cbConnectSuccess(r, self.m_channelType)
                self.m_cbOnEnterChannel(r)
            else
                -- 채팅 서버 로그인 실패, 채팅 창을 닫는다.
                self:disconnect()
                self.m_cbConnectFail(r)
            end
            return 0

        elseif (msg['pcode'] == 'S_CHAT_RESPONSE') then
            local r = self.m_chat.SChatResponse():Parse(msg['payload'])
            --cclog(luadump(r))
            local raw = r['json']
            if raw and type(raw) == 'string' then
                local json = dkjson.decode(raw)
                if json then
                    cclogf('from:%s(%s), msg = %s', json['uid'], json['nickname'], json['message'])
                    json['content_category'] = 'general'
                    self:pushMsg(json)
                end
            end
            return 0

        elseif (msg['pcode'] == 'S_WHISPER_RESPONSE') then
            local r = self.m_chat.SChatResponse():Parse(msg['payload'])
            local raw = r['json']
            if raw and type(raw) == 'string' then
                local json = dkjson.decode(raw)
                if json then
                    --cclogf('from:%s(%s), msg = %s', json['uid'], json['nickname'], json['message'])
                    json['content_category'] = 'whisper'
                    self:pushMsg(json)
                end
            end
            return 0

        elseif (msg['pcode'] == 'S_CHAT_CHANGE_CHANNEL') then
            local r = self.m_chat.SChatChangeChannel():Parse(msg['payload'])
            cclogf('login result = %s, channel = %s', r['ret'], r['channelName'])

            -- @chatting for GSP
            r.channelName = self:virtualChannelName(r['channelName'])

            if r.ret == 'Success' then
                self.m_channelName = r['channelName']
                self.m_channelType = self.m_requestedChannelType
                self.m_cbChangeChannelSuccess(r)
                self.m_cbOnEnterChannel(r)
            else
                -- 채팅 서버 채널 변경 실패
                self.m_cbChangeChannelFail(r)
            end
            return 0

        end
        return 0

    elseif (name == SocketTCP.EVENT_CLOSE) then
        self:setStatus('Closed')
        self.m_channelName = nil
        self.m_channelType = CHAT_CLIENT_CHANNEL_TYPE_NORMAL
        return 0

    elseif (name == SocketTCP.EVENT_CLOSED) then
        self:setStatus('Disconnected')
        self.m_channelName = nil
        self.m_channelType = CHAT_CLIENT_CHANNEL_TYPE_NORMAL
        return 0

	end

    return 0;
end

-------------------------------------
-- function connect
-- @brief
-------------------------------------
function ChatClient:connect(t)
    self.m_cbConnectSuccess = t['success'] or function() end
    self.m_cbConnectFail = t['fail'] or function() end

    if (self.m_status == 'Success') then
        -- 현재 접속 중이므로 현재의 채널 정보를 그대로 보냄
        self.m_cbConnectSuccess({ret = 'Success', channelName = self.m_channelName}, self.m_channelType, true)
    else
        self.m_socket:connect()
        self:setStatus('Connecting')
    end
end

-------------------------------------
-- function disconnect
-- @brief
-------------------------------------
function ChatClient:disconnect()
    self.m_socket:disconnect()

    self.m_channelName = nil
    self.m_channelType = CHAT_CLIENT_CHANNEL_TYPE_NORMAL
    self.m_requestedChannelType = CHAT_CLIENT_CHANNEL_TYPE_NORMAL
    self:setStatus('Disconnected')
end

-------------------------------------
-- function requestLogin
-- @brief
-------------------------------------
function ChatClient:requestLogin()
    local p = self.m_session.CLoginReq()

    p['uid'] = self.m_uid
	p['nickname'] = self.m_nickname
    p['did'] = self.m_dragonInfo

    p['sessionKey'] = ''
    --p.recvCounter = nil

    -- @chatting for GSP
    p['offset'] = self.m_channelOffset

    cclogf('chatclient: request login uid = %s, nickname = %s, offset = %d', p['uid'], p['nickname'], p['offset'])

    if (self:write(self.m_Protocol.C_LOGIN_REQ, p) == false) then
        -- 소켓 라이팅 실패, 로그인 실패로 처리
        self:disconnect()
        self.m_cbConnectFail({ret = 'Socket Writing Fail'})
        return -1
    end

    return 0
end

-------------------------------------
-- function sendNormalMsg
-- @brief
-------------------------------------
function ChatClient:sendNormalMsg(msg)
    if (self.m_status ~= 'Success') then
        return false
    end

    local p = self.m_chat.CChatNormalMsg()
    p['message'] = msg
    self:write(self.m_Protocol.C_CHAT_NORMAL_MSG, p)
    return true
end

-------------------------------------
-- function sendWhisperMsg
-- @brief
-------------------------------------
function ChatClient:sendWhisperMsg(peer_nickname, msg)
    if (self.m_status ~= 'Success') then
        return false
    end

    local p = self.m_chat.CChatWhisperMsg()
    p['message'] = msg
    p['nickname'] = peer_nickname
    self:write(self.m_Protocol.C_CHAT_WHISPER_MSG, p)
    return true
end

-------------------------------------
-- function requestChangeChannel
-- @brief
-------------------------------------
function ChatClient:requestChangeChannel(t)
    if (self.m_status ~= 'Success') then
        return
    end

    local success = t['success'] or function() end
    local fail = t['fail'] or function() end

    -- 현재 채널과 같은 채널에는 재입장 요청하면 안된다.
    if (self.m_channelName == t['channelName']) and (self.m_channelType == t['channelType']) then
        return
    end

    if (t['channelType'] == CHAT_CLIENT_CHANNEL_TYPE_NORMAL) then
        local channelNumber = tonumber(t['channelName'])

        if (not channelNumber) then
            fail({ ret = 'NotExist' })
            return
        end

        if (channelNumber < NormalChatChannelRange['min']) or (channelNumber > NormalChatChannelRange['max']) then
            fail({ ret = 'NotExist' })
            return
        end
    end

    self.m_requestedChannelType = t['channelType']
    self.m_cbChangeChannelSuccess = success
    self.m_cbChangeChannelFail = fail

    local p = self.m_chat.CChatChangeChannel()
    p['channelName'] = self:realChannelName(t['channelName'])
	p['channelType'] = t['channelType']

    -- @chatting for GSP
    p['offset'] = self.m_channelOffset

    self:write(self.m_Protocol.C_CHAT_CHANGE_CHANNEL, p)
end

-------------------------------------
-- function write
-- @brief
-------------------------------------
function ChatClient:write(pcode, msg)
    local p = self.m_protocol.ClientMessage()
    local errMsg

    p['pcode'] = pcode
    p['payload'], errMsg = msg:Serialize()

    if errMsg then
        cclogf(errMsg)
        return false
    end

    local pkt
    if pcode ~= self.m_Protocol.C_LOGIN_REQ then
        local sc = self.m_sendCounter + 1
		p['packetId'] = sc
		p['recvCounter'] = self.m_recvCounter
		pkt = p:Serialize()

		--self.successCallbackMap[sc] = successCallback
		--self.failCallbackMap[sc] = failCallback
		--self.sentPacketMap[sc] = pkt

		self.m_sendCounter = sc
        --if (self.m_status ~= 'Success') then
		--	return
		--end
    else
        p['packetId'] = 0
		pkt = p:Serialize()
    end

    self:send(pkt, p['packetId'])
    return true
end

-------------------------------------
-- function send
-- @brief
-------------------------------------
function ChatClient:send(p, packetId)
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
-- function virtualChannelName
-- @brief
-------------------------------------
function ChatClient:virtualChannelName(channelName)
    -- NORMAL채널은 offset을 적용, GUILD채널은 offset을 미적용
    if (self.m_requestedChannelType == CHAT_CLIENT_CHANNEL_TYPE_NORMAL) then
        local channel = tonumber(channelName)
        if channel then
            local adjustedChannel = channel - self.m_channelOffset
            channelName = tostring(adjustedChannel)
        end
    end

    return channelName
end

-------------------------------------
-- function realChannelName
-- @brief
-------------------------------------
function ChatClient:realChannelName(channelName)
    -- NORMAL채널은 offset을 적용, GUILD채널은 offset을 미적용
    if (self.m_requestedChannelType == CHAT_CLIENT_CHANNEL_TYPE_NORMAL) then
        local channel = tonumber(channelName)
        if channel then
            local adjustedChannel = channel + self.m_channelOffset
            channelName = tostring(adjustedChannel)
        end
    end

    return channelName
end

-------------------------------------
-- function isConnecting
-- @brief
-------------------------------------
function ChatClient:isConnecting()
    return (self.m_status == 'Success')
end

-------------------------------------
-- function pushMsg
-- @brief
-------------------------------------
function ChatClient:pushMsg(msg)
    table.insert(self.m_msgQueue, msg)

    if self.m_changedMsgQueueCb then
        self.m_changedMsgQueueCb(msg)
    end
end

-------------------------------------
-- function popMsg
-- @brief
-------------------------------------
function ChatClient:popMsg(buf)
    if self.m_msgQueue == nil then return end

    for i, v in pairs(self.m_msgQueue) do
        buf[i] = v
    end
    self.m_msgQueue = {}

    if self.m_changedMsgQueueCb then
        self.m_changedMsgQueueCb(false)
    end
end

-------------------------------------
-- function isExistNewMsg
-- @brief
-------------------------------------
function ChatClient:isExistNewMsg()
    if self.m_msgQueue and (table.count(self.m_msgQueue) > 0) then
        return true
    end
    return false
end

-------------------------------------
-- function getNormalChannelRange
-- @brief
-------------------------------------
function ChatClient:getNormalChannelRange()
    return NormalChatChannelRange
end

-------------------------------------
-- function setStatus
-- @brief
-------------------------------------
function ChatClient:setStatus(status)
    self.m_status = status

    if self.m_cbChangeStatus then
        self.m_cbChangeStatus(status)
    end
end


-------------------------------------
-- function setChangeStatusCB
-- @brief
-- @param function(status)
-------------------------------------
function ChatClient:setChangeStatusCB(cb)
    self.m_cbChangeStatus = cb
end
