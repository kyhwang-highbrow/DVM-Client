-------------------------------------
-- class ServerData_EventArenaPlay
-------------------------------------
ServerData_EventArenaPlay = class({
        m_serverData = 'ServerData',

        m_eventData = 'Table',


    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventArenaPlay:init(server_data)
        self.m_serverData = server_data
end

-------------------------------------
-- function request_eventData
-------------------------------------
function ServerData_EventArenaPlay:request_eventData(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self.m_eventData = ret['event_arena_play_info']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/event_arena_play/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function init
-------------------------------------
function ServerData_EventArenaPlay:request_eventReward(reward_type, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local type = reward_type

    -- 콜백
    local function success_cb(ret)
        -- 보상수령은 우편함으로...

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/event_arena_play/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', type)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end



-------------------------------------
-- function getRemainEventTimeStr
-- @breif 초기화
-------------------------------------
function ServerData_EventArenaPlay:getRemainEventTimeStr()
    if not self.m_eventData then return '' end

    local expire_time = self.m_eventData['end']
    local server_time = Timer:getServerTime()
    local msg = ''
    time = (expire_time/1000 - server_time)

    if (time > 0) then
        enable = false
        local show_second = true
        local first_only = false
        
        msg = Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, show_second, first_only))
    end

    return msg
end

-------------------------------------
-- function getWinRewardInfo
-- @breif 승리 횟수 보상
-------------------------------------
function ServerData_EventArenaPlay:getWinRewardInfo()
    local list = {}

    if (self.m_eventData) then
        list = self.m_eventData['win_info']
    end

    return list
end

-------------------------------------
-- function getPlayRewardInfo
-- @breif 참여 횟수 보상
-------------------------------------
function ServerData_EventArenaPlay:getPlayRewardInfo()
    local list = {}

    if (self.m_eventData) then
        list = self.m_eventData['play_info']
    end

    return list
end


-------------------------------------
-- function getPlayCount
-- @breif 참여 횟수 보상
-------------------------------------
function ServerData_EventArenaPlay:getPlayCount()
    local count = 0

    if (self.m_eventData) then
        count = self.m_eventData['play_cnt']
    end

    return count
end

-------------------------------------
-- function getWinCount
-- @breif 승리 횟수 보상
-------------------------------------
function ServerData_EventArenaPlay:getWinCount()
    local count = 0

    if (self.m_eventData) then
        count = self.m_eventData['win_cnt']
    end

    return count
end

-------------------------------------
-- function hasReward
-- @breif 받을 보상이 있는지?
-------------------------------------
function ServerData_EventArenaPlay:hasReward(reward_type)
    local has_reward = false
    local reward_info
    local reward_step
    local play_count

    if (reward_type == 'play') then
        reward_info = self:getPlayRewardInfo()
        reward_step = reward_info['product']['step']
        play_count  = self:getPlayCount()

    else
        reward_info = self:getWinRewardInfo()
        reward_step = reward_info['product']['step']
        play_count  = self:getWinCount()

    end

    for idx = 1, reward_step do
        local is_received = reward_info['reward'][tostring(idx)] == 1
        local is_larger_number = play_count >= reward_info['product']['price_' .. idx]

        if (is_larger_number) and (not is_received) then
            has_reward = true
            break
        end
    end

    return has_reward
end