-------------------------------------
-- class ServerData_AdventureFirstReward
-- @brief 스테이지 최초 클리어 보상
--        ServerData_Adventure에 의존된 데이터
-------------------------------------
ServerData_AdventureFirstReward = class({
        m_serverData = 'ServerData',
        m_firstRewardDataTable = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AdventureFirstReward:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function organizeFirstRewardDataTable
-------------------------------------
function ServerData_AdventureFirstReward:organizeFirstRewardDataTable(first_reward_list)
    self.m_firstRewardDataTable = table.listToMap(first_reward_list, 'stage_id')
end

-------------------------------------
-- function getFirstRewardInfo
-------------------------------------
function ServerData_AdventureFirstReward:getFirstRewardInfo(stage_id)
    return self.m_firstRewardDataTable[stage_id]
end