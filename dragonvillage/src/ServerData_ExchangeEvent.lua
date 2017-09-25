-------------------------------------
-- class ServerData_ExchangeEvent
-------------------------------------
ServerData_ExchangeEvent = class({
        m_serverData = 'ServerData',

        m_nMaterialCnt = 'number', -- 재화 보유량
        m_nMaterialGet = 'number', -- 재화 획득량
        m_nMaterialUse = 'number', -- 재화 누적 소모량

        m_productInfo = 'map', -- 교환 상품 정보
        m_rewardInfo = 'map', -- 보상 정보

        m_endTime = 'number', -- 종료 시간
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ExchangeEvent:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function parseProductInfo
-------------------------------------
function ServerData_ExchangeEvent:parseProductInfo(product_info)
    self.m_productInfo = {}
    local info = self.m_productInfo
    local step = product_info['step']
    
    for i = 1, step do
        local data = { step = i,
                       price = product_info['price_'..i], 
                       reward = product_info['mail_content_'..i] }
        table.insert(info, data)
    end
end

-------------------------------------
-- function isGetReward
-- @brief 받은 보상인지 검사
-------------------------------------
function ServerData_ExchangeEvent:isGetReward(step)
    local step = tostring(step) 
    local reward_info = self.m_rewardInfo

    return (reward_info[step] == 1) and true or false
end

-------------------------------------
-- function hasReward
-- @brief 받아야 할 보상이 있는지 (누적 보상)
-------------------------------------
function ServerData_ExchangeEvent:hasReward()
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
function ServerData_ExchangeEvent:getStatusText()
    local curr_time = Timer:getServerTime()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
end

-------------------------------------
-- function networkCommonRespone
-------------------------------------
function ServerData_ExchangeEvent:networkCommonRespone(ret)
    self.m_nMaterialCnt = ret['event'] or 0
    self.m_nMaterialGet = ret['event_get'] or 0
    self.m_nMaterialUse = ret['event_use'] or 0

    if (ret['event_reward']) then
        self.m_rewardInfo = ret['event_reward']
    end
end

-------------------------------------
-- function request_eventInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_ExchangeEvent:request_eventInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)    
        self:networkCommonRespone(ret)
        self:parseProductInfo(ret['table_event_product'][1])
        
        self.m_endTime = ret['end']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/event_info')
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
function ServerData_ExchangeEvent:request_eventUse(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)                    
        self:networkCommonRespone(ret)

        g_highlightData:setHighlightMail()
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

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
function ServerData_ExchangeEvent:request_eventReward(step, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)                    
        self:networkCommonRespone(ret)

        g_highlightData:setHighlightMail()
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

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