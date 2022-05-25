-- 챌린지 모드 스테이지 난이도
CHALLENGE_MODE_DIFFICULTY = {}
CHALLENGE_MODE_DIFFICULTY.EASY = 0
CHALLENGE_MODE_DIFFICULTY.NORMAL = 1
CHALLENGE_MODE_DIFFICULTY.HARD = 2
CHALLENGE_MODE_DIFFICULTY.HELL = 3 -- 현재는 사용하지 않지만 예비용으로 추가

-- 챌린지 모드 스테이지 난이도+자동 여부 판단하는 (enum기능)테이블 필요해서 따로 생성, 값은 난이도 포인트 하드코딩
-- [WARNING] 2018-12-05 포인트 중복 고려하지 않은 상태, 지옥 난이도 포인트 임의로 설정한 상태
CHALLENGE_MODE_DIFFICULTY.EASY_AUTO = 20
CHALLENGE_MODE_DIFFICULTY.EASY_HAND = 30
CHALLENGE_MODE_DIFFICULTY.NORMAL_AUTO = 40
CHALLENGE_MODE_DIFFICULTY.NORMAL_HAND = 60
CHALLENGE_MODE_DIFFICULTY.HARD_AUTO = 80
CHALLENGE_MODE_DIFFICULTY.HARD_HAND = 100
CHALLENGE_MODE_DIFFICULTY.HELL_AUTO = 120
CHALLENGE_MODE_DIFFICULTY.HELL_HAND = 150

-------------------------------------
-- class ServerData_ChallengeMode
-- @instance g_challengeMode
-------------------------------------
ServerData_ChallengeMode = class({
        m_serverData = 'ServerData',
        m_gameKey = 'number',

        m_matchUserInfo = 'StructUserInfoArena',
		m_playerUserInfo = 'StructUserInfoArena',
        
        m_lStagesDetailInfo = 'list',
        m_lStagesInfo = 'list',
        m_lTotalPoint = 'list',
        m_lPlayInfo = 'list',
        m_lOpenInfo = 'list',
        m_lDifficultyInfo = 'list',
		
        -- 시즌 보상 획득 상태
        -- 0 -> 이번 시즌 보상 받을게 있음
        -- 1 -> 이번 시즌 보상 받음
        -- 2 -> 이번 시즌 보상 받을게 없음
        m_seasonRewardStatus = 'number',
        m_tSeasonRewardInfo = 'talbe', -- 시즌 보상을 받았을 경우
        
        -- 그림자 신전 오픈 여부
        m_isChallengeModeOpen = 'boolean',

        m_selectedStage = 'number',
        m_selectedDifficulty = 'number', -- DIFFICULTY (ConstantDifficulty.lua)
        m_selectedAuto = 'boolean',
        m_tempLogData = 'table',

        -- 랭킹 정보에 사용
        m_nGlobalOffset = 'number', -- 랭킹
        m_lGlobalRank = 'list',

        -- 테이블 정보 (관리 테이블, 시즌 보상)
        m_challengeRewardTable = 'table',
        m_challengeManageTable = 'table',


        -- 마스터 구역 관련
        m_masterStartStage = 'number', -- 해당 층 부터 마스터 구역
        
        -- 입장 자격
        m_bEnterChallengeMode = 'boolean',

        -- 스테이지 별 보상 정보
        m_tReward = 'table',

        -- 지난 콜로세움 티어 정보
        m_arenaLastTierName = 'str',

        -- 정규화에 필요한 정보
        m_isMasterMode = 'bollean',
        m_masterStartTime = 'milisecond',
        m_challengeModeEndTime = 'milisecond',
        m_challengeModeStartTime = 'milisecond',

        m_tableLastInfo = 'boolean', -- 지난 시즌 기록
    })

