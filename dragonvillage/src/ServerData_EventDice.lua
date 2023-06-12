-------------------------------------
-- class ServerData_EventDice
-------------------------------------
ServerData_EventDice = class({
        m_lCellList = 'table',
        m_lLapList = 'table',

        m_diceInfo = 'StructEventDiceInfo',
        m_receiveDiceDirty = 'boolean',

        m_endTime = 'time',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventDice:init()
    self.m_receiveDiceDirty = false
end

-------------------------------------
-- function getDiceInfo
-------------------------------------
function ServerData_EventDice:getDiceInfo()
    return self.m_diceInfo
end

-------------------------------------
-- function getCellList
-------------------------------------
function ServerData_EventDice:getCellList()
    return self.m_lCellList
end

-------------------------------------
-- function getLapList
-------------------------------------
function ServerData_EventDice:getLapList()
    return self.m_lLapList
end


-------------------------------------
-- function setReceiveDiceDirty
-------------------------------------
function ServerData_EventDice:setReceiveDiceDirty(b)
    self.m_receiveDiceDirty = b
end

-------------------------------------
-- function getReceiveDirty
-------------------------------------
function ServerData_EventDice:getReceiveDiceDirty()
    return self.m_receiveDiceDirty
end

-------------------------------------
-- function isExpansionLap
-------------------------------------
function ServerData_EventDice:isExpansionLap()
    if self.m_lLapList == nil then
        return false
    end

    if #self.m_lLapList <= 6 then
        return false
    end

    if #self.m_lLapList == 10 then
        return true
    end

    return false
end

-------------------------------------
-- function isAvailableLapReward
-------------------------------------
function ServerData_EventDice:isAvailableLapReward(_lap)
    if (g_hotTimeData:isActiveEvent('event_dice') == false) then
        return false
    end

    if self.m_lLapList == nil then
        return false
    end

    local dice_info = self:getDiceInfo()
    if dice_info == nil then
        return false
    end

    local lap_cnt = dice_info:getCurrLapCnt()
    for i, t_lap in ipairs(self.m_lLapList) do
        local lap = _lap
        local is_available = lap_cnt >= t_lap['lap'] and t_lap['is_recieved'] == false
        
        if lap == nil then
            if is_available == true then
                return true
            end
        else
            if lap == t_lap['lap'] then
                return  is_available
            end
        end
    end

    return false
end

-------------------------------------
-- function getDiceDailyGoldPrice
-------------------------------------
function ServerData_EventDice:getDiceDailyGoldPrice()
    if self.m_diceInfo == nil then
        return 0
    end

    return self.m_diceInfo['gold_use'] or 0
end

-------------------------------------
-- function makePrettyCellList
-------------------------------------
function ServerData_EventDice:makePrettyCellList(t_data)
    local l_ret = {}

    for cell, reward in pairs(t_data) do
        local l_reward = plSplit(reward, ';')
        local cell_num = tonumber(cell)

        table.insert(l_ret, {
            ['item_id'] = tonumber(l_reward[1]),
            ['value'] = l_reward[2],
            ['cell'] = cell_num
        })
    end
    
    table.sort(l_ret, function(a, b) 
        return a['cell'] < b['cell']
    end)
    
    return l_ret
end

-------------------------------------
-- function makePrettyLapRewardList
-------------------------------------
function ServerData_EventDice:makePrettyLapRewardList(t_data, t_reward)
    local l_ret = {}

    -- reward = '700001;1,700002;1'
    for lap, reward in pairs(t_data) do
        
        local comma_split_list = plSplit(reward, ',')
        local l_reward = {}
        for i, each_reward_str in pairs(comma_split_list) do
            local semi_split_list = plSplit(each_reward_str, ';')
            table.insert(l_reward, {
                ['item_id'] = tonumber(semi_split_list[1]),
                ['value'] = tonumber(semi_split_list[2]),
            })
        end
        
        local lap_num = tonumber(lap)
        local is_recieved = (t_reward[lap] == 1)

        table.insert(l_ret, {
            ['l_reward'] = l_reward,
            ['lap'] = lap_num,
            ['is_recieved'] = is_recieved
        })
    end
    
    table.sort(l_ret, function(a, b) 
        return a['lap'] < b['lap']
    end)

    return l_ret
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventDice:getStatusText()
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
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
-- function request_diceInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventDice:request_diceInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self.m_lCellList = self:makePrettyCellList(ret['cell_list'])
        self.m_lLapList = self:makePrettyLapRewardList(ret['lap_list'], ret['dice_reward'])
        self.m_diceInfo = StructEventDiceInfo(ret['dice_info'])
        self.m_endTime = ret['end']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/dice/info')
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
-- function request_diceRoll
-- @brief 이벤트 재화 사용
-------------------------------------
function ServerData_EventDice:request_diceRoll(finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
	
    -- 추가 주사위 사용 여부 지정 (골드로 일일 5회)
    local use_add_dice = false
    local curr_dice = self.m_diceInfo:getCurrDice()
    if (curr_dice <= 0) then -- 현재 주사위가 없을 경우
        if (not self.m_diceInfo:useAllAddDice()) then -- 추가 주사위 일일 횟수가 남아있을 경우
            use_add_dice = true
        end
    end

    -- 콜백
    local function success_cb(ret)
        self.m_diceInfo:apply(ret['dice_info'])
		g_serverData:networkCommonRespone(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/dice/roll')
    ui_network:setParam('uid', uid)
	ui_network:setParam('add_dice', use_add_dice)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    ui_network:hideBGLayerColor()

    return ui_network
end

-------------------------------------
-- function request_diceReward
-- @brief 이벤트 재화 누적 보상
-------------------------------------
function ServerData_EventDice:request_diceReward(lap, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)                    

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/dice/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('lap', lap)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end