-------------------------------------
-- class ServerData_BattlePass
-- @brief 
-------------------------------------

ServerData_BattlePass = class({
        m_serverData = 'ServerData',

        m_battlePathInfo = 'StructBattlePassInfo',

    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_BattlePass:init(server_data)
    self.m_serverData = server_data
    self.m_battlePathInfo = StructBattlePassInfo()

    -- 테스트 데이터
    -- 필요한것을 아래에 가라로 집어넣으면 됨
    local t_fake_info = {}
    t_fake_info["isPurchased"] = true
    t_fake_info["max_exp"] = 10000
    t_fake_info["cur_exp"] = 10

    t_fake_info["item_list"] = {
        {itemIndex = 1, item_normal = "779255;1", item_pass = "703016;3", isReceived = true, isPassReceived = true},
        {itemIndex = 2, item_normal = "779255;1", item_pass = "703016;3", isReceived = true, isPassReceived = true},
        {itemIndex = 3, item_normal = "779255;1", item_pass = "703016;3", isReceived = true, isPassReceived = true},
        {itemIndex = 4, item_normal = "779255;1", item_pass = "703016;3", isReceived = true, isPassReceived = true},
        {itemIndex = 5, item_normal = "779255;1", item_pass = "703016;3", isReceived = false, isPassReceived = true},
        {itemIndex = 6, item_normal = "779255;1", item_pass = "703016;3", isReceived = false, isPassReceived = true},
        {itemIndex = 7, item_normal = "779255;1", item_pass = "703016;3", isReceived = false, isPassReceived = true},
        {itemIndex = 8, item_normal = "779255;1", item_pass = "703016;3", isReceived = false, isPassReceived = true},
        {itemIndex = 9, item_normal = "779255;1", item_pass = "703016;3", isReceived = false, isPassReceived = true},
        {itemIndex = 10, item_normal = "779255;1", item_pass = "703016;3", isReceived = false, isPassReceived = true}
    }

    table.sort(t_fake_info["item_list"], function(a, b) return (tonumber(a['itemIndex']) < tonumber(b['itemIndex'])) end)

    self.m_battlePathInfo:updateInfo(t_fake_info)
end


-------------------------------------
-- function getNormalRewardInfo
-------------------------------------
function ServerData_BattlePass:getRewardList()
    local tResult = {}
    if (not self.m_battlePathInfo) then return tResult end

    return self.m_battlePathInfo:getRewardList()
end

-------------------------------------
-- function getExp
-- curExp, maxExp 반환
-------------------------------------
function ServerData_BattlePass:getExp()
    if (not self.m_battlePathInfo) then return 0, 0 end

    return self.m_battlePathInfo:getExp()
end

-------------------------------------
-- function getRemainTime
-------------------------------------
function ServerData_BattlePass:getRemainTime()
    --Str('{1} 남음', datetime.makeTimeDesc(time, show_second, first_only))
    local tResult = {}
    if (not self.m_battlePathInfo) then return tResult end

    return self.m_battlePathInfo:getRemainTime()
end

-------------------------------------
-- function getExp
-- curExp, maxExp 반환
-------------------------------------
function ServerData_BattlePass:getNormalRewardInfo()
    if (not self.m_battlePathInfo) then return 0, 0 end

    return self.m_battlePathInfo:getExp()
end

-------------------------------------
-- function getExp
-- curExp, maxExp 반환
-------------------------------------
function ServerData_BattlePass:getSpecialRewardInfo()
    if (not self.m_battlePathInfo) then return 0, 0 end

    return self.m_battlePathInfo:getExp()
end

-------------------------------------
-- function request_battlePassInfo
-------------------------------------
function ServerData_BattlePass:request_battlePassInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/battle_pass/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_battlePassReward
-------------------------------------
function ServerData_BattlePass:request_battlePassReward(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/battle_pass/reward')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end
