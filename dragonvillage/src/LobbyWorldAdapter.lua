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

        -- 내부에서 생성하는 변수들
        m_lobbyManager = '',
        m_lobbyMap = '',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyWorldAdapter:init(lobby_ui, parent_node, chat_client_socket)
    self.m_lobbyUI = lobby_ui
    self.m_lobbyWolrdParentNode = parent_node
    self.m_chatClientSocket = chat_client_socket

    self:init_lobbyManager()
    self:init_lobbyMap()
end

-------------------------------------
-- function init_lobbyManager
-------------------------------------
function LobbyWorldAdapter:init_lobbyManager()
    local chat_client_socket = self.m_chatClientSocket

    -- 로비 매니저 생성
    local lobby_manager = LobbyManager()
    lobby_manager:setChatClientSocket(chat_client_socket)
    chat_client_socket:addRegularListener(lobby_manager)
    self.m_lobbyManager = lobby_manager

    -- 이벤트 리스터 등록
    lobby_manager:addListener('LobbyManager_ADD_USER', self)
    lobby_manager:addListener('LobbyManager_REMOVE_USER', self)
    lobby_manager:addListener('LobbyManager_CHARACTER_MOVE', self)
end

-------------------------------------
-- function init_lobbyMap
-------------------------------------
function LobbyWorldAdapter:init_lobbyMap()
    local parent_node = self.m_lobbyWolrdParentNode

    local lobby_map = LobbyMapFactory:createLobbyWorld(parent_node)
    self.m_lobbyMap = lobby_map
    
    -- 위치 랜덤으로 지정
    local t_data = {}
    t_data['x'], t_data['y'] = lobby_map:getRandomSpot()
    self.m_chatClientSocket:setUserInfo(t_data)

    -- 유저 설정
    local struct_user_info = self.m_lobbyManager.m_playerUserInfo
    local leader_dragon = g_dragonsData:getLeaderDragon()
    struct_user_info.m_leaderDragonObject = StructDragonObject(leader_dragon)
    local tamer_bot = lobby_map:makeLobbyTamerBot(struct_user_info)

    -- 첫 위치 지정
    local x, y = struct_user_info:getPosition()
    tamer_bot:setPosition(x, y)

     -- 이벤트 리스터 등록
    lobby_map:addListener('LobbyMap_CHARACTER_MOVE', self)
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

    -- 유저 퇴장
    elseif (event_name == 'LobbyManager_REMOVE_USER') then
        local struct_user_info = t_event
        local uid = struct_user_info:getUid()
        self.m_lobbyMap:removeLobbyTamer(uid)

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



    -- 유저 이동 (실시간 동기화 고민해볼 것 쿨타임 고려해봐!)
    elseif (event_name == 'LobbyMap_CHARACTER_MOVE') then
        local x, y = t_event['x'], t_event['y']
        self.m_lobbyManager:requestCharacterMove(x, y)

    else
        cclog('[UI_Village] 정의되지 않은 event_name ' .. event_name)
    end
end