-------------------------------------
---@class ServerListData
-------------------------------------
ServerListData = class({
        -- server name 종류 (QA, DEV, Korea, Asia, Japan, America, Global)
	    m_recommandServerName = 'string',
        m_selectServerName = 'string',
        m_tservers = 'table'
    })

-------------------------------------
-- function init
-------------------------------------
function ServerListData:init()
    self.m_recommandServerName = ''
    self.m_selectServerName = ''
    self.m_tservers = {}
end

-------------------------------------
-- function initWithData
-------------------------------------
function ServerListData:initWithData(tdata)
    self.m_tservers = clone(tdata['servers'])
    local tserverList = self.m_tservers
    
    local tremove = {}
    local targetServer = CppFunctionsClass:getTargetServer()
    local recommandServerNum = tdata['recommandedServer']
    local recommandServerName = nil
    local defaultServerName = nil

    --서버변경 테스트때문에 개발이랑 qa랑 보이게
    if (targetServer == SERVER_NAME.DEV) or (targetServer == SERVER_NAME.QA) then
        for i, server in pairs(tserverList) do
            if (server['server_name'] == SERVER_NAME.DEV) then
            elseif (server['server_name'] == SERVER_NAME.QA) then
            elseif (isWin32() == false) and (isMac() == false)  and (server['server_name'] == SERVER_NAME.EUROPE) then -- @sgkim 2020.11.24 유럽 서버 추가 준비를 위해 임의로 추가
            else -- 위에서 허용되지 않은 서버 항목은 삭제
                table.insert(tremove, 1, i)
            end
        end
        recommandServerName = targetServer
    else
        if (recommandServerNum ~= 3) then
            recommandServerNum = 8
        end

        for i, server in pairs(tserverList) do
            local server_name = server['server_name']
            -- 라이브 서버에서는 DEV, QA서버를 제외한다
            if (server_name == SERVER_NAME.DEV) or (server_name == SERVER_NAME.QA) or (server_name == SERVER_NAME.EUROPE) then
                table.insert(tremove, 1, i)
            else
                if server['server_num'] == recommandServerNum then
                    recommandServerName = server_name
                end

                if defaultServerName == nil then
                    defaultServerName = server_name
                end
            end
        end
    end

    for i,v in ipairs(tremove) do
        table.remove(tserverList, v)
    end

    --로컬에 저장된거 있으면 그거 우선
    local local_server_name = g_localData:getServerName()
    if local_server_name then        
        self.m_recommandServerName = local_server_name
    else
        self.m_recommandServerName = recommandServerName or defaultServerName    
    end
    self:selectServer(self.m_recommandServerName)
end

-------------------------------------
-- function getServerList
-------------------------------------
function ServerListData:getServerList()
    return self.m_tservers
end

-------------------------------------
-- function getSelectServer
-------------------------------------
function ServerListData:getSelectServer()
    return self.m_selectServerName
end

-------------------------------------
-- function selectServer
-- @brief 서버 선택
-------------------------------------
function ServerListData:selectServer(server_name)    
    -- 서버 1개의 정보를 받아옴
    local t_server_info = self:getGameServerInfo(server_name)

    if (not t_server_info) then
        return
    end

    -- 선택된 서버 이름 저장
    self.m_selectServerName = server_name

    cclog('# ServerListData:selectServer(server_name) : ' .. tostring(server_name))
    cclog('  api_server_ip : ' .. tostring(t_server_info['api_server_ip']))
    cclog('  chat_server : ' .. tostring(t_server_info['chat_server']))
    cclog('  clan_chat_server : ' .. tostring(t_server_info['clan_chat_server']))

    -- 게임이 설정된 서버 기준으로 동작할 수 있게 설정
    SetApiUrl(t_server_info['api_server_ip'])
    SetChatServerUrl(t_server_info['chat_server'])
    SetClanChatServerUrl(t_server_info['clan_chat_server'])

    -- 로컬 데이터에 선택된 서버 정보 저장 (로컬 파일에까지 저장)
    if g_localData then
        g_localData:setServerName(server_name)
    end
end

-------------------------------------
-- function getGameServerInfo
-- @brief 게임 서버 정보 리턴
-- @return 게임 서버 1개의 정보를 담은 테이블
-- {
--      "server_name":"Korea",
--      "newOne":0,
--      "api_server_ip":"dvm-api.perplelab.com",
--      "server_num":1,
--      "clan_chat_server":"dvm-ch1.perplelab.com:2223/",
--      "chat_server":"dvm-ch1.perplelab.com:2222",
--      "db_server_ip":""
-- }
-------------------------------------
function ServerListData:getGameServerInfo(server_name)
    if (not self.m_tservers) then
        return nil
    end

    local t_server_info = nil
    for _, server in pairs(self.m_tservers) do
        if (server['server_name'] == server_name) then
            t_server_info = server
            break
        end
    end

    return t_server_info
end

-------------------------------------
-- function createWithData
-------------------------------------
function ServerListData:createWithData(tdata)
    local serverList = ServerListData:getInstance()
    serverList:initWithData(tdata)

    return serverList
end

-------------------------------------
-- function getInstance
---@return ServerListData
-------------------------------------
function ServerListData:getInstance()
    if (not g_serverListData) then
        g_serverListData = ServerListData()
    end

    return g_serverListData
end