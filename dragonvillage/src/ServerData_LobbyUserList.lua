-------------------------------------
-- class ServerData_LobbyUserList
-------------------------------------
ServerData_LobbyUserList = class({
        m_serverData = 'ServerData',
        m_lobbyLeaderDoid = 'doid',
        m_validateTime = 'number', -- 로비 유저 정보의 유효시간(타임 스탬프)

        m_posX = '',
        m_posY = '',
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
        
        self:setDefaultLobbyUserData(ret['lobby_user_info'])

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
-- function requestLobbyUserList_UseUI
-------------------------------------
function ServerData_LobbyUserList:requestLobbyUserList_UseUI(cb_func)
    if (self:checkNeedUpdate_LobbyUserList() == false) then
        if cb_func then
            cb_func()
        end
        return
    end

    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        self:applyLobbyUserInfo(ret['lobby_user_info'])
        self.m_validateTime = ret['validate_time']

        if cb_func then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/lobby_user_list')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
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

-------------------------------------
-- function setDefaultLobbyUserData
-- @brief 데이터가 없는 유저 초기화
-------------------------------------
function ServerData_LobbyUserList:setDefaultLobbyUserData(l_lobby_user_list)
    for i,v in ipairs(l_lobby_user_list) do
        -- 닉네임
        if (not v['nick']) then
            v['nick'] = Str('닉네임미지정')
        end

        -- 레벨
        if (not v['lv']) then
            v['lv'] = 1
        end

        -- 길드
        if (not v['guild']) then
            local sum_random = SumRandom()
            sum_random:addItem(1, '천지창조')
            sum_random:addItem(1, '카오스')
            sum_random:addItem(1, 'SKT T1')
            sum_random:addItem(1, 'TSM')
            sum_random:addItem(1, '최강역삼초등학교')
            sum_random:addItem(1, '서울대학교')
            sum_random:addItem(1, '퍼플랩')
            v['guild'] = sum_random:getRandomValue()
        end

        --리더 드래곤 (lobby leader)
        if (not v['leader']) then
            local table_dragon = TableDragon()

            -- test값이 1인 데이터만 사용
            local function condition_func(t_table)
                if (t_table['test'] == 1) then
                    return true
                else
                    return false
                end
            end

            local l_valid_dragons = table_dragon:filterList_condition(condition_func)
            local rand_idx = math_random(1, #l_valid_dragons)
            local t_dragon = l_valid_dragons[rand_idx]

            local t_dragon_data = {}
            t_dragon_data['did'] = t_dragon['did']
            t_dragon_data['evolution'] = 1
            t_dragon_data['grade'] = 1
            t_dragon_data['lv'] = 1
            t_dragon_data['exp'] = 1
            t_dragon_data['skill_0'] = 1
            t_dragon_data['skill_1'] = 1
            t_dragon_data['skill_2'] = 0
            t_dragon_data['skill_3'] = 0
            
            v['leader'] = t_dragon_data
        end
    end
end
