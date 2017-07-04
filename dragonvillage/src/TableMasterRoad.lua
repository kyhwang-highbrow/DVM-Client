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