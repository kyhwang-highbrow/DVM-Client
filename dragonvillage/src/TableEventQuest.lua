local PARENT = TableClass

-------------------------------------
-- class TableEventQuest
-------------------------------------
TableEventQuest = class(PARENT, {
})

local THIS = TableEventQuest
-------------------------------------
-- function init
-------------------------------------
function TableEventQuest:init()
    self.m_tableName = 'table_event_quest'
    self.m_orgTable = self:getfilteredOrgTable()
	self:arrangeData()
end

-------------------------------------
-- function getfilteredOrgTable
-- @brief 조건에 맞추어 퀘스트를 걸러냄
-- @20190805 active 조건 : active = 0 인 퀘스트는 orgTable에서 제외시킴
-------------------------------------
function TableEventQuest:getfilteredOrgTable()
    local table_filtered = {}
    local org_table = TABLE:get(self.m_tableName)
    for key, data in pairs(org_table) do
        local is_active = CheckValidDateFromTableDataValue(data['start_date'], data['end_date'])
        if (is_active) then
            table_filtered[key] = data
        end
    end

    return table_filtered
end

-------------------------------------
-- function arrangeData
-------------------------------------
function TableEventQuest:arrangeData()
	local reward_str, t_reward, reward_iv, item_id = nil

    for qid, t_quest in pairs(self.m_orgTable) do
		-- reward parsing
		reward_str = t_quest['reward']
		t_reward = self:seperate(reward_str, ',')

		t_quest['t_reward'] = {}
		for i, each_reward in pairs(t_reward) do 
			reward_iv = self:seperate(each_reward, ';')
            item_id = TableItem:getItemIDFromItemType(reward_iv[1]) or tonumber(reward_iv[1])
			t_quest['t_reward'][i] = {['item_id'] = item_id, ['count'] = reward_iv[2]}
		end
	end
end

-------------------------------------
-- function arrangeDataByStr
-------------------------------------
function TableEventQuest.arrangeDataByStr(reward_str)
    local t_reward = plSplit(reward_str, ',')
    local t_quest = {}
    for i, each_reward in pairs(t_reward) do 
    	reward_iv = plSplit(each_reward, ';')
        item_id = TableItem:getItemIDFromItemType(reward_iv[1]) or tonumber(reward_iv[1])
    	local t_data = {['item_id'] = item_id, ['count'] = reward_iv[2]}
        table.insert(t_quest, t_data)
    end
    return t_quest
end

-------------------------------------
-- function getQuestType
-------------------------------------
function TableEventQuest:getQuestType(qid)
    if (self == THIS) then
        self = THIS()
    end

    local type = self:getValue(qid, 'type')
    return type
end

-------------------------------------
-- function getQuestDesc
-------------------------------------
function TableEventQuest:getQuestDesc(qid)
    if (self == THIS) then
        self = THIS()
    end

    local t_desc = self:getValue(qid, 't_desc')
    return t_desc
end

-------------------------------------
-- function findLastQuest
-------------------------------------
function TableEventQuest:findLastQuest(qid)
    if (self == THIS) then
        self = THIS()
    end
    local qid = qid
    local t_quest
    
    repeat
        qid = qid + 1
        t_quest = self:get(qid, true)
    until(t_quest == nil)

    qid = qid - 1

    return qid, self:get(qid)
end


-------------------------------------
-- function isLastQuest
-------------------------------------
function TableEventQuest:isLastQuest(qid)
    if (self == THIS) then
        self = THIS()
    end
    return (self:get(qid + 1, true) == nil)
end

-------------------------------------
-- function getTitleQuestMap
-- @brief 해당 칭호를 얻기 위한 조건 맵 생성
-------------------------------------
function TableEventQuest:getTitleQuestMap()
    if (self == THIS) then
        self = THIS()
    end
    
    local map_title_quest = {}

    for qid, t_quest in pairs(self.m_orgTable) do
        local title = t_quest['title']
        if (title and title ~= '') then
            local t_desc = t_quest['t_desc']
            local clear_value = t_quest['clear_value']
            local str_clear = Str(t_desc, comma_value(clear_value))
            map_title_quest[title] = str_clear
        end
    end

    --[[
        ['10130']='50명의 친구에게 우정의 징표 받기';
        ['10098']='드래곤과 500회 작별하기';
    ]]--

    return map_title_quest
end

------------------------------------
-- function getQuestTable
-- @brief 
-------------------------------------
function TableEventQuest:getQuestTable()
    if (self == THIS) then
        self = THIS()
    end

    return self.m_orgTable
end

------------------------------------
-- function isRewardMailTypeQuest
-- @brief 메일로 수령/즉시 수령 인지 판단, table_quest에서 mail_content에 보상 목록이 있다면 return true
-------------------------------------
function TableEventQuest:isRewardMailTypeQuest(qid)
    if (self == THIS) then
        self = THIS()
    end

    local mail_content = self:getValue(qid, 'mail_content')
    if (mail_content == '' or mail_content == nil) then
        return false
    end

    return true
end