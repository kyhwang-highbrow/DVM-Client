-------------------------------------
-- class ServerData_EventDealking
-- g_eventIncarnationOfSinsData
-------------------------------------
ServerData_EventDealking = class({
    m_tMyRankInfo = 'table', -- 속성별 자신의 순위 정보가 들어있음 (light, dark, fire, water, earth, total(전체순위))
    m_rewardStatus = 'number', -- 보상 받았는지 상태 저장
    m_tReceiveReward = 'table', -- 획득하는 보상 정보 
    m_lCloseRankers = 'list', -- 랭크 앞, 자신, 뒤 등수의 유저 정보

    m_tRewardInfo = 'table', -- 랭킹 보상 정보
    m_tAttrInfo = 'table', -- 요일별 입장 가능한 속성 정보
    m_todayDow = 'number', -- 오늘 요일 (1 = 일요일, 2, 3, 4, 5, 6, 7 = 토요일)
    m_gameState = 'boolean',
    m_rankNoti = 'boolean',
    m_isOpened = 'boolean',

    m_tDealkingBossInfo = 'Map',
    m_includeTablesInfo = 'boolean', -- 처음 한번만 테이블 요청
    m_myDummyRankingInfo = 'table', -- 더미 랭킹 정보
})

ServerData_EventDealking.STATE = {
    ['INACTIVE'] = 1,	-- 이벤트 비활성화
    ['OPEN'] = 2,		-- 이벤트 던전 입장 가능
    ['REWARD'] = 3,		-- 보상 수령 가능
    ['DONE'] = 4,		-- 보상 수령 후 
}

ServerData_EventDealking.GAME_TIME = {
    ['LIMIT'] = 120,	-- 제한 시간
    ['FEVER'] = 40,	-- 피버 타임(마지막 40초)
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventDealking:init()
    self.m_rewardStatus = 0
    self.m_rankNoti = true
    self.m_isOpened = false
    self.m_includeTablesInfo = true
    self.m_tMyRankInfo = {}

    self:makeBossMap()    
end

-------------------------------------
-- function makeBossMap
-------------------------------------
function ServerData_EventDealking:makeBossMap()
    self.m_tDealkingBossInfo = {}

    -- 1번 보스
    self.m_tDealkingBossInfo[1] = {
        ['name'] = Str('훈련용 가고일'),
        ['fever_time'] = 30,
    }

    -- 2번 보스
    self.m_tDealkingBossInfo[2] = {
        ['name'] = Str('훈련용 수정 거인'),
        ['fever_time'] = 15,
    }
end

-------------------------------------
-- function getBossMap
-------------------------------------
function ServerData_EventDealking:getBossMap()
    return self.m_tDealkingBossInfo
end

-------------------------------------
--- @function getMyDummyRanking
-------------------------------------
function ServerData_EventDealking:getMyDummyRanking()
    if self.m_myDummyRankingInfo ~= nil then
        return self.m_myDummyRankingInfo
    end

    self.m_myDummyRankingInfo = clone(self:getMyRankInfo()['total'])
    self.m_myDummyRankingInfo['rank'] = -1
    self.m_myDummyRankingInfo['score'] = -1
    self.m_myDummyRankingInfo['total'] = 0
    self.m_myDummyRankingInfo['rate'] = -1
    return self.m_myDummyRankingInfo

--[[     
    "tier":"beginner",
    "tamer":110002,
    "total":0,
    "score":-1,
    "lv":18,
    "challenge_score":0,
    "rate":"-Infinity",
    "last_tier":"beginner",
    "arena_score":0,
    "ancient_score":0,
    "rp":-1,
    "un":3239521,
    "rank":-1,
    "uid":"CaPwu0HcdwhafLAOTK229MNOZL93",
    "nick":"밥먹고자기",
    "leader":{
      "lv":1,
      "mastery_lv":0,
      "grade":3,
      "rlv":0,
      "eclv":0,
      "dragon_skin":0,
      "did":120431,
      "transform":1,
      "mastery_skills":{
      },
      "evolution":1,
      "mastery_point":0
    },
    "costume":730200,
    "clear_time":0
  } ]]
end


