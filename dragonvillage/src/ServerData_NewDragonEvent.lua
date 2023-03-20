-------------------------------------
-- class ServerData_NewDragonEvent
-------------------------------------
ServerData_NewDragonEvent = class({
    m_serverData = 'ServerData',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_NewDragonEvent:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getNewDragonEventDungeonStageIdList
-------------------------------------
function ServerData_NewDragonEvent:getNewDragonEventDungeonStageIdList()
    -- 시나리오 작업할 수 있도록 일단 하드코딩
    return {
        4230101, 
        4230102, 
        4230103, 
        4230104, 
        4230105, 
        4230106, 
        4230107, 
        4230108, 
        4230109, 
        4230110,
    }
end
