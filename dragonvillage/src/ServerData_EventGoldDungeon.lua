-------------------------------------
-- class ServerData_EventGoldDungeon
-- @instance g_eventGoldDungeonData
-------------------------------------
ServerData_EventGoldDungeon = class({
        m_stamina = 'number', -- 입장권

        m_playCount = 'number', -- 누적 플레이 횟수

        m_productInfo = 'list', -- 교환 상품 정보
        m_rewardInfo = 'map', -- 보상 정보
        m_staminaDropInfo = 'map', -- 각 모드별 입장권 획득 정보
        m_totalGold = 'number', --이벤트 누적 획득 골드량

        m_endTime = 'time',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventGoldDungeon:init()
end

-------------------------------------
-- function getInstance
-------------------------------------
function ServerData_EventGoldDungeon:getInstance()
    if (not g_eventGoldDungeonData) then
        g_eventGoldDungeonData = ServerData_EventGoldDungeon()
    end

    return g_eventGoldDungeonData
end

-------------------------------------
-- function getStaminaCount
-------------------------------------
function ServerData_EventGoldDungeon:getStaminaCount()
    return self.m_stamina or 0
end

-------------------------------------
-- function getPlayCount
-------------------------------------
function ServerData_EventGoldDungeon:getPlayCount()
    return self.m_playCount
end

-------------------------------------
-- function getProductInfo
-------------------------------------
function ServerData_EventGoldDungeon:getProductInfo()
    return self.m_productInfo
end

-------------------------------------
-- function getRewardInfo
-------------------------------------
function ServerData_EventGoldDungeon:getRewardInfo()
    return self.m_rewardInfo
end

-------------------------------------
-- function getStaminaInfo
-------------------------------------
function ServerData_EventGoldDungeon:getStaminaInfo()
    return self.m_staminaDropInfo or {}
end

function ServerData_EventGoldDungeon:getTotalGold()
    return self.m_totalGold or 0
end

-------------------------------------
-- function hasReward
-- @brief 받아야 할 보상이 있는지 (누적 보상)
-------------------------------------
function ServerData_EventGoldDungeon:hasReward()
    if (not self.m_productInfo) then
        return false
    end

    if (not self.m_rewardInfo) then
        return false
    end

    local event_info = self.m_productInfo
    local reward_info = self.m_rewardInfo

    local curr_cnt = self.m_playCount
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
-- function parseProductInfo
-------------------------------------
function ServerData_EventGoldDungeon:parseProductInfo(product_info)
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
-- function getStatusText
-------------------------------------
function ServerData_EventGoldDungeon:getStatusText()
    local curr_time = Timer:getServerTime()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
end

-------------------------------------
-- function confirm_reward
-- @brief 보상 정보
-------------------------------------
function ServerData_EventGoldDungeon:confirm_reward(ret)
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
-- function isGetReward
-- @brief 받은 보상인지 검사
-------------------------------------
function ServerData_EventGoldDungeon:isGetReward(step)
    local step = tostring(step) 
    local reward_info = self.m_rewardInfo

    return (reward_info[step] == 1) and true or false
end

-------------------------------------
-- function networkCommonRespone
-------------------------------------
function ServerData_EventGoldDungeon:networkCommonRespone(ret)
    g_serverData:networkCommonRespone(ret)
    self.m_stamina = g_staminasData:getStaminaCount('event_st')

    -- 누적 플레이 횟수
    if (ret['play_cnt']) then
        self.m_playCount = ret['play_cnt']
    end

    -- 이벤트 종료 시간
    if (ret['end']) then
        self.m_endTime = ret['end']
    end

    -- 보상 획득 정보
    if (ret['event_dungeon_reward']) then
        self.m_rewardInfo = ret['event_dungeon_reward']
    end

    -- 입장권 획득 정보
    if (ret['stamina_info']) then
        self.m_staminaDropInfo = ret['stamina_info']
    end

    if(ret['event_dungeon_totalGold']) then
        self.m_totalGold = ret['event_dungeon_totalGold']
    end
end

-------------------------------------
-- function request_dungeonInfo
-- @brief 황금던전 정보
-------------------------------------
function ServerData_EventGoldDungeon:request_dungeonInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:networkCommonRespone(ret)
        self:parseProductInfo(ret['event_dungeon_product'][1])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/event_dungeon/info')
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
function ServerData_EventGoldDungeon:request_clearReward(step, finish_cb, fail_cb)
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
    ui_network:setUrl('/game/event_dungeon/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('step', step)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function isHighlightRed_gd
-- @brief 빨간 느낌표 아이콘 출력 여부
-------------------------------------
function ServerData_EventGoldDungeon:isHighlightRed_gd()
    -- 황금 날개(입장권)가 있을 경우 (1개 이상)
    if (self:getStaminaCount() > 0) then
        return true
    end

    -- 획득 가능한 누적 보상이 있을 경우
    if (self:hasReward() == true) then
        return true
    end

    return false
end

-------------------------------------
-- function isHighlightYellow_gd
-- @brief 노란 느낌표 아이콘 출력 여부
-------------------------------------
function ServerData_EventGoldDungeon:isHighlightYellow_gd()
    -- 획득 가능한 입장권이 있을 경우

    local t_stamina_info = self:getStaminaInfo()

    -- 데이터 구조
    -- ['dungeon']={
    --         ['ticket']=0;
    --         ['play']=0;
    --         ['max_ticket']=1;
    --         ['max_play']=10;
    -- };
    -- ['ancient']={
    --         ['ticket']=0;
    --         ['play']=0;
    --         ['max_ticket']=1;
    --         ['max_play']=5;
    -- };
    -- ['adv']={
    --         ['ticket']=0;
    --         ['play']=0;
    --         ['max_ticket']=1;
    --         ['max_play']=15;
    -- };
    -- ['pvp']={
    --         ['ticket']=0;
    --         ['play']=0;
    --         ['max_ticket']=1;
    --         ['max_play']=10;
    -- };

    for i,v in pairs(t_stamina_info) do
        local ticket = (v['ticket'] or 0)
        local max_ticket = (v['max_ticket'] or 0)

        if (ticket < max_ticket) then
            return true
        end
    end

    return false
end