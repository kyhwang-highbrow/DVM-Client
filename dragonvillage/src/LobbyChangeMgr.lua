LOBBY_TYPE = {
    NORMAL = 1,
    CLAN = 2,
}

-------------------------------------
-- class LobbyChangeMgr
-------------------------------------
LobbyChangeMgr = class({
        m_bEntering = 'boolean', -- 로비 변경 후 최초 진입인가
        m_curType = 'LOBBY_TYPE',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyChangeMgr:init()
    self.m_bEntering = false

    -- 로컬에 저장된 경우
    if (g_settingData:get('lobby_type')) then
        self.m_curType = g_settingData:get('lobby_type')
    else
        -- 저장되지 않은 경우
        -- 클랜 미가입시 마을 기본
        if (g_clanData:isClanGuest()) then
            self.m_curType = LOBBY_TYPE.NORMAL
        -- 클랜 가입시 클랜 로비 기본
        else
            self.m_curType = LOBBY_TYPE.CLAN
        end
    end
end

-------------------------------------
-- function getInstance
-------------------------------------
function LobbyChangeMgr:getInstance()
    if g_lobbyChangeMgr then
        return g_lobbyChangeMgr
    end

    g_lobbyChangeMgr = LobbyChangeMgr()

    return g_lobbyChangeMgr
end

-------------------------------------
-- function getLobbyType
-------------------------------------
function LobbyChangeMgr:getLobbyType()
    local cur_type = self.m_curType
    -- 로비 타입 가져올때 유효한 타입인지 체크
    self:checkType(cur_type)

    return cur_type
end

-------------------------------------
-- function getLobbyEntering
-------------------------------------
function LobbyChangeMgr:getLobbyEntering()
    return self.m_bEntering
end

-------------------------------------
-- function getChatClientSocket
-- @brief 로비별 연결될 채팅 서버
-------------------------------------
function LobbyChangeMgr:getChatClientSocket()
    local type = self.m_curType

    if (type == LOBBY_TYPE.NORMAL) then
        return g_chatClientSocket

    elseif (type == LOBBY_TYPE.CLAN) then
        return g_clanChatClientSocket
    end
end

-------------------------------------
-- function getLobbyManager
-- @brief 로비별 연결될 로비 매니저
-------------------------------------
function LobbyChangeMgr:getLobbyManager()
    local type = self.m_curType

    if (type == LOBBY_TYPE.NORMAL) then
        return g_lobbyManager

    elseif (type == LOBBY_TYPE.CLAN) then
        return g_clanLobbyManager
    end
end

-------------------------------------
-- function getLobbyMap
-- @brief 로비별 로비맵 생성
-------------------------------------
function LobbyChangeMgr:getLobbyMap(parent_node, lobby_ui)
    local type = self.m_curType
    local lobby_map

    if (type == LOBBY_TYPE.NORMAL) then
        lobby_map = LobbyMapFactory:createLobbyWorld(parent_node, lobby_ui)

    elseif (type == LOBBY_TYPE.CLAN) then
        lobby_map = LobbyMapFactory:createClanLobbyWorld(parent_node, lobby_ui)
    end

    return lobby_map
end

-------------------------------------
-- function getTamerBaseScale
-- @brief 로비별 테이머 기본 스케일
-------------------------------------
function LobbyChangeMgr:getTamerBaseScale()
    local type = self.m_curType
    local base_scale

    if (type == LOBBY_TYPE.NORMAL) then
        base_scale = 1.0

    elseif (type == LOBBY_TYPE.CLAN) then
        base_scale = 0.85
    end

    return base_scale
end

-------------------------------------
-- function globalUpdatePlayerUserInfo
-- @brief 채팅 서버에 변경사항 적용
-------------------------------------
function LobbyChangeMgr:globalUpdatePlayerUserInfo()
    local type = self.m_curType
    local chat_client_socket = self:getChatClientSocket()
    if (g_chatClientSocket) then
        g_chatClientSocket:globalUpdatePlayerUserInfo()
    end

    if (g_clanChatClientSocket) then
        g_clanChatClientSocket:globalUpdatePlayerUserInfo()
    end
end

-------------------------------------
-- function changeTypeAndGotoLobby
-- @brief 로비 타입 변경후 변경된 로비 진입
-------------------------------------
function LobbyChangeMgr:changeTypeAndGotoLobby(type)
    if (self.m_curType == type) then
        return
    end

    self:checkType(type)
    self.m_bEntering = true

    UI_BlockPopup()

    local use_loading = true
    local scene = SceneLobby(use_loading)
    scene:runScene()
end

-------------------------------------
-- function checkType
-------------------------------------
function LobbyChangeMgr:checkType(type)
    local invalid = true
    for _, _type in pairs(LOBBY_TYPE) do
        if (type == _type) then
            invalid = false
            break
        end
    end

    if (invalid) then
        error('정의되지 않은 LOBBY_TYPE : '..type)
    end

    if (type == LOBBY_TYPE.CLAN) then
        -- 클랜 미가입시 강제로 변경
        if (g_clanData:isClanGuest()) then
            type = LOBBY_TYPE.NORMAL
        end
    end

    self.m_curType = type

    -- 로컬에 저장
    g_settingData:applySettingData(type, 'lobby_type')
end