ServerData_ChallengeMode.STATE = {
	['INACTIVE'] = 1,	-- 이벤트 던전 비활성화
	['LOCK'] = 2,		-- 레벨 제한
	['OPEN'] = 3,		-- 이벤트 던전 입장 가능
	['REWARD'] = 4,		-- 보상 수령 가능
	['DONE'] = 5,		-- 보상 수령 후 
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_ChallengeMode:init(server_data)
    self.m_tempLogData = {}
    self.m_lStagesDetailInfo = {}
    self.m_isMasterMode = false
end

-------------------------------------
-- function isActive_challengeMode
-- @brief 챌린지 모드 이벤트가 활성화(이벤트 기간+보상 수령 기간) 상태인지 여부 true or false
-------------------------------------
function ServerData_ChallengeMode:isActive_challengeMode()
    return (self:getChallengeModeState_Routine() ~= ServerData_ChallengeMode.STATE['INACTIVE'])
end

-------------------------------------
-- function isOpen_challengeMode
-- @brief 챌린지 모드 이벤트를 플레이할 수 있는 상태인지 여부 true or false
-------------------------------------
function ServerData_ChallengeMode:isOpen_challengeMode()
    return (self:getChallengeModeState_Routine() == ServerData_ChallengeMode.STATE['OPEN'])
end

-------------------------------------
-- function getChallengeModeState
-- @brief 이벤트 그림자 신전의 상태 
-- @use ServerData_ChallengeMode.STATE
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeState()
	-- 예외처리
	if (not self.m_isChallengeModeOpen) then
		return ServerData_ChallengeMode.STATE['INACTIVE']

	-- 이벤트 기간
	elseif (g_hotTimeData:isActiveEvent('event_challenge')) then
		
		-- 레벨 체크
		if (g_contentLockData:isContentLock('challenge_mode')) then
			return ServerData_ChallengeMode.STATE['LOCK']

		else
			return ServerData_ChallengeMode.STATE['OPEN']
		end

	-- 보상 수령 기간
	elseif (g_hotTimeData:isActiveEvent('event_challenge_reward')) then
		
		-- 레벨 체크
		if (g_contentLockData:isContentLock('challenge_mode')) then
			return ServerData_ChallengeMode.STATE['LOCK']

		-- 보상 수령 전 (0 -> 이번 시즌 보상 받을게 있음)
		elseif (self.m_seasonRewardStatus == 0) then
			return ServerData_ChallengeMode.STATE['REWARD']

		-- 보상 수령 후 (1 -> 이번 시즌 보상 받음, 2 -> 이번 시즌 보상 받을게 없음)
		elseif (self.m_seasonRewardStatus == 1) or (self.m_seasonRewardStatus == 2) then
			return ServerData_ChallengeMode.STATE['DONE']

		end

	end

	-- 해당 없으면 비활성화
	return ServerData_ChallengeMode.STATE['INACTIVE']
end

-------------------------------------
-- function isChallengeModeMasterMode
-- @brief 이벤트 그림자 신전 마스터 상태 
-------------------------------------
function ServerData_ChallengeMode:isChallengeModeMasterMode()
	return self.m_isMasterMode
end

-------------------------------------
-- function getChallengeModeState_Routine
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeState_Routine()

    -- 예외처리
	if (not self.m_isChallengeModeOpen) then
		return ServerData_ChallengeMode.STATE['INACTIVE']

	-- 이벤트 기간
	else
		-- 레벨 체크
		if (g_contentLockData:isContentLock('challenge_mode')) then
			return ServerData_ChallengeMode.STATE['LOCK']
		else
			return ServerData_ChallengeMode.STATE['OPEN']
		end
	end
	-- 해당 없으면 비활성화
	return ServerData_ChallengeMode.STATE['INACTIVE']
end

-------------------------------------
-- function getPlayerArenaUserInfo
-------------------------------------
function ServerData_ChallengeMode:getPlayerArenaUserInfo()
    -- 기본 정보 생성을 위해 호출
    if (not self.m_playerUserInfo) then
        self:refresh_playerUserInfo()
    end

    -- 덱 정보는 항상 갱신
    local t_deck_data = g_deckData:getDeck_lowData(DECK_CHALLENGE_MODE)
    self.m_playerUserInfo:applyPvpDeckData(t_deck_data)

    -- 클랜 정보는 항상 갱신
    self.m_playerUserInfo:setStructClan(g_clanData:getClanStruct())

    return self.m_playerUserInfo
end

-------------------------------------
-- function refresh_playerUserInfo
-- @brief 플레이어 정보 갱신
-------------------------------------
function ServerData_ChallengeMode:refresh_playerUserInfo(t_data, l_deck)
	if (not self.m_playerUserInfo) then
		local struct_user_info = StructUserInfoArena()
    
		struct_user_info.m_uid = g_userData:get('uid')
		struct_user_info.m_lv = g_userData:get('lv')
		struct_user_info.m_nickname = g_userData:get('nick')
        struct_user_info.m_lastArenaTier = t_data and t_data['arena_last_season_tier'] or 'beginner'
		
		-- 클랜
		local struct_clan = g_clanData:getClanStruct()
		if (struct_clan) then
			struct_user_info.m_userData = struct_clan:getClanName()
		else
			struct_user_info.m_userData = ''
		end

		local t_deck_data = g_deckData:getDeck_lowData(DECK_CHALLENGE_MODE)
		struct_user_info:applyPvpDeckData(t_deck_data)

		self.m_playerUserInfo = struct_user_info
	end

    if t_data then
        local struct_user_info = self.m_playerUserInfo

        if t_data['lv'] then
            struct_user_info.m_lv = t_data['lv']
        end

        if t_data['rate'] then
            struct_user_info.m_rankPercent = t_data['rate']
        end

        if t_data['rank'] then
            struct_user_info.m_rank = t_data['rank']
        end

        if t_data['tier'] then
            struct_user_info.m_tier = t_data['tier']
        end

        if t_data['tamer'] then
            struct_user_info.m_tamerID = t_data['tamer']
        end

        if t_data['leader'] then
            struct_user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])
        end

        if t_data['rp'] then
            struct_user_info.m_rp = t_data['rp']
        end
    end

    -- 덱 설정
    if l_deck then
        self.m_playerUserInfo:applyPvpDeckData(l_deck)
    end
