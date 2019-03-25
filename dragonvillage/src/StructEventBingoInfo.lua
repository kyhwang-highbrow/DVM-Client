local PARENT = Structure

-------------------------------------
-- class StructEventBingoInfo
-- @brief 이벤트 팝업에 등록된 탭
-------------------------------------
StructEventBingoInfo = class(PARENT, {
        table_bingo_reward = 'table',
        
        event = 'number',
        event_get = 'number',
        event_use = 'number',
        event_max = 'number',

        bingo_count_info = 'table',
        bingo_number = 'list',
        bingo_line = 'list',
        bingo_pick_count = 'number',
        event_pick_price = 'number',
        event_price = 'number',

        m_lSortedCntReward = 'list',
    })

local THIS = StructEventBingoInfo

--[[
    "table_event_product":[
                          {"event_version":"201901bingo",
                          "price_type":"",
                          "step":5,
                          "mail_content_1":"703003;1",
                          "price_1":1,
                          "buy_count_1":"",
                          "mail_content_2":"703019;1",
                          "price_2":3,
                          "buy_count_2":"",
                           ...
    "event":0,
    "event_get":0,
    "event_max":1500,
    "event_use":0,
    "bingo_count_info":{
       "bingo_count":0,
       "bingo_count_reward":{
           "1":"703003;1",
           "3":"703019;1",
           "6":"703010;1",
           "9":"703011;1",
           "12":"703004;1"}
           },
    "bingo_number":{},
    "bingo_line":{},
    "bingo_pick_count":0,

--]]

-------------------------------------
-- function getClassName
-------------------------------------
function StructEventBingoInfo:getClassName()
    return 'StructEventBingoInfo'
end

-------------------------------------
-- function getBingoNumberList
-------------------------------------
function StructEventBingoInfo:getBingoNumberList()
    return self['bingo_number'] or {}
end

-------------------------------------
-- function getThis
-------------------------------------
function StructEventBingoInfo:getThis()
    return THIS
end

-------------------------------------
-- function getBingoRewardCnt
-------------------------------------
function StructEventBingoInfo:getBingoRewardCnt()
    return self['bingo_count_info']['bingo_count'] or 0
end

-------------------------------------
-- function getBingoRewardList
-------------------------------------
function StructEventBingoInfo:getBingoRewardList()
    return self.m_lSortedCntReward or {}
    
end

-------------------------------------
-- function sortCntReward
-------------------------------------
function StructEventBingoInfo:sortCntReward(ret)
    local t_cnt_reward = ret['bingo_count_info']['bingo_count_reward'] or {}
    local l_cnt_reward = {}

    --[[
        reward_index 를 기준으로 정렬한 리스트 생성
        {
                ['reward_index']=1;
                ['reward_str']='703003;1';
        };
        {
                ['reward_index']=3;
                ['reward_str']='703019;1';
        };
    --]]
    for key, data in pairs(t_cnt_reward) do
        local t_temp = {}
        t_temp['reward_index'] = tonumber(key)
        t_temp['reward_str'] = data
        table.insert(l_cnt_reward, t_temp)
    end
    
    local func_sort = function(a, b)
        return a['reward_index'] <b['reward_index']
    end

    table.sort(l_cnt_reward, func_sort)
    self.m_lSortedCntReward = l_cnt_reward
end

-------------------------------------
-- function isCompeletBingo
-------------------------------------
function StructEventBingoInfo:isCompeletBingo()
    local last_ind = self:getBingoRewardListCnt()
    local is_last = self['bingo_count_info']['count_reward_'..last_ind]

    if (is_last == 1) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getBingoRewardListCnt
-------------------------------------
function StructEventBingoInfo:getBingoRewardListCnt()
    return #self:getBingoRewardList() or 0
end

-------------------------------------
-- function getBingoLineRewardList
-------------------------------------
function StructEventBingoInfo:getBingoLineRewardList()
    return self['table_bingo_reward'] or {}
end

-------------------------------------
-- function getEventItemCnt
-------------------------------------
function StructEventBingoInfo:getEventItemCnt()
    return self['event'] or 0
end

-------------------------------------
-- function getTodayEventItemCnt
-------------------------------------
function StructEventBingoInfo:getTodayEventItemCnt()
    return self['event_get']  or 0
end

-------------------------------------
-- function getPickEventItemCnt
-------------------------------------
function StructEventBingoInfo:getPickEventItemCnt()
    return self['bingo_pick_count'] or 0
end

-------------------------------------
-- function getBingoLine
-------------------------------------
function StructEventBingoInfo:getBingoLine()
    local m_bingo_line = self['bingo_line']
    return m_bingo_line or {}
end

-------------------------------------
-- function getBingoLineCnt
-------------------------------------
function StructEventBingoInfo:getBingoLineCnt()
    return self['bingo_count_info']['bingo_count'] or 0
end

-------------------------------------
-- function getTodayMaxEventItemCnt
-------------------------------------
function StructEventBingoInfo:getTodayMaxEventItemCnt()
    return self['event_max'] or 0
end

-------------------------------------
-- function addBingoNumber
-------------------------------------
function StructEventBingoInfo:addBingoNumber(number)
    local l_bingo_number = self:getBingoNumberList()
    table.insert(l_bingo_number, number)
end

-------------------------------------
-- function applyInfo
-------------------------------------
function StructEventBingoInfo:applyInfo(ret)
    if (ret['event']) then
        self['event'] = ret['event']
    end

    if (ret['event_get']) then
        self['event_get'] = ret['event_get']
    end

    if (ret['bingo_pick_count']) then
        self['bingo_pick_count'] = ret['bingo_pick_count']
    end

    if (ret['bingo_count_info']) then
        self['bingo_count_info'] = ret['bingo_count_info']
        self:sortCntReward(ret)
    end

    if (ret['bingo_line']) then
        self['bingo_line'] = ret['bingo_line']
    end
end

-------------------------------------
-- function addBingoClearLine
-------------------------------------
function StructEventBingoInfo:addBingoClearLine(ret)
    local l_bingo = self['bingo_line']
    for i, number in ipairs(ret) do
        local key = tostring(number)
        l_bingo[key] = 0
    end
    self['bingo_line'] = l_bingo
end

-------------------------------------
-- function getBingoCntRewardState
-------------------------------------
function StructEventBingoInfo:getBingoCntRewardState(ind)
    local t_bingo_cnt_info = self['bingo_count_info']
    for key, state in pairs(t_bingo_cnt_info) do
        if (string.match(key, 'count_reward_')) then
            local reward_ind = string.match(key, '%d+')
            if (tostring(reward_ind) == tostring(ind)) then
                return state -- 0 : 받을 수 없음, 1 : 받음
            end
        end
    end
end

-------------------------------------
-- function getBingoLineReward
-------------------------------------
function StructEventBingoInfo:getBingoLineRewardState(ind)
    local t_line = self['bingo_line']
    for key, state in pairs(t_line) do
        if (tostring(key) == tostring(ind)) then
            return state -- 0 : 받을 수 없음, 1 : 받음
        end
    end
end

-------------------------------------
-- function isHighlightRed_ex
-- @brief 빨간 느낌표 아이콘 출력 여부
-------------------------------------
function StructEventBingoInfo:isHighlightRed_ex()

    -- 받아야 할 누적 획득 보상이 있는 경우
    if (self:hasCntReward() == true) then
        return true
    end

    -- 받아야 할 빙고 보상이 있는 경우
    if (self:hasBingoReward()) then
        return true
    end

    return false
end

-------------------------------------
-- function isHighlightYellow_ex
-- @brief 노란 느낌표 아이콘 출력 여부
-------------------------------------
function StructEventBingoInfo:isHighlightYellow_ex()
    -- 일일 최대 획득량이 남았을 경우
    if (self:getTodayEventItemCnt() < 1500) then
        return true
    end

    return false
end

-------------------------------------
-- function hasBingoReward
-------------------------------------
function StructEventBingoInfo:hasBingoReward()
    local t_bingo = self:getBingoLine()
    for _, is_reward in pairs(t_bingo) do
        
        if (is_reward == 0) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function hasCntReward
-------------------------------------
function StructEventBingoInfo:hasCntReward()
    local bingo_cnt = self:getBingoRewardCnt()
    local reward_cnt = self:getBingoRewardListCnt()
    for i=1, reward_cnt do
        if (self.m_lSortedCntReward[i]['reward_index'] > bingo_cnt) then
            if (self:getBingoCntRewardState(i) == 1) then
                return true
            end
        end
    end
    return false
end





