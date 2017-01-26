-------------------------------------
-- class ServerData_Quest
-------------------------------------
ServerData_Quest = class({
        m_serverData = 'ServerData',
		m_tableQuest = 'TableQuest',

		m_workedData = 'table',

		m_bDirtyQuestInfo = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Quest:init(server_data)
    self.m_serverData = server_data
	self.m_tableQuest = TableQuest()
	self.m_workedData = {}

	self.m_bDirtyQuestInfo = true

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
	local l_quest = self.m_serverData:get('quest_info') or {}

    for _,v in pairs(l_quest) do
        if (quset_id == v['qid']) then
            return clone(v)
        end
    end

    return nil
end


-------------------------------------
-- function mergeWithServerData
-- @breif 테이블 데이타와 서버 데이타를 조합해서 UI에서 활용 가능한 퀘스트 데이타 생성
-------------------------------------
function ServerData_Quest:mergeWithServerData()
	local t_table_quest = clone(self.m_tableQuest.m_orgTable)
	
	local qid, t_server_quest

	for i, t_quest in pairs(t_table_quest) do 
		qid = t_quest['qid']
		t_server_quest = self:getServerQuest(qid)

		if (t_server_quest) then 
			-- server data가 있다면 남아있는 퀘스트
			t_quest['is_cleared'] = false
			for i, v in pairs(t_server_quest) do 
				t_quest[i] = v
			end
		else
			-- server data가 없다면 클리어 한것
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

	-- type에 해당하는 퀘스트 뽑아냄
	for i, quest in pairs(self.m_workedData) do 
		if (quest['type'] == quest_type) then
			table.insert(l_quest, quest)
		end
	end

	--[[ 보상 수령 가능한 것을 위로
	table.sort(l_quest, function(a, b)
		return a['clearcnt'] > a['rewardcnt']
	end)]]

	-- qid 작은 순서대로 정렬
	table.sort(l_quest, function(a, b) 
		return (tonumber(a['qid']) < tonumber(b['qid']))
	end)

	return l_quest
end


-------------------------------------
-- function getAllClearQuestTable
-- @brief getQuestListByType와 같은 기능이지만 경량화
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

-------------------------------------
-- function requestQuestInfo
-------------------------------------
function ServerData_Quest:requestQuestInfo(cb_func)
	--[[
    if (not self.m_bDirtyQuestInfo) then
        if cb_func then
            cb_func()
        end
        return
    end
	]]

    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        if ret['quest_info'] then
            self:applyQuestInfo(ret['quest_info'])
			self:mergeWithServerData()
        end

        if cb_func then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/quest/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function applyQuestInfo
-- @breif 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_Quest:applyQuestInfo(data)
    self.m_serverData:applyServerData(data, 'quest_info')
    self.m_bDirtyQuestInfo = false
end

-------------------------------------
-- function requestQuestReward
-------------------------------------
function ServerData_Quest:requestQuestReward(qid, cb_func)
    local uid = g_userData:get('uid')
	local qid = qid
	if (not qid) then 
		error('잘못된 퀘스트 보상 접근')
	end

    -- 성공 시 콜백
    local function success_cb(ret)
        if cb_func then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/quest/get_reward')
    ui_network:setParam('uid', uid)
	ui_network:setParam('qid', qid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end
