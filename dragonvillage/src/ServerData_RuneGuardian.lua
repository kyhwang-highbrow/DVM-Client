-------------------------------------
-- class ServerData_RuneGuardian
-------------------------------------
ServerData_RuneGuardian = class({
    m_serverData = 'ServerData',
    m_stageClearMap = 'Map<number, table>',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_RuneGuardian:init(server_data)
    self.m_serverData = server_data
    self.m_stageClearMap = {}
end

-------------------------------------
-- function applyRuneGuardianClearInfo
-------------------------------------
function ServerData_RuneGuardian:applyRuneGuardianClearInfo(t_info)
    for stage_id, v in pairs(t_info) do
        self.m_stageClearMap[tonumber(stage_id)] = v['cl_cnt']
    end
end

-------------------------------------
-- function isRuneGuardianStageClear
-------------------------------------
function ServerData_RuneGuardian:isRuneGuardianStageClear(stage_id)
    local clear_value = self.m_stageClearMap[stage_id]
    if clear_value ~= nil then
        return clear_value > 0
    end
    return false
end