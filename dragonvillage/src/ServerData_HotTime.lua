-------------------------------------
-- class ServerData_HotTime
-------------------------------------
ServerData_HotTime = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_HotTime:init(server_data)
    self.m_serverData = server_data
end