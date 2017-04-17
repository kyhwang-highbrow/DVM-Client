local PARENT = TableClass

-------------------------------------
-- class TableQuest
-------------------------------------
TableQuest = class(PARENT, {
		------------Quest type-----------------------
		CHALLENGE = 'challenge',
		DAILY = 'daily',
		NEWBIE = 'newbie'
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
	local reward_str = nil
	local t_reward = nil
	local reward_iv = nil
	
    for qid, t_quest in pairs(self.m_orgTable) do
		-- reward parsing
		reward_str = t_quest['reward']
		t_reward = self:seperate(reward_str, ',')
		t_quest['t_reward'] = {}
		for i, each_reward in pairs(t_reward) do 
			reward_iv = self:seperate(each_reward, ':')
			t_quest['t_reward']['reward_type_'..i] = reward_iv[1]
			t_quest['t_reward']['reward_unit_'..i] = reward_iv[2]
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
-- function getMaxStep
-------------------------------------
function TableQuest:getMaxStep(qid)
    if (self == THIS) then
        self = THIS()
    end

    local max_step = self:getValue(qid, 'max_cnt')
    return max_step
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
-- function getQuestUnit
-------------------------------------
function TableQuest:getQuestUnit(qid)
    if (self == THIS) then
        self = THIS()
    end

    local unit = self:getValue(qid, 'unit')
    return unit
end

-------------------------------------
-- function getRewardInfoList
-------------------------------------
function TableQuest:getRewardInfoList(qid, step)
    if (self == THIS) then
        self = THIS()
    end

    local reward_str = self:getValue(qid, 'reward')
    local l_item_list = ServerData_Item:parsePackageItemStr(reward_str)

    local reward_max_cnt = self:getValue(qid, 'reward_max_cnt')
    reward_max_cnt = math_min(reward_max_cnt, step)

    for i,v in ipairs(l_item_list) do
        v['count'] = (v['count'] * reward_max_cnt)
    end

    return l_item_list
end