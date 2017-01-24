-------------------------------------
-- class ServerData_Quest
-------------------------------------
ServerData_Quest = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Quest:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getQuestData
-------------------------------------
function ServerData_Quest:getQuestData(qid)
    self.m_serverData:get('quests', qid)
end