-------------------------------------
-- class ServerData_EventIncarnationOfSins
-- g_eventIncarnationOfSinsData
-------------------------------------
ServerData_EventIncarnationOfSins = class({
        m_tMyRankInfo = 'table', -- 속성별 자신의 순위 정보가 들어있음 (light, dark, fire, water, earth, total(전체순위))
        m_rewardStatus = 'number', -- 보상 받았는지 상태 저장
        m_tReceiveReward = 'table', -- 획득하는 보상 정보 

        m_lCloseRankers = 'list', -- 랭크 앞, 자신, 뒤 등수의 유저 정보

        m_tRewardInfo = 'table', -- 랭킹 보상 정보
        m_tAttrInfo = 'table', -- 요일별 입장 가능한 속성 정보
        m_todayDow = 'number', -- 오늘 요일 (1 = 일요일, 2, 3, 4, 5, 6, 7 = 토요일)
        m_Info = 'table', -- 
        m_gameState = 'boolean',
        m_rankNoti = 'boolean',
        m_isOpened = 'boolean'
    })

ServerData_EventIncarnationOfSins.STATE = {
    ['INACTIVE'] = 1,	-- 이벤트 비활성화
	['OPEN'] = 2,		-- 이벤트 던전 입장 가능
	['REWARD'] = 3,		-- 보상 수령 가능
	['DONE'] = 4,		-- 보상 수령 후 
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventIncarnationOfSins:init()
    self.m_rewardStatus = 0
    self.m_rankNoti = true
    self.m_isOpened = false
end

-------------------------------------
-- function getEventState
-------------------------------------
function ServerData_EventIncarnationOfSins:getEventState()
    -- 예외처리
	if (not g_hotTimeData) then
		return ServerData_EventIncarnationOfSins.STATE['INACTIVE']

    -- 이벤트 기간
	elseif (g_hotTimeData:isActiveEvent('event_incarnation_of_sins')) then
		return ServerData_EventIncarnationOfSins.STATE['OPEN']
	
    -- 보상 수령 기간
	elseif (g_hotTimeData:isActiveEvent('event_incarnation_of_sins_reward')) then
		if (self.m_rewardStatus == 0) then
			return ServerData_EventIncarnationOfSins.STATE['REWARD']

		-- 보상 수령 후 (1 -> 이번 시즌 보상 받음, 2 -> 이번 시즌 보상 받을게 없음)
		elseif (self.m_rewardStatus == 1) or (self.m_rewardStatus == 2) then
			return ServerData_EventIncarnationOfSins.STATE['DONE']
        end
	end

	-- 해당 없으면 비활성화
	return ServerData_EventIncarnationOfSins.STATE['INACTIVE']
end

-------------------------------------
-- function canPlay
-- @brief 게임 플레이가 가능한가
-------------------------------------
function ServerData_EventIncarnationOfSins:canPlay()
    return (self:getEventState() == ServerData_EventIncarnationOfSins.STATE['OPEN'])
end

-------------------------------------
-- function canReward
-- @brief 보상을 받을 수 있는가
-------------------------------------
function ServerData_EventIncarnationOfSins:canReward()
    return (self:getEventState() == ServerData_EventIncarnationOfSins.STATE['REWARD'])
end

-------------------------------------
-- function isPlaying
-- @brief 죄악의 화신을 플레이 중인지
-------------------------------------
function ServerData_EventIncarnationOfSins:isPlaying()
    if (self.m_gameState == true) then
        return true
    end

    return false
end

-------------------------------------
-- function getRankNoti
-- @brief
-------------------------------------
function ServerData_EventIncarnationOfSins:getRankNoti()
    return self.m_rankNoti
end

-------------------------------------
-- function setRankNoti
-- @brief
-------------------------------------
function ServerData_EventIncarnationOfSins:setRankNoti(v)
    self.m_rankNoti = v
end

-------------------------------------
-- function isActive
-- @brief 활성화되어있는가
-------------------------------------
function ServerData_EventIncarnationOfSins:isActive()
    return (self:getEventState() ~= ServerData_EventIncarnationOfSins.STATE['INACTIVE'])
end

-------------------------------------
-- function getMyRank
-- @brief 내 랭킹 받아오기
-------------------------------------
function ServerData_EventIncarnationOfSins:getMyRank(type)
    type = (type or 'total')
    
    local result = -1

    if (self.m_tMyRankInfo) then
        result = self.m_tMyRankInfo[type]['rank']
    end

    return result
end

-------------------------------------
-- function getMyScore
-- @brief 내 랭킹점수 받아오기
-------------------------------------
function ServerData_EventIncarnationOfSins:getMyScore(type)
    type = (type or 'total')    

    local result = -1

    if (self.m_tMyRankInfo) then
        result = self.m_tMyRankInfo[type]['score']
    end

    return result
end

-------------------------------------
-- function getMyRate
-- @brief 내 랭킹 퍼센트 받아오기
-------------------------------------
function ServerData_EventIncarnationOfSins:getMyRate(type)
    type = (type or 'total')    

    local result = -1

    if (self.m_tMyRankInfo) then
        result = self.m_tMyRankInfo[type]['rate']
    end

    return result
end

-------------------------------------
-- function getTimeText
-- @brief 이벤트 남은시간 받아오기
-------------------------------------
function ServerData_EventIncarnationOfSins:getTimeText()
    if (self.m_Info == nil) then 
        return 
    end

    local time_info = self.m_Info

    local start_time = time_info['start_date_timestamp'] / 1000
    local end_time = time_info['end_date_timestamp'] / 1000

    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    local str = ''
    if (curr_time < start_time) then
        local time = (start_time - curr_time)
        str = Str('{1} 후 열림', ServerTime:getInstance():makeTimeDescToSec(time, true))
    elseif (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
    else
        str = Str('이벤트가 종료되었습니다.')
    end

    return str
end

-------------------------------------
-- function setInfo
-- @brief 이벤트 정보 설정
-------------------------------------
function ServerData_EventIncarnationOfSins:setInfo(t_data)
    self.m_Info = t_data
end

-------------------------------------
-- function isOpenAttr
-- @brief 해당 속성이 현재 열려있는지 판단
-------------------------------------
function ServerData_EventIncarnationOfSins:isOpenAttr(attr)    
    -- 플레이 기간이 아닐 땐 모두 잠겨있음
    if (not self:canPlay()) then
        return false
    end
    
    if (self.m_tAttrInfo == nil) then
        return false
    end

    local today_dow = self.m_todayDow
    return self.m_tAttrInfo[attr][today_dow]
end

-------------------------------------
-- function getOpenAttrStr
-- @brief 해당 속성이 열리는 요일을 문자열로 반환
-------------------------------------
function ServerData_EventIncarnationOfSins:getOpenAttrStr(attr)
    if (self.m_tAttrInfo == nil) then
        return ''
    end

    local l_weekday_name_list = {Str('일'), Str('월'), Str('화'), Str('수'), Str('목'), Str('금'), Str('토')}
    local str = nil
    local t_attr_info = self.m_tAttrInfo[attr]

    for dow = 1, 7 do
        if t_attr_info[dow] == false then
            return false
        end

        return str
    end


    -- 월 ~ 토요일
    for dow = 2, 7 do
        if (t_attr_info[dow] == true) then
            if (str == nil) then
                str = l_weekday_name_list[dow]
            else
                str = str .. ',' .. l_weekday_name_list[dow]
            end        
        end
    end

    -- 일요일
    if (t_attr_info[1] == true) then
        if (str == nil) then
            str = l_weekday_name_list[1]
            
        else
            str = str .. ',' .. l_weekday_name_list[1]
        end        
    end


    return str
end

-------------------------------------
-- function setCloseRankers
-- @brief 앞뒤 등수 유저 정보 저장
-- @param l_rankers : 앞, 자신, 뒤 최대 3명의 랭크 정보 리스트
-------------------------------------
function ServerData_EventIncarnationOfSins:setCloseRankers(l_rankers)
    local uid = g_userData:get('uid')

    self.m_lCloseRankers = {}
    self.m_lCloseRankers['me_ranker'] = nil
    self.m_lCloseRankers['upper_ranker'] = nil
    self.m_lCloseRankers['lower_rank'] = nil

    for _,data in ipairs(l_rankers) do
        if (data['uid'] == uid) then
            self.m_lCloseRankers['me_ranker'] = data
        end
    end

    if (self.m_lCloseRankers['me_ranker'] == nil) then return end
    local my_rank = self.m_lCloseRankers['me_ranker']['rank']
    local upper_rank = my_rank - 1
    local lower_rank = my_rank + 1

    for _,data in ipairs(l_rankers) do
        if (tonumber(data['rank']) == tonumber(upper_rank)) then
            self.m_lCloseRankers['upper_ranker'] = data
        end

        if (tonumber(data['rank']) == tonumber(lower_rank)) then
            self.m_lCloseRankers['lower_rank'] = data
        end
    end
end

-------------------------------------
-- function getCloseRankers
-- @brief 앞뒤 등수 유저 정보 반환 
-------------------------------------
function ServerData_EventIncarnationOfSins:getCloseRankers()
    return self.m_lCloseRankers['upper_ranker'], self.m_lCloseRankers['me_ranker'], self.m_lCloseRankers['lower_rank']
end

-------------------------------------
-- function openRankingPopupForLobby
-- @brief 로비에서 랭킹 팝업 바로 여는 경우 사용, 랭킹 보상이 있는지도 체크하여 출력한다.
-------------------------------------
function ServerData_EventIncarnationOfSins:openRankingPopupForLobby()
    local function finish_cb()
        -- 랭킹 팝업
        UI_EventIncarnationOfSinsRankingPopup()

        local last_info = self.m_tMyRankInfo['total']
        local reward_info = self.m_tReceiveReward
        ccdump(last_info)
        ccdump(reward_info)

        -- 보상을 받을 수 있는 상태라면
        if (last_info and reward_info) then
            -- 랭킹 보상 팝업
            UI_EventIncarnationOfSinsRewardPopup(last_info, reward_info)
            g_highlightData:setHighlightMail()
        end
    end

    self:request_eventIncarnationOfSinsInfo(true, finish_cb, nil)
end


local mInit = false
-------------------------------------
-- function request_eventIncarnationOfSinsInfo
-- @brief 이벤트 정보를 요청
-- @param include_reward : 이벤트 랭킹 보상을 받을지 여부
-------------------------------------
function ServerData_EventIncarnationOfSins:request_eventIncarnationOfSinsInfo(include_reward, finish_cb, fail_cb)
    local uid = g_userData:get('uid')
    local include_tables = false
    local include_reward = include_reward or false

    -- 맨 처음 한번만 require
    if (not mInit) then
        mInit = true
        require('UI_EventIncarnationOfSins')
        require('UI_EventIncarnationOfSinsFullPopup')
        require('UI_EventIncarnationOfSinsEntryPopup')
        require('UI_EventIncarnationOfSinsRankingPopup')
        require('UI_EventIncarnationOfSinsRankingTotalTab')
        require('UI_EventIncarnationOfSinsRankingAttributeTab')
        require('UI_BannerIncarnationOfSins')
        require('UI_EventIncarnationOfSinsRewardPopup')
        require('UI_ResultLeaderBoard_IncarnationOfSins')
        require('UI_ResultLeaderBoard_IncarnationOfSinsListItem')
        include_tables = true
    end

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        self:response_eventIncarnationOfSinsInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/event/incarnation_of_sins/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('include_tables', include_tables) -- 정보 관련 테이블 내려받을지 여부 
    ui_network:setParam('reward', include_reward) -- 랭킹 보상 지급 여부
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()
end

-------------------------------------
-- function response_eventIncarnationOfSinsInfo
-------------------------------------
function ServerData_EventIncarnationOfSins:response_eventIncarnationOfSinsInfo(ret)
    if (ret['rankinfo']) then
        self.m_tMyRankInfo = ret['rankinfo']
    end
    
    if (ret['reward']) then
        self.m_rewardStatus = ret['reward']
    end 
    
    if (ret['reward_info']) then
        self.m_tReceiveReward = ret['reward_info']
    else
        self.m_tReceiveReward = nil
    end

    if (ret['dow']) then
        self.m_todayDow = ret['dow']
    end 

    if (ret['table_incarnation_of_sins_rank']) then
        self.m_tRewardInfo = ret['table_incarnation_of_sins_rank']
    end

    if (ret['table_incarnation_of_sins_attr']) then
        local l_dow_info = ret['table_incarnation_of_sins_attr']
        local t_attr_info = {}
        t_attr_info['fire'] = {}
        t_attr_info['water'] = {}
        t_attr_info['earth'] = {}
        t_attr_info['light'] = {}
        t_attr_info['dark'] = {}

        for i, dow_info in ipairs(l_dow_info) do
            local dow = dow_info['dow']  -- 요일
            local dow_attr = dow_info['attr'] -- 속성
            if (dow_attr == 'all') then
                for attr, attr_info in pairs(t_attr_info) do
                    attr_info[dow] = true
                end
            else
                for attr, attr_info in pairs(t_attr_info) do
                    if (dow_attr == attr) then
                        attr_info[dow] = true
                    else
                        attr_info[dow] = false
                    end
                end
            end         
        end
        
        self.m_tAttrInfo = t_attr_info -- table[attr(string)][dow(number)] = true(boolean) 이면 attr 속성이 dow 요일일때 열려있다.
    end
end

-------------------------------------
-- function request_EventIncarnationOfSinsAttrRanking
-- @brief 랭킹 정보를 요청하고, cb_func를 통해 랭킹 정보를 다룸
-- @param attr_type : 속성 (earth, water, fire, light, dark, all(다섯가지 속성 전부 조회), total(합산 점수))
-- @param search_type : 랭킹을 조회할 그룹 (world, clan, friend)
-- @param offset : 랭킹 리스트의 offset 값 (-1 : 내 랭킹 기준, 0 : 상위 랭킹 기준, 20 : 랭킹의 20번째부터 조회..) 
-- @param param_success_cb : 받은 데이터를 이용하여 처리할 콜백 함수
-- @param param_fail_cb : 통신 실패 처리할 콜백 함수
-------------------------------------
function ServerData_EventIncarnationOfSins:request_EventIncarnationOfSinsAttrRanking(attr_type, search_type, offset, limit, param_success_cb, param_fail_cb)
    local uid = g_userData:get('uid')
    local attr = attr_type -- default : total
    local type = search_type -- default : world
    local offset = offset -- default : 0
    local limit = limit -- default : 20

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        self:response_eventIncarnationOfSinsInfo(ret)

        if param_success_cb then
            param_success_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/event/incarnation_of_sins/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('attr', attr) 
    ui_network:setParam('type', type)
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
-- function request_eventIncarnationOfSinsStart
-- @brief 죄악의 화신과 전투 시작 요청
-- @param stage : 전투한 스테이지 ID
-- @param attr : 전투한 보스 속성 (earth, water, fire, light, dark)
-- @param deck_name1 : 1번 덱 이름
-- @param deck_name2 : 2번 덱 이름
-- @param token1 : 1번 덱 검증 토큰
-- @param token2 : 2번 덱 검증 토큰
-- @param finish_cb : 통신 성공 처리할 콜백 함수
-- @param fail_cb : 통신 실패 처리할 콜백 함수
-------------------------------------
function ServerData_EventIncarnationOfSins:request_eventIncarnationOfSinsStart(stage, attr, deck_name1, deck_name2, token1, token2, finish_cb, fail_cb)
    local uid = g_userData:get('uid')
    local stage = stage
    local attr = attr
    local deck_name1 = deck_name1
    local deck_name2 = deck_name2
    local token1 = token1
    local token2 = token2
        
    local function success_cb(ret)
        self.m_gameState = true

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    local function response_status_cb(ret)
        -- 요일에 맞지 않는 속성
        if (ret['status'] == -2150) then

            -- 요일 새로고침
            if (ret['dow']) then
                self.m_todayDow = ret['dow']
            end

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
    local api_url = '/event/incarnation_of_sins/start'
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage)
    ui_network:setParam('attr', attr)
    ui_network:setParam('deck_name1', deck_name1)
    ui_network:setParam('deck_name2', deck_name2)
    ui_network:setParam('token1', token1)
    ui_network:setParam('token2', token2)
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
function ServerData_EventIncarnationOfSins:request_eventIncarnationOfSinsFinish(stage, attr, damage, choice_deck, clear_time, check_time, finish_cb, fail_cb)
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
    local api_url = '/event/incarnation_of_sins/finish'
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
-- function getPossibleReward_IncarnationsOfSins
-- @brief 획득할 수 있는 보상 데이터를 반환
-- @param my_rank : 현재 등수
-- @param my_ratio : 현재 랭크 비율 
-------------------------------------
function ServerData_EventIncarnationOfSins:getPossibleReward_IncarnationsOfSins(my_rank, my_ratio)
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