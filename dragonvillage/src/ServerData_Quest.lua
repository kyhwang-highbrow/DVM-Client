-------------------------------------
-- class ServerData_Quest
-------------------------------------
ServerData_Quest = class({
        m_serverData = 'ServerData',
		m_tableQuest = 'TableQuest',

		m_workedData = 'table',

		m_bDirtyQuestInfo = 'bool',

        m_focusNewbieQid = '',
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
-- function makeQuestFullData
-- @breif 테이블 데이타와 서버 데이타를 조합해서 UI에서 활용 가능한 퀘스트 데이타 생성
-------------------------------------
function ServerData_Quest:makeQuestFullData()
	local t_table_quest = clone(self.m_tableQuest.m_orgTable)


    local focus_newbie_qid = nil
    local high_newbie_qid = nil

    self.m_workedData = {}

	for qid, t_quest in pairs(t_table_quest) do         
		local t_server_quest = self:getServerQuest(qid)

        local struct_quest_data = StructQuestData(t_server_quest)
        self.m_workedData[qid] = struct_quest_data
        

        -- 초보자 퀘스트 포커스 qid 검색
        if (struct_quest_data.m_type == 'newbie') and (not struct_quest_data:isQuestEnded()) then
            if (not focus_newbie_qid) or (qid < focus_newbie_qid)  then
                focus_newbie_qid = qid
            end
        end

        if (not high_newbie_qid) or (high_newbie_qid < qid) then
            high_newbie_qid = qid
        end

        --[[
        -- server data가 있다면 남아있는 퀘스트
		if (t_server_quest) then 
			-- 서버에서 주는것
            for i, v in pairs(t_server_quest) do 
				t_quest[i] = v
			end

            -- 클라에서 만들어 사용하는것
			t_quest['is_cleared'] = false
            if (t_quest['clearcnt'] > t_quest['rewardcnt']) then
                -- 아직 보상을 수령하지 않았다면 다음 목표를 노출하지 않는다.
                t_quest['goal_cnt'] = t_quest['clearcnt']
            else
				-- 혹시 그래도 서버에서 정보를 보낼 경우를 위한 처리
				if (t_quest['rewardcnt'] >= t_quest['max_cnt']) then 
					-- 퀘스트를 전부 완료한 상태
					t_quest['is_cleared'] = true
					t_quest['goal_cnt'] = t_quest['clearcnt']
				else
					t_quest['goal_cnt'] = t_quest['clearcnt'] + 1
				end
            end

        -- server data가 없다면 클리어 한것
		else
            -- 서버에서 주는것
            t_quest['clearcnt'] = t_quest['max_cnt']
            t_quest['rewardcnt'] = t_quest['max_cnt']
            t_quest['rawcnt'] = (t_quest['max_cnt'] * t_quest['unit'])
            
            -- 클라에서 만들어 사용하는것
            t_quest['is_cleared'] = true
            t_quest['goal_cnt'] = t_quest['max_cnt']
		end


        -- 초보자 퀘스트 포커스 qid 검색
        if (t_quest['type'] == 'newbie') and (not t_quest['is_cleared']) then
            if (not focus_newbie_qid) or (t_quest['qid'] < focus_newbie_qid)  then
                focus_newbie_qid = t_quest['qid']
            end
        end
        --]]
    end

    self.m_focusNewbieQid = focus_newbie_qid or high_newbie_qid
end

-------------------------------------
-- function getQuestListByType
-------------------------------------
function ServerData_Quest:getQuestListByType(quest_type)
	-- type에 해당하는 퀘스트 뽑아냄
    local l_quest = {}
	for i, quest in pairs(self.m_workedData) do 
		if (quest.m_type == quest_type) then
			table.insert(l_quest, quest)
		end
	end
	
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


    -- 초보자퀘스트는 qid로만 정렬
    if (quest_type == 'newbie') then
        table.sort(t_ret, function(a, b)
            return (tonumber(a['qid']) < tonumber(b['qid']))
	    end)
    end
	
	return t_ret
end

-------------------------------------
-- function getAllClearQuestTable
-- @brief getQuestListByType와 같은 기능이지만 특정 타입 찾는 용으로 경량화
-------------------------------------
function ServerData_Quest:getAllClearQuestTable(quest_type)
	local all_clear_type = quest_type .. '_all'
	local ret = nil

    for i,v in pairs(self.m_workedData) do
        if (v.m_type == all_clear_type) then
            ret = clone(v)
			break;
        end
    end

	return ret
end

-------------------------------------
-- function hasRewardableQuest
-- @brief 보상 수령 가능한 퀘스트가 있는지 찾는다.
-- @return boolean
-------------------------------------
function ServerData_Quest:hasRewardableQuest(quest_type)
    local is_exist = false

	-- type에 해당하는 퀘스트 뽑아냄
	for i, quest in pairs(self.m_workedData) do 
		if (quest.m_type == quest_type) then
            -- 보상 수령 가능한 상태
			if quest:hasReward() then
                is_exist = true
                break
            end
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
			self:makeQuestFullData()
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
-- function applyGoods
-- @breif 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_Quest:applyGoods(data, key)
    self.m_serverData:applyServerData(data, 'user', key)
    self.m_bDirtyQuestInfo = false
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

        g_serverData:networkCommonRespone_addedItems(ret)
		
		-- @TODO 퀘스트 정보 테이블 새로 만듬 -> 추후에는 갱신할수 있도록....
		if (isDirtyData) then 
			self:makeQuestFullData()
		end

        if (cb_func) then
			local t_quest_data = self:getQuest(qid)
            cb_func(t_quest_data)
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
