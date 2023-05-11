-------------------------------------
-- class ServerData_EventVote
-------------------------------------
ServerData_EventVote = class({
    m_dragonMap = 'Map<StructDragonObject>', -- 신화 드래곤 리스트
    m_rewardMap = 'Map<>', -- 투표 보상 리스트
    m_eventVoteCount = 'number', -- 튜표 횟수
    m_staminaDropInfo = 'Map<>', -- 투표권 획득 플레이 요구 사항
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventVote:init(server_data)
    self.m_dragonMap = {}
    self.m_rewardMap = {}
    self.m_eventVoteCount = 0
    self.m_staminaDropInfo = {}
end

-------------------------------------
-- function applyDragonVoteResponse
-- @brief 투표 대상 드래곤 리스트 세팅
-------------------------------------
function ServerData_EventVote:applyDragonVoteResponse(t_ret)

    -- 드래곤 리스트
    if t_ret['event_vote_dragon_list'] ~= nil then
        local dragon_list = t_ret['event_vote_dragon_list']
        self.m_dragonMap = {}

        for _, did in ipairs(dragon_list) do
            local t_dragon_data = {}
            t_dragon_data['did'] = did
            t_dragon_data['evolution'] = 3
            t_dragon_data['grade'] = 6
            local struct_dragon = StructDragonObject(t_dragon_data)
            table.insert(self.m_dragonMap, struct_dragon)
        end
    end

    -- 투표 확률 보상 정보
    if t_ret['event_vote_reward'] ~= nil then
        self.m_rewardMap = {}
        local vote_reward_map = t_ret['event_vote_reward']

        for item_id, v in pairs(vote_reward_map) do
            self.m_rewardMap[tonumber(item_id)] = clone(v)
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
        g_serverData:networkCommonRespone(ret)

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