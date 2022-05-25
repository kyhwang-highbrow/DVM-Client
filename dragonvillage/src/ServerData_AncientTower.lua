ANCIENT_TOWER_STAGE_ID_START = 1401000
ANCIENT_TOWER_STAGE_ID_FINISH = 1401050

ANCIENT_TOWER_MAX_DEBUFF_LEVEL = 5

-------------------------------------
-- class ServerData_AncientTower
-------------------------------------
ServerData_AncientTower = class({
        m_serverData = 'ServerData',

        m_challengingInfo = 'StructAncientTowerFloorData',
        m_challengingStageID = 'number', -- 현재 진행중인 층의 스테이지 아이디
        m_clearStageID = 'number', -- 최종 클리어한 층의 스테이지 아이디

        m_challengingFloor = 'number', -- 현재 진행중인 층    
        m_challengingCount = 'number', -- 도전 횟수
        m_clearFloor = 'number', -- 최종 클리어한 층

        m_lStage = 'table',
        m_nStage = 'number',

        m_startTime = 'number', -- 시즌 시작 시간
        m_endTime = 'number', -- 시즌 종료 시간

        m_nGlobalOffset = 'number',
        m_lGlobalRank = 'list', -- 전체 랭킹 정보

        m_playerUserInfo = 'StructUserInfoAncientTower', -- 내 랭킹 정보

        
        m_nTotalRank = 'number', -- 시즌 내 순위
        m_nTotalRate = 'number', 
        m_nTotalScore = 'number', -- 시즌 내 총점수

        m_tSeasonRewardInfo = 'table', -- 시즌 보상 정보
        m_tClanRewardInfo = 'table', -- 클랜 보상 정보

        m_bOpen = 'booelan',
		m_stageIdInAuto = 'number', -- 연속 전투 중, 스테이지 아이디 기록

        m_rewardTable = 'table', -- 보상 테이블
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AncientTower:init(server_data)
    self.m_serverData = server_data
    self.m_lStage = nil
    self.m_nStage = 0
    self.m_bOpen = true
	self.m_startTime = 0
	self.m_endTime = 0
    self.m_nTotalRank = 0
end

-------------------------------------
-- function getNextStageID
-- @brief
-------------------------------------
function ServerData_AncientTower:getNextStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id + 1)

    if t_drop then
        local next_stage = stage_id + 1
        next_stage = (next_stage > ANCIENT_TOWER_STAGE_ID_FINISH) and ANCIENT_TOWER_STAGE_ID_FINISH or next_stage
        return next_stage
    else
        return stage_id
    end
end

-------------------------------------
-- function getSimplePrevStageID
-- @brief
-------------------------------------
function ServerData_AncientTower:getSimplePrevStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id - 1)

    if t_drop then
        return stage_id - 1
    else
        return stage_id
    end
end

-------------------------------------
-- function getStageName
-------------------------------------
function ServerData_AncientTower:getStageName(stage_id)
    local floor = self:getFloorFromStageID(stage_id)

    local name = Str('고대의 탑 {1}층', floor)
    return name
end

-------------------------------------
-- function setClearStage
-------------------------------------
function ServerData_AncientTower:setClearStage(stage_id)
	self.m_clearStageID = stage_id
	self.m_clearFloor = (stage_id % ANCIENT_TOWER_STAGE_ID_START)
end

-------------------------------------
-- function setInfoForLobby
-------------------------------------
function ServerData_AncientTower:setInfoForLobby(t_info)
	self:setClearStage(t_info['ancient_clear_stage'])
	self.m_bOpen = t_info['open']
	self.m_startTime = t_info['start_time']
	self.m_endTime = t_info['end_time']
end

-------------------------------------
-- function getClearFloor
-------------------------------------
function ServerData_AncientTower:getClearFloor()
	return self.m_clearFloor
end