-------------------------------------
-- function getEventState
-------------------------------------
function ServerData_EventDealking:getEventState()
    -- 예외처리
    if (not g_hotTimeData) then
        return ServerData_EventDealking.STATE['INACTIVE']

    -- 보상 수령 기간
    elseif (g_hotTimeData:isActiveEvent('event_dealking_reward')) then
        if (self.m_rewardStatus == 0) then
            return ServerData_EventDealking.STATE['REWARD']

        -- 보상 수령 후 (1 -> 이번 시즌 보상 받음, 2 -> 이번 시즌 보상 받을게 없음)
        elseif (self.m_rewardStatus == 1) or (self.m_rewardStatus == 2) then
            return ServerData_EventDealking.STATE['DONE']
        end

    -- 이벤트 기간
    elseif (g_hotTimeData:isActiveEvent('event_dealking')) then
        return ServerData_EventDealking.STATE['OPEN']
    end

    -- 해당 없으면 비활성화
    return ServerData_EventDealking.STATE['INACTIVE']
end

-------------------------------------
-- function canPlay
-- @brief 게임 플레이가 가능한가
-------------------------------------
function ServerData_EventDealking:canPlay()
    return (self:getEventState() == ServerData_EventDealking.STATE['OPEN'])
end

-------------------------------------
-- function canReward
-- @brief 보상을 받을 수 있는가
-------------------------------------
function ServerData_EventDealking:canReward()
    return (self:getEventState() == ServerData_EventDealking.STATE['REWARD'])
end

-------------------------------------
--- @function isPlaying
--- @brief 딜킹을 플레이 중인지
-------------------------------------
function ServerData_EventDealking:isPlaying()
    if (self.m_gameState == true) then
        return true
    end

    return false
end


-------------------------------------
--- @function isReceivedReward
--- @brief 최종 보상을 받았는지?
-------------------------------------
function ServerData_EventDealking:isReceivedReward()
    if (self.m_gameState == true) then
        return true
    end

    return false
end



-------------------------------------
-- function getRankNoti
-- @brief
-------------------------------------
function ServerData_EventDealking:getRankNoti()
    return self.m_rankNoti
end

-------------------------------------
-- function setRankNoti
-- @brief
-------------------------------------
function ServerData_EventDealking:setRankNoti(v)
    self.m_rankNoti = v
end

-------------------------------------
-- function isActive
-- @brief 활성화되어있는가
-------------------------------------
function ServerData_EventDealking:isActive()
    return (self:getEventState() ~= ServerData_EventDealking.STATE['INACTIVE'])
end

-------------------------------------
--- @function getEventDealkingStageId
-------------------------------------
function ServerData_EventDealking:getEventDealkingStageId(boss_type, selected_attr)
    local attr_map = {
        ['light'] = 1,
        ['fire'] = 2,
        ['water'] = 3,
        ['earth'] = 4,
        ['dark'] = 5,
    }

    local stage_id = 3100000 + (boss_type * 100) + attr_map[selected_attr]
    return stage_id
end

-------------------------------------
-- function getMyRankInfo
-- @brief 내 랭킹 받아오기
-------------------------------------
function ServerData_EventDealking:getMyRankInfo(_boss_type)
    local boss_type = _boss_type or 0

    if self.m_tMyRankInfo ~= nil then
        return self.m_tMyRankInfo[boss_type]
    end

    return nil
end

-------------------------------------
-- function getMyRankInfoTotal
-- @brief 내 랭킹 받아오기
-------------------------------------
function ServerData_EventDealking:getMyRankInfoTotal(_boss_type)
    local my_rank_info = self:getMyRankInfo(_boss_type)
    if (my_rank_info) then
        if my_rank_info['total'] == nil then
            return self:getMyDummyRanking()
        end
        return my_rank_info['total']
    end

    return self:getMyDummyRanking()
end


-------------------------------------
-- function getMyRank
-- @brief 내 랭킹 받아오기
-------------------------------------
function ServerData_EventDealking:getMyRank(_boss_type, type)
    type = (type or 'total')
    local boss_type = _boss_type or 0
    local result = -1

    local my_rank_info = self:getMyRankInfo(boss_type)
    if (my_rank_info) then
        if my_rank_info[type] == nil then
            return self:getMyDummyRanking()['rank']
        end
        result = my_rank_info[type]['rank']
    end

    return result
end

-------------------------------------
-- function getMyScore
-- @brief 내 랭킹점수 받아오기
-------------------------------------
function ServerData_EventDealking:getMyScore(_boss_type, type)
    type = (type or 'total')    
    local boss_type = _boss_type or 0
    local result = -1
    local my_rank_info = self:getMyRankInfo(boss_type)
    if (my_rank_info) then
        if my_rank_info[type] == nil then
            return self:getMyDummyRanking()['score']
        end
        result = my_rank_info[type]['score']
    end
    return result
