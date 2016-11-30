-------------------------------------
-- class ServerData
-------------------------------------
ServerData = class({
        m_rootTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData:init()
    self.m_rootTable = nil
end

-------------------------------------
-- function getInstance
-------------------------------------
function ServerData:getInstance()
    if g_serverData then
        return g_serverData
    end
    
    g_serverData = ServerData()
    g_serverData:loadServerDataFile()

    -- 'user'
    g_userData = ServerData_User(g_serverData)

    -- 'dragons'
    g_dragonsData = ServerData_Dragons(g_serverData)

    -- 'deck'
    g_deckData = ServerData_Deck(g_serverData)

    -- 'staminas' (user/staminas)
    g_staminasData = ServerData_Staminas(g_serverData)

    return g_serverData
end

-------------------------------------
-- function getServerDataSaveFileName
-------------------------------------
function ServerData:getServerDataSaveFileName()
    local file = 'server_data.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadServerDataFile
-------------------------------------
function ServerData:loadServerDataFile()
    local f = io.open(self:getServerDataSaveFileName(), 'r')

    if f then
        local content = f:read('*all')

        if #content > 0 then
            self.m_rootTable = json.decode(content)
        end
        f:close()
    else
        self.m_rootTable = {}

        self.m_rootTable['local'] = {}

        -- 기본 설정 데이터
        self.m_rootTable['local']['lowResMode'] = false
        self.m_rootTable['local']['bgm'] = true
        self.m_rootTable['local']['sfx'] = true
        self.m_rootTable['local']['fps'] = false

        self:saveServerDataFile()
    end
end

-------------------------------------
-- function saveServerDataFile
-------------------------------------
function ServerData:saveServerDataFile()
    local f = io.open(self:getServerDataSaveFileName(),'w')
    if (not f) then
        return false
    end

    -- cclog(luadump(self.m_rootTable))
    local content = dkjson.encode(self.m_rootTable, {indent=true})
    f:write(content)
    f:close()

    return true
end

-------------------------------------
-- function clearServerDataFile
-------------------------------------
function ServerData:clearServerDataFile()
    os.remove(self:getServerDataSaveFileName())
end


-------------------------------------
-- function applyServerData
-- @brief 서버로부터 받은 정보로 세이브 데이터를 갱신
-------------------------------------
function ServerData:applyServerData(data, ...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                container[key] = {}
            end
            container = container[key]
        else
            if (data ~= nil) then
                container[key] = clone(data)
            else
                container[key] = nil
            end
        end
    end

    self:saveServerDataFile()
end

-------------------------------------
-- function get
-- @brief
-------------------------------------
function ServerData:get(...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return clone(container[key])
            end
        end
    end

    return nil
end

-------------------------------------
-- function getRef
-- @brief
-------------------------------------
function ServerData:getRef(...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return container[key]
            end
        end
    end

    return nil
end


-------------------------------------
-- function applySetting
-------------------------------------
function ServerData:applySetting()
    -- fps 출력
    local fps = self:get('local', 'fps')
    cc.Director:getInstance():setDisplayStats(fps)

    -- 저사양모드
    local lowResMode = self:get('local', 'lowResMode')
    setLowEndMode(lowResMode)

    -- 배경음
    local bgm = self:get('local', 'bgm')
    SoundMgr:setBgmOnOff(bgm)

    -- 효과음
    local sfx = self:get('local', 'sfx')
    SoundMgr:setSfxOnOff(sfx)
end

-------------------------------------
-- function developCache
-------------------------------------
function ServerData:developCache()
    if LocalServer then
        LocalServer['user_local_server'] = self:get('cache', 'user_local_server')
    end
end


-------------------------------------
-- function networkCommonRespone
-- @breif 중복되는 코드를 방지하기 위해 ret값에 예약된 데이터를 한번에 처리
-------------------------------------
function ServerData:networkCommonRespone(ret)
    -- 서버 시간 동기화
    if (ret['server_info'] and ret['server_info']['server_time']) then
        local server_time = math_floor(ret['server_info']['server_time'] / 1000)
        Timer:setServerTime(server_time)
    end

    -- 스태미나 동기화
    if (ret['staminas']) then
        local data = ret['staminas']
        g_serverData:applyServerData(data, 'user', 'staminas')
    end
end
