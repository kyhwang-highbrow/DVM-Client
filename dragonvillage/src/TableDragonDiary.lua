local PARENT = TableClass

-------------------------------------
-- class TableDragonDiary
-------------------------------------
TableDragonDiary = class(PARENT, {
        last_step = nil, -- 'num',
    })

local THIS = TableDragonDiary

-------------------------------------
-- function init
-------------------------------------
function TableDragonDiary:init()
    self.m_tableName = 'dragon_diary'
    self.m_orgTable = TABLE:get(self.m_tableName)
	self:arrangeData()

    if (TableDragonDiary.last_step == nil) then
        TableDragonDiary.last_step = self:getLastStep()
    end
end

-------------------------------------
-- function arrangeData
-------------------------------------
function TableDragonDiary:arrangeData()
	local reward_str = nil
	local t_reward = nil
	local reward_iv = nil
	local t_temp = nil

    -- 시작 테이머로 구분 (선택 드래곤에 해당되는 퀘스트만 들고 있자)
	local t_diary_table = self.m_orgTable
    local tid = g_userData:get('start_tamer')
    local name = TableTamer():getTamerType(tid)
    local new_diary_table = {}
    for k, v in pairs(t_diary_table) do
        local rid = k
        local idx = getDigit(rid, 100, 1)
        local target_idx = (name == 'goni') and 0 or 1 

        if (target_idx == idx) then
            new_diary_table[rid] = v
        end
    end

    self.m_orgTable = new_diary_table

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
function TableDragonDiary:getSortedList()
    if (self == THIS) then
        self = THIS()
    end

	local t_diary_table = self.m_orgTable

	local l_diary_list = table.MapToList(t_diary_table)
	table.sort(l_diary_list, function(a, b) 
		local a_id = (a['rid'])
		local b_id = (b['rid'])
		return a_id < b_id
	end)

	return l_diary_list
end

-------------------------------------
-- function getLastStep
-- @brief 마지막 rid를 반환
-------------------------------------
function TableDragonDiary:getLastStep()
    if (TableDragonDiary.last_step) then
        return TableDragonDiary.last_step
    else
        return self:findLastStep()
    end
end

-------------------------------------
-- function findLastStep
-- @brief 마지막 rid를 찾는다. 강제로 갱신할때도 사용할 예정
-------------------------------------
function TableDragonDiary:findLastStep()
    if (self == THIS) then
        self = THIS()
    end

    local tid = g_userData:get('start_tamer')
    local name = TableTamer():getTamerType(tid)
    local rid = (name == 'goni') and 11001 or 11101

    local t_dragon_diary
    repeat
        rid = rid + 1
        t_dragon_diary = self:get(rid, 'skip_error_msg')
    until (t_dragon_diary == nil)

    return rid - 1
end