end

-------------------------------------
-- function getMyRate
-- @brief 내 랭킹 퍼센트 받아오기
-------------------------------------
function ServerData_EventDealking:getMyRate(_boss_type, type)
    type = (type or 'total')    
    local boss_type = _boss_type or 0
    local result = -1

    local my_rank_info = self:getMyRankInfo(boss_type)
    if (my_rank_info) then
        if my_rank_info[type] == nil then
            return self:getMyDummyRanking()['rate']
        end
        result = my_rank_info[type]['rate']
    end

    return result
end

-------------------------------------
-- function getRemainTimeString
-- @brief 이벤트 남은시간 받아오기
-------------------------------------
function ServerData_EventDealking:getRemainTimeString()
    -- TODO : 구현을 해야한다.
    return g_hotTimeData:getEventRemainTimeTextDetail('event_dealking') or ''
end

-------------------------------------
-- function isOpenAttr
-- @brief 해당 속성이 현재 열려있는지 판단
-------------------------------------
function ServerData_EventDealking:isOpenAttr(attr)
    -- 플레이 기간이 아닐 땐 모두 잠겨있음
    if (not self:canPlay()) then
        return false
    end

    return true
end

-------------------------------------
--- @function getEventBossName
-------------------------------------
function ServerData_EventDealking:getEventBossName(boss_type)
    local t_boss = self.m_tDealkingBossInfo[boss_type]
    if t_boss == nil then
        return ''
    end
    return t_boss.name
end

-------------------------------------
--- @function getEventBossFeverTime
-------------------------------------
function ServerData_EventDealking:getEventBossFeverTime(boss_type)
    local t_boss = self.m_tDealkingBossInfo[boss_type]
    if t_boss == nil then
        return 0
    end
    return t_boss['fever_time']
end

-------------------------------------
-- function openRankingPopupForLobby
-- @brief 로비에서 랭킹 팝업 바로 여는 경우 사용, 랭킹 보상이 있는지도 체크하여 출력한다.
-------------------------------------
function ServerData_EventDealking:openRankingPopupForLobby()
end

-------------------------------------
-- function request_eventDealkingInfo
-- @brief 이벤트 정보를 요청
-- @param include_reward : 이벤트 랭킹 보상을 받을지 여부
-------------------------------------
function ServerData_EventDealking:request_eventDealkingInfo(finish_cb, fail_cb)
    local uid = g_userData:get('uid')    

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        self:response_eventDealkingInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end

        self.m_includeTablesInfo = false
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/event/dealking/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('include_tables', self.m_includeTablesInfo) -- 정보 관련 테이블 내려받을지 여부     
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end

-------------------------------------
-- function response_eventDealkingInfo
-------------------------------------
function ServerData_EventDealking:response_eventDealkingInfo(ret)
    local boss_count = table.count(self.m_tDealkingBossInfo)
    for i = 0, boss_count do
        local str = string.format('rankinfo_%d', i)
        if (ret[str] ~= nil) then            
            self.m_tMyRankInfo[i] = clone(ret[str])
        end
    end

    if (ret['reward']) then
        self.m_rewardStatus = ret['reward']
    end 

    if (ret['table_dealking_rank']) then
        self.m_tRewardInfo = ret['table_dealking_rank']
    end
end

