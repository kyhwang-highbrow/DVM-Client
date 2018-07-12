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
function TableMasterRoad:getSortedList(curr_rid)
    if (self == THIS) then
        self = THIS()
    end

    local t_road = self:get(curr_rid)
    local road_type = t_road['road_type']
    local l_road_list = self:filterList('road_type', road_type)
    
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
        if (self == THIS) then
            self = THIS()
        end
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

-------------------------------------
-- function getTitleStr
-------------------------------------
function TableMasterRoad:getTitleStr(t_road)
    if (not t_road) then
        return ''
    end

    if (t_road['road_type'] == 'normal') then
        return Str('마스터의 길')
    elseif (t_road['road_type'] == 'expert') then
        return Str('마스터의 길 (상급)')
    else
        return 'something wrong'
    end
end

-------------------------------------
-- function getDescStr
-------------------------------------
function TableMasterRoad:getDescStr(t_road)
    if (not t_road) then
        return ''
    end

	-- 번역 안되는 부분 수정 (임시 조치)
	local desc_1 = t_road['desc_1']
	if (Translate:isNeedTranslate()) then
		if (string.find(t_road['desc_1'], '어려움')) then
			desc_1 = string.gsub(t_road['desc_1'], '어려움', Str('어려움'))

		elseif (string.find(t_road['desc_1'], '지옥')) then
			desc_1 = string.gsub(t_road['desc_1'], '지옥', Str('지옥'))

		end	
	end

    return Str(t_road['t_desc'], desc_1, t_road['desc_2'], t_road['desc_3'])
end

-------------------------------------
-- function getRoadIdxStandard
-------------------------------------
function TableMasterRoad:getRoadIdxStandard(rid)
    if (self == THIS) then
        self = THIS()
    end

    local road_type = self:getValue(rid, 'road_type')
    if (road_type == 'normal') then
        return 10000
    elseif (road_type == 'expert') then
        return 10114
    end
end