-------------------------------------
-- function isAncientTowerStage
-------------------------------------
function ServerData_AncientTower:isAncientTowerStage(stage_id)
    if (stage_id > ANCIENT_TOWER_STAGE_ID_START) and (stage_id <= ANCIENT_TOWER_STAGE_ID_FINISH) then
        return true
    end
    return false
end

-------------------------------------
-- function goToAncientTowerScene
-------------------------------------
function ServerData_AncientTower:goToAncientTowerScene(use_scene, stage_id)
    local function finish_cb()
        if use_scene then
            local function close_cb()
                SceneLobby():runScene()
            end
            local scene = SceneCommon(UI_AncientTower, close_cb)
            scene:runScene()
        else
            local ui = UI_AncientTower()
        end        
    end    
    self:request_ancientTowerInfo(stage_id, finish_cb, fail_cb)
end

-------------------------------------
-- function request_ancientTowerInfo
-------------------------------------
function ServerData_AncientTower:request_ancientTowerInfo(stage, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 현재 게임모드는 스테이지 아이디로 구분하고 있는데 시험의 탑은 고대의 탑 스테이지를 그대로 씀.
    -- 시험의 탑 진행중인지 선택된 속성으로 구분하므로 여기서 반드시 nil 처리 해줘야 함!
    g_attrTowerData:setSelAttr(nil)

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        
        local t_challenging_info = ret['ancient_stage']

        self.m_challengingInfo = StructAncientTowerFloorData(t_challenging_info)
        self.m_challengingStageID = t_challenging_info['stage']
		self.m_stageIdInAuto = self.m_challengingStageID
        self.m_challengingFloor = (self.m_challengingStageID % ANCIENT_TOWER_STAGE_ID_START)

        self:setClearStage(ret['ancient_clear_stage'])

        self.m_challengingCount = t_challenging_info['fail_cnt']
        self.m_startTime = ret['start_time']
        self.m_endTime = ret['end_time']

        self.m_nTotalRank = ret['myrank']
        self.m_nTotalRate= ret['myrate']
        self.m_nTotalScore = ret['total_score']

        self.m_bOpen = ret['open']

        -- 시즌 보상
        self:setRewardInfo(ret)

        if (not self.m_lStage) then
            self.m_lStage = self:makeAcientTower_stageList()
            self.m_nStage = table.count(self.m_lStage)
        end

         if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/ancient/info')
    ui_network:setParam('uid', uid)
    if (stage) then
        ui_network:setParam('stage', stage)
    end
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_ancientTowerRank
-------------------------------------
function ServerData_AncientTower:request_ancientTowerRank(offset, finish_cb, rank_type)
    -- 파라미터
    local uid = g_userData:get('uid')
    local offset = offset or 0

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        self.m_playerUserInfo = StructUserInfoAncientTower:create_forRanking(ret['my_info'])

        self.m_nGlobalOffset = ret['offset']
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            local user_info = StructUserInfoAncientTower:create_forRanking(v)
            table.insert(self.m_lGlobalRank, user_info)
        end
        
        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/ancient/rank')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', rank_type)
    ui_network:setParam('offset', offset)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_ancientTowerSeasonRankInfo
