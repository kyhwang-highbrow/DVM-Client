local PARENT = TableClass

-------------------------------------
-- class TableQuest
-------------------------------------
TableQuest = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableQuest:init()
    self.m_tableName = 'quest'
    self.m_orgTable = TABLE:get(self.m_tableName)
	self:parsingReward()
end

-------------------------------------
-- function getQuestListByType
-------------------------------------
function TableQuest:getQuestListByType(quest_type)
    local l_quest = self:filterList('type', quest_type)

	-- qid 작은 순서대로 정렬
	table.sort(l_quest, function(a, b) 
		return tonumber(a['qid']) < tonumber(b['qid'])
	end)

	return l_quest
end

-------------------------------------
-- function parsingReward
-------------------------------------
function TableQuest:parsingReward()
	local reward_str = nil
	local t_reward = nil
	local reward_iv = nil
	
    for qid, t_quest in pairs(self.m_orgTable) do
		reward_str = t_quest['reward']
		t_reward = seperate(reward_str, ',')
		
		for i, each_reward in pairs(t_reward) do 
			reward_iv = seperate(each_reward, ':')
			t_quest['reward_type_'..i] = reward_iv[1]
			t_quest['reward_value_'..i] = reward_iv[2]
		end
	end
end

-------------------------------------
-- function getAllClearQuestTable
-------------------------------------
function TableQuest:getAllClearQuestTable(quest_type)
	local all_clear_type = quest_type .. '_all'
	local key = 'type'
	local ret = nil

    for i,v in pairs(self.m_orgTable) do 
        if (v[key] == all_clear_type) then
            ret = v
			break;
        end
    end

	return ret
end


