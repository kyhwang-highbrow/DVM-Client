-------------------------------------
-- class ServerData_AdventureFirstReward
-- @brief 스테이지 최초 클리어 보상
--        ServerData_Adventure에 의존된 데이터
-------------------------------------
ServerData_AdventureFirstReward = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AdventureFirstReward:init(server_data)
    self.m_serverData = server_data
end