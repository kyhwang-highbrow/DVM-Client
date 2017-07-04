local PARENT = TableClass

-------------------------------------
-- class TableMasterRoad
-------------------------------------
TableMasterRoad = class(PARENT, {
    })

local THIS = TableMasterRoad

-------------------------------------
-- function init
-------------------------------------
function TableMasterRoad:init()
    self.m_tableName = 'master_road'
    self.m_orgTable = TABLE:get(self.m_tableName)
	self:arrangeData()
end

-------------------------------------
-- function arrangeData
-------------------------------------
function TableMasterRoad:arrangeData()
	local reward_str = nil
	local t_reward = nil
	local reward_iv = nil
	local t_temp = nil

    for _, t_quest in pairs(self.m_orgTable) do
		-- reward parsing
		reward_str = t_quest['reward']
		t_reward = self:seperate(reward_str, ',')
		t_temp = {}

		for i, each_reward in pairs(t_reward) do 
			reward_iv = self:seperate(each_reward, ';')
			table.insert(t_temp, {item_type = reward_iv[1], count = reward_iv[2]})
		end

		t_quest['t_reward'] = t_temp
	end
end

-------------------------------------
-- function getSortedList
-- @brief mid를 기준으로 정렬된 리스트 반환
-------------------------------------
function TableMasterRoad:getSortedList()
    if (self == THIS) then
        self = THIS()
    end

	local t_road_table = self.m_orgTable
	local l_road_list = table.MapToList(t_road_table)
	table.sort(l_road_list, function(a, b) 
		local a_id = (a['mid'])
		local b_id = (b['mid'])
		return a_id < b_id
	end)

	return l_road_list
end