-- @brief 시즌 보상은 바뀜. 서버에서 보상 정보 받아옴
-------------------------------------
function ServerData_AncientTower:request_ancientTowerSeasonRankInfo(finish_cb)
     -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
         self.m_rewardTable = ret['table_ancient_rank']
         if finish_cb then
            return finish_cb()
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/ancient/table')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function requestAllAncientScore
-------------------------------------
function ServerData_AncientTower:requestAllAncientScore(finish_cb)
    --[[
         "status":0,
         "ancient_clear_stage":1401006,
         "message":"success",
         "open":true,
         "start_time":1553734800000,
         "end_time":1554908400000,
         "server_info":{
           "midnight":1554217200000,
           "hour":9,
           "timezone":"Asia/Seoul",
           "server_time":1554186268397
         },
         "myrate":0.40000000596046,
         "myrank":2,
         "total_score":21521,
         "season":201913,
         "ancient_stage_all":{
           "1401018":{
             "stage":1401018,
             "score":0,
             "fail_cnt":0,
             "topuser_score":0,
             "hiscore":0
           },
           "1401045":{
             "stage":1401045,
             "score":0,
             "fail_cnt":0,
             "topuser_score":0,
             "hiscore":0
           },
           "1401044":{
             "stage":1401044,
             "score":0,
             "fail_cnt":0,
             "topuser_score":0,
             "hiscore":0
           },
    --]]
    
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
         if finish_cb then
            return finish_cb(ret['ancient_stage_all'])
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/ancient/info_all')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end


-------------------------------------
-- function makeAcientTower_stageList
-------------------------------------
function ServerData_AncientTower:makeAcientTower_stageList()
    local table_drop = TableDrop()

    local function condition_func(t_table)
        local stage_id = t_table['stage']
        local game_mode = g_stageData:getGameMode(stage_id)

        if (game_mode ~= GAME_MODE_ANCIENT_TOWER) then
            return false
        end

        -- 고대의탑 시험의탑 스테이지 구분하려 했으나 클리어 데이터 초기화하지 않는 이상 서버 작업 어려움
        -- 계속 공용으로 쓰기로 함
        if (stage_id > ANCIENT_TOWER_STAGE_ID_FINISH) then
            return false
        end

        return true
    end

    -- 테이블에서 조건에 맞는 테이블만 리턴
    local l_stage_list = table_drop:filterTable_condition(condition_func)

    -- stage(stage_id) 순서로 정렬
    local function sort_func(a, b)
        return a['stage'] < b['stage']
    end
    table.sort(l_stage_list, sort_func)

    return l_stage_list
end

-------------------------------------
-- function getAcientTower_stageList
-------------------------------------
function ServerData_AncientTower:getAcientTower_stageList()
    return self.m_lStage
end

-------------------------------------
-- function getAcientTower_stageCount
-------------------------------------
function ServerData_AncientTower:getAcientTower_stageCount()
    return self.m_nStage
end

-------------------------------------
-- function getChallengingStageID
-- @brief 현재 도전중인 스테이지 아이디를 얻음
-------------------------------------
function ServerData_AncientTower:getChallengingStageID()
    return self.m_challengingStageID
end

-------------------------------------
-- function getTopStageID
-------------------------------------
function ServerData_AncientTower:getTopStageID()
    return (self.m_nStage + ANCIENT_TOWER_STAGE_ID_START)
end

-------------------------------------
-- function getChallengingFloor
-- @brief 현재 도전중인 층을 얻음
-------------------------------------
function ServerData_AncientTower:getChallengingFloor()
    return self.m_challengingFloor
end

-------------------------------------
-- function getChallengingCount
-- @brief 도전 횟수를 얻음
-------------------------------------
function ServerData_AncientTower:getChallengingCount()
    return self.m_challengingCount or 0
end

-------------------------------------
-- function getRankText
-------------------------------------
function ServerData_AncientTower:getRankText()
    local season_rank = self.m_nTotalRank
    local season_rate = self.m_nTotalRate
    if (season_rank <= 0) then
        return Str('순위 없음')
    end

    return Str('{1}위', comma_value(season_rank))
end

-------------------------------------
-- function isOpenStage
-- @brief stage_id에 해당하는 스테이지가 입장 가능한지를 리턴
-------------------------------------
function ServerData_AncientTower:isOpenStage(stage_id)
    local clear_stage = self.m_clearStageID 
    clear_stage = (clear_stage == 0) and ANCIENT_TOWER_STAGE_ID_START or clear_stage
    local is_open = (stage_id <= clear_stage + 1)
    return is_open
end

-------------------------------------
-- function getFloorFromStageID
-- @brief stage_id로부터 해당 층 수를 얻음
-------------------------------------
function ServerData_AncientTower:getFloorFromStageID(stage_id)
    return (stage_id % 1000)
end

-------------------------------------
-- function getStageIDFromFloor
-- @brief 층수로부터 stage_id를 얻음
-------------------------------------
function ServerData_AncientTower:getStageIDFromFloor(floor)
    return (ANCIENT_TOWER_STAGE_ID_START + floor)
end

-------------------------------------
-- function _refresh_playerUserInfo
-------------------------------------
function ServerData_AncientTower:_refresh_playerUserInfo(struct_user_info, t_data)
    -- 최신 정보로 갱신
    struct_user_info.m_nickname = g_userData:get('nick')
    struct_user_info.m_lv = g_userData:get('lv')

    do -- 고대의탑 정보 갱신
        if t_data['rank'] then
            struct_user_info.m_rank = t_data['rank']
        end

        if t_data['score'] then
            struct_user_info.m_score = t_data['score']
        end

        if t_data['rate'] then
            struct_user_info.m_rankPercent = t_data['rate']
        end
    end
end

-------------------------------------
-- function isOpen
-- @breif 고대의탑 오픈 여부 (시간 체크와 별도로 진입시 검사)
-------------------------------------
function ServerData_AncientTower:isOpen()
    return self.m_bOpen
end

-------------------------------------
-- function isOpenAncientTower
-- @breif 고대의탑 오픈 여부
-------------------------------------
function ServerData_AncientTower:isOpenAncientTower()
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
	
	return (start_time <= curr_time) and (curr_time <= end_time)
end

-------------------------------------
-- function getAncientTowerStatusText
-------------------------------------
function ServerData_AncientTower:getAncientTowerStatusText()
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)

    local str = ''
    if (not self:isOpenAncientTower()) then
        local time = (start_time - curr_time)
        if (time < 0) then
            str = Str('오픈시간이 아닙니다.')
        else
            str = Str('{1} 남았습니다.', datetime.makeTimeDesc(time, true))
        end

    elseif (curr_time < start_time) then
        local time = (start_time - curr_time)
        str = Str('{1} 후 열림', datetime.makeTimeDesc(time, true))

    elseif (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true))

    else
        str = Str('시즌이 종료되었습니다.')
    end

    return str
