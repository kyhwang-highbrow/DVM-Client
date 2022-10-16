-------------------------------------
---@class ServerData_AccessTime
---@return ServerData_AccessTime
-------------------------------------
ServerData_AccessTime = class({
        m_serverData = 'ServerData',

        m_oriTime = 'number', -- 서버에 저장된 최종 접속시간
        m_addTime = 'number', -- 서버와 통신후 증가된 접속시간
        m_timer = 'number',
        m_timeSinceStartup = 'number', -- 구동 후 흐른 실제 시간 (초), lua number는 double 이므로 1.5억년은 버틸 수 있다.

        m_bRecord = 'boolean', -- 접속시간 기록 여부
        m_bEvent = 'boolean', -- 이벤트 진행중인지 (현재는 상시 이벤트)

        m_lEventData = 'list', -- 이벤트 보상 리스트
        m_lRewardData = 'list', -- 받은 보상 리스트

        m_checkTime = 'number',
    })

local TIMER_TICK = 1
local AUTO_SAVE_SEC = 1 * 60
local MAX_SAVE_SEC = 60 * 60

-------------------------------------
-- function init
-------------------------------------
function ServerData_AccessTime:init(server_data)
    self.m_serverData = server_data
    
    self.m_oriTime = 0
    self.m_addTime = 0
    self.m_timer = 0
    self.m_checkTime = 0
    self.m_timeSinceStartup = 0

    self.m_bRecord = true
    self.m_bEvent = false
end

-------------------------------------
-- function request_accessTime
-------------------------------------
function ServerData_AccessTime:request_accessTime(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:response_accessTime(ret)
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/access_time/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_accessTime
-------------------------------------
function ServerData_AccessTime:response_accessTime(ret)
    g_serverData:networkCommonRespone_addedItems(ret)
    self:networkCommonRespone(ret)
    self.m_lEventData = ret['table_access_time'] or nil
    self.m_lRewardData = ret['reward'] or nil
    self.m_bEvent = (self.m_lEventData) and true or false
end

-------------------------------------
-- function request_saveTime
-------------------------------------
function ServerData_AccessTime:request_saveTime(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 접속시간
    local time = self:getTime()

    -- 성공 콜백
    local function success_cb(ret)
		self:response_saveTime(ret, finish_cb)
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/access_time/update')
    ui_network:setLoadingMsg(Str('접속 동기화 중...'))
    ui_network:setParam('uid', uid)
    ui_network:setParam('access_time', time)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_saveTime
-------------------------------------
function ServerData_AccessTime:response_saveTime(ret, finish_cb)
    self:networkCommonRespone(ret)
    -- 접속시간 저장 후에도 보상정보 갱신 (날짜변경된 경우 갱신해줘야함)
    if (ret['reward']) then
        self.m_lRewardData = ret['reward']
    end

    if finish_cb then
        finish_cb(ret)
    end
end

-------------------------------------
-- function request_reward
-------------------------------------
function ServerData_AccessTime:request_reward(step, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 접속시간
    local time = self:getTime()

    -- 성공 콜백
    local function success_cb(ret)
        -- @analytics
        Analytics:trackGetGoodsWithRet(ret, '일일 접속 보상')

        g_serverData:networkCommonRespone_addedItems(ret)
        self:networkCommonRespone(ret)
        self.m_lRewardData = ret['reward'] or nil

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/access_time')
    ui_network:setParam('uid', uid)
    ui_network:setParam('access_time', time)
    ui_network:setParam('step', step)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function networkCommonRespone
-- @brief 서버와 통신후에는 addTime 항상 초기화 
-------------------------------------
function ServerData_AccessTime:networkCommonRespone(ret)
    self.m_oriTime = ret['access_time']
    self.m_addTime = 0
    self.m_timer = 0
end

-------------------------------------
-- function recordTime
-- @brief 글로벌 스케쥴러가 아닌 씬에 스케쥴러 등록 반복해줌 
-------------------------------------
function ServerData_AccessTime:recordTime(scene)
    if (not self.m_bEvent) or (not scene) then return end

    local function update(dt)
        if (not self.m_bRecord) then return end

        self.m_timer = (self.m_timer + dt)

        -- 배속 처리
        local time_scale = cc.Director:getInstance():getScheduler():getTimeScale()
        local tick = time_scale/TIMER_TICK

        while (self.m_timer >= tick) do
            self.m_timer = (self.m_timer - tick)
            self.m_addTime = self.m_addTime + TIMER_TICK
            self.m_checkTime = self.m_checkTime + TIMER_TICK
            self.m_timeSinceStartup = self.m_timeSinceStartup + TIMER_TICK
        end
    end

    scene:scheduleUpdateWithPriorityLua(update, 0)
end

-------------------------------------
-- function getTime
-------------------------------------
function ServerData_AccessTime:getTime(is_minute)
    local is_minute = is_minute or false
    local access_time = self.m_oriTime + self.m_addTime
    if (is_minute) then access_time = math_floor(access_time/60) end
    
    return access_time
end

-------------------------------------
-- function getSaveTime
-- @brief 로컬에 저장된 시간이 지정된 시간 이상이면 저장
-------------------------------------
function ServerData_AccessTime:getSaveTime()
    if (self.m_oriTime <= MAX_SAVE_SEC) and
       (self.m_addTime >= AUTO_SAVE_SEC) then
        return self:getTime()
    else
        return nil
    end
end

-------------------------------------
-- function getTimeSinceStartup
-------------------------------------
function ServerData_AccessTime:getTimeSinceStartup()
    return self.m_timeSinceStartup
end

-------------------------------------
-- function startCheckTimer
-------------------------------------
function ServerData_AccessTime:startCheckTimer()
    self.m_checkTime = 0
end

-------------------------------------
-- function getCheckTime
-------------------------------------
function ServerData_AccessTime:getCheckTime()
    return self.m_checkTime
end

-------------------------------------
-- function setRecordTime
-- @brief 백그라운드로 갈 경우 접속시간 누적시키지 않음
-------------------------------------
function ServerData_AccessTime:setRecordTime(record)
    self.m_bRecord = record or false
end

-------------------------------------
-- function isGetReward
-- @brief 받은 보상인지 검사
-------------------------------------
function ServerData_AccessTime:isGetReward(step)
    local step = tostring(step) 
    local reward_info = self.m_lRewardData

    return reward_info[step] and true or false
end

-------------------------------------
-- function hasReward
-- @brief 받아야 할 보상이 있는지
-------------------------------------
function ServerData_AccessTime:hasReward()
    local event_info = self.m_lEventData
    local reward_info = self.m_lRewardData
    local curr_time = self:getTime()

    for i, v in ipairs(event_info) do
        local step = tostring(v['step'])
        local need_time = v['time']
        if (not reward_info[step]) and (curr_time >= need_time) then
            return true
        end
    end

    return false
end



