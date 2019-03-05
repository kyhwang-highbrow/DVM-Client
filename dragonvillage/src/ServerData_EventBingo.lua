-------------------------------------
-- class ServerData_EventBingo
-------------------------------------
ServerData_EventBingo = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventBingo:init(server_data)
    self.m_serverData = server_data
end
