local PARENT = class(UI, IEventDispatcher:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class UI_Village
-- @brief
-------------------------------------
UI_Village = class(PARENT, {
        m_chatClientSocket = '',
        m_lobbyManager = '',
        m_lobbyMap = '',
    })

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function UI_Village:init()
    local vars = self:load('chat_lobby.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Village')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Village:initUI()
    self:initChatClientSocket()
    self:initEditBox()
    self:initWorld()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Village:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Village:refresh()
end


-------------------------------------
-- function initWorld
-------------------------------------
function UI_Village:initWorld()
    local vars = self.vars
    local lobby_map = LobbyMapFactory:createLobbyWorld(vars['worldNode'])
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
-- function initChatClientSocket
-------------------------------------
function UI_Village:initChatClientSocket()
    -- 소켓 생성
    local chat_client_socket = ChatClientSocket('192.168.1.63', '3927')

    -- 유저 정보 입력
    local uid = g_serverData:get('local', 'uid')
    local tamer = g_userData:get('tamer')
    local nickname = g_userData:get('nick')
    local lv = g_userData:get('lv')

    -- 리더 드래곤
    local leader_dragon = g_dragonsData:getLeaderDragon()
    local did = leader_dragon and tostring(leader_dragon['did']) or ''
    if (did ~= '') then
        did = did .. ';' .. leader_dragon['evolution']
    end

    local t_data = {}
    t_data['uid'] = tostring(uid)
    t_data['tamer'] = tostring(tamer)
    t_data['nickname'] = nickname
    t_data['did'] = did
    t_data['level'] = lv
    t_data['x'] = 0
    t_data['y'] = -150
    chat_client_socket:setUserInfo(t_data)

    -- 로비 매니저 생성
    local lobby_manager = LobbyManager()
    lobby_manager:setChatClientSocket(chat_client_socket)
    chat_client_socket:addRegularListener(lobby_manager)
    self.m_lobbyManager = lobby_manager

    -- 이벤트 리스터 등록
    lobby_manager:addListener('LobbyManager_ADD_USER', self)
    lobby_manager:addListener('LobbyManager_REMOVE_USER', self)
    lobby_manager:addListener('LobbyManager_CHARACTER_MOVE', self)

    self.m_chatClientSocket = chat_client_socket
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_Village:initEditBox()
    local vars = self.vars

    -- 채팅 EditBox에서 입력 완료 후 바로 전송하기
    local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            --self:click_enterBtn()
            local msg = pSender:getText()
            local len = string.len(msg)
            if (len <= 0) then
                UIManager:toastNotificationRed('메시지를 입력하세요.')
                return
            end

            if self.m_lobbyManager:sendNormalMsg(msg) then
                vars['editBox']:setText('')
            else
                UIManager:toastNotificationRed('메시지 전송에 실패하였습니다.')
            end
        end
    end
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function onEvent
-------------------------------------
function UI_Village:onEvent(event_name, t_event, ...)

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

-------------------------------------
-- function onClose
-------------------------------------
function UI_Village:onClose()
    self.m_chatClientSocket:close()
end