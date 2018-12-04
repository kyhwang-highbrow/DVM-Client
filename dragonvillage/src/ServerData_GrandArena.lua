-------------------------------------
-- class ServerData_GrandArena
-- @instance g_grandArena
-------------------------------------
ServerData_GrandArena = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_GrandArena:init(server_data)
end


-------------------------------------
-- function isActive_grandArena
-- @brief 챌린지 모드 이벤트가 진행 중인지 여부 true or false
-------------------------------------
function ServerData_GrandArena:isActive_grandArena()
    return true
end