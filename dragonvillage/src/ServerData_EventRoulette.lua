
----------------------------------------------------------------------
-- class ServerData_EventRoulette
-- @brief 
-- https://highbrow.atlassian.net/wiki/spaces/dvm/pages/1442742280
----------------------------------------------------------------------
ServerData_EventRoulette = class({
    m_rouletteInfo = 'table',
    m_probabilityTable = 'table',
    m_probIndexKeyList = 'list[index]',

    --m_bDirtyTable = 'boolean',

    m_resultIndex = 'number',

    m_dailyRankingRewardList = 'table', -- 일일랭킹 보상 리스트
    m_totalRankingRewardList = 'table', -- 전체랭킹 보상 리스트

    -- 시즌 보상 수령 시 사용
    m_lastInfo = 'table',           -- 
    m_lastInfoDaily = 'table',      -- 
    m_rewardInfo = 'table',         --
    m_rewardInfoDaily = 'table',    -- 

    m_nGlobalOffset = 'number', -- 현재 랭킹 시작하는 등수
    m_lGlobalRank = 'table',
    m_myRanking = 'StructEventRouletteRanking',


    -- TEMP
    m_resultTable = 'table', -- 최종 수령 상품 및 점수 임시저장용 테이블
})

----------------------------------------------------------------------
-- function getInstance
----------------------------------------------------------------------
function ServerData_EventRoulette:getInstance()
    if g_eventRouletteData then
        return g_eventRouletteData
    end

    g_eventRouletteData = ServerData_EventRoulette()

    return g_eventRouletteData
end


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function ServerData_EventRoulette:init()
    --self.m_bDirtyTable = true
    self.m_myRanking = StructEventRouletteRanking()
end

-- function ServerData_EventRoulette:isActiveEvent()
--     return g_hotTimeData:isActiveEvent('event_roulette')
-- end

----------------------------------------------------------------------
-- function request_rouletteInfo
-- param is_table_required  probability와 rank 테이블 정보를 받을 것인지 여부
-- param is_reward_required 랭킹 보상을 받을 것인지에 대한 여부
----------------------------------------------------------------------
function ServerData_EventRoulette:request_rouletteInfo(is_table_required, is_reward_required, finish_cb, fail_cb)

    -- -- 테이블 정보를 받아온 상태면 다시 받아올 필요 x
    -- if (not self.m_bDirtyTable) then
    --     is_table_required = false
    -- end

    local user_id = g_userData:get('uid')

    local function success_cb(ret)

        self:response_rouletteInfo(ret)

        -- if (self.m_rankTable and self.m_probabilityTable) then 
        --     self.m_bDirtyTable = false
        -- end

        if(finish_cb) then finish_cb(ret) end
    end

    local network = UI_Network()
    network:setUrl('/event/roulette/info')
    network:setParam('uid', user_id)
    network:setParam('include_tables', is_table_required)
    network:setParam('reward', is_reward_required)
    network:setRevocable(true)
    network:setSuccessCB(success_cb)
    network:setFailCB(fail_cb)
    network:request()

    return network
end

