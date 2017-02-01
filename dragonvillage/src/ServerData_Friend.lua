-------------------------------------
-- class ServerData_Friend
-------------------------------------
ServerData_Friend = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Friend:init(server_data)
    self.m_serverData = server_data
end