end

-------------------------------------
-- function makeChallengeModeStructUserInfo
-------------------------------------
function ServerData_ChallengeMode:makeChallengeModeStructUserInfo(data)
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

	-- 클랜명만 사용하는 경우 m_userData에 집어넣음
	elseif (data['clan']) then
		struct_user_info.m_userData = data['clan']

    end

    local uid = data['uid']
    return struct_user_info
end

-------------------------------------
-- function makeMatchUserInfo
-------------------------------------
function ServerData_ChallengeMode:makeMatchUserInfo(data)
    self.m_matchUserInfo = self:makeChallengeModeStructUserInfo(data)
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
-- function getChallengeModeStagePoint
-- @brief 스테이지 점수
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeStagePoint(stage)
    local point = 0

    if self.m_lTotalPoint[stage] then
        -- point = (self.m_lTotalPoint[stage] - 10000)
        -- @sgkim 2018-10-24 클리어 층 개념이 사라지면서 점수를 그대로 사용
        point = self.m_lTotalPoint[stage]
    end

    return point
end

-------------------------------------
-- function getChallengeModeVictoryModePoint
-- @brief 승리모드 별로 정렬하기 위해 스테이지 점수 반환 (잠긴 상태 9999점, 승리 없음 0점)
-- @brief (최상위)잠긴 상태 → 어려움 자동 승리→ 어려움 수동 승리 → ... →쉬움 수동 승리 → 승리 없음
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeVictoryModePoint(stage)
    local is_open = self:isOpenStage_challengeMode(stage)
    if (not is_open) then
        return 99999
    else
        return self:getChallengeModeStagePoint(stage) or 0
    end
end

