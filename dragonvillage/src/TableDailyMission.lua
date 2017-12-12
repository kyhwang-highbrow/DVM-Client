local PARENT = TableClass

-------------------------------------
-- class TalbeDailyMission
-------------------------------------
TalbeDailyMission = class(PARENT, {
    })

local THIS = TalbeDailyMission

-------------------------------------
-- function init
-------------------------------------
function TalbeDailyMission:init()
    self.m_tableName = 'table_daily_mission'
    self.m_orgTable = TABLE:get(self.m_tableName)
end