end

-------------------------------------
-- function setRewardInfo
-------------------------------------
function ServerData_AncientTower:setRewardInfo(ret)
    if (not ret['reward']) then
        return
    end
    
    -- 개인
    if (ret['lastinfo']) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoAncientTower()
        struct_user_info.m_uid = g_userData:get('uid')

        self:_refresh_playerUserInfo(struct_user_info, ret['lastinfo'])

        self.m_tSeasonRewardInfo = {}
        self.m_tSeasonRewardInfo['rank'] = struct_user_info
        self.m_tSeasonRewardInfo['reward_info'] =ret['reward_info']

        -- @analytics
        Analytics:trackGetGoodsWithRet(ret, '고대의 탑(랭킹)')
    end

    -- 클랜
    if (ret['last_clan_info']) then
        self.m_tClanRewardInfo = {}
        self.m_tClanRewardInfo['rank'] = StructClanRank(ret['last_clan_info'])
        self.m_tClanRewardInfo['reward_info'] = ret['reward_clan_info']
    end
end

-------------------------------------
-- function isAttrChallengeMode
-- @brief 시험의 탑 모드인지
-------------------------------------
function ServerData_AncientTower:isAttrChallengeMode()
    return g_attrTowerData:getSelAttr() and true or false
end

-------------------------------------
-- function checkAttrTowerAndGoStage
-- @brief 시험의 탑인지, 고대의 탑인지 체크한 후 UI 이동
-------------------------------------
function ServerData_AncientTower:checkAttrTowerAndGoStage(stage_id)
    local attr = g_attrTowerData:getSelAttr()
    
    if (attr) then
        UINavigator:goTo('attr_tower', attr, stage_id)
    else
        UINavigator:goTo('ancient', stage_id)
    end
end

