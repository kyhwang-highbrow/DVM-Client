-------------------------------------
-- class ServerData_ChallengeMode
-------------------------------------
ServerData_ChallengeMode = class({
        m_serverData = 'ServerData',
        m_gameKey = 'number',
        m_matchUserInfo = 'StructUserInfoArena',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ChallengeMode:init(server_data)
end


-------------------------------------
-- function isActive_challengeMode
-- @brief 챌린지 모드 이벤트가 진행 중인지 여부 true or false
-------------------------------------
function ServerData_ChallengeMode:isActive_challengeMode()
    -- 임시로 오픈
    return true
end

-------------------------------------
-- function getPlayerArenaUserInfo
-------------------------------------
function ServerData_ChallengeMode:getPlayerArenaUserInfo()
    local struct_user_info = StructUserInfoArena()
    struct_user_info.m_uid = g_userData:get('uid')
	struct_user_info:setStructClan(g_clanData:getClanStruct())

    local t_data = g_deckData:getDeck_lowData(DECK_CHALLENGE_MODE)
    struct_user_info:applyPvpDeckData(t_data)

    return struct_user_info
    --return self.m_playerUserInfo
end

-------------------------------------
-- function makeMatchUserInfo
-------------------------------------
function ServerData_ChallengeMode:makeMatchUserInfo(data)
    local struct_user_info = StructUserInfoArena()

    -- 기본 유저 정보
    struct_user_info.m_uid = data['uid']
    struct_user_info.m_nickname = data['nick']
    struct_user_info.m_lv = data['lv']
    struct_user_info.m_tamerID = data['tamer']
    struct_user_info.m_leaderDragonObject = StructDragonObject(data['leader'])
    struct_user_info.m_tier = data['tier']
    struct_user_info.m_rank = data['rank']
    struct_user_info.m_rankPercent = data['rate']
    
    -- 콜로세움 유저 정보
    struct_user_info.m_rp = data['rp']
    struct_user_info.m_matchResult = data['match']

    struct_user_info:applyRunesDataList(data['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
    struct_user_info:applyDragonsDataList(data['dragons'])

    -- 덱 정보 (매치리스트에 넘어오는 덱은 해당 유저의 방어덱)
    struct_user_info:applyPvpDeckData(data['deck'])

    -- 클랜
    if (data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(data['clan_info'])
        struct_user_info:setStructClan(struct_clan)
    end

    local uid = data['uid']
    self.m_matchUserInfo = struct_user_info
end

-------------------------------------
-- function getMatchUserInfo
-------------------------------------
function ServerData_ChallengeMode:getMatchUserInfo()

    -- 개발 중에 임시 데이터로 사용
    if (not self.m_matchUserInfo) then
        local data = require 'challenge_user_temp'
        local struct_user_info = StructUserInfoArena()
        for i,v in pairs(data) do
            struct_user_info[i] = v
        end

        -- 룬 오프젝트
        for i,v in pairs(struct_user_info.m_runesObject) do
            struct_user_info.m_runesObject[i] = StructRuneObject(v)
        end

        -- 드래곤 오브젝트
        for i,v in pairs(struct_user_info.m_dragonsObject) do
            struct_user_info.m_dragonsObject[i] = StructDragonObject(v)

            -- 룬 오프젝트
            for roid,data in pairs(v.m_mRuneObjects) do
                v.m_mRuneObjects[roid] = StructRuneObject(data)
            end
        end

        self.m_matchUserInfo = struct_user_info
    end


    if (not self.m_matchUserInfo) then
        return nil
    end

    return self.m_matchUserInfo
end


-------------------------------------
-- function request_challengeModeInfo
-- @brief 챌린지 모드(그림자의 신전) info 요청
-------------------------------------
function ServerData_ChallengeMode:request_challengeModeInfo(stage_id, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 동기화
        g_serverData:networkCommonRespone(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        -- -1351 invalid time (오픈 시간이 아님)
        if (ret['status'] == -1351) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'))
            return true
        end

        return false
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/challenge/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('floor', 1)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_challengeModeStart
-- @brief 챌린지 모드(그림자의 신전) 게임 시작 통신
-------------------------------------
function ServerData_ChallengeMode:request_challengeModeStart(finish_cb, fail_cb)
    local func_request
    local func_success_cb
    local func_response_status_cb


    func_request = function()
        -- 유저 ID
        local uid = g_userData:get('uid')
        local token = g_stageData:makeDragonToken(DECK_CHALLENGE_MODE)

        -- 네트워크 통신
        local ui_network = UI_Network()
        ui_network:setUrl('/game/challenge/start')
        ui_network:setParam('uid', uid)
        ui_network:setParam('deck_name', DECK_CHALLENGE_MODE)
        ui_network:setParam('token', token)
        ui_network:setParam('stage', 1)
        ui_network:setParam('play_cnt', 1)
        ui_network:setParam('is_auto', true)
        ui_network:setMethod('POST')
        ui_network:setSuccessCB(func_success_cb)
        ui_network:setResponseStatusCB(response_status_cb)
        ui_network:setFailCB(fail_cb)
        ui_network:setRevocable(true)
        ui_network:setReuse(false)
        ui_network:request()
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    func_response_status_cb = function(ret)
        --[[
        if (ret['status'] == -1108) then
            -- 비슷한 티어 매칭 상대가 없는 상태
            -- 콜로세움 UI로 이동
            local function ok_cb()
                UINavigator:goTo('arena')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('현재 점수 구간 내의 대전 가능한 상대가 없습니다.\n다른 상대의 콜로세움 참여를 기다린 후에 다시 시도해 주세요.'), ok_cb)
            return true
        end
        --]]

        return false
    end

    -- 성공 콜백
    func_success_cb = function(ret)
        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)

        -- 상대방 정보 여기서 설정
        if (ret['match_user']) then
            self:makeMatchUserInfo(ret['match_user'])
        end

        self.m_gameKey = ret['gamekey']

        -- 실제 플레이 시간 로그를 위해 체크 타임 보냄
        g_accessTimeData:startCheckTimer()

        if finish_cb then
            finish_cb(ret)
        end
    end

    func_request()
end

-------------------------------------
-- function request_challengeModeFinish
-- @brief 챌린지 모드(그림자의 신전) 게임 시작 통신
-------------------------------------
function ServerData_ChallengeMode:request_challengeModeFinish(is_win, play_time, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        --[[
        -- invalid season
        if (ret['status'] == -1364) then
            -- 전투 UI로 이동
            local function ok_cb()
                UINavigator:goTo('battle_menu', 'competition')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'), ok_cb)
            return true
        end
        --]]

        return false
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/challenge/finish')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_win', is_win and 1 or 0)
    ui_network:setParam('gamekey', self.m_gameKey)

    -- 수동/자동
    --local is_auto = self.m_tempLogData['is_auto'] or false
    --ui_network:setParam('is_auto', is_auto)
    ui_network:setParam('is_auto', true)

    ui_network:setParam('stage', 1)

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end