-------------------------------------
-- function getChallengeModeClearStageDifficulty
-- @brief 클리어한 스테이지 난이도
-- @return number CHALLENGE_MODE_DIFFICULTY
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeClearStageDifficulty(stage)
    local difficulty = self.m_lDifficultyInfo[stage]

    -- difficulty가 nil일 경우 스테이지 클리어 하지 못한 상태
    return difficulty
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
-- function getChallengeModeStagePlayCnt
-- @brief 스테이지 플레이 횟수
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeStagePlayCnt(stage)
    local play_cnt = 0

    if self.m_lPlayInfo[stage] then
        play_cnt = self.m_lPlayInfo[stage]
    end

    return play_cnt
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
-- function setChallengeModeDifficultyInfo
-- @brief 서버에서 넘어온 데이터 가공
-------------------------------------
function ServerData_ChallengeMode:setChallengeModeDifficultyInfo(data_map)
    if (not data_map) then
        return
    end

    self.m_lDifficultyInfo = {}

    -- difficulty (CHALLENGE_MODE_DIFFICULTY)
    -- difficulty 가 nil일 경우 스테이지 클리어 하지 못한 상태
    for i,difficulty in pairs(data_map) do
        local stage = tonumber(i)
        self.m_lDifficultyInfo[stage] = difficulty
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
function ServerData_ChallengeMode:request_challengeModeInfo(stage, finish_cb, fail_cb, include_reward)
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
        if ret['difficulty_info'] then
            self:setChallengeModeDifficultyInfo(ret['difficulty_info'])
        end

        -- 플레이어 랭킹 정보 갱신
        if ret['my_info'] then
            self:refresh_playerUserInfo(ret['my_info'], nil)
        end

		-- 보상 수령 여부 저장
		if (ret['reward']) then
			self.m_seasonRewardStatus = ret['reward']
		end

        -- 챌린지 모드 시즌 보상 정보
        if ret['table_challenge_rank'] then
            self.m_challengeRewardTable = ret['table_challenge_rank']
        end

        -- 챌린지 모드 관리 테이블
        if ret['table_challenge_management'] then
            self.m_challengeManageTable = ret['table_challenge_management']
        end

        -- 시즌 보상 정보 저장
        if ret['reward_info'] and (0 < table.count(ret['reward_info'])) then
            self.m_tSeasonRewardInfo = ret['reward_info']
        end

        if (ret['lastinfo']) then
            self.m_tableLastInfo = ret['lastinfo']
        else
            self.m_tableLastInfo = nil
        end
        
        -- 입장 가능 여부 저장
        if ret['available'] then
            self.m_bEnterChallengeMode = ret['available']
        end

        -- 그림자 신전 오픈 여부
        if ret['open'] then
            self.m_isChallengeModeOpen = ret['open']
        end

        if (ret['table_challenge_management']) then
            self:applyManageData(ret['table_challenge_management'])
        end

        if (ret['arena_last_season_tier']) then
            self.m_arenaLastTierName = ret['arena_last_season_tier']
        end

        if (ret['master_start_time']) then
            self.m_masterStartTime = ret['master_start_time']
        end
        
        if (ret['master_open']) then
            self.m_isMasterMode = ret['master_open']
        end
        
        if (ret['end_time']) then
            self.m_challengeModeEndTime = ret['end_time']
        end
        
        if (ret['start_time']) then
            self.m_challengeModeStartTime = ret['start_time']
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

        -- -1364 invalid season
        elseif (ret['status'] == -1364) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'))
            return true
        end

        return false
    end

    -- 서버에서 stages_info를 매번 호출하면 부하가 있기때문에 데이터가 있으면 중복으로 받지 않게 처리
    local include_infos = true
    if self.m_lStagesInfo and (0 < table.count(self.m_lStagesInfo)) then
        include_infos = false
    end

    -- 서버에서 테이블 정보를 받아옴
    local include_tables = false
    if (self.m_challengeRewardTable == nil) or (self.m_challengeManageTable == nil) then
        include_tables = true
    end
    
    -- 시즌 보상을 받을지 여부 (타이틀 화면에서 정보 요청을 위해 호출될때는 제외하기 위함)
    local include_reward = (include_reward or false)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/challenge/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('floor', stage)
    ui_network:setParam('include_infos', include_infos)
    ui_network:setParam('include_tables', include_tables)
    ui_network:setParam('reward', include_reward) -- true면 시즌 보상을 지금, false면 시즌 보상을 미지급
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_challengeModeStageDetailInfo
-- @brief 챌린지 모드(그림자의 신전) stage별 상세 정보 요청
-------------------------------------
function ServerData_ChallengeMode:request_challengeModeStageDetailInfo(stage, finish_cb, fail_cb)
    -- 데이터가 존재하면 그대로 리턴
    if (self.m_lStagesDetailInfo[stage]) then
        finish_cb()
        return
    end

    -- 성공 콜백
    local function success_cb(ret)
        self.m_lStagesDetailInfo[stage] = ret['stage_info'] 

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        return false
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/challenge/stage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage)
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
    local diff = g_challengeMode:getSelectedDifficulty()
    local stage = self.m_selectedStage
    func_request = function()
        -- 유저 ID
        local uid = g_userData:get('uid')
        local token = g_stageData:makeDragonToken(DECK_CHALLENGE_MODE)

        -- 네트워크 통신
        local ui_network = UI_Network()
        ui_network:setUrl('/game/challenge/start')
        ui_network:setParam('uid', uid)
        ui_network:setParam('difficulty', diff)
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
    local difficulty = self.m_selectedDifficulty

    -- 성공 콜백
    local function success_cb(ret)
        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        if (is_win == true) then
            self:setSelectedStage(self.m_selectedStage + 1)
        end

		-- 점수 갱신
		if (ret['point']) then
			self.m_lTotalPoint[stage] = ret['point']
		end

		-- open info 갱신
		local is_open_next_team = self:isOpenNextTeam(stage, is_win)
		if (is_open_next_team) then
			self.m_lOpenInfo[stage + 1] = 1
		end

        if finish_cb then
            finish_cb(ret, stage, is_open_next_team)
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
    ui_network:setParam('difficulty', difficulty)

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
-- function resetSelectedStage
-- @brief
-------------------------------------
function ServerData_ChallengeMode:resetSelectedStage()
    self.m_selectedStage = nil
end