-------------------------------------
-- function getPossibleReward
-- @brief 받을 수 있는 보상, 인덱스 리턴
-------------------------------------
function ServerData_AncientTower:getPossibleReward()
    local l_rank_list = g_ancientTowerData.m_rewardTable
    
    -- @jhakim 20190405 점수+rank로 보상 판단하는 버젼, score_min 여부로 판단
    if (l_rank_list[1]['score_min'] ~= '') then
        return self:getPossibleReward_score()
    else
        return self:getPossibleReward_rank()
    end
end

-------------------------------------
-- function getPossibleReward_rank
-------------------------------------
function ServerData_AncientTower:getPossibleReward_rank()
    local my_rank = g_ancientTowerData.m_nTotalRank
    local my_rank_rate = g_ancientTowerData.m_nTotalRate
    local l_rank_list = g_ancientTowerData.m_rewardTable

    -- 한번도 플레이 하지 않은 경우
    if (my_rank == -1) then
        return nil
    end
    
    for i,data in ipairs(l_rank_list) do
        
        local rank_min = tonumber(data['rank_min'])
        local rank_max = tonumber(data['rank_max'])

        local ratio_min = tonumber(data['ratio_min'])
        local ratio_max = tonumber(data['ratio_max'])

        -- 순위 필터
        if (rank_min and rank_max) then
            if (rank_min <= my_rank) and (my_rank <= rank_max) then
                return data, i
            end

        -- 비율 필터
        elseif (ratio_min and ratio_max) then
            if (ratio_min < my_rank_rate) and (my_rank_rate <= ratio_max) then
                return data, i
            end
        end
    end

    -- 마지막 보상 리턴
    local last_ind = #l_rank_list
    return l_rank_list[last_ind], last_ind
end

-------------------------------------
-- function getPossibleReward_score
-------------------------------------
function ServerData_AncientTower:getPossibleReward_score()
    local my_rank = g_ancientTowerData.m_nTotalRank
    local my_score = g_ancientTowerData.m_nTotalScore
    local l_rank_list = g_ancientTowerData.m_rewardTable
    
    -- 한번도 플레이 하지 않은 경우
    if (my_rank == -1) then
        return nil
    end

    for i,data in ipairs(l_rank_list) do

        local rank_min = tonumber(data['rank_min'])
        local rank_max = tonumber(data['rank_max'])

        local score_min = tonumber(data['score_min'])

        -- 순위 필터
        if (rank_min and rank_max) then
            if (rank_min <= my_rank) and (my_rank <= rank_max) then
                if (my_score >= data['score_min']) then
                    return data, i
                end
            end

        -- 점수 필터
        elseif (data['score_min']) then
            if (my_score >= data['score_min']) then
                return data, i
            end
        end
    end

    -- 마지막 보상 리턴
    local last_ind = #l_rank_list
    return l_rank_list[last_ind], last_ind
end

-------------------------------------
-- function getUntilNextRewardText
-------------------------------------
function ServerData_AncientTower:getUntilNextRewardText()
    local possible_reward, ind = self:getPossibleReward()
    local l_rank_list = g_ancientTowerData.m_rewardTable
    local my_rank = g_ancientTowerData.m_nTotalRank or 0
    local my_score = math_max(g_ancientTowerData.m_nTotalScore, 0) or 0

    -- 1위는 표시할 남은 점수/순위가 없음
    if (ind == 1) then
        return '-'
    end

    -- 받을 보상이 없는 사람은 마지막 단계+1로 세팅
    if (not ind) then
        ind = #l_rank_list + 1
    end

    -- 점수 기준인 경우
    if (l_rank_list[ind-1]['rank_max'] == '') then
        local dis = l_rank_list[ind-1]['score_min'] - my_score
        return Str('다음 단계 보상까지 {1}점 남음', comma_value(math.abs(dis)))
    end

    -- 순위 기준인 경우
    local dis = l_rank_list[ind-1]['rank_max'] - my_rank
    return Str('다음 단계 보상까지 {1}위 남음', math.abs(dis))

end