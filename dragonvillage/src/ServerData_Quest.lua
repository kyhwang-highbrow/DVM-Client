-------------------------------------
-- class ServerData_Quest
-------------------------------------
ServerData_Quest = class({
        m_serverData = 'ServerData',
		m_tableQuest = 'TableQuest',

		m_tQuestInfo = 'table', -- m_workedData
        m_tRewardInfo = 'table',

        m_dailyClearQuest = 'StructQuestData',

		m_bDirtyQuestInfo = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Quest:init(server_data)
    self.m_serverData = server_data
	self.m_tableQuest = TableQuest()
	self.m_tQuestInfo = {}

	self.m_bDirtyQuestInfo = true
end

-------------------------------------
-- function getQuest
-------------------------------------
function ServerData_Quest:getQuest(quset_id)

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
-- function applyQuestInfo
-- @breif 테이블 데이타와 서버 데이타를 조합해서 UI에서 활용 가능한 퀘스트 데이타 생성
-------------------------------------
function ServerData_Quest:applyQuestInfo(t_quest_info)
    --self.m_tQuestInfo = t_quest_info

    local struct_quest
    for quest_type, t_quest_type in pairs(t_quest_info) do

        local t_focus = t_quest_type['focus']
        local t_reward = t_quest_type['reward']

        local l_quest = {}
        local t_quest, reward, t_data, struct_quest
        for qid, rawcnt in pairs(t_focus) do
            t_quest = self.m_tableQuest:get(tonumber(qid))
            reward = t_reward[qid] and true or false

            t_data ={['qid'] = qid, ['rawcnt'] = rawcnt, ['quest_type'] = quest_type, ['reward'] = reward, ['t_quest'] = t_quest}
            struct_quest = StructQuestData(t_data)

            if (t_quest['key'] == 'dq_clear') then
                self.m_dailyClearQuest = struct_quest
            else
                table.insert(l_quest, struct_quest)
            end
        end

        self.m_tQuestInfo[quest_type] = {}
        --self.m_tQuestInfo[quest_type]['focus'] = t_focus
        --self.m_tQuestInfo[quest_type]['reward'] = t_reward
        self.m_tQuestInfo[quest_type]['quest'] = l_quest
    end

end

-------------------------------------
-- function getQuestListByType
-- @brief 해당 타입의 진행중인 퀘스트를 리턴한다.
-------------------------------------
function ServerData_Quest:getQuestListByType(quest_type)
    local l_quest = self.m_tQuestInfo[quest_type]['quest']

	-- 보상 있는 퀘스트, 완료한 퀘스트만 추출
	local l_reward_quest = {}
	local l_completed_quest = {}
	local l_normal_quest = {}
	for i, quest in pairs(l_quest) do
		-- 보상 있는 퀘스트
		if quest:hasReward() then
			table.insert(l_reward_quest ,quest)
		
        -- 남아있는 퀘스트
		elseif (not quest:isQuestEnded()) then
			table.insert(l_normal_quest, quest)
		
        -- 완료한 퀘스트
		else
            table.insert(l_completed_quest, quest)
			
		end
	end

    -- 전부 qid 순으로 정렬    
    table.sort(l_reward_quest, function(a, b)
        return (tonumber(a['qid']) < tonumber(b['qid']))
	end)
	table.sort(l_normal_quest, function(a, b)
        return (tonumber(a['qid']) < tonumber(b['qid']))
	end)
	table.sort(l_completed_quest, function(a, b)
        return (tonumber(a['qid']) < tonumber(b['qid']))
	end)

	-- merge 해서 리턴
	local t_ret = table.merge(l_reward_quest, l_normal_quest)
	t_ret = table.merge(t_ret, l_completed_quest)
    
	return t_ret
end

-------------------------------------
-- function getAllClearDailyQuestTable
-- @brief daily quest all clear를 찾아서 반환
-------------------------------------
function ServerData_Quest:getAllClearDailyQuestTable()
	return self.m_dailyClearQuest
end

-------------------------------------
-- function hasRewardableQuest
-- @brief 보상 수령 가능한 퀘스트가 있는지 찾는다.
-- @return boolean
-------------------------------------
function ServerData_Quest:hasRewardableQuest(quest_type)
    local is_exist = false

	-- type에 해당하는 퀘스트 뽑아냄
	for i, quest in pairs(self.m_tQuestInfo[quest_type]['quest']) do 
        -- 보상 수령 가능한 상태
		if quest:hasReward() then
            is_exist = true
            break
        end
	end

	return is_exist
end

-------------------------------------
-- function requestQuestInfo
-- @brief 서버에 퀘스트 정보 요청
-------------------------------------
function ServerData_Quest:requestQuestInfo(cb_func)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        if ret['quest_info'] then
            self:applyQuestInfo(ret['quest_info'])
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
-- function requestQuestReward
-- @brief 서버에 퀘스트 보상 수령 요청
-------------------------------------
function ServerData_Quest:requestQuestReward(qid, cb_func)
    local uid = g_userData:get('uid')
	local qid = qid
	if (not qid) then 
		error('잘못된 퀘스트 보상 접근')
	end

    -- 성공 시 콜백
    local function success_cb(ret)
		local isDirtyData = false

		-- 받은 정보 갱신 
        if (ret['quest_info']) then
		    self:applyQuestInfo(ret['quest_info'])
			isDirtyData = true
        end

        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        if (cb_func) then
			--local t_quest_data = self:getQuest(qid)
            --cb_func(t_quest_data)
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
