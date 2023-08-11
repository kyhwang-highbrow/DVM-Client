-------------------------------------
-- class ServerData_Latea
-------------------------------------
ServerData_Latea = class({
    m_serverData = 'ServerData',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_Latea:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getMyLateaBuffIdList
-------------------------------------
function ServerData_Latea:getMyLateaBuffIdList(deck_key)
    return {}
end