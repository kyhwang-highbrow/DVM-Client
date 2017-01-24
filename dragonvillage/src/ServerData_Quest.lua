-------------------------------------
-- class ServerData_Quest
-------------------------------------
ServerData_Quest = class({
        m_serverData = 'ServerData',
		m_tableQuest = 'TableQuest',

		m_workedData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Quest:init(server_data)
    self.m_serverData = server_data
	self.m_tableQuest = TableQuest()
	self.m_workedData = {}

	self:mergeWithSeverData()
end

-------------------------------------
-- function getQuest
-------------------------------------
function ServerData_Quest:getQuest(quset_id)
	for _, v in pairs(self.m_workedData) do
        if (quset_id == v['qid']) then
            return clone(v)
        end
    end
end

-------------------------------------
-- function getServerQuest
-------------------------------------
function ServerData_Quest:getServerQuest(quset_id)
	local l_quest = self.m_serverData:get('quests') or {}

    for _,v in pairs(l_quest) do
        if (quset_id == v['qid']) then
            return clone(v)
        end
    end

    return
	{
        rewardcnt = 10,
        clearcnt = 10,
		rawcnt = 1
    }
end


-------------------------------------
-- function mergeWithSeverData
-- @breif ���̺� ����Ÿ�� ���� ����Ÿ�� �����ؼ� UI���� Ȱ�� ������ ����Ʈ ����Ÿ ����
-------------------------------------
function ServerData_Quest:mergeWithSeverData()
	local t_table_quest = clone(self.m_tableQuest.m_orgTable)
	
	local qid, t_server_quest

	for i, t_quest in pairs(t_table_quest) do 
		qid = t_quest['qid']
		t_server_quest = self:getServerQuest(qid)

		if (t_server_quest) then 
			-- server data�� �ִٸ� �����ִ� ����Ʈ
			t_quest['is_cleared'] = false
			for i, v in pairs(t_server_quest) do 
				t_quest[i] = v
			end
		else
			-- server data�� ���ٸ� Ŭ���� �Ѱ�
			t_quest['is_cleared'] = true
		end
	end

	self.m_workedData = t_table_quest
end

-------------------------------------
-- function getQuestListByType
-------------------------------------
function ServerData_Quest:getQuestListByType(quest_type)
    local l_quest = {}

	-- type�� �ش��ϴ� ����Ʈ �̾Ƴ�
	for i, quest in pairs(self.m_workedData) do 
		if (quest['type'] == quest_type) then
			table.insert(l_quest, quest)
		end
	end

	-- qid ���� ������� ����
	table.sort(l_quest, function(a, b) 
		return tonumber(a['qid']) < tonumber(b['qid'])
	end)

	return l_quest
end


-------------------------------------
-- function getAllClearQuestTable
-- @brief getQuestListByType�� ���� ��������� �淮ȭ
-------------------------------------
function ServerData_Quest:getAllClearQuestTable(quest_type)
	local all_clear_type = quest_type .. '_all'
	local key = 'type'
	local ret = nil

    for i,v in pairs(self.m_workedData) do
        if (v[key] == all_clear_type) then
            ret = clone(v)
			break;
        end
    end

	return ret
end


