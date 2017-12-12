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

-------------------------------------
-- function getMissionList
-------------------------------------
function TableDailyMission:getMissionList(key)
	if (self == THIS) then
        self = THIS()
    end

	local list = self:filterList('mission', key)
	table.sort(list, function(a, b)
		return tonumber(a['day']) < tonumber(b['day'])
	end)

	return list
end