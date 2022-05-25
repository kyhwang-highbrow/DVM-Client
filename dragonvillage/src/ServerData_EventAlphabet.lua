-------------------------------------
-- class ServerData_EventAlphabet
-------------------------------------
ServerData_EventAlphabet = class({
        m_exchangeInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventAlphabet:init()
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventAlphabet:getStatusText()
    local time = g_hotTimeData:getEventRemainTime('event_alphabet') or 0
    return Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
end

-------------------------------------
-- function confirm_reward
-- @brief 보상 정보
-------------------------------------
function ServerData_EventAlphabet:confirm_reward(ret)
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
-- function request_alphabetEventInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventAlphabet:request_alphabetEventInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:response_alphabetEvent(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/alphabet_event/info')
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
-- function request_alphabetEventReward
-- @brief 단어 조합 보상
-------------------------------------
function ServerData_EventAlphabet:request_alphabetEventReward(finish_cb, reward_id)

    -- 와일드 알파벳이 사용된 숫자 체크
    local t_word_data = self:getAlphabetEvent_WordData(reward_id)
    local wild_cnt = t_word_data['wild_alphabet_cnt'] or 0

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:response_alphabetEvent(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/alphabet_event/reward')
    ui_network:setParam('uid', uid)
	ui_network:setParam('reward_id', reward_id)
    ui_network:setParam('wild_cnt', wild_cnt)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    -- 에러 코드 (통신상의 이슈로 서버와 클라이언트의 데이터가 일치하지 않을 때 발생할 수 있음)
    -- NOT_ENOUGH ALPHABET -1237
    -- INVALID ALPHABET -1337

    return ui_network
end

-------------------------------------
-- function response_alphabetEvent
-- @brief
-------------------------------------
function ServerData_EventAlphabet:response_alphabetEvent(ret)
    -- 알파벳 테이블을 서버에서 받아옴
    if ret['table_alphabet_event'] then
        TABLE:setServerTable('table_alphabet_event', ret['table_alphabet_event'])
    end

    -- server_info 정보를 갱신
	g_serverData:networkCommonRespone(ret)

    -- 보상 획득 정보
    if ret['exchange_info'] then
        self.m_exchangeInfo = ret['exchange_info']
    end
end

-------------------------------------
-- function getAlphabetEvent_WordData
-- @brief
-------------------------------------
function ServerData_EventAlphabet:getAlphabetEvent_WordData(word_id)
    -- 교환 횟수
    -- 최대 교환 횟수

    -- max                  모두 교환
    -- not_exchangeable     교환 불가
    -- exchangeable         교환 가능 (일반 알파벳만 사용)
    -- exchangeable_wild    (와일드 알파벳 사용)

    local t_word_data = {}
    t_word_data['exchange_cnt'] = self.m_exchangeInfo['event_alphabet_' .. word_id] or 0
    t_word_data['exchange_max'] = TableAlphabetEvent():getValue(word_id, 'buy_count') or 0
    t_word_data['wild_alphabet_cnt'] = 0
    t_word_data['status'] = 'not_exchangeable'


    local status = 'not_exchangeable'
    if (t_word_data['exchange_max'] <= t_word_data['exchange_cnt']) then
        status = 'max'
    else
        local l_alphabet = TableAlphabetEvent:getAlphabetList(word_id)

        -- clone된 알파벳 수량
        local alphabet_data = g_userData:get('alphabet')
        if (not alphabet_data['700299']) then
            alphabet_data['700299'] = 0
        end
        
        local wild_alphabet_cnt = 0
        local exchangeable = true

        for _,item_id in ipairs(l_alphabet) do

            local item_id_str = tostring(item_id)
            if (not alphabet_data[item_id_str]) then
                alphabet_data[item_id_str] = 0
            end

            if (alphabet_data[item_id_str] <= 0) then
                if (alphabet_data['700299'] <= 0) then
                    exchangeable = false
                    break
                else
                    wild_alphabet_cnt = (wild_alphabet_cnt + 1)
                    alphabet_data['700299'] = math_max(alphabet_data['700299'] - 1)
                end
            end

            -- 사용된 수량 감소
            alphabet_data[item_id_str] = math_max(alphabet_data[item_id_str] - 1)
        end

        if exchangeable then
            t_word_data['wild_alphabet_cnt'] = wild_alphabet_cnt
            if (1 <= wild_alphabet_cnt) then
                status = 'exchangeable_wild'
            else
                status = 'exchangeable'
            end
        end
    end
    t_word_data['status'] = status

    return t_word_data
end

-------------------------------------
-- function isHighlightRed_alphabet
-- @brief 빨간 느낌표 아이콘 출력 여부
--        획득 가능한 보상이 있을 경우
-------------------------------------
function ServerData_EventAlphabet:isHighlightRed_alphabet()
    if (not self.m_exchangeInfo) then
        return false
    end

    local l_word = TableAlphabetEvent:getWordList()

    for i,v in ipairs(l_word) do
        local word_id = v['id']
        local t_word_data = self:getAlphabetEvent_WordData(word_id)
        local status = t_word_data['status']
        if (status == 'exchangeable') or (status == 'exchangeable_wild') then
            return true
        end
    end

    return false
end

-------------------------------------
-- function isHighlightYellow_alphabet
-- @brief 노란 느낌표 아이콘 출력 여부
--        주요 상품의 교환 가능 횟수가 남아있을 경우
-------------------------------------
function ServerData_EventAlphabet:isHighlightYellow_alphabet()
    if (not self.m_exchangeInfo) then
        return false
    end

    local l_word = TableAlphabetEvent:getWordList()

    -- 주요 상품 리스트업
    local l_word_id = {}
    for i,v in pairs(l_word) do
        if (v['noti'] == 1) then
            table.insert(l_word_id, v['id'])
        end
    end

    for _,word_id in ipairs(l_word_id) do
        local t_word_data = self:getAlphabetEvent_WordData(word_id)
        local status = t_word_data['status']
        if (status ~= 'max') then
            return true
        end
    end

    return false
end