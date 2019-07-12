-------------------------------------
-- class ServerData_PurchasePoint
-- @instance g_purchasePointData
-------------------------------------
ServerData_PurchasePoint = class({
        m_serverData = 'ServerData',
        m_purchasePointInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_PurchasePoint:init(server_data)
    self.m_serverData = server_data
    self.m_purchasePointInfo = {}
end

-------------------------------------
-- function response_purchasePointInfo
-- @brief
-- @used_at API:/users/lobby
-------------------------------------
function ServerData_PurchasePoint:response_purchasePointInfo(ret, finish_cb)
    self:applyPurchasePointInfo(ret['purchase_point_info'])

    if finish_cb then
        finish_cb(ret)
    end
end

-------------------------------------
-- function applyPurchasePointInfo
-- @brief
-------------------------------------
function ServerData_PurchasePoint:applyPurchasePointInfo(t_data)
    if (not t_data) then
        return
    end
    -- t_dat : ret에 purchase_point_info라는 key 값으로 아래와 같은 형태로 전달됨
    -- start, end : timestamp
    --"purchase_point_info": {
    --    "purchase_point_list": {
    --        "1010001": {
    --            "end": 1539788400000,
    --            "start": 1538578800000,
    --            "start_day":"20190213"
    --            "is_start":1,
    --            "step_list": {
    --                "2": {
    --                    "item": "700002;5000000",
    --                    "purchase_point": 50000
    --                },
    --                "4": {
    --                    "item": "770455;1",
    --                    "purchase_point": 300000
    --                },
    --                "1": {
    --                    "item": "700402;3",
    --                    "purchase_point": 1
    --                },
    --                "3": {
    --                    "item": "700001;10000",
    --                    "purchase_point": 100000
    --                }
    --            }
    --        }
    --    },
    --    "purchase_point_reward": {
    --        "1010001": 0
    --    },
    --    "purchase_point": {
    --        "1010001": 60
    --    }
    --}

    if (not self.m_purchasePointInfo) then
        self.m_purchasePointInfo = {}
    end
    
    if t_data['purchase_point_list'] then
        self.m_purchasePointInfo['purchase_point_list'] = t_data['purchase_point_list']
    end

    if t_data['purchase_point'] then
        self.m_purchasePointInfo['purchase_point'] = t_data['purchase_point']
    end

    if t_data['purchase_point_reward'] then
        self.m_purchasePointInfo['purchase_point_reward'] = t_data['purchase_point_reward']
    end
end

-------------------------------------
-- function request_purchasePointReward
-------------------------------------
function ServerData_PurchasePoint:request_purchasePointReward(version, reward_step, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self.m_purchasePointInfo['purchase_point_reward'][version] = ret['purchase_point_info']['purchase_point_reward'][version]
        -- 보상 획득 UI
        -- ItemObtainResult(ret) -- UI 에서 출력함

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/purchase_point/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('version', version)
    ui_network:setParam('reward_step', reward_step)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function hasPurchasePointReward
-- @brief
-------------------------------------
function ServerData_PurchasePoint:hasPurchasePointReward()
    local purchase_point_list = self.m_purchasePointInfo['purchase_point_list'] or {}

    for version, t_data in pairs(purchase_point_list) do
        local curr_purchase_point = self:getPurchasePoint(version)
        local curr_purchase_reward_step = self:getPurchaseRewardStep(version)
        for i,v in pairs(t_data['step_list']) do
            -- 다음 보상이 획득 가능하지 확인
            if (tonumber(i) == (curr_purchase_reward_step + 1)) then
                if (v['purchase_point'] <= curr_purchase_point) then
                    return true
                end
            end
        end
    end

    return false
end

-------------------------------------
-- function getPurchasePoint
-- @brief
-------------------------------------
function ServerData_PurchasePoint:getPurchasePoint(version)
   local purchase_point = self.m_purchasePointInfo['purchase_point'] or {}
   return purchase_point[tostring(version)] or 0
end

-------------------------------------
-- function getPurchaseRewardStep
-- @brief
-------------------------------------
function ServerData_PurchasePoint:getPurchaseRewardStep(version)
   local purchase_point_reward = self.m_purchasePointInfo['purchase_point_reward'] or {}
   return purchase_point_reward[tostring(version)] or 0
end

-------------------------------------
-- function getPurchasePointEventRemainTime
-- @brief event 항목의 남은 시간
-- @return sec
-------------------------------------
function ServerData_PurchasePoint:getPurchasePointEventRemainTime(version)
    local purchase_point_info = self:getPurchasePointInfo(version)

    if (not purchase_point_info) then
        return 0
    end

    local end_time = purchase_point_info['end']
    if (not end_time) or (end_time == 0) then
        return 0
    end

    end_time = end_time / 1000

    local curr_time = Timer:getServerTime()
    local time = (end_time - curr_time)

    return time
end

-------------------------------------
-- function getPurchasePointEventRemainTime_milliSecond
-- @brief event 항목의 남은 시간
-- @return sec
-------------------------------------
function ServerData_PurchasePoint:getPurchasePointEventRemainTime_milliSecond(version)
    local purchase_point_info = self:getPurchasePointInfo(version)

    if (not purchase_point_info) then
        return 0
    end

    local end_time = purchase_point_info['end']
    if (not end_time) or (end_time == 0) then
        return 0
    end

    end_time = end_time

    local curr_time = Timer:getServerTime_Milliseconds()
    local time = (end_time - curr_time)

    return time
end

-------------------------------------
-- function getPurchasePointEventRemainTimeText
-- @brief event 항목의 남은 시간 텍스트
-------------------------------------
function ServerData_PurchasePoint:getPurchasePointEventRemainTimeText(version)
	local time = self:getPurchasePointEventRemainTime(version)
    if (time > 0) then
        local time_str = Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time))
        return time_str
    else
        return ''
    end
end

-------------------------------------
-- function getEventPopupTabList
-- @brief UI_EventPopup의 탭 리스트 생성 용도
-------------------------------------
function ServerData_PurchasePoint:getEventPopupTabList()
    local purchase_point_list = self.m_purchasePointInfo['purchase_point_list'] or {}

    local l_item_list = {}

    for version,v in pairs(purchase_point_list) do
        if self:isActivePurchasePointEvent(version) then
            local event_data = {}
            event_data['t_name'] = Str('누적 결제 이벤트')
            event_data['icon'] = 'ui/event/list_purchase_point.png'
            event_data['version'] = version

            local struct_event_popup_tab = StructEventPopupTab(event_data)
            local type_name = 'purchase_point_' .. version
            struct_event_popup_tab.m_type = type_name
            struct_event_popup_tab.m_sortIdx = 0

            -- 획득 가능한 보상이 있는지 확인
            local curr_purchase_point = self:getPurchasePoint(version)
            local curr_purchase_reward_step = self:getPurchaseRewardStep(version)
            struct_event_popup_tab.m_hasNoti = false
            for i,v in pairs(v['step_list']) do
                -- 다음 보상이 획득 가능하지 확인
                if (tonumber(i) == (curr_purchase_reward_step + 1)) then
                    if (v['purchase_point'] <= curr_purchase_point) then
                        struct_event_popup_tab.m_hasNoti = true
                        break
                    end
                end
            end

            l_item_list[type_name] = struct_event_popup_tab
        end
    end

    return l_item_list
end


-------------------------------------
-- function getPurchasePointInfo
-- @brief 해당 버전에 대한 정보 리턴 (row data)
-------------------------------------
function ServerData_PurchasePoint:getPurchasePointInfo(version)
    local version = tostring(version)
    local purchase_point_list = self.m_purchasePointInfo['purchase_point_list'] or {}

    if (not purchase_point_list) then
        return nil
    end

    return purchase_point_list[version]
end

-------------------------------------
-- function getPurchasePoint_rewardStepInfo
-- @brief 해당 버전, 해당 보상 스텝에 대한 정보 리턴
-------------------------------------
function ServerData_PurchasePoint:getPurchasePoint_rewardStepInfo(version, step)
    local purchase_point_info = self:getPurchasePointInfo(version)
    if (not purchase_point_info) then
        return nil
    end

    local step_list = purchase_point_info['step_list'] or {}
    local t_step = step_list[tostring(step)]
    -- "item": "700001;10000",
	-- "purchase_point": 100000
    
    if (not t_step) then
        return nil
    end

    local reward_state = nil
    local step_num = tonumber(step)
    local curr_step = self:getPurchaseRewardStep(version)
    local next_step = (curr_step + 1)
    local curr_point = self:getPurchasePoint(version)

    -- 획득 완료
    if (step_num <= curr_step) then
        reward_state = 1

    -- 획득 가능
    elseif (step_num == next_step) and (t_step['purchase_point'] <= curr_point) then
        reward_state = 0

    -- 획득 불가
    else
        reward_state = -1
    end

    return t_step, reward_state
end

-------------------------------------
-- function getPurchasePoint_stepCount
-- @breif 해당 버전의 보상 단계 갯수 리턴
-------------------------------------
function ServerData_PurchasePoint:getPurchasePoint_stepCount(version)
    local purchase_point_info = self:getPurchasePointInfo(version)
    if (not purchase_point_info) then
        return 0
    end

    local step_list = purchase_point_info['step_list'] or {}
    local count = table.count(step_list)
    return count
end

-------------------------------------
-- function getLastRewardType
-- @breif 최종 보상 타입 반환
-------------------------------------
function ServerData_PurchasePoint:getLastRewardType(version)
    local last_step = self:getPurchasePoint_stepCount(version)
    local t_last_reward = self:getPurchasePoint_rewardStepInfo(version, last_step)
    local reward_type = t_last_reward['reward_type']
    return reward_type
end

-------------------------------------
-- function getLastRewardDesc
-- @breif 최종 보상 설명 반환
-------------------------------------
function ServerData_PurchasePoint:getLastRewardDesc(version)
    local last_step = self:getPurchasePoint_stepCount(version)
    local t_last_reward = self:getPurchasePoint_rewardStepInfo(version, last_step)
    
    if (not t_last_reward) then
        return ''
    end
    
    local reward_desc = t_last_reward['t_desc']
    return Str(reward_desc)
end

-------------------------------------
-- function getPurchasePoint_stepCount
-- @breif 해당 버전의 시간 정보 리턴
-------------------------------------
function ServerData_PurchasePoint:getPurchasePointTime(version)
    local purchase_point_info = self:getPurchasePointInfo(version)
    if (not purchase_point_info) then
        return 0
    end

    local time_str = ''

    -- 업데이트 이후부터 시작 : 2/13 업데이트 이후 ~ 다음 안내시까지
    -- 지정한 시간 부터 시작 : 2/13 00:00 ~ 다음 안내시까지
    local is_after_update = purchase_point_info['is_start'] or 0
    local start_time = purchase_point_info['start_day']
    local start_month = string.sub(start_time, 5, 6)
    local start_day = string.sub(start_time, 7, 8)
    local start_str = Str('{1}/{2}', tonumber(start_month), tonumber(start_day))

    if (is_after_update == 1) then
        time_str = Str('{1} 점검 후 ~ 다음 안내시까지', start_str)
    else
        time_str = Str('{1} ~ 다음 안내시까지', start_str .. ' 00:00')
    end

    return time_str
end


-------------------------------------
-- function getPurchasePoint_lastStepPoint
-- @breif
-------------------------------------
function ServerData_PurchasePoint:getPurchasePoint_lastStepPoint(version)
    local cnt = self:getPurchasePoint_stepCount(version)
    return self:getPurchasePoint_step(version, cnt)
end

-------------------------------------
-- function getPurchasePoint_step
-- @breif
-------------------------------------
function ServerData_PurchasePoint:getPurchasePoint_step(version, step)
    local t_step, reward_state = self:getPurchasePoint_rewardStepInfo(version, step)
    if (not t_step) then
        return 0
    end

    local purchase_point = (t_step['purchase_point'] or 0)
    return purchase_point
end

-------------------------------------
-- function isActivePurchasePointEvent
-- @brief 해당 버전이 활성화 상태인지 여부
-------------------------------------
function ServerData_PurchasePoint:isActivePurchasePointEvent(version)
    -- 핫타임에  event_purchase_point 가 설정되어 있어야 함
    if (not g_hotTimeData) then
        return false
    end
    
    -- 핫타임에  event_purchase_point 가 설정되어 있어야 함
    if (not g_hotTimeData:isActiveEvent('event_purchase_point')) then
        return false
    end

    -- 해당 버전 정보가 없는 경우
    local purchase_point_info = self:getPurchasePointInfo(version)
    if (not purchase_point_info) then
        return false
    end

    local curr_time = Timer:getServerTime()
    local start_time = purchase_point_info['start'] / 1000
    local end_time = purchase_point_info['end'] / 1000
    
    -- 이벤트 시작 시간 전
    if (curr_time < start_time) then
        return false
    end

    -- 이벤트 시작 시간 후
    if (end_time < curr_time) then
        return false
    end

    return true
end