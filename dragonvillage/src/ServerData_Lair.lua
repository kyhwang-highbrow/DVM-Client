-------------------------------------
-- class ServerData_Lair
-------------------------------------
ServerData_Lair = class({
    m_serverData = 'ServerData',
    m_lairStats = 'list<number>',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_Lair:init(server_data)
    self.m_serverData = server_data
    self.m_lairStats = {}
end

-------------------------------------
-- function getLairStats
-------------------------------------
function ServerData_Lair:getLairStats()
    return self.m_lairStats
end

-------------------------------------
-- function getLairStatsStringData
-------------------------------------
function ServerData_Lair:getLairStatsStringData()
    if #self.m_lairStats == 0 then
        return ''
    end

    local str = table.concat(self.m_lairStats, ',')
    return ',' .. str
end