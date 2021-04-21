
----------------------------------------------------------------------
-- class ServerData_EventRoulette
-- @brief 
-- https://highbrow.atlassian.net/wiki/spaces/dvm/pages/1442742280
----------------------------------------------------------------------
ServerData_EventRoulette = class({
    m_rouletteInfo = 'table',
    m_probabilityTable = 'table',
    m_rankTable = 'table',

    --m_bDirtyTable = 'boolean',


})

----------------------------------------------------------------------
-- function getInstance
----------------------------------------------------------------------
function ServerData_EventRoulette:getInstance()
    if g_eventRouletteData then
        return g_eventRouletteData
    end

    g_eventRouletteData = ServerData_EventRoulette()

    return g_eventRouletteData
end


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function ServerData_EventRoulette:init()
    --self.m_bDirtyTable = true
end

----------------------------------------------------------------------
-- function request_rouletteInfo
-- param is_table_required  probability와 rank 테이블 정보를 받을 것인지 여부
-- param is_reward_required 랭킹 보상을 받을 것인지에 대한 여부
----------------------------------------------------------------------
function ServerData_EventRoulette:request_rouletteInfo(is_table_required, is_reward_required, finish_cb, fail_cb)

    -- -- 테이블 정보를 받아온 상태면 다시 받아올 필요 x
    -- if (not self.m_bDirtyTable) then
    --     is_table_required = false
    -- end

    local user_id = g_userData:get('uid')

    local function success_cb(ret)
        if ret['roulette_info'] then -- 룰렛 관련 정보
            self.m_rouletteInfo = ret['roulette_info']
            self.m_rouletteInfo['start_date'] = self.m_rouletteInfo['start_date'] / 1000
            self.m_rouletteInfo['end_date'] = self.m_rouletteInfo['end_date'] / 1000
        end

        if ret['table_event_probability'] then -- 룰렛 확률 테이블
            self.m_probabilityTable = ret['table_event_probability']
        end

        if ret['table_event_rank'] then -- 랭킹 정보 테이블
            self.m_rankTable = ret['table_event_rank']
        end

        -- if (self.m_rankTable and self.m_probabilityTable) then 
        --     self.m_bDirtyTable = false
        -- end

        if(finish_cb) then finish_cb(ret) end
    end

    local network = UI_Network()
    network:setUrl('/event/roulette/info')
    network:setParam('uid', user_id)
    network:setParam('include_tables', is_table_required)
    network:setParam('reward', is_reward_required)
    network:setRevocable(true)
    network:setSuccessCB(success_cb)
    network:setFailCB(fail_cb)
    network:request()

    return network
end

----------------------------------------------------------------------
-- function request_rouletteInfo
-- param step   몇번째 룰렛을 돌리는지 (step : 1, 2)
-- picked_group step 2에 필요한 당첨된 그룹 (step 1으로 받는 return 값)
----------------------------------------------------------------------
function ServerData_EventRoulette:request_rouletteStart(step, picked_group, finish_cb, fail_cb)
    local user_id = g_userData:get('uid')

    local function success_cb(ret)

        if(finish_cb) then finish_cb(ret) end
    end


    local network = UI_Network()
    network:setUrl('/event/roulette/start')
    network:setParam('uid', user_id)
    network:setParam('step', step)
    network:setParam('picked_group', picked_group)
    network:setRevocable(true)
    network:setSuccessCB(success_cb)
    network:setFailCB(fail_cb)
    network:request()

    return network
end 

----------------------------------------------------------------------
-- function request_rouletteRanking
----------------------------------------------------------------------
function ServerData_EventRoulette:request_rouletteRanking(offset, limit, type, division, finish_cb, fail_cb)
    local user_id = g_userData:get('uid')

    local function success_cb(ret)
        
        if(finish_cb) then finish_cb(ret) end
    end


    local network = UI_Network()
    network:setUrl('/event/roulette/ranking')
    network:setParam('uid', user_id)
    network:setParam('offset', offset)    -- -1 : 자신의 위치, 그 외에는 랭킹의 위치
    network:setParam('limit', limit) -- 몇개의 리스트를 불러올지 (default : 20)
    network:setParam('type', type)  -- world, friend, clan
    network:setParam('division', division) -- total, daily
    network:setRevocable(true)
    network:setSuccessCB(success_cb)
    network:setFailCB(fail_cb)
    network:request()

    return network
end

----------------------------------------------------------------------
-- function getTotalScore
-- return 종합 누적 점수
----------------------------------------------------------------------
function ServerData_EventRoulette:getTotalScore()
    return self.m_rouletteInfo['score']
end

----------------------------------------------------------------------
-- function request_rouletteRanking
-- return 오늘 누적 점수
----------------------------------------------------------------------
function ServerData_EventRoulette:getDailyScore()
    return self.m_rouletteInfo['score']
end

----------------------------------------------------------------------
-- function getTicketNum
-- return 보유중인 룰렛 티켓 수
----------------------------------------------------------------------
function ServerData_EventRoulette:getTicketNum()
    return self.m_rouletteInfo['roulette']
end

----------------------------------------------------------------------
-- function getTicketNum
----------------------------------------------------------------------
function ServerData_EventRoulette:getTimeText()
    local start_time = self.m_rouletteInfo['start_date']
    local end_time = self.m_rouletteInfo['end_date']

    local curr_time = Timer:getServerTime()

    
    local str = ''
    if (curr_time < start_time) then
        local time = (start_time - curr_time)
        str = Str('{1} 후 열림', datetime.makeTimeDesc(time, true))
    elseif (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true))
    else
        is_season_ended = true
        str = Str('이벤트가 종료되었습니다.')
    end

    return str
end
