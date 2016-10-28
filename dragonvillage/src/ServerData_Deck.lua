-------------------------------------
-- class ServerData_Deck
-------------------------------------
ServerData_Deck = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Deck:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_Deck:get(key)
    return self.m_serverData:get('deck', key)
end

-------------------------------------
-- function getDeck
-------------------------------------
function ServerData_Deck:getDeck(type)
    return self:get(type)
end