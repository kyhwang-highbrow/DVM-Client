local PARENT = TableClass

-------------------------------------
-- class TableShop
-------------------------------------
TableShop = class(PARENT, {
		
		------------Shop type-----------------------
		GACHA = 'draw',
		CASH = 'cash',
		GOLD = 'gold',
		STAMINA = 'wing'
    })

-------------------------------------
-- function init
-------------------------------------
function TableShop:init()
    self.m_tableName = 'quest'
    self.m_orgTable = TABLE:get(self.m_tableName)
	self:arrangeData()
end

-------------------------------------
-- function arrangeData
-------------------------------------
function TableShop:arrangeData()
	local reward_str = nil
	local t_reward = nil
	local reward_iv = nil
	
    for qid, t_quest in pairs(self.m_orgTable) do
		-- reward parsing
		reward_str = t_quest['reward']
		t_reward = seperate(reward_str, ',')
		t_quest['t_reward'] = {}
		for i, each_reward in pairs(t_reward) do 
			reward_iv = seperate(each_reward, ':')
			t_quest['t_reward']['reward_type_'..i] = reward_iv[1]
			t_quest['t_reward']['reward_unit_'..i] = reward_iv[2]
		end
	end
end
