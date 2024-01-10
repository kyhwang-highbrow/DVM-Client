-------------------------------------
--- @class ServerData_WorldRaid
-- g_worldRaidData
-------------------------------------
ServerData_WorldRaid = class({
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_WorldRaid:init()
end

-------------------------------------
--- @function isAvailableWorldRaid
-------------------------------------
function ServerData_WorldRaid:isAvailableWorldRaid()
    return true --g_hotTimeData:isActiveEvent('world_raid')
end