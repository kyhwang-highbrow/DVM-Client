local SOCKET_TICK_TIME = 0.1             -- check socket data interval
local SOCKET_RECONNECT_TIME = 5            -- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3    -- socket failure timeout

local STATUS_OK = "ok"
local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

local socket = require "socket.core"

SocketTCP = class{
    tcp = 'socket',
    host = 'string',
    port = 'number',
    retryConnect = 'boolean',
    isConnected = 'boolean',
    status = 'string',
    
    waitConnect = 'number',
    connectTimeTickSchedulerID = 'handler',
    reconnectSchedulerID = 'handler',
    tickSchedulerID = 'handler',
    
    co = 'coroutine',
    recvBuffer = 'string',
}

SocketTCP.EVENT_DATA = "EVENT_DATA"
SocketTCP.EVENT_CLOSE = "EVENT_CLOSE"
SocketTCP.EVENT_CLOSED = "EVENT_CLOSED"
SocketTCP.EVENT_CONNECTED = "EVENT_CONNECTED"
SocketTCP.EVENT_CONNECT_FAILURE = "EVENT_CONNECT_FAILURE"

function SocketTCP:init(host, port, retryConnect)
    --cclog('SocketTCP: create socket host:%s, port:%d', host, port)
    self.host = host
    self.port = port
    self.retryConnect = retryConnect
    self.isConnected = false
    self.waitConnect = nil
    self.connectTimeTickSchedulerID = nil
    self.tickSchedulerID = nil
    self.reconnectSchedulerID = nil
    self.co = nil
    self.recvBuffer = ""
    self.status = STATUS_OK
end

function SocketTCP:connect(host, port, retryConnect)
    if host then self.host = host end
    if port then self.port = port end
    if retryConnect then self.retryConnect = retryConnect end
    
    self.tcp = socket.tcp()
    self.tcp:settimeout(0)
    
    local function __checkConnect()
        local __succ = self:_connect()
        if __succ then
            self:_onConnected()
        end
        return __succ
    end    
    
    cclog('SocketTCP.connect: try to connect host:%s, port:%d', self.host, self.port)
    
    if not __checkConnect() then
        local __connectTimeTick = function()
            if self.isConnected then return end
            self.waitConnect = self.waitConnect or 0
            self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
            if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
                self.waitConnect = nil
                self:close()
                self:_connectFailure()
            end
            __checkConnect()
        end
        self.connectTimeTickSchedulerID = scheduler.scheduleGlobal(__connectTimeTick, SOCKET_TICK_TIME)
    end
end

function SocketTCP:close(...)
    cclog("SocketTCP.close")
    self.tcp:close()
    if self.connectTimeTickSchedulerID then scheduler.unscheduleGlobal(self.connectTimeTickSchedulerID) end
    if self.tickSchedulerID then scheduler.unscheduleGlobal(self.tickSchedulerID) end
    self:dispatchEvent({name=SocketTCP.EVENT_CLOSE})
end

function SocketTCP:disconnect()
    self:_disconnect()
    self.retryConnect = false -- initiative to disconnect, no reconnect.
end

function SocketTCP:send(__data)
    if not self.isConnected then
        cclog('sending on disconnect')
        return
    end
    local __sent, __status = self.tcp:send(__data)
    if __status then
        cclog('SocketTCP.send: error %s, %s', tostring(__sent), tostring(__status))
        self.status = __status
    end
end

--------------------
-- function override
--------------------
function SocketTCP:dispatchEvent(t)
end

--------------------
-- function private action
--------------------
function SocketTCP:_connect()
    local __succ, __status = self.tcp:connect(self.host, self.port)
    --cclog("SocketTCP._connect: %s", __status)
    return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function SocketTCP:_disconnect()
    self.isConnected = false
    self.tcp:shutdown()
    self:dispatchEvent({name=SocketTCP.EVENT_CLOSED})
end

function SocketTCP:_connectFailure(status)
    --cclog("SocketTCP._connectFailure")
    self:dispatchEvent({name=SocketTCP.EVENT_CONNECT_FAILURE})
    self:_reconnect();
end

function SocketTCP:_reconnect(__immediately)
    if not self.retryConnect then return end
    cclog("SocketTCP._reconnect")
    
    if __immediately then self:connect() return end
    if self.reconnectSchedulerID then scheduler.unscheduleGlobal(self.reconnectSchedulerID) end
    local __doReConnect = function ()
        self:connect()
    end
    self.reconnectSchedulerID = scheduler.performWithDelayGlobal(__doReConnect, SOCKET_RECONNECT_TIME)
end

--------------------
-- function event
--------------------
function SocketTCP:_onConnected()
    self.isConnected = true
    self.recvBuffer = ""
    self:dispatchEvent({name=SocketTCP.EVENT_CONNECTED})
    
    if self.connectTimeTickSchedulerID then scheduler.unscheduleGlobal(self.connectTimeTickSchedulerID) end
    cclog('SocketTCP._onConnected:')
    
    local __func = function()
        local function recv(len)
            local __body, __status, __partial
            while len > #self.recvBuffer do
                __body, __status, __partial = self.tcp:receive("*a")
                if __body then
                    self.recvBuffer = self.recvBuffer .. __body
                elseif __status == STATUS_TIMEOUT then
                    if __partial then
                        self.recvBuffer = self.recvBuffer .. __partial
                    end
                    coroutine.yield()
                else
                    return false, __status
                end
            end
            __body = self.recvBuffer:sub(1, len)
            self.recvBuffer = self.recvBuffer:sub(len + 1)
            return true, __body
        end
        while true do
            --read length
            local res, chunk = recv(4)
            if not res then
                self.status = chunk
                break
            end
            
            --TODO: 받은 패킷에 대한 정의가 필요. 일단 앞 4바이트를 길이로 정함.
            --http://www.inf.puc-rio.br/~roberto/struct/ 참고할 것
            local len = struct.unpack(">i4", chunk)
            --read body
            res, chunk = recv(len)
            if not res then
                self.status = chunk
                break
            end
            
            --TODO: 패킷 처리, 일단 len 만큼 string이 온다고 가정함
            --http://www.inf.puc-rio.br/~roberto/struct/ 참고할 것

            --jjo, protobuffer 처리를 위해 unpack 하지 않고 넘긴다. (2014/11/04)
            --__data = struct.unpack("c"..len, chunk)
            __data = chunk
            
            --cclog('read packet %d bytes', len)
            
            self:dispatchEvent({name=SocketTCP.EVENT_DATA, data=__data})
        end        
    end
    
    -- create coroutine
    self.co = coroutine.create(__func)
    
    local __tick = function(dt)
        local ret, _, msg = updateCoroutine(self.co, dt)

        --코루틴 내부에서 에러가 났을 경우 다시 연결
        if (not ret) or self.status == STATUS_CLOSED or self.status == STATUS_NOT_CONNECTED then
            self.status = STATUS_OK
            self:close()
            if self.isConnected then
                self:_onDisconnect()
            else
                self:_connectFailure()
            end
            return
        end
    end
    
    -- start to read TCP data
    self.tickSchedulerID = scheduler.scheduleGlobal(__tick, SOCKET_TICK_TIME)
end

function SocketTCP:_onDisconnect()
    --cclog("SocketTCP._onDisConnect");
    self.isConnected = false
    self:dispatchEvent({name=SocketTCP.EVENT_CLOSED})
    self:_reconnect();
end