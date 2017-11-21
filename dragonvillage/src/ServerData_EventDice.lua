-------------------------------------
-- class ServerData_EventDice
-------------------------------------
ServerData_EventDice = class({
        m_lCellList = 'table',
        m_lLapList = 'table',

        m_diceInfo = 'StructEventDiceInfo',

        m_endTime = 'time',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventDice:init()
end

-------------------------------------
-- function getDiceInfo
-------------------------------------
function ServerData_EventDice:getDiceInfo()
    return self.m_diceInfo
end


-------------------------------------
-- function parseProductInfo
-------------------------------------
function ServerData_EventDice:parseProductInfo(product_info)
    self.m_productInfo = {}
    if (product_info) then
        local info = self.m_productInfo
        local step = product_info['step']
    
        for i = 1, step do
            local data = { step = i,
                           price = product_info['price_'..i], 
                           reward = product_info['mail_content_'..i] }
            table.insert(info, data)
        end
    end
end

-------------------------------------
-- function isGetReward
-- @brief 받은 보상인지 검사
-------------------------------------
function ServerData_EventDice:isGetReward(step)
    local step = tostring(step) 
    local reward_info = self.m_rewardInfo

    return (reward_info[step] == 1) and true or false
end

-------------------------------------
-- function hasReward
-- @brief 받아야 할 보상이 있는지 (누적 보상)
-------------------------------------
function ServerData_EventDice:hasReward()
    local event_info = self.m_productInfo
    local reward_info = self.m_rewardInfo

    local curr_cnt = self.m_nMaterialUse
    for i, v in ipairs(event_info) do
        local step = tostring(v['step'])
        local need_cnt = v['price']
        if (reward_info[step] == 0) and (curr_cnt >= need_cnt) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventDice:getStatusText()
    local curr_time = Timer:getServerTime()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
end

-------------------------------------
-- function confirm_reward
-- @brief 보상 정보
-------------------------------------
function ServerData_EventDice:confirm_reward(ret)
    local item_info = ret['item_info'] or nil
    if (item_info) then
        UI_MailRewardPopup(item_info)
    else
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

        g_highlightData:setHighlightMail()
    end
end

-------------------------------------
-- function request_eventInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventDice:request_eventInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)    
        self.m_lCellList = ret['cell_list']
        self.m_lLapList = ret['lap_list']

        self.m_diceInfo = StructEventDiceInfo(ret['dice_info'])

        self.m_endTime = ret['end']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/dice_info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_eventUse
-- @brief 이벤트 재화 사용
-------------------------------------
function ServerData_EventDice:request_eventUse(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)                    
        self:networkCommonRespone(ret)
        self:confirm_reward(ret)
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/event_use')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_eventReward
-- @brief 이벤트 재화 누적 보상
-------------------------------------
function ServerData_EventDice:request_eventReward(step, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)                    
        self:networkCommonRespone(ret)
        self:confirm_reward(ret)
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/event_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('step', step)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end