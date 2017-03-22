-------------------------------------
-- class ServerData_Runes
-------------------------------------
ServerData_Runes = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Runes:init(server_data)
    self.m_serverData = server_data
end