-------------------------------------
-- function getSelectedDifficulty
-- @brief
-------------------------------------
function ServerData_ChallengeMode:getSelectedDifficulty()
    if (not self.m_selectedDifficulty) then
        return DIFFICULTY.NORMAL
    end

    return self.m_selectedDifficulty
end

-------------------------------------
-- function setSelectedDifficulty
-- @brief
-------------------------------------
function ServerData_ChallengeMode:setSelectedDifficulty(difficulty, is_auto)
    self.m_selectedDifficulty = difficulty

    if (is_auto ~= nil) then
        self.m_selectedAuto = is_auto
    end
end

-------------------------------------
-- function resetSelectedDifficulty
-- @brief
-------------------------------------
function ServerData_ChallengeMode:resetSelectedDifficulty()
    self.m_selectedDifficulty = nil
end

-------------------------------------
-- function getTopStage
-- @brief 100층을 조정하진 않는걸로 했으니 조정하게 되면 수정!
-------------------------------------
function ServerData_ChallengeMode:getTopStage()
    return 100
end

-------------------------------------
-- function isOpenStage_challengeMode
-- @breif 스테이지 오픈 여부
-------------------------------------
function ServerData_ChallengeMode:isOpenStage_challengeMode(stage)
    -- 1스테이지는 항상 오픈
    if (stage <= 1) then
        return true
    end

    -- 가장 높은 층보다 높을 경우
	if (stage > self:getTopStage()) then
		return false
	end

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

-------------------------------------
-- function isOpenNextTeam
-- @breif 다음 팀이 열렸는지?
-------------------------------------
function ServerData_ChallengeMode:isOpenNextTeam(stage, is_win)
	local is_open = false
		
	-- 1위팀 클리어한 경우 항상 false
	if (stage >= self:getTopStage()) then
		
	-- 다음 스테이지 오픈 안되어 있는 상황에서
	elseif (not self:isOpenStage_challengeMode(stage + 1)) then
		-- 승리
		if (is_win) then
			is_open = true
		-- 1회 이상 도전 (@sgkim 2018-10-23 3회에서 1회로 변경)
        --elseif (self:getChallengeModeStagePlayCnt(stage) + 1 >= 3) then
		elseif (self:getChallengeModeStagePlayCnt(stage) + 1 >= 1) then
			is_open = true
		end
	end

	return is_open
end

-------------------------------------
-- function getLastChallengeTeam
-- @breif 도전해야할 가장 최상위 팀
-------------------------------------
function ServerData_ChallengeMode:getLastChallengeTeam()
	local ret = 1
	for stage, _ in pairs(self.m_lOpenInfo) do
		if (ret < stage) then
			ret = stage
		end
	end
	local top = self:getTopStage()
	local team = (top - ret + 1)
    local bottom = 1

    -- 마스터 시즌이 아니라면
    if (not g_challengeMode:isChallengeModeMasterMode()) then
        bottom = self:getMasterStage()
    end

	return math_clamp(team, bottom, top)
end

-------------------------------------
-- function getChallengeMode_StageDetailInfo
-- @breif 스테이지 상세 정보
-------------------------------------
function ServerData_ChallengeMode:getChallengeMode_StageDetailInfo(stage)
    return self.m_lStagesDetailInfo[stage]
end


-------------------------------------
-- function getChallengeMode_StageInfo
-- @breif 스테이지 정보
-------------------------------------
function ServerData_ChallengeMode:getChallengeMode_StageInfo(stage)
    return self.m_lStagesInfo[stage]
end

-------------------------------------
-- function getChallengeMode_staminaCost
-- @breif 그림자 신전 플레이에 필요한 날개 갯수
-------------------------------------
function ServerData_ChallengeMode:getChallengeMode_staminaCost(stage)
    
    local is_master = self:isMasterStage(100-stage)
    if (is_master) then
        return self.m_challengeManageTable['cost_value_master'] or 20 -- 테이블 값 하드 코딩
    else
        return self.m_challengeManageTable['cost_value'] or 10 -- 테이블 값 하드 코딩
    end

    --[[
    local play_cnt = self:getChallengeModeStagePlayCnt(stage)

    local cost_value = 5
    local cost_delta = 5
    local cost_maximum = 50

    -- @sgkim 2018-10-23 그림자의 신전 개편으로 모든 스테이지에서 10개로 고정
    cost_value = 10
    cost_delta = 0
    cost_maximum = 10

    local stamina = cost_value + (play_cnt * cost_delta)
    stamina = math_min(stamina, cost_maximum)

    return stamina
    --]]
end

