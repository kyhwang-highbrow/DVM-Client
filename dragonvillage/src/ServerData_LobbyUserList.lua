-------------------------------------
-- class ServerData_LobbyUserList
-------------------------------------
ServerData_LobbyUserList = class({
        m_serverData = 'ServerData',
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
        self.m_serverData:applyServerData(ret['lobby_user_info'], 'lobby_user_list')
        success_cb(ret)
    end

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_cb

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function getLobbyUserList
-------------------------------------
function ServerData_LobbyUserList:getLobbyUserList()
    return self.m_serverData:get('lobby_user_list')
end