-------------------------------------
-- class ServerData_ChallengeMode
-------------------------------------
ServerData_ChallengeMode = class({
        m_serverData = 'ServerData',
        m_gameKey = 'number',
        m_matchUserInfo = 'StructUserInfoArena',
        
        m_lStagesInfo = 'list',
        m_lTotalPoint = 'list',
        m_lPlayInfo = 'list',
        m_lOpenInfo = 'list',

        m_selectedStage = 'number',
        m_tempLogData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ChallengeMode:init(server_data)
    self.m_tempLogData = {}
end


-------------------------------------
-- function isActive_challengeMode
-- @brief 챌린지 모드 이벤트가 진행 중인지 여부 true or false
-------------------------------------
function ServerData_ChallengeMode:isActive_challengeMode()
    if (not g_hotTimeData) then
        return false
    end
    
    if (not g_hotTimeData:isActiveEvent('event_challenge')) then
        return false
    end

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
-- function setChallengeModeStagesInfo
-- @brief 서버에서 넘어온 데이터 가공
-------------------------------------
function ServerData_ChallengeMode:setChallengeModeStagesInfo(t_stages_info)
    self.m_lStagesInfo = {}

    for i,v in pairs(t_stages_info) do
        local stage = tonumber(i)
        v['stage'] = stage
        self.m_lStagesInfo[stage] = v
    end
end

-------------------------------------
-- function setChallengeModeTotalPoint
-- @brief 서버에서 넘어온 데이터 가공
-------------------------------------
function ServerData_ChallengeMode:setChallengeModeTotalPoint(data_map)
    self.m_lTotalPoint = {}

    for i,v in pairs(data_map) do
        local stage = tonumber(i)
        self.m_lTotalPoint[stage] = v
    end
end

-------------------------------------
-- function setChallengeModePlayInfo
-- @brief 서버에서 넘어온 데이터 가공
-------------------------------------
function ServerData_ChallengeMode:setChallengeModePlayInfo(data_map)
    self.m_lPlayInfo = {}

    for i,v in pairs(data_map) do
        local stage = tonumber(i)
        self.m_lPlayInfo[stage] = v
    end
end

-------------------------------------
-- function setChallengeModeOpenInfo
-- @brief 서버에서 넘어온 데이터 가공
-------------------------------------
function ServerData_ChallengeMode:setChallengeModeOpenInfo(data_map)
    self.m_lOpenInfo = {}

    for i,v in pairs(data_map) do
        local stage = tonumber(i)
        self.m_lOpenInfo[stage] = v
    end
end


-------------------------------------
-- function getChallengeModeStagesInfo
-- @brief
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeStagesInfo()

    --{
    --  "clan":"소녀",
    --  "uid":"4hsvml8fjkaY43u6pdQh9M4uhPq1",
    --  "nick":"1민2강",
    --  "leader":"120655;60;0;0;4;0;3;6;5;5;1;1;3;9;0;225;13500;225;0;711215:15:2:atk_add|440:atk_multi|8:avoid_add|2:def_add|10:hp_add|580:cri_dmg_add|3;710226:15:1:atk_multi|46:resistance_add|3:avoid_add|4:aspd_add|2:hp_multi|4:def_add|5;710236:12:4:def_add|360:cri_dmg_add|8:hit_rate_add|1:atk_add|8:atk_multi|6:avoid_add|5;710246:15:2:cri_chance_add|46::avoid_add|6:def_multi|5:hp_add|226:accuracy_add|3;710256:15:2:hp_add|34440::cri_chance_add|8:hit_rate_add|3:atk_multi|3:cri_dmg_add|4;711266:15:3:hp_multi|46::atk_multi|10:resistance_add|3:cri_dmg_add|3:hit_rate_add|2",
    --  "rank":61,
    --  "deck":{
    --    "formationlv":41,
    --    "tamer":110002,
    --    "tamerInfo":{
    --      "skill_lv4":47,
    --      "tid":110002,
    --      "skill_lv3":50,
    --      "skill_lv2":50,
    --      "costume":730200,
    --      "skill_lv1":50
    --    },
    --    "deck":{
    --      "4":"5a2d574f91bcb66c04a8f9cd",
    --      "1":"5ac5e9ab91bcb66dbc0c7c7c",
    --      "5":"5ac9b1b7f6608a5f319ada07",
    --      "2":"5b640551f6608a691664d956",
    --      "3":"5b6c248091bcb613c143f3df"
    --    },
    --    "formation":"defence",
    --    "leader":5,
    --    "deckName":"arena"
    --  }

    return self.m_lStagesInfo
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

        -- 스테이지 정보
        if ret['stages_info'] then
            self:setChallengeModeStagesInfo(ret['stages_info'])
        end
        if ret['total_point'] then
            self:setChallengeModeTotalPoint(ret['total_point'])
        end
        if ret['play_info'] then
            self:setChallengeModePlayInfo(ret['play_info'])
        end
        if ret['open_info'] then
            self:setChallengeModeOpenInfo(ret['open_info'])
        end

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

    local stage = self.m_selectedStage

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
        ui_network:setParam('stage', stage)
        ui_network:setParam('is_auto', true) -- 3회 미만에서는 자동으로만 해야하는 조건이 있어서 서버에서 체크함(클라는 시점이 안맞아서 그냥 true로 던짐)
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
    local stage = self.m_selectedStage

    -- 성공 콜백
    local function success_cb(ret)
        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        if (is_win == true) then
            self:setSelectedStage(self.m_selectedStage + 1)
        end

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
    local is_auto = self.m_tempLogData['is_auto'] or false
    ui_network:setParam('is_auto', is_auto)

    ui_network:setParam('stage', stage)

    -- 통신 후에는 삭제
    self.m_tempLogData = {}

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getSelectedStage
-- @brief
-------------------------------------
function ServerData_ChallengeMode:getSelectedStage()
    if (not self.m_selectedStage) then
        local max = nil
        for i,v in pairs(self.m_lOpenInfo) do
            if (not max) or (max < i) then
                max = i
            end
        end
        self.m_selectedStage = max
    end

    return self.m_selectedStage or 1
end

-------------------------------------
-- function setSelectedStage
-- @brief
-------------------------------------
function ServerData_ChallengeMode:setSelectedStage(stage)
    self.m_selectedStage = math_clamp(stage, 1, 100)
end

-------------------------------------
-- function isOpenStage_challengeMode
-- @breif 스테이지 오픈 여부
-------------------------------------
function ServerData_ChallengeMode:isOpenStage_challengeMode(stage)
    if self.m_lOpenInfo[stage] then
        if (self.m_lOpenInfo[stage] == 1) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function isClearStage_challengeMode
-- @breif 스테이지 클리어 여부
-------------------------------------
function ServerData_ChallengeMode:isClearStage_challengeMode(stage)

    -- 점수 데이터에 점수가 있으면 클리어로 간주
    if self.m_lTotalPoint[stage] then
        if (self.m_lTotalPoint[stage] > 0) then
            return true
        end
    end

    return false
end