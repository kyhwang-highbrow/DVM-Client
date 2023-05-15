-------------------------------------
-- class ServerData_EventVote
-------------------------------------
ServerData_EventVote = class({
    m_dragonList = 'List<number>', -- 신화 드래곤 리스트
    m_rewardList = 'List<table>', -- 투표 보상 리스트
    m_eventVoteCount = 'number', -- 튜표 횟수
    m_staminaDropInfo = 'Map<>', -- 투표권 획득 플레이 요구 사항
    m_rankList = 'List<table>', -- 랭킹 정보
    m_updatedAt = 'ExperationTime',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventVote:init(server_data)
    self.m_updatedAt = ExperationTime:createWithUpdatedAyInitialized()
    self.m_dragonList = {}
    self.m_rewardList = {}
    self.m_eventVoteCount = 0
    self.m_staminaDropInfo = {}
    self.m_rankList = {}
end

-------------------------------------
-- function getDragonList
-------------------------------------
function ServerData_EventVote:getDragonList()
    return self.m_dragonList
end

-------------------------------------
-- function getStaminaInfo
-------------------------------------
function ServerData_EventVote:getStaminaInfo()
    return self.m_staminaDropInfo
end

-------------------------------------
-- function getRewardList
-------------------------------------
function ServerData_EventVote:getRewardList()
    return self.m_rewardList
end

-------------------------------------
-- function getDragonRankList
-------------------------------------
function ServerData_EventVote:getDragonRankList()
    return self.m_rankList
end

-------------------------------------
-- function getMyVoteCount
-------------------------------------
function ServerData_EventVote:getMyVoteCount()
    return self.m_eventVoteCount
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventVote:getStatusText()
    local time = g_hotTimeData:getEventRemainTime('event_vote')
    return Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
end

-------------------------------------
-- function isExpiredRankingUpdate
-------------------------------------
function ServerData_EventVote:isExpiredRankingUpdate()
    if self.m_updatedAt:isExpired() == true or #self.m_rankList == 0 then
        self.m_updatedAt:setUpdatedAt()
        self.m_updatedAt:applyExperationTime_SecondsLater(10)
        return true
    end

    return false
end

-------------------------------------
-- function isAvailableEventVote
-------------------------------------
function ServerData_EventVote:isAvailableEventVote()
    local vote_count = g_userData:get('event_vote_ticket')
    return vote_count > 0
end

-------------------------------------
-- function applyDragonVoteResponse
-- @brief 투표 대상 드래곤 리스트 세팅
-------------------------------------
function ServerData_EventVote:applyDragonVoteResponse(t_ret)

    -- 드래곤 리스트
    if t_ret['event_vote_dragon_list'] ~= nil then
        self.m_dragonList = t_ret['event_vote_dragon_list']
    end

    -- 랭크 리스트
    if t_ret['rank_list'] ~= nil then
        self.m_rankList = clone(t_ret['rank_list'])
    end

    -- 투표 확률 보상 정보
    if t_ret['event_vote_reward'] ~= nil then
        self.m_rewardList = {}
        local vote_reward_map = t_ret['event_vote_reward']

        for item_id, v in pairs(vote_reward_map) do
            local t_data = {item_id = tonumber(item_id), count = v['count'], rate = v['rate']}
            table.insert(self.m_rewardList, t_data)
        end
    end

    -- 입장권 획득 정보
    if (t_ret['stamina_info']) then
        self.m_staminaDropInfo = t_ret['stamina_info']
    end

    -- 현재까지 나의 투표 횟수
    if t_ret['event_vote_count'] ~= nil then
        self.m_eventVoteCount = t_ret['event_vote_count']
    end
end

-------------------------------------
-- function requestEventVoteInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventVote:requestEventVoteInfo(cb_func, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        -- 투표 정보
        self:applyDragonVoteResponse(ret)

        if cb_func ~= nil then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/vote/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function requestEventVoteDragon
-- @brief 드래곤 투표하기
-------------------------------------
function ServerData_EventVote:requestEventVoteDragon(did_str, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        -- 투표 정보
        self:applyDragonVoteResponse(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end
    
    -- 성공 시 콜백
    local function status_cb(ret)       
        if ret['status'] == 1128 then
            MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'), function () 
                UINavigator:goTo('lobby')
            end)
            return true
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/vote/vote')
    ui_network:setParam('uid', uid)
    ui_network:setParam('didstr', did_str)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function requestEventVoteGetRanking
-- @brief 드래곤 투표 랭킹 정보
-------------------------------------
function ServerData_EventVote:requestEventVoteGetRanking(finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)

        -- 투표 정보
        self:applyDragonVoteResponse(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end
    
    -- 성공 시 콜백
    local function status_cb(ret)       
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/vote/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end