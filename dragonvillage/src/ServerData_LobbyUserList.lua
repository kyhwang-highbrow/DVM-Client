-------------------------------------
-- class ServerData_LobbyUserList
-------------------------------------
ServerData_LobbyUserList = class({
        m_serverData = 'ServerData',
        m_lobbyLeaderDoid = 'doid',
        m_validateTime = 'number', -- 로비 유저 정보의 유효시간(타임 스탬프)
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_LobbyUserList:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_LobbyUserList:get(key)
    return self.m_serverData:get('lobby_user_list', key)
end

-------------------------------------
-- function requestLobbyUserList
-------------------------------------
function ServerData_LobbyUserList:requestLobbyUserList(uid, success_cb, fail_cb)
    -- 파라미터 셋팅
    local t_data = {}
    t_data['uid'] = uid

    -- 요청 정보 설정
    local t_request = {}
    t_request['url'] = '/users/lobby_user_list'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    -- 성공 시 콜백 함수
    t_request['success'] = function(ret)
        self:applyLobbyUserInfo(ret['lobby_user_info'])
        self.m_validateTime = ret['validate_time']
        success_cb(ret)
    end

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function applyLobbyUserInfo
-------------------------------------
function ServerData_LobbyUserList:applyLobbyUserInfo(lobby_user_info)
    self.m_serverData:applyServerData(lobby_user_info, 'lobby_user_list')

    -- 플레이어의 리더(lobby)드래곤의 doid를 저장
    local player_user_info = self:getLobbyUser_playerOnly()

    if player_user_info['leader'] then
        self.m_lobbyLeaderDoid = player_user_info['leader']['id']
    else
        self.m_lobbyLeaderDoid = nil
    end
end

-------------------------------------
-- function getLobbyUserList
-------------------------------------
function ServerData_LobbyUserList:getLobbyUserList()
    return self.m_serverData:get('lobby_user_list')
end

-------------------------------------
-- function getLobbyUser_playerOnly
-- @brief 플레이어 유저의 정보만 리턴
-------------------------------------
function ServerData_LobbyUserList:getLobbyUser_playerOnly()
     local l_lobby_user_list = self.m_serverData:get('lobby_user_list')

     local player_user_info = nil

     local uid = g_userData:get('uid')

     for i,v in ipairs(l_lobby_user_list) do
        if (v['uid'] == uid) then
            player_user_info = v
            break
        end
     end

     return player_user_info
end

-------------------------------------
-- function checkNeedUpdate_LobbyUserList
-- @brief 로비 유저 리스트 정보를 갱신해야 하는지 확인하는 함수
-------------------------------------
function ServerData_LobbyUserList:checkNeedUpdate_LobbyUserList()
    
    do -- 0. 정보가 없는지 확인
        local l_lobby_user_list = self.m_serverData:get('lobby_user_list')
        if (not l_lobby_user_list) then
            return true
        end
    end

    do -- 1. 리더 드래곤 변경 확인
        local doid = nil
        local t_dragon_data = g_dragonsData:getLeaderDragon('lobby')
        if t_dragon_data then
            doid = t_dragon_data['id']
        end

        if (self.m_lobbyLeaderDoid ~= doid) then
            return true
        end
    end

    do -- 2. 데이터 유효시간 체크
        -- 서버상의 시간을 얻어옴
        local server_time = Timer:getServerTime()
        local validate_time = (self.m_validateTime / 1000)
        if (validate_time <= server_time) then
            return true
        end
    end

    return false
end