-------------------------------------
-- class ServerData_EventMatchCard
-------------------------------------
ServerData_EventMatchCard = class({
        m_boardInfo = 'table',
        m_ticket = 'number', -- 입장권
        m_cardGift = 'number', -- 아이템 교환권
        m_endTime = 'time',

        m_accessTimeInfo = 'table', -- 접속 시간 보상 정보
        m_accessTimeRecievedInfo = 'table', -- 받은 보상 정보

        m_productInfo = 'table', -- 누적 교환 보상 정보
        m_productRecievedInfo = 'table', -- 받은 보상 정보
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventMatchCard:init()
end

-------------------------------------
-- function networkCommonRespone
-------------------------------------
function ServerData_EventMatchCard:networkCommonRespone(ret)
    if (ret['card_play']) then
        self.m_ticket = ret['card_play']
    end

    if (ret['card_gift']) then
        self.m_cardGift = ret['card_gift']
    end

    if (ret['card_exchange']) then
        self.m_productRecievedInfo = ret['card_exchange']
    end

    if (ret['reward']) then
        self.m_accessTimeRecievedInfo = ret['reward']
    end

    if (ret['end']) then
        self.m_endTime = ret['end']
    end
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventMatchCard:getStatusText()
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
end

-------------------------------------
-- function isGetTicket
-- @brief 받은 보상인지 검사
-------------------------------------
function ServerData_EventMatchCard:isGetTicket(step)
    local step = tostring(step) 
    local reward_info = self.m_accessTimeRecievedInfo

    -- 첫 접속은 무조건 받은 보상으로 판단
    if (step == '0') then
        return true
    end

    return reward_info[step] and true or false
end

-------------------------------------
-- function parseProductInfo
-------------------------------------
function ServerData_EventMatchCard:parseProductInfo(product_info)
    self.m_productInfo = {}
    if (product_info) then
        local info = self.m_productInfo
        local step = product_info['step']
    
        for i = 1, step do
            local data = { step = i,
                           max_buy_cnt = product_info['buy_count_'..i], 
                           price = product_info['price_'..i], 
                           reward = product_info['mail_content_'..i] }
            table.insert(info, data)
        end
    end
end

-------------------------------------
-- function setBoardInfo
-------------------------------------
function ServerData_EventMatchCard:setBoardInfo(board_info)
    self.m_boardInfo = {}
    for k, v in pairs(board_info) do
        local data = {
            slot = k,
            pair = v['pair'],
            grade = v['grade']
        }

        self.m_boardInfo[k] = data
    end
end

-------------------------------------
-- function getBuyCnt
-- @brief 
-------------------------------------
function ServerData_EventMatchCard:getBuyCnt(step)
    local step = tostring(step) 
    local reward_info = self.m_productRecievedInfo
    return reward_info[step] or 0
end

-------------------------------------
-- function request_eventInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventMatchCard:request_eventInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:networkCommonRespone(ret)
        self.m_accessTimeInfo = ret['table_event_access_time']
        -- 접속시 주는 입장권 UI에 표시 하기 위해 임시 데이터 넣어줌
        local temp_data = {
            step = 0,
            time = 0
        }
        table.insert(self.m_accessTimeInfo, temp_data)

        self:parseProductInfo(ret['table_event_product'][1])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/match_card/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_playStart
-- @brief 게임 시작
-------------------------------------
function ServerData_EventMatchCard:request_playStart(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:networkCommonRespone(ret)
        self:setBoardInfo(ret['board'])
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/match_card/start')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_playFinish
-- @brief 게임 종료
-------------------------------------
function ServerData_EventMatchCard:request_playFinish(str_grade, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:networkCommonRespone(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/match_card/finish')
    ui_network:setParam('uid', uid)
    ui_network:setParam('grades', str_grade)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_timeReward
-- @brief 티켓 수령
-------------------------------------
function ServerData_EventMatchCard:request_timeReward(step, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 접속시간
    local time = g_accessTimeData:getTime()

    -- 콜백
    local function success_cb(ret)
        self:networkCommonRespone(ret)
        
        UIManager:toastNotificationGreen(Str('이용권을 획득하였습니다.'))

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/access_time')
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
-- function request_productReward
-- @brief 보상 교환
-------------------------------------
function ServerData_EventMatchCard:request_productReward(step, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:networkCommonRespone(ret)
        ItemObtainResult_Shop(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/match_card/exchange')
    ui_network:setParam('uid', uid)
    ui_network:setParam('step', step)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end
