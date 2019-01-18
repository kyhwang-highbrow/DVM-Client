local PARENT = class(IEventDispatcher:getCloneClass(), IEventListener:getCloneTable())

-------------------------------------
-- class LobbyWorldAdapter
-- @brief
-------------------------------------
LobbyWorldAdapter = class(PARENT, {

        -- 외부에서 전달받는 변수들
        m_lobbyUI = 'UI_Lobby',
        m_lobbyWolrdParentNode = 'cc.Node',
        m_chatClientSocket = '',
        m_lobbyManager = '',

        -- 내부에서 생성하는 변수들
        m_lobbyMap = '',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyWorldAdapter:init(lobby_ui, parent_node, chat_client_socket, lobby_manager)
    self.m_lobbyUI = lobby_ui
    self.m_lobbyWolrdParentNode = parent_node
    self.m_chatClientSocket = chat_client_socket
    self.m_lobbyManager = lobby_manager

    self:init_lobbyManager()
    self:init_lobbyMap()
    self:init_lobbyUserList()
end

-------------------------------------
-- function init_lobbyManager
-------------------------------------
function LobbyWorldAdapter:init_lobbyManager()
    if (not self.m_lobbyManager) then
        return
    end

    -- 이벤트 리스터 등록
    self.m_lobbyManager:addListener('LobbyManager_CHAT_NORMAL_MSG', self)
    self.m_lobbyManager:addListener('LobbyManager_ADD_USER', self)
    self.m_lobbyManager:addListener('LobbyManager_REMOVE_USER', self)
    self.m_lobbyManager:addListener('LobbyManager_CHARACTER_MOVE', self)
    self.m_lobbyManager:addListener('LobbyManager_UPDATE_USER', self)
end

-------------------------------------
-- function init_lobbyMap
-------------------------------------
function LobbyWorldAdapter:init_lobbyMap()
    local parent_node = self.m_lobbyWolrdParentNode
    local lobby_type = g_lobbyChangeMgr:getLobbyType()

    self.m_lobbyMap = g_lobbyChangeMgr:getLobbyMap(parent_node, self.m_lobbyUI)
    
    if (not self.m_lobbyManager) then
        return
    end

    if (not self.m_chatClientSocket) then
        return
    end
    
    local t_data = {}
    if (not self.m_lobbyManager.m_playerUserInfo) then -- 위치 랜덤으로 지정 (처음에만)
        t_data['x'], t_data['y'] = self.m_lobbyMap:getRandomSpot()
    end
    self.m_chatClientSocket:changeUserInfo(t_data)

    -- 유저 설정
    local struct_user_info = self.m_lobbyManager.m_playerUserInfo
    local leader_dragon = g_dragonsData:getLeaderDragon()
    struct_user_info.m_leaderDragonObject = StructDragonObject(leader_dragon)
    local tamer_bot = self.m_lobbyMap:makeLobbyTamerBot(struct_user_info)

    -- 첫 위치 지정
    local is_lobby_change = g_lobbyChangeMgr:getLobbyEntering()
    local x, y

    -- 로비가 바뀐 경우 진입점에 가까운 곳에 위치시킴
    if (is_lobby_change) then
        g_lobbyChangeMgr.m_bEntering = false
        x, y = self.m_lobbyMap:getEntrySpot()
    else
        x, y = struct_user_info:getPosition()
    end
    tamer_bot:setPosition(x, y)

     -- 이벤트 리스터 등록
    self.m_lobbyMap:addListener('LobbyMap_CHARACTER_MOVE', self)
end

-------------------------------------
-- function init_lobbyUserList
-------------------------------------
function LobbyWorldAdapter:init_lobbyUserList()
    if (not self.m_lobbyManager) then
        return
    end

    if (not self.m_lobbyManager.m_userInfoList) then
        return
    end

    if (not self.m_lobbyMap) then
        return
    end

    for i,v in pairs(self.m_lobbyManager.m_userInfoList) do
        local t_event = v
        self:onEvent('LobbyManager_ADD_USER', t_event)
    end
end


-------------------------------------
-- function onEvent
-------------------------------------
function LobbyWorldAdapter:onEvent(event_name, t_event, ...)
    -- 유저 입장
    if (event_name == 'LobbyManager_ADD_USER') then
        local struct_user_info = t_event
        local tamer_bot = self.m_lobbyMap:makeLobbyTamerBot(struct_user_info)

        -- 첫 위치 지정
        local x, y = struct_user_info:getPosition()
        tamer_bot:setPosition(x, y)
        self.m_lobbyMap:updateLobbyObject(struct_user_info)

    -- 유저 퇴장
    elseif (event_name == 'LobbyManager_REMOVE_USER') then
        local struct_user_info = t_event
        local uid = struct_user_info:getUid()
        self.m_lobbyMap:removeLobbyTamer(uid)
        self.m_lobbyMap:updateLobbyObject(struct_user_info)

    -- 유저 이동
    elseif (event_name == 'LobbyManager_CHARACTER_MOVE') then
        local struct_user_info = t_event
        local uid = struct_user_info:getUid()

        for i,v in pairs(self.m_lobbyMap.m_lLobbyTamerBotOnly) do
            if (uid == v.m_userData:getUid()) then
                local x,y = struct_user_info:getPosition()
                v:setMove(x, y, 400)
            end
        end

    -- 유저 채팅
    elseif (event_name == 'LobbyManager_CHAT_NORMAL_MSG') then
        local json = t_event
        local uid = json['uid']

        for i,v in pairs(self.m_lobbyMap.m_lLobbyTamer) do
            if (uid == v.m_userData:getUid()) then
                SensitivityHelper:doActionBubbleText(v.m_rootNode, nil, nil, 'chat_tamer', json['message'])
            end
        end

    -- 유저 정보 갱신
    elseif (event_name == 'LobbyManager_UPDATE_USER') then
        local struct_user_info = t_event
        local uid = struct_user_info:getUid()
        self.m_lobbyMap:updateLobbyTamer(uid, struct_user_info)






    -- 유저 이동 (실시간 동기화 고민해볼 것 쿨타임 고려해봐!)
    elseif (event_name == 'LobbyMap_CHARACTER_MOVE') then
        local x, y = t_event['x'], t_event['y']
        self.m_lobbyManager:requestCharacterMove(x, y)

    else
        cclog('[LobbyWorldAdapter] 정의되지 않은 event_name ' .. event_name)
    end
end

-------------------------------------
-- function getLobbymap
-------------------------------------
function LobbyWorldAdapter:getLobbymap()
    return self.m_lobbyMap
end

-------------------------------------
-- function onDestroy
-------------------------------------
function LobbyWorldAdapter:onDestroy()
    self:release_EventDispatcher()
    self:release_EventListener()

    if (self.m_lobbyMap) then
        self.m_lobbyMap:onDestroy()
        self.m_lobbyMap = nil
    end
end