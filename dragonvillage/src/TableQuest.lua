local PARENT = TableClass

-------------------------------------
-- class TableQuest
-------------------------------------
TableQuest = class(PARENT, {
		------------Quest type-----------------------
		CHALLENGE = 'challenge',
		SPECIAL = 'special',
		DAILY = 'daily',
    })

local THIS = TableQuest

-------------------------------------
-- function init
-------------------------------------
function TableQuest:init()
    self.m_tableName = 'quest'
    self.m_orgTable = TABLE:get(self.m_tableName)
	self:arrangeData()
end

-------------------------------------
-- function arrangeData
-------------------------------------
function TableQuest:arrangeData()
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
-- function getQuestType
-------------------------------------
function TableQuest:getQuestType(qid)
    if (self == THIS) then
        self = THIS()
    end

    local type = self:getValue(qid, 'type')
    return type
end

-------------------------------------
-- function getQuestDesc
-------------------------------------
function TableQuest:getQuestDesc(qid)
    if (self == THIS) then
        self = THIS()
    end

    local t_desc = self:getValue(qid, 't_desc')
    return t_desc
end

-------------------------------------
-- function findLastQuest
-------------------------------------
function TableQuest:findLastQuest(qid)
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
function TableQuest:isLastQuest(qid)
    if (self == THIS) then
        self = THIS()
    end
    return (self:get(qid + 1, true) == nil)
end

-------------------------------------
-- function getTitleQuestMap
-- @brief 해당 칭호를 얻기 위한 조건 맵 생성
-------------------------------------
function TableQuest:getTitleQuestMap()
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
function TableQuest:getQuestTable()
    if (self == THIS) then
        self = THIS()
    end

    return self.m_orgTable
end