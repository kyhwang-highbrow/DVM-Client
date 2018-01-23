-------------------------------------
-- class ServerListData
-------------------------------------
ServerListData = class({
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
    local recommandServerName
    local defaultServerName
    --서버변경 테스트때문에 개발이랑 qa랑 보이게
    if targetServer == SERVER_NAME.DEV or targetServer == SERVER_NAME.QA then
        for i, server in pairs(tserverList) do
            if server['server_name'] ~= SERVER_NAME.DEV and server['server_name'] ~= SERVER_NAME.QA then
                table.insert(tremove, 1, i)
            end
        end
        recommandServerName = targetServer
    else
        for i, server in pairs(tserverList) do
            if server['server_name'] == SERVER_NAME.DEV or server['server_name'] == SERVER_NAME.QA then
                table.insert(tremove, 1, i)
            else
                if server['server_num'] == recommandServerNum then
                    recommandServerName = server['server_name']
                end

                if defaultServerName == nil then
                    defaultServerName = server['server_name']
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
    self:selectServer( self.m_recommandServerName )
end

-------------------------------------
-- function getServerList()
-------------------------------------
function ServerListData:getServerList()
    return self.m_tservers
end

-------------------------------------
-- function getSelectServer()
-------------------------------------
function ServerListData:getSelectServer()
    return self.m_selectServerName
end

-------------------------------------
-- function selectServer( name )
-- @brief 서버 선택
-------------------------------------
function ServerListData:selectServer( serverName )    
    self.m_selectServerName = serverName

    cclog( 'selectServer : ' .. serverName )
    local servers = self.m_tservers
    if servers then
        for _, server in pairs( servers ) do
            if server['server_name'] == serverName then                        
                cclog( 'api_server_ip : ' .. server['api_server_ip'] )
                cclog( 'chat_server : ' .. server['chat_server'] )
                cclog( 'clan_chat_server : ' .. server['clan_chat_server'] )
                
                SetApiUrl(server['api_server_ip'])
                SetChatServerUrl(server['chat_server'])
                SetClanChatServerUrl(server['clan_chat_server'])

                break
            end
        end
                                
    end
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
-------------------------------------
function ServerListData:getInstance()
    if (not g_serverListData) then
        g_serverListData = ServerListData()
    end

    return g_serverListData
end