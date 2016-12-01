-------------------------------------
-- class ServerData_User
-------------------------------------
ServerData_User = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_User:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_User:get(...)
    return self.m_serverData:get('user', ...)
end

-------------------------------------
-- function applyServerData
-------------------------------------
function ServerData_User:applyServerData(data, ...)
    return self.m_serverData:applyServerData(data, 'user', ...)
end

-------------------------------------
-- function getFruitCount
-- @brief 보유중인 열매 갯수 리턴
-------------------------------------
function ServerData_User:getFruitCount(fruit_id)
    local fruit_id = tostring(fruit_id)
    local count = self:get('fruits', fruit_id) or 0
    return count
end

-------------------------------------
-- function getResetFruitCount
-- @brief 망각의 열매 갯수 리턴
-------------------------------------
function ServerData_User:getResetFruitCount()
    local fruit_id = self:getResetFruitID()
    return self:getFruitCount(fruit_id)
end

-------------------------------------
-- function getResetFruitID
-- @brief 망각의 열매 ID
-------------------------------------
function ServerData_User:getResetFruitID()
    -- 망각의 열매 id : 702009
    return 702009
end

-------------------------------------
-- function getEvolutionStoneCount
-- @brief 보유중인 진화재료 갯수 리턴
-------------------------------------
function ServerData_User:getEvolutionStoneCount(evolution_stone_id)
    local evolution_stone_id = tostring(evolution_stone_id)
    local count = self:get('evolution_stones', evolution_stone_id) or 0
    return count
end

-------------------------------------
-- function getUserLevelInfo
-- @brief
-------------------------------------
function ServerData_User:getUserLevelInfo()
    local table_user_level = TableUserLevel()

    local lv = g_userData:get('lv')
    local exp = g_userData:get('exp')
    local percentage = table_user_level:getUserLevelExpPercentage(lv, exp)

    return lv, exp, percentage
end