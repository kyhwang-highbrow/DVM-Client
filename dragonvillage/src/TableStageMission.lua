local PARENT = TableClass

-------------------------------------
-- class TableStageMission
-------------------------------------
TableStageMission = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableStageMission:init()
    self.m_tableName = 'stage_mission'
    self.m_orgTable = TABLE:get(self.m_tableName)
end