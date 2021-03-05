-------------------------------------
-- class ServerData_BattlePass
-- @brief 
-------------------------------------

ServerData_BattlePass = class({
        m_serverData = 'ServerData',

        m_battlePassTable = 'TableBattlePass',
        -- StructBattlePassInfo Map
        -- keyword : product id
        m_tPassData = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_BattlePass:init(server_data)
    self.m_serverData = server_data
    self.m_battlePassTable = TableBattlePass()
    self.m_tPassData = {}
end


-- getter, setter
-------------------------------------
-- function isPurchased
-- 결제 여부
-------------------------------------
function ServerData_BattlePass:isPurchased(product_id)
    local t_data = m_tPassData[tostring(product_id)]

    if (not t_data or t_data['is_premium']) then return false end
    if (not m_tPassData[product_id]['is_premium'] ~= 1) then return false end

    -- 1:결제O or 0:결제X
    return true
end

-------------------------------------
-- function getNormalList
-- 일반보상 리스트
-------------------------------------
function ServerData_BattlePass:getNormalList(product_id)
    return self.m_battlePassTable:getNormalRewardList()
end

-------------------------------------
-- function getPremiumList
-- 패스보상 리스트
-------------------------------------
function ServerData_BattlePass:getPremiumList(product_id)
    return self.m_battlePassTable:getPremiumRewardList()
end


-------------------------------------
-- function getRewardedNormalList
-- 받은 일반보상 리스트
-------------------------------------
function ServerData_BattlePass:getRewardedNormalList(product_id)
    
end

-------------------------------------
-- function getRewardedPremiumList
-- 받은 패스보상 리스트
-------------------------------------
function ServerData_BattlePass:getRewardedPremiumList(product_id)
    
end

-------------------------------------
-- function getMaxLevel
-- 달성할 수 있는 맥스 레벨
-------------------------------------
function ServerData_BattlePass:getMaxLevel(product_id)
    
end

-------------------------------------
-- function getCurLevel
-- 현재 유저 레벨
-------------------------------------
function ServerData_BattlePass:getCurLevel(product_id)
    
end

-------------------------------------
-- function getTotalExp
-- 현재 유저 경험치
-------------------------------------
function ServerData_BattlePass:getTotalExp(product_id)
    
end

-------------------------------------
-- function getRequiredExpForLevelUp
-- 레벨업에 필요한 경험치
-------------------------------------
function ServerData_BattlePass:getRequiredExpForLevelUp(product_id)
    
end

-------------------------------------
-- function getExp
-- 레벨 구간 기준 현재 유저 경험치
-------------------------------------
function ServerData_BattlePass:getExp(product_id)
    
end

-------------------------------------
-- function getRemainTimeStr
-- 남은 시간
-------------------------------------
function ServerData_BattlePass:getRemainTimeStr(product_id)
    
end




-- server communication
-------------------------------------
-- function request_battlePassInfo
-------------------------------------
function ServerData_BattlePass:request_battlePassInfo(finish_cb, fail_cb)
    -- 테이블 정보 한번 업뎃해주기
    self.m_battlePassTable:updateTableMap()

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:updateBattlePassInfo(ret['battle_pass_info'])

        ccdump(self.m_tPassData)

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
-- function request_battlePremiumReward
-------------------------------------
function ServerData_BattlePass:request_battlePremiumReward(finish_cb, fail_cb)
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

-------------------------------------
-- function updateBattlePassInfo
-- 전체 정보 업데이트
-------------------------------------
function ServerData_BattlePass:updateBattlePassInfo(data)
    self.m_tPassData = {}

    if (not data) then return self.m_tPassData end

    for id, tData in pairs(data) do
        if (tData) then
            self.m_tPassData[tostring(id)] = StructBattlePassInfo(tData)
        end
    end
end

-------------------------------------
-- function generateTestData
-- 테스트 데이터 만들어서 반환
-------------------------------------
function ServerData_BattlePass:generateTestData()

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

    return t_fake_info
end