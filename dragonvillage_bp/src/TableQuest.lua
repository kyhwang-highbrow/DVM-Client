local PARENT = TableClass

-------------------------------------
-- class TableQuest
-------------------------------------
TableQuest = class(PARENT, {
		------------Quest type-----------------------
		CHALLENGE = 'challenge',
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