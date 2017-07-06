local PARENT = TableClass

-------------------------------------
-- class TableMasterRoad
-------------------------------------
TableMasterRoad = class(PARENT, {
        last_road = nil, -- 'num',
    })

local THIS = TableMasterRoad

-------------------------------------
-- function init
-------------------------------------
function TableMasterRoad:init()
    self.m_tableName = 'master_road'
    self.m_orgTable = TABLE:get(self.m_tableName)
	self:arrangeData()

    if (TableMasterRoad.last_road == nil) then
        TableMasterRoad.last_road = self:getLastRoad()
    end
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
		local a_id = (a['rid'])
		local b_id = (b['rid'])
		return a_id < b_id
	end)

	return l_road_list
end

-------------------------------------
-- function getLastRoad
-- @brief 마지막 road id를 반환
-------------------------------------
function TableMasterRoad:getLastRoad()
    if (TableMasterRoad.last_road) then
        return TableMasterRoad.last_road
    else
        return self:findLastRoad()
    end
end

-------------------------------------
-- function findLastRoad
-- @brief 마지막 road id를 찾는다. 강제로 갱신할때도 사용할 예정
-------------------------------------
function TableMasterRoad:findLastRoad()
    if (self == THIS) then
        self = THIS()
    end

    local rid = 10000
    local t_master_road
    repeat
        rid = rid + 1
        t_master_road = self:get(rid, 'skip_error_msg')
    until (t_master_road == nil)

    return rid - 1
end