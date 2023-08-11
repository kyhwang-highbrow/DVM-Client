-------------------------------------
-- class ServerData_Latea
-------------------------------------
ServerData_Latea = class({
    m_serverData = 'ServerData',
    m_lateaStats = 'list<number>',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_Latea:init(server_data)
    self.m_serverData = server_data
    self.m_lateaStats = {}
end

-------------------------------------
-- function getLateaStats
-------------------------------------
function ServerData_Latea:getLateaStats()
    return self.m_lateaStats
end

-------------------------------------
-- function getLateaStatsStringData
-------------------------------------
function ServerData_Latea:getLateaStatsStringData()
    if #self.m_lateaStats == 0 then
        return ''
    end

    local str = table.concat(self.m_lateaStats, ',')
    return ',' .. str
end