-------------------------------------
-- function getChallengeModeStatusText
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeStatusText()
    local time = self:getChallengeModeRemainTime()
    local str = ''

    if (not self:isOpen_challengeMode()) then
        local remain_time = 0
        if (self.m_challengeModeStartTime) then
            local start_time = self.m_challengeModeStartTime
            local cur_time = ServerTime:getInstance():getCurrentTimestampSeconds()
            remain_time = (start_time/1000) - cur_time
        end
        if (remain_time > 0) then
            str = Str('다음 시즌 오픈까지 {1}', ServerTime:getInstance():makeTimeDescToSec(remain_time, true))
        else
            str = Str('오픈시간이 아닙니다.')
        end

    elseif (0 < time) then
        str = Str('시즌 종료까지') ..' '.. Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true)) -- param : sec, showSeconds, firstOnly, timeOnly

    else
        str = Str('종료되었습니다.')
    end

    return str
end

-------------------------------------
-- function getChallengeModeMasterStatusText
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeMasterStatusText()
    local time = self.m_masterStartTime or 0
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local end_time = tonumber(time)/1000
    time = (end_time - curr_time)
    return time
end

-------------------------------------
-- function getChallengeModeRemainTime
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeRemainTime()
    local time = self.m_challengeModeEndTime or 0
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local end_time = tonumber(time)/1000
    time = (end_time - curr_time)
    return time
end

-------------------------------------
-- function request_challengeModeRanking
-- @brief 챌린지 모드(그림자의 신전) 랭킹 통신
-------------------------------------
function ServerData_ChallengeMode:request_challengeModeRanking(rank_type, offset, finish_cb, fail_cb)
    local func_request
    local func_success_cb
    local func_response_status_cb

    func_request = function()
        -- 유저 ID
        local uid = g_userData:get('uid')

        -- 네트워크 통신
        local ui_network = UI_Network()
        ui_network:setUrl('/game/challenge/ranking')
        ui_network:setParam('uid', uid)
        ui_network:setParam('type', rank_type)
        ui_network:setParam('offset', offset)
        ui_network:setParam('limit', 30)
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
        return false
    end

    -- 성공 콜백
    func_success_cb = function(ret)
        self.m_nGlobalOffset = ret['offset']

        -- 유저 리스트 저장
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            local user_info = StructUserInfoArena:create_forRanking(v)
            table.insert(self.m_lGlobalRank, user_info)
        end

        -- 플레이어 랭킹 정보 갱신
        if ret['my_info'] then
            self:refresh_playerUserInfo(ret['my_info'], nil)
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    func_request()
end

-------------------------------------
-- function getChallengeModeClearPoint
-- @brief 난이도, 자동 전투 여부에 따른 클리어 점수 리턴
--        (변경의 여지가 거의 없어서 서버와 클라이언트 모두 하드코딩으로 처리함)
-- @return number
-------------------------------------
function ServerData_ChallengeMode:getChallengeModeClearPoint(difficulty, is_auto)
    local point = 0

    -- 쉬움
    if (difficulty == CHALLENGE_MODE_DIFFICULTY.EASY) then
        point = conditionalOperator(is_auto, 30, 20)

    -- 보통
    elseif (difficulty == CHALLENGE_MODE_DIFFICULTY.NORMAL) then
        point = conditionalOperator(is_auto, 60, 40)

    -- 어려움
    elseif (difficulty == CHALLENGE_MODE_DIFFICULTY.HARD) then
        point = conditionalOperator(is_auto, 100, 80)
    
    -- 지옥
    elseif (difficulty == CHALLENGE_MODE_DIFFICULTY.HELL) then
        point = conditionalOperator(is_auto, 150, 120)

    else
        error('difficulty : ' .. tostring(difficulty))
    end

    return point
end

-------------------------------------
-- function parseChallengeModeStagePoint
-- @brief 스테이지 점수로 난이도, 자동 전투 여부
--        하드코딩
-------------------------------------
function ServerData_ChallengeMode:parseChallengeModeStagePoint(point)
    local difficulty = nil
    local is_auto = nil
    local text = nil 

    if (point == 0) then
        difficulty = nil
        is_auto = false
        text = Str('기록 없음')

    -- 쉬움
    elseif (point == 20) then
        difficulty = DIFFICULTY.EASY
        is_auto = false
        text = Str('쉬움 (수동)')

    elseif (point == 30) then
        difficulty = DIFFICULTY.EASY
        is_auto = true
        text = Str('쉬움 (자동)')

    -- 보통
    elseif (point == 40) then
        difficulty = DIFFICULTY.NORMAL
        is_auto = false
        text = Str('보통 (수동)')

    elseif (point == 60) then
        difficulty = DIFFICULTY.NORMAL
        is_auto = true
        text = Str('보통 (자동)')

    -- 어려움
    elseif (point == 80) then
        difficulty = DIFFICULTY.HARD
        is_auto = false
        text = Str('어려움 (수동)')

    elseif (point == 100) then
        difficulty = DIFFICULTY.HARD
        is_auto = true
        text = Str('어려움 (자동)')

    -- 지옥
    elseif (point == 120) then
        difficulty = DIFFICULTY.HELL
        is_auto = false
        text = Str('지옥 (수동)')
    elseif (point == 150) then
        difficulty = DIFFICULTY.HELL
        is_auto = true
        text = Str('지옥 (자동)')
    end

    return difficulty, is_auto, text