----------------------------------------------------------------------
-- function response_rouletteInfo
----------------------------------------------------------------------
function ServerData_EventRoulette:response_rouletteInfo(ret)
    if ret['roulette_info'] then -- 룰렛 관련 정보
        self.m_rouletteInfo = ret['roulette_info']
        self.m_rouletteInfo['start_date'] = self.m_rouletteInfo['start_date'] / 1000
        self.m_rouletteInfo['end_date'] = self.m_rouletteInfo['end_date'] / 1000
    end

    if ret['table_event_probability'] and (self.m_probabilityTable == nil) and (self.m_probIndexKeyList == nil) then -- 룰렛 확률 테이블
        --self.m_probabilityTable = ret['table_event_probability']
        for key, data in pairs(ret['table_event_probability']) do
            local step = data['step']

            if (self.m_probabilityTable == nil) then 
                self.m_probabilityTable = {} 
                self.m_probIndexKeyList = {}
            end
            if (self.m_probabilityTable[step] == nil) then self.m_probabilityTable[step] = {} end

            if (step == 1) then 
                table.insert(self.m_probabilityTable[step], data)
                self.m_probIndexKeyList[data['group_code']] = #self.m_probabilityTable[step]
                if (#self.m_probabilityTable[step] > 8) then
                    ccdump(self.m_probabilityTable)
                    ccerror('')
                end
            elseif (step == 2) then
                local group_code = data['group_code']
                
                if (not self.m_probabilityTable[step][group_code]) then self.m_probabilityTable[step][group_code] = {} end
                table.insert(self.m_probabilityTable[step][group_code], data)
                self.m_probIndexKeyList[tostring(data['id'])] = #self.m_probabilityTable[step][group_code]
                if (#self.m_probabilityTable[step][group_code] > 8) then
                    ccdump(self.m_probabilityTable)
                    ccerror('')
                end
            else
                if IS_DEV_SERVER() then
                    error('There isn\'t any steps over 2 in table_event_probability')
                end
            end
        end
    end

    -- 보상이 들어왔을 경우 정보 저장, nil 여부로 보상 확인
    if (ret['lastinfo']) then
        self.m_lastInfo = StructEventRouletteRanking():apply(ret['lastinfo'])
    else
        self.m_lastInfo = nil
    end

    if (ret['lastinfo_daily']) then
        self.m_lastInfoDaily = StructEventRouletteRanking():apply(ret['lastinfo_daily'])
    else
        self.m_lastInfoDaily = nil
    end
    -- 보상 아이템 정보 들어왔을 경우 정보 저장, nil 여부로 보상 확인
    if (ret['reward_info']) then
        self.m_rewardInfo = ret['reward_info']
    else
        self.m_rewardInfo = nil
    end

    if (ret['reward_info_daily']) then
        self.m_rewardInfoDaily = ret['reward_info_daily']
    else
        self.m_rewardInfoDaily = nil
    end

    if ret['table_event_rank'] then -- 랭킹 정보 테이블
        self:updateRankingInfo(ret['table_event_rank'])
    end
end

----------------------------------------------------------------------
-- function updateRankingInfo
-- param step   request_rouletteInfo에서 받은 리턴값 중 랭킹정보만 따로 처리
----------------------------------------------------------------------
function ServerData_EventRoulette:updateRankingInfo(ret)
    self.m_dailyRankingRewardList = {}
    self.m_totalRankingRewardList = {}

    if (not ret) then return end

    for i, reward in ipairs(ret) do
        if (reward and reward['version']) then
            if (string.find(reward['version'], 'daily')) then
                -- 일일랭킹
                table.insert(self.m_dailyRankingRewardList, reward)
            else
                -- 전체랭킹
                table.insert(self.m_totalRankingRewardList, reward)
            end
        end
    end
end

----------------------------------------------------------------------
-- function request_rouletteStart
-- param step   몇번째 룰렛을 돌리는지 (step : 1, 2)
-- picked_group step 2에 필요한 당첨된 그룹 (step 1으로 받는 return 값)
----------------------------------------------------------------------
function ServerData_EventRoulette:request_rouletteStart(finish_cb, fail_cb) 
    local user_id = g_userData:get('uid')
    local step = self:getCurrStep()
    local picked_group = self:getPickedGroup()
    
    local function success_cb(ret)

        self:response_rouletteStart(ret)

        --_serverData:receiveReward(ret)
        if(finish_cb) then finish_cb(ret) end
    end


    local network = UI_Network()
    network:setUrl('/event/roulette/start')
    network:setParam('uid', user_id)
    network:setParam('step', step)
    network:setParam('picked_group', picked_group)
    network:hideLoading()
    network:setRevocable(true)
    network:setSuccessCB(success_cb)
    network:setFailCB(fail_cb)
    network:request()

    return network
end 
----------------------------------------------------------------------
-- function response_rouletteStart
-- ret 룰렛의 결과 정보
----------------------------------------------------------------------
function ServerData_EventRoulette:response_rouletteStart(ret)

    if IS_DEV_SERVER() then
        local step = self:getCurrStep()
        local group = self:getPickedGroup()
    end

    self.m_rouletteInfo = ret['roulette_info']

    -- 2단계 룰렛의 결과에 해당하는 index를 이용해 각도를 계산하기 위한 변수
    if ret['picked_id'] then
        self.m_rouletteInfo['picked_id'] = tostring(ret['picked_id'])
    end

    -- 연출 이후 보상 결과 팝업을 위해 저장
    --if 
    self.m_resultTable = {}
    --if (self.m_resultTable == nil) then self.m_resultTable = {} end
    
    self.m_resultTable['item_info'] = ret['item_info'] -- '779154;1'
    local item_info = ret['mail_item_info']

    -- 아이템이 리스트 형태로 내려왔을 수도 있다.
    if (item_info and not item_info['item_id']) then
        for _, v in ipairs(item_info) do
            if (v) then item_info = v end
        end
    end
    self.m_resultTable['mail_item_info'] = item_info


    self.m_resultTable['bonus_score'] = ret['bonus_score'] -- number
    self.m_resultTable['score'] = ret['score'] -- number
end


----------------------------------------------------------------------
-- function request_rouletteRanking
----------------------------------------------------------------------
function ServerData_EventRoulette:request_rouletteRanking(offset, limit, type, division, finish_cb, fail_cb)
    local user_id = g_userData:get('uid')

    local function success_cb(ret)
        self.m_nGlobalOffset = ret['offset']

        -- 유저 리스트 저장
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            table.insert(self.m_lGlobalRank, StructEventRouletteRanking():apply(v))
        end
        
        -- 플레이어 랭킹 정보 갱신
        if ret['my_info'] then
            self:refreshMyRanking(ret['my_info'], nil)
        end

        if(finish_cb) then finish_cb(ret) end
    end


    local network = UI_Network()
    network:setUrl('/event/roulette/ranking')
    network:setParam('uid', user_id)
    network:setParam('offset', offset)    -- -1 : 자신의 위치, 그 외에는 랭킹의 위치
    network:setParam('limit', limit) -- 몇개의 리스트를 불러올지 (default : 20)
    network:setParam('type', type)  -- world, friend, clan
    network:setParam('division', division) -- total, daily
    network:setRevocable(true)
    network:setSuccessCB(success_cb)
    network:setFailCB(fail_cb)
    network:request()

    return network
end

----------------------------------------------------------------------
-- function getItemList
----------------------------------------------------------------------
function ServerData_EventRoulette:getItemList()
    local step = self:getCurrStep()
    local result

    if (step == 1) then
        result = self.m_probabilityTable[step]
    elseif (step == 2) then
        local group = self:getPickedGroup()
        result = self.m_probabilityTable[step][group]
    else
        --result = {}
    end

    return result
end


----------------------------------------------------------------------
-- function getTotalScore
-- return 종합 누적 점수
----------------------------------------------------------------------
function ServerData_EventRoulette:getTotalScore()
    return self.m_rouletteInfo['score']
end

----------------------------------------------------------------------
-- function request_rouletteRanking
-- return 오늘 누적 점수
----------------------------------------------------------------------
function ServerData_EventRoulette:getDailyScore()
    return self.m_rouletteInfo['score']
end

----------------------------------------------------------------------
-- function getTicketNum
-- return 보유중인 룰렛 티켓 수
----------------------------------------------------------------------
function ServerData_EventRoulette:getTicketNum()
    return self.m_rouletteInfo['roulette']
end

----------------------------------------------------------------------
-- function getTicketNum
----------------------------------------------------------------------
function ServerData_EventRoulette:getTimeText()
    local start_time = self.m_rouletteInfo['start_date']
    local end_time = self.m_rouletteInfo['end_date']

    local curr_time = Timer:getServerTime()

    
    local str = ''
    if (curr_time < start_time) then
        local time = (start_time - curr_time)
        str = Str('{1} 후 열림', datetime.makeTimeDesc(time, true))
    elseif (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true))
    else
        is_season_ended = true
        str = Str('이벤트가 종료되었습니다.')
    end

    return str
end


----------------------------------------------------------------------
-- function getCurrStep
-- return step (1 or 2)
----------------------------------------------------------------------
function ServerData_EventRoulette:getCurrStep()
    if (not self.m_rouletteInfo['picked_group']) 
        or (self.m_rouletteInfo['picked_group'] == '') then
        return 1
    else
        return 2
    end
end
----------------------------------------------------------------------
-- function getPickedGroup
-- return 
----------------------------------------------------------------------
function ServerData_EventRoulette:getPickedGroup()
    return self.m_rouletteInfo['picked_group']
end


----------------------------------------------------------------------
-- function getCurrStep
----------------------------------------------------------------------
function ServerData_EventRoulette:getRandAngle()
    local gap = 2
    local step = self:getCurrStep()
    local group_code = self.m_rouletteInfo['picked_group']

    local elementNum
    if (step == 1) then
        elementNum = #self.m_probabilityTable[step]
    elseif (step == 2) then
        elementNum = #self.m_probabilityTable[step][group_code]
    end

     local angle = 360 / elementNum

     local rand_angle = math.random(0 + gap, angle - gap)

    local target_angle =  angle * (self.m_resultIndex - 1) + rand_angle
    --stringx.split

    
    --local error = velocity / 100 

    -- 100, -2, 50s : 200

    -- 100, -50, 2s : 1
    -- 1000, -500, 2s : 10
    -- 10000, -5000, 2s : 100

    -- 100, -20, 5s : 1
    -- 1000, -200, 5s : 10
end

function ServerData_EventRoulette:getPickedItemIndexForSkip()
    local step = self:getCurrStep()
    local index

    if (step == 1) then -- 1단계에서 STOP 이후 step이 바뀐 상태
        local key = self:getPickedGroup()
        index = self.m_probIndexKeyList[key]
    elseif (step == 2) then -- 2단계에서 STOP 이후 step이 바뀐 상태
        local key = self.m_rouletteInfo['picked_id']
        index = self.m_probIndexKeyList[key]
    else
        if IS_DEV_SERVER() then
            error('There isn\'t any steps over 2 in table_event_probability')
        end
    end
    
    return index
end

function ServerData_EventRoulette:getPickedItemIndex()
    local step = self:getCurrStep()
    local index

    if (step == 2) then -- 1단계에서 STOP 이후 step이 바뀐 상태
        local key = self:getPickedGroup()
        index = self.m_probIndexKeyList[key]
    elseif (step == 1) then -- 2단계에서 STOP 이후 step이 바뀐 상태
        local key = self.m_rouletteInfo['picked_id']
        index = self.m_probIndexKeyList[key]
    else
        if IS_DEV_SERVER() then
            error('There isn\'t any steps over 2 in table_event_probability')
        end
    end

    return index
end

----------------------------------------------------------------------
-- function getItemCard
----------------------------------------------------------------------
function ServerData_EventRoulette:getItemCard(data, is_item_card)
    local item_id = data['item_id']
    local count = data['val']
    local item_type = TableItem:getItemType(item_id)


    local item_card 
    if is_item_card then
        item_card = UI_ItemCard(item_id, count)
        item_card = item_card.root
    else
        item_card = IconHelper:getItemIcon(tonumber(data['item_id']))

        if (item_type == 'dragon') or (item_type == 'relation_point') or (item_type == 'slime') or (item_type == 'reinforce_point') then
            item_card:setScale(0.8)
        end
    end
    
    local ani_name
    if (data['noti_level'] == 1) then 
        ani_name = 'summon_hero'
    elseif (data['noti_level'] == 2) then
        ani_name = 'summon_regend_2'
    end

    if ani_name then
        local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
        rarity_effect:changeAni(ani_name, true)
		rarity_effect:setScale(1.7)
		--rarity_effect:setAlpha(0)
		item_card:addChild(rarity_effect.m_node)
        --rarity_effect.m_node:runAction(cc.FadeIn:create(ANI_DURATION))
    end

    return item_card
end

----------------------------------------------------------------------
-- function getIcon
----------------------------------------------------------------------
function ServerData_EventRoulette:getIcon(index, is_item_card)
    local step = self:getCurrStep()

    local icon
    local count

    if step == 1 then
        local data = self.m_probabilityTable[step][index]
        local file_name = data['group_code']
        icon =  IconHelper:getIcon('res/ui/icons/item_group/' .. file_name .. '.png')
        
        count = data['val']
    elseif step == 2 then
        local group_code = self:getPickedGroup()
        local data = self.m_probabilityTable[step][group_code][index]
        count = data['val']

        --icon =  IconHelper:getItemIcon(tonumber(data['item_id']))
            icon = self:getItemCard(data, is_item_card)
    else
    end

    return icon, count
end


----------------------------------------------------------------------
-- function getIcon
----------------------------------------------------------------------
function ServerData_EventRoulette:getRewardIcon(step, group_code, index)
    local data
    local icon
    local probability
    local count

    
    if (step == 1) then
        data = self.m_probabilityTable[step][index]
        local file_name = data['group_code']
        icon =  IconHelper:getIcon('res/ui/icons/item_group/' .. file_name .. '.png')

    elseif (step == 2) then
        --local group_code = self:getPickedGroup()
        data = self.m_probabilityTable[step][group_code][index]
        --icon =  IconHelper:getItemIcon(tonumber(data['item_id']))

        icon = self:getItemCard(data, true)
    else

    end

    probability = data['real_weight']
    count = data['val']

    return icon, count, probability
end

----------------------------------------------------------------------
-- function getAngle
----------------------------------------------------------------------
function ServerData_EventRoulette:getGroupCodeFromIndex(index)
    return self.m_probabilityTable[1][index]['group_code']
end
----------------------------------------------------------------------
-- function getAngle
----------------------------------------------------------------------
function ServerData_EventRoulette:getAngle(index)
    local step = self:getCurrStep()
    local num

    if step == 1 then
        num = #self.m_probabilityTable[step]
    elseif step == 2 then
        local group_code = self:getPickedGroup()
        num = #self.m_probabilityTable[step][group_code]
    else
    end

    local angle = 360 / num

    return ((index - 1) * (360 - angle)) % 360
end

----------------------------------------------------------------------
-- function MakeRewardPopup
----------------------------------------------------------------------
function ServerData_EventRoulette:MakeRewardPopup()
    if self.m_resultTable and self.m_resultTable['mail_item_info'] then
        UI_EventRouletteRewardPopup(self.m_resultTable)
    end
end

----------------------------------------------------------------------
-- function MakeRankingRewardPopup
----------------------------------------------------------------------
function ServerData_EventRoulette:MakeRankingRewardPopup()
    local last_info = self.m_lastInfo
    local lastinfo_daily = self.m_lastInfoDaily
    local reward_info = self.m_rewardInfo
    local reward_info_daily = self.m_rewardInfoDaily

    if (last_info and reward_info) then
        -- 랭킹 보상 팝업
        UI_EventRankingRewardPopup(false, UI_EventRouletteRankListItem, last_info, reward_info)
    end
    
    if (lastinfo_daily and reward_info_daily) then
        -- 일일랭킹 보상 팝업
        UI_EventRankingRewardPopup(true, UI_EventRouletteRankListItem, lastinfo_daily, reward_info_daily)
    end
end

-------------------------------------
-- function refreshMyRanking
-------------------------------------
function ServerData_EventRoulette:refreshMyRanking(t_my_info)
    self.m_myRanking:apply(t_my_info)
end








local PARENT = StructUserInfo

-------------------------------------
-- class UI_EventRoulette.UI_RankTab.StructEventRouletteRanking
-- @brief 소원 구슬
-------------------------------------
StructEventRouletteRanking = class(PARENT, {
        m_rp = 'number',         -- ranking point
        m_rank = 'number',       -- 월드 랭킹
        m_rankPercent = 'float',-- 월드 랭킹 퍼센트
    })


-------------------------------------
-- function init
-------------------------------------
function StructEventRouletteRanking:init()
    self.m_rp = 0
    self.m_rank = 0
    self.m_rankPercent = 0
end

-------------------------------------
-- function apply
-- @brief 
-------------------------------------
function StructEventRouletteRanking:apply(t_data)
    self.m_uid = t_data['uid']
    self.m_nickname = t_data['nick']
    self.m_lv = t_data['lv']
    self.m_rank = t_data['rank']
    self.m_rankPercent = t_data['rate']
    self.m_rp = t_data['rp']

    self.m_leaderDragonObject = StructDragonObject(t_data['leader'])

    if (t_data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(t_data['clan_info'])
        self:setStructClan(struct_clan)
    end

    return self
end

-------------------------------------
-- function getUserText
-------------------------------------
function StructEventRouletteRanking:getUserText()
        local str
    if self.m_lv and (0 < self.m_lv) then
        str = Str('Lv.{1} {2}', self.m_lv, self.m_nickname)
    else
        str = self.m_nickname
    end
    return str
end

-------------------------------------
-- function getRankStr
-------------------------------------
function StructEventRouletteRanking:getRankStr()
    if (self.m_rank == 0) then
        return '-'
    else
        return Str('{1}위', comma_value(self.m_rank))
    end
end

-------------------------------------
-- function getScoreStr
-------------------------------------
function StructEventRouletteRanking:getScoreStr()
    local rp = self.m_rp
    if (rp <= 0) then
        rp = 0
    end
    return Str('{1}점', comma_value(rp))
end