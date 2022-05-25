-------------------------------------
-- class ServerData_EventImageQuiz
-- @instance g_eventImageQuizData
-- @brief 드래곤 이미지 퀴즈 이벤트
-------------------------------------
ServerData_EventImageQuiz = class({
    m_gameKey = 'number',

    m_ticket = 'number', -- 입장권

    m_playCount = 'number', -- 누적 플레이 횟수
    m_score = 'number',

    -- 누적 플레이 보상 리스트 / 수령 여부
    m_lProductInfoPlay = 'list',
    m_mRewardInfoPlay = 'map',

    -- 누적 점수 보상 리스트 / 수령 여부
    m_lProductInfoScore = 'list', 
    m_mRewardInfoScore = 'map',

    -- 각 모드별 입장권 획득 정보
    m_ticketDropInfo = 'map',

    m_endTime = 'time',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventImageQuiz:init()
end

-------------------------------------
-- function getInstance
-------------------------------------
function ServerData_EventImageQuiz:getInstance()
    if (not g_eventImageQuizData) then
        g_eventImageQuizData = ServerData_EventImageQuiz()
    end

    return g_eventImageQuizData
end

-------------------------------------
-- function getTicketCount
-------------------------------------
function ServerData_EventImageQuiz:getTicketCount()
    return self.m_ticket or 0
end

-------------------------------------
-- function getPlayCount
-------------------------------------
function ServerData_EventImageQuiz:getPlayCount()
    return self.m_playCount
end

-------------------------------------
-- function getScore
-------------------------------------
function ServerData_EventImageQuiz:getScore()
    return self.m_score
end

-------------------------------------
-- function getProductInfo
-------------------------------------
function ServerData_EventImageQuiz:getProductInfo(info_type)
    if (info_type == 'play') then
        return self.m_lProductInfoPlay
    elseif (info_type == 'score') then
        return self.m_lProductInfoScore
    end
end

-------------------------------------
-- function getRewardInfo
-------------------------------------
function ServerData_EventImageQuiz:getRewardInfo(info_type)
    if (info_type == 'play') then
        return self.m_mRewardInfoPlay
    elseif (info_type == 'score') then
        return self.m_mRewardInfoScore
    end
end

-------------------------------------
-- function getTicketInfo
-------------------------------------
function ServerData_EventImageQuiz:getTicketInfo()
    return self.m_ticketDropInfo or {}
end

-------------------------------------
-- function parseProductInfo
-------------------------------------
function ServerData_EventImageQuiz:parseProductInfo(product_info)
    local l_ret = {}
    if (product_info) then
        local step = product_info['step']
        for i = 1, step do
            local data = { step = i,
                           price = product_info['price_'..i], 
                           reward = product_info['mail_content_'..i] }
            table.insert(l_ret, data)
        end
    end
    
    table.sort(l_ret, function(a, b)
        return tonumber(a['step']) < tonumber(b['step'])
    end)

    return l_ret
end

-------------------------------------
-- function getEndTimeText
-------------------------------------
function ServerData_EventImageQuiz:getEndTimeText()
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
end

-------------------------------------
-- function confirm_reward
-- @brief 보상 정보
-------------------------------------
function ServerData_EventImageQuiz:confirm_reward(ret)
    -- 테이머 코스튬 수령 처리
    -- @mskim 코스튬도 우편으로 받을 수 있도록 처리하는 것이 좋지 않을까?
    if (ret['tamers_costume']) then
        g_tamerCostumeData.m_bDirtyCostumeInfo = true
        local toast_msg = Str('테이머 관리에서 코스튬을 선택할 수 있습니다.')
        UI_ToastPopup(toast_msg)
        
    else
        local item_info = ret['item_info'] or nil
        if (item_info) then
            UI_MailRewardPopup(item_info)
        else
            local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
            UI_ToastPopup(toast_msg)

            g_highlightData:setHighlightMail()
        end

    end
end

-------------------------------------
-- function isGetReward
-- @brief 받은 보상인지 검사
-------------------------------------
function ServerData_EventImageQuiz:isGetReward(step, reward_type)
    local step = tostring(step) 
    local reward_info = reward_type == 'play' and self.m_mRewardInfoPlay or self.m_mRewardInfoScore

    return (reward_info[step] == 1) and true or false
end

-------------------------------------
-- function networkCommonRespone
-------------------------------------
function ServerData_EventImageQuiz:responseCommonData(ret)
    if (not ret) then 
        return
    end

    -- 입장권
    if (ret['ticket']) then
        self.m_ticket = ret['ticket']
    end

    -- 누적 플레이 횟수
    if (ret['play_cnt']) then
        self.m_playCount = ret['play_cnt']
    end

    -- 누적 점수
    if (ret['score']) then
        self.m_score = ret['score']
    end

    -- 이벤트 종료 시간
    if (ret['end']) then
        self.m_endTime = ret['end']
    end

    -- 누적 점수
    if (ret['score_info']) then
        -- 누적 점수 보상 리스트
        self.m_lProductInfoScore = self:parseProductInfo(ret['score_info']['product'])
        
        -- 누적 점수 보상 획득 정보
        self.m_mRewardInfoScore = ret['score_info']['reward']
    end

    -- 누적 플레이
    if (ret['play_info']) then
        -- 누적 플레이 보상 리스트
        self.m_lProductInfoPlay = self:parseProductInfo(ret['play_info']['product'])

        -- 누적 플레이 보상 획득 정보
        self.m_mRewardInfoPlay = ret['play_info']['reward']
    end

    -- 입장권 획득 정보
    if (ret['ticket_info']) then
        self.m_ticketDropInfo = ret['ticket_info']
        self.m_ticketDropInfo['day'] = nil
    end
end

-------------------------------------
-- function request_eventImageQuizInfo
-------------------------------------
function ServerData_EventImageQuiz:request_eventImageQuizInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:responseCommonData(ret['event_imagequiz_info'])
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/event_imagequiz/info')
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
-- function request_clearReward
-- @brief 황금던전 클리어 누적보상
-------------------------------------
function ServerData_EventImageQuiz:request_clearReward(step, reward_type, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)                    
        g_serverData:networkCommonRespone(ret)
        
        self:responseCommonData(ret['event_imagequiz_info'])
        self:confirm_reward(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/event_imagequiz/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', reward_type)
    ui_network:setParam('step', step)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_eventImageQuizStart
-------------------------------------
function ServerData_EventImageQuiz:request_eventImageQuizStart(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self.m_gameKey = ret['gamekey']

        -- 스피드핵 방지 실제 플레이 시간 기록
        g_accessTimeData:startCheckTimer()

        if finish_cb then
            finish_cb()
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/event_imagequiz/start')
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
-- function request_eventImageQuizFinish
-------------------------------------
function ServerData_EventImageQuiz:request_eventImageQuizFinish(clear_cnt, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:responseCommonData(ret['event_imagequiz_info'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/event_imagequiz/finish')
    ui_network:setParam('uid', uid)
    ui_network:setParam('gamekey', self.m_gameKey)
    ui_network:setParam('clear_cnt', clear_cnt)
    ui_network:setParam('check_time', g_accessTimeData:getCheckTime())
    ui_network:setParam('access_time', g_accessTimeData:getTime())
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function hasReward
-- @brief 받아야 할 보상이 있는지 (누적 점수 & 누적 플레이)
-------------------------------------
function ServerData_EventImageQuiz:hasReward(reward_type)
    if (self.m_lProductInfoPlay == nil or self.m_lProductInfoScore == nil) then
        return false
    end

    local event_info
    local reward_info
    local curr_cnt

    if (reward_type == 'play') then
        event_info = self.m_lProductInfoPlay
        reward_info = self.m_mRewardInfoPlay
        curr_cnt = self.m_playCount
    elseif (reward_type == 'score') then
        event_info = self.m_lProductInfoScore
        reward_info = self.m_mRewardInfoScore
        curr_cnt = self.m_score
    end

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
-- function isHighlightRed_imageQuiz
-- @brief 빨간 느낌표 아이콘 출력 여부
--        획득 가능한 보상이 있을 경우
-------------------------------------
function ServerData_EventImageQuiz:isHighlightRed_imageQuiz()
    return self:hasReward('play') or self:hasReward('score')
end

-------------------------------------
-- function isHighlightYellow_imageQuiz
-- @brief 노란 느낌표 아이콘 출력 여부
--        주요 상품의 교환 가능 횟수가 남아있을 경우
-------------------------------------
function ServerData_EventImageQuiz:isHighlightYellow_imageQuiz()
    if (self.m_ticket == nil) then
        return false
    end
    return self.m_ticket > 0
end