end

-------------------------------------
-- function getRecommandDifficulty
-- @brief 추천 난이도
-------------------------------------
function ServerData_ChallengeMode:getRecommandDifficulty(stage)
    
    -- 1회도 플레이 하지 않았을 경우 보통 추천
    local play_cnt = self:getChallengeModeStagePlayCnt(stage)
    if (play_cnt <= 0) then
        return DIFFICULTY.NORMAL, false
    end
    
    local point = self:getChallengeModeStagePoint(stage)
    local difficulty, is_auto = self:parseChallengeModeStagePoint(point)

    -- 클리어 난이도가 없는 경우 쉬움 추천
    if (not difficulty) then
        return DIFFICULTY.EASY, false
    end

    -- 자동전투로 클리어 하지 않은 경우 현재 난이도 추천
    if (is_auto == false) then
        return difficulty, true
    end

    -- 마스터 층 아래에는 HELL이 없음
    local limit_difficulty = DIFFICULTY.HARD
    if (100 - self:getMasterStage() < stage) then
        limit_difficulty = DIFFICULTY.HELL
    end
    
    -- 자동 전투로 클리어 했을 경우 다음 난이도 추천
    if (is_auto == true) then
        local next_difficulty = (difficulty + 1)
        
        if (limit_difficulty < next_difficulty) then
            return limit_difficulty, true
        else
            return next_difficulty, false
        end
    end
end


-------------------------------------
-- function getCumulativeGold
-- @brief 도전 보상, 승리 보상 누적 골드
-------------------------------------
function ServerData_ChallengeMode:getCumulativeGold()
    local cumulative_gold = 0
    for stage=1, 100 do
        -- 도전 보상 (1회 이상 플레이)
        if (0 < self:getChallengeModeStagePlayCnt(stage)) then
            cumulative_gold = (cumulative_gold + 20000)
        end

        -- 승리 보상
        if self:isClearStage_challengeMode(stage) then
            cumulative_gold = (cumulative_gold + 80000)
        end
    end

    return cumulative_gold
end

-------------------------------------
-- function getCumulativeGrindStone
-- @brief 누적 연마석
-------------------------------------
function ServerData_ChallengeMode:getCumulativeGrindStone()
    local cumulative_gold = 0
    for stage=1, 60 do
        -- 승리 보상
        if self:isClearStage_challengeMode(stage) then
            cumulative_gold = (cumulative_gold + 1)
        end
    end

    return cumulative_gold
end

-------------------------------------
-- function applyManageData
-------------------------------------
function ServerData_ChallengeMode:applyManageData(t_manage_data)
    self.m_tReward = {} 
    for i,v in ipairs(t_manage_data) do
        if (v['table']['use'] == 'stage_clear_reward' or v['table']['use'] == 'stage_clear_reward_master') then
            self.m_tReward[v['table']['use']] = v['table']['value']          
        elseif (v['table']['use'] == 'master_stage_limit') then
            self.m_masterStartStage = v['table']['value']
        end
    end
end

-------------------------------------
-- function getRewardList
-------------------------------------
function ServerData_ChallengeMode:getRewardList(reward_type)
    if (reward_type == 'clear_reward') then
        return self.m_tReward['stage_clear_reward']
    elseif (reward_type == 'clear_reward_master') then
        return self.m_tReward['stage_clear_reward_master']
    end
end

-------------------------------------
-- function getMasterStage
-------------------------------------
function ServerData_ChallengeMode:getMasterStage()
    if (not self.m_masterStartStage) then
        return 40 -- 서버 값이 오지 않을 경우 노출되는 것을 막기 위해 하드코딩
    end
    
    return tonumber(self.m_masterStartStage)
end

-------------------------------------
-- function isMasterStage
-------------------------------------
function ServerData_ChallengeMode:isMasterStage(stage)
    local master_stage = self:getMasterStage()
    if (stage < master_stage) then
        return true
    end
    
    return false
