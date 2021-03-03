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

