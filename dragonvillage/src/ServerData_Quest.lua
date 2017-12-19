-------------------------------------
-- class ServerData_Quest
-------------------------------------
ServerData_Quest = class({
        m_serverData = 'ServerData',
		m_tableQuest = 'TableQuest',

		m_tQuestInfo = 'table',

        m_dailyClearQuest = 'StructQuestData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Quest:init(server_data)
    self.m_serverData = server_data
	self.m_tableQuest = TableQuest()
	self.m_tQuestInfo = {}
end

-------------------------------------
-- function getQuest
-------------------------------------
function ServerData_Quest:getQuest(quest_type, quest_id)
    local l_quest = self.m_tQuestInfo[quest_type]

    for i, quest in pairs(l_quest) do
        if (tonumber(quest['qid']) == tonumber(quest_id)) then
            return quest
        end
    end

    return nil
end

-------------------------------------
-- function applyQuestInfo
-- @breif 테이블 데이타와 서버 데이타를 조합해서 UI에서 활용 가능한 퀘스트 데이타 생성
-------------------------------------
function ServerData_Quest:applyQuestInfo(t_quest_info)
    local t_data, struct_quest
    local qid_n, rawcnt, reward, clear
    local is_end

    -- DAILY
    do
        local quest_type = TableQuest.DAILY
        local t_daily = t_quest_info[quest_type]
    
        -- server_data 분류
        local t_focus = t_daily['focus']
        local l_reward = t_daily['reward']

        -- 클라 데이터 생성 (테이블 기반)
        local l_quest = {}
        local l_quest_list = self.m_tableQuest:filterList('type', quest_type)

        for _, t_quest in pairs(l_quest_list) do
            qid_n = tonumber(t_quest['qid'])
            rawcnt = t_focus[tostring(qid_n)]
            reward = table.find(l_reward, qid_n) and true or false
            is_end = (rawcnt == nil) and (reward == false)

            -- StructQuestData 생성
            t_data ={['qid'] = qid_n, ['rawcnt'] = rawcnt, ['quest_type'] = quest_type, ['reward'] = reward, ['is_end'] = is_end, ['t_quest'] = t_quest}
            struct_quest = StructQuestData(t_data)

            -- 데일리 클리어는 따로 빼준다.
            if (t_quest['key'] == 'dq_clear') then
                self.m_dailyClearQuest = struct_quest
            else
                table.insert(l_quest, struct_quest)
            end
        end

        self.m_tQuestInfo[quest_type] = l_quest
    end

    -- CHALLENGE
    do
        local quest_type = TableQuest.CHALLENGE
        local t_challenge = t_quest_info[quest_type]
    
        -- server_data 분류
        local t_focus = t_challenge['focus']
        local l_reward = t_challenge['reward']

        -- 클라 데이터 생성 (서버 정보 기반)
        local l_quest = {}
        for qid, rawcnt in pairs(t_focus) do
            qid_n = tonumber(qid)
            t_quest = self.m_tableQuest:get(qid_n)
            reward = table.find(l_reward, qid_n) and true or false
            
            -- 보상도 받았고 달성도 했는데 다음 focus를 안준다면 이미 클리어한것
            is_end = false
            if (rawcnt >= t_quest['clear_value']) and (reward == false) then
                is_end = true
            end

            -- StructQuestData 생성
            t_data ={['qid'] = qid_n, ['rawcnt'] = rawcnt, ['quest_type'] = quest_type, ['reward'] = reward, ['is_end'] = is_end, ['t_quest'] = t_quest}
            struct_quest = StructQuestData(t_data)

            table.insert(l_quest, struct_quest)
        end
        --[[ 
        
        # 업적을 모두 클리어한 후에는 서버에서 focus id를 주지 않을 것으로 생각하고 만든 기능인데
        # 업적 모두 클리어 후에도 마지막 id를 계속 보내주고 있다
        # 모두 클리어 후에도 raw count를 UI에 찍어줘야 하지 않나해서 보내주신듯한데 
        # 개인적으로는 필요없다 생각 

        -- 업적 모두 클리어한 것 체크
        local l_challenge_type = self.m_tableQuest:filterList('default', 1)
        if (#l_quest < #l_challenge_type) then
            local digit, is_cleared
            -- 업적 로컬 테이블을 순회한다.(타입별로만 뽑아온것)
            for _, t_challenge in pairs(l_challenge_type) do
                digit = math_floor(t_challenge['qid'] / 100)
                is_cleared = true

                -- 서버에서 받은 qid 체크하여 없는지 체크
                for qid, _ in pairs(t_focus) do
                    if (digit == math_floor(qid / 100)) then
                        is_cleared = false
                        break
                    end
                end

                -- 없다면 마지막 ID로 추가해준다. 
                if (is_cleared) then
                    local last_qid, t_quest = self.m_tableQuest:findLastQuest(t_challenge['qid'])
                    t_data ={['qid'] = last_qid, ['rawcnt'] = nil, ['quest_type'] = quest_type, ['reward'] = nil, ['t_quest'] = t_quest}
                    struct_quest = StructQuestData(t_data)
                    table.insert(l_quest, struct_quest)
                end
            end  
        end

        ]]

        self.m_tQuestInfo[quest_type] = l_quest
    end

end

-------------------------------------
-- function getQuestListByType
-- @brief 해당 타입의 진행중인 퀘스트를 리턴한다.
-------------------------------------
function ServerData_Quest:getQuestListByType(quest_type)
    local l_quest = self.m_tQuestInfo[quest_type]

	-- 보상 있는 퀘스트, 완료한 퀘스트만 추출
	local l_reward_quest = {}
	local l_completed_quest = {}
	local l_normal_quest = {}

	for i, quest in pairs(l_quest) do
		-- 보상 있는 퀘스트
		if quest:hasReward() then
			table.insert(l_reward_quest ,quest)
		
        -- 남아있는 퀘스트
		elseif (not quest:isEnd()) then
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
	local l_ret = table.merge(l_reward_quest, l_normal_quest)
	l_ret = table.merge(l_ret, l_completed_quest)
    
	return l_ret
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
	for i, quest in pairs(self.m_tQuestInfo[quest_type]) do 
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
function ServerData_Quest:requestQuestReward(quest, cb_func)
    local uid = g_userData:get('uid')
	local qid = quest['qid']

	if (not qid) then 
		error('잘못된 퀘스트 보상 접근')
	end

    -- 성공 시 콜백
    local function success_cb(ret)

		-- 받은 정보 갱신 
        if (ret['quest_info']) then
		    self:applyQuestInfo(ret['quest_info'])
        end
        
        -- 하이라이트 갱신
        if (ret['highlight']) then
            g_highlightData:applyHighlightInfo(ret)
        end

        -- 구글 평점 유도 팝업 : 테이머 레벨 7 달성 업적 클리어시 1회 노출
        if (tonumber(qid) == 10106) then
            UI_CheersPopup()
        end

        if (cb_func) then
            -- 업적 : 마지막 퀘스트인지 체크하여 아니라면 다음 qid로 진행
            if (quest['quest_type'] == TableQuest.CHALLENGE) then
                if (not self.m_tableQuest:isLastQuest(qid)) then
                    qid = qid + 1
                end
            end

            local t_quest_data = self:getQuest(quest['quest_type'], qid)
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