end

-------------------------------------
-- function isVictoryAllStage
-- @brief 난이도 상관없이 모든 스테이지에서 승리했는지 체크
-------------------------------------
function ServerData_ChallengeMode:isVictoryAllStage()
    local max_stage = 100 --2018.12.20 그림자 신전 스테이지 총 갯수

    for stage = 1, max_stage do
        local point = self:getChallengeModeStagePoint(stage)
        if (point == 0) then
            return false
        end
    end
    return true
end

-------------------------------------
-- function checkPromotePopupCondition
-- @brief 그림자 신전 입장 권유 팝업 조건 체크
-------------------------------------
function ServerData_ChallengeMode:checkPromotePopupCondition()
    -- 0. 그림자 신전 이벤트 중인가
	-- 1. 그림자 신전 레벨 조건 확인
    -- 2. 오픈 이후 3일 이상 입장x, 마지막으로 입장 후 3일이상 입장x
    -- 3. 1일 1회만 표시
    -- 4. 모든 스테이지를 승리한 유저에게는 표시x

    local cur_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    
    -- 0. 그림자 신전 이벤트 중인가
    if (not self:isOpen_challengeMode()) then
        -- 이벤트 기간이 아니라면 관련 데이터 초기화
        -- g_settingData:resetChallengeSettingData()
        return false
    end

    -- 1. 레벨 체크
	if (g_contentLockData:isContentLock('challenge_mode')) then
        return false
    end

    -- 2. 오픈 이후 3일 이상 입장x, 마지막으로 입장 후 3일이상 입장x
    do  
        local cur_day = math.floor(datetime.secondToDay(cur_time))
        local last_entry_day = 0--g_settingData:getChellengeModeLastEntry()

        -- 그림자 신전 입장을 아예 안한 상태 제외
        if (last_entry_day == 0) then
            return false
        end

        if (cur_day - last_entry_day < 3) then
            return false
        end
    end

    -- 3. 1일 1회만 표시
    local popup_expired = g_settingData:getPromoteExpired('challenge_mode')
    if (cur_time < popup_expired) then
        return false
    end

    -- 4. 모든 스테이지를 승리한 유저에게는 표시x
    if (self:isVictoryAllStage()) then
        return false
    end
    
    return true
end

-------------------------------------
-- function getUserCanEnterChallengeMode
-- @brief 유저의 입장 자격
-------------------------------------
function ServerData_ChallengeMode:getUserCanEnterChallengeMode()
    return self.m_bEnterChallengeMode
end

-------------------------------------
-- function getLastArenaTierName
-- @brief 지난 콜로세움 티어 아이디
-------------------------------------
function ServerData_ChallengeMode:getLastArenaTierName()
    return self.m_arenaLastTierName
end

-------------------------------------
-- function getUserServer
-------------------------------------
function ServerData_ChallengeMode:getUserServer(uid, is_color)
    local server_str = plSplit(uid, '@') -- 'qewdf_dfs@America' 를 qewdf_dfs 와 America로 분리
    local server_color = '{@server_name}'

    if (not server_str[1]) then
        server_str = "<KOR>"
    else
        if (server_str[2] == 'America') then
            server_str = "<USA>"
        elseif (server_str[2] == 'Japan') then
            server_str = "<JPN>"
        elseif(server_str[2] == 'Asia') then
            server_str = "<ASIA>"
        else
            server_str = "<KOR>"
        end
    end
    if (is_color) then
        server_str = server_color .. server_str
    end
    return server_str
end

-------------------------------------
-- function setInfoForLobby
-------------------------------------
function ServerData_ChallengeMode:setInfoForLobby(ret)
    if (ret['start_time']) then
        self.m_challengeModeStartTime = ret['start_time']
    end
    
    if (ret['end_time']) then
        self.m_challengeModeEndTime = ret['end_time']
    end

    if ret['open_info'] then
        self:setChallengeModeOpenInfo(ret['open_info'])
    end
    
    if ret['master_open'] then
        self.m_isMasterMode = ret['master_open']
    end

    if (ret['open']) then
        self.m_isChallengeModeOpen = ret['open']
    end

    if (ret['lastinfo']) then
        self.m_tableLastInfo = ret['lastinfo']
    else
        self.m_tableLastInfo = nil
    end

    -- 시즌 보상 정보 저장
    if ret['reward_info'] and (0 < table.count(ret['reward_info'])) then
        self.m_tSeasonRewardInfo = ret['reward_info']
    end
end