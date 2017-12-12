local PARENT = TableClass

-------------------------------------
-- class TableDailyMission
-------------------------------------
TableDailyMission = class(PARENT, {
    })

local THIS = TableDailyMission

-------------------------------------
-- function init
-------------------------------------
function TableDailyMission:init()
    self.m_tableName = 'table_daily_mission'
    self.m_orgTable = TABLE:get(self.m_tableName)
end
