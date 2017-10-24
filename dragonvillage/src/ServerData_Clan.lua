-------------------------------------
-- class ServerData_Clan
-------------------------------------
ServerData_Clan = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Clan:init(server_data)
    self.m_serverData = server_data
end