-------------------------------------
-- function request_EventDealkingRanking
-- @brief 랭킹 정보를 요청하고, cb_func를 통해 랭킹 정보를 다룸
-- @param attr_type : 속성 (earth, water, fire, light, dark, all(다섯가지 속성 전부 조회), total(합산 점수))
-- @param search_type : 랭킹을 조회할 그룹 (world, clan, friend)
-- @param offset : 랭킹 리스트의 offset 값 (-1 : 내 랭킹 기준, 0 : 상위 랭킹 기준, 20 : 랭킹의 20번째부터 조회..) 
-- @param param_success_cb : 받은 데이터를 이용하여 처리할 콜백 함수
-- @param param_fail_cb : 통신 실패 처리할 콜백 함수
-------------------------------------
function ServerData_EventDealking:request_EventDealkingRanking(boss_type, attr_type, search_type, offset, limit, param_success_cb, param_fail_cb)
    local uid = g_userData:get('uid')
    local attr = attr_type -- default : total
    local type = search_type -- default : world
    local offset = offset -- default : 0
    local limit = limit -- default : 20

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        self:response_eventDealkingInfo(ret)

        if param_success_cb then
            param_success_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/event/dealking/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('rank_type', boss_type)
    ui_network:setParam('attr', attr) 
    ui_network:setParam('filter', type)
    ui_network:setParam('offset', offset)
    ui_network:setParam('limit', limit)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(param_fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end

-------------------------------------
--- @function request_eventDealkingStart
--- @brief 딜킹 전투 시작 요청
--- @param finish_cb : 통신 성공 처리할 콜백 함수
--- @param fail_cb : 통신 실패 처리할 콜백 함수
-------------------------------------
function ServerData_EventDealking:request_eventDealkingStart(stage, attr, deck_name, finish_cb, fail_cb)
    local uid = g_userData:get('uid')
    local token = g_stageData:makeDragonToken(deck_name)

    local function success_cb(ret)
        self.m_gameState = true

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    local function response_status_cb(ret)
        -- 요일에 맞지 않는 속성
        if (ret['status'] == -2150) then
            -- 로비로 이동
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 

            MakeSimplePopup(POPUP_TYPE.OK, Str('이미 종료된 던전입니다.'), ok_cb)
            return true
        end

        return false
    end

    local ui_network = UI_Network()
    local api_url = '/event/dealking/start'
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage)
    ui_network:setParam('attr', attr)
    ui_network:setParam('deck_name', deck_name)    
    ui_network:setParam('token', token)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
-- function request_eventIncarnationOfSinsFinish
-- @brief 죄악의 화신과 전투 종료하고 점수 저장
-- @param stage : 전투한 스테이지 ID
-- @param attr : 전투한 보스 속성 (earth, water, fire, light, dark)
-- @param damage : 보스에게 입힌 대미지
-- @param choice_deck : 수동 조작한 덱 번호 (up : 1, down : 2)
-- @param clear_time : 인게임에서 소요된 시간
-- @param check_time : 타임스탬프
-- @param finish_cb : 통신 성공 처리할 콜백 함수
-- @param fail_cb : 통신 실패 처리할 콜백 함수
-------------------------------------
function ServerData_EventDealking:request_eventIncarnationOfSinsFinish(stage, attr, damage, choice_deck, clear_time, check_time, finish_cb, fail_cb)
    local uid = g_userData:get('uid')
    local stage = stage
    local attr = attr
    local damage = damage
    local choice_deck = choice_deck
    local clear_time = clear_time
    local check_time = check_time
        
    local function success_cb(ret)
        self.m_gameState = false

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    local function response_status_cb(ret)
        -- 현재 시간에 잠겨 있는 속성
        if (ret['status'] == -1364) then
            -- 로비로 이동
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('입장 가능한 시간이 아닙니다.'), ok_cb)
            return true
        end

        return false
    end

    local ui_network = UI_Network()
    local api_url = '/event/dealking/finish'
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage)
    ui_network:setParam('attr', attr)
    ui_network:setParam('damage', damage)
    ui_network:setParam('choice_deck', choice_deck)
    ui_network:setParam('clear_time', clear_time)
    ui_network:setParam('check_time', check_time)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
--- @function request_eventDealkingReward
--- @brief 보상 요청(보상 정보가 있으면 보상 팝업까지 노출)
-------------------------------------
function ServerData_EventDealking:request_eventDealkingReward(finish_cb, fail_cb)
    local uid = g_userData:get('uid')
       
    local function success_cb(ret)
        self:response_eventDealkingInfo(ret)
        if (finish_cb) then
            finish_cb(ret)
        end
    end

    local function response_status_cb(ret)
        return false
    end


    local ui_network = UI_Network()
    local api_url = '/event/dealking/reward'
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
--- @function getPossibleReward
--- @brief 획득할 수 있는 보상 데이터를 반환
--- @param integer : 현재 등수
--- @param integer : 현재 랭크 비율 
-------------------------------------
function ServerData_EventDealking:getPossibleReward(my_rank, my_ratio)
    local my_rank = tonumber(my_rank)
    local my_rank_rate = tonumber(my_ratio) * 100

    local l_rank_list = self.m_tRewardInfo

    -- 한번도 플레이 하지 않은 경우, 최상위 보여줌
    if (my_rank <= 0) then
        return nil, 0
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
    return l_rank_list[last_ind], last_ind or 0
end