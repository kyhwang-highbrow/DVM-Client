local PARENT = TableClass

-------------------------------------
-- class TableDrop
-------------------------------------
TableDrop = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDrop:init()
    self.m_tableName = 'drop'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getStageMissionList
-------------------------------------
function TableDrop:getStageMissionList(stage_id)
	local t_drop = self:get(stage_id)
    local t_ret = {}

    for i=1, 3 do
        local mission_str = t_drop['mission_0' .. i]
        local trim_execution = true
        local l_list = self:seperate(mission_str, ',', trim_execution)
		table.insert(t_ret, l_list)
		--[[
			local type = l_list[1]
			local value_1 = l_list[2]
			local value_2 = l_list[3]
			local value_3 = l_list[4]
		]]
	end

	return t_ret
end