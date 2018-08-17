-------------------------------------
-- class ServerData_Quest
-------------------------------------
ServerData_Quest = class({
        m_serverData = 'ServerData',
		m_tableQuest = 'TableQuest',

		m_tQuestInfo = 'table',

        m_dailyClearQuest = 'StructQuestData',
        m_dailyQuestSubscription = 'table',
        --"daily_quest_subscription":{
        --    "max_day":14,
        --    "active":true,
        --    "cur_day":1,
        --    "add_reward_stats":{
        --      "cash":0,
        --      "fp":0,
        --      "clan_coin":0,
        --      "amethyst":0,
        --      "stamina":0,
        --      "gold":0
        --    }
        --  }
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
		if (t_daily) then
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
                end

                table.insert(l_quest, struct_quest)
			end

			self.m_tQuestInfo[quest_type] = l_quest
		end
    end

    -- CHALLENGE
    do
        local quest_type = TableQuest.CHALLENGE
        local t_challenge = t_quest_info[quest_type]
		if (t_challenge) then
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

			self.m_tQuestInfo[quest_type] = l_quest
		end
    end

	-- SPECIAL
    do
        local quest_type = TableQuest.SPECIAL
		self.m_tQuestInfo[quest_type] = {}
        local t_challenge = t_quest_info[quest_type]
		if (t_challenge) then
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

			self.m_tQuestInfo[quest_type] = l_quest
		end
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

        -- 일일 퀘스트 보상 2배
        self.m_dailyQuestSubscription = ret['daily_quest_subscription']

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
        
		-- 여기서 highlight 정보가 넘어오긴 하는데.. 어차피 로비에서 다시 통신하는 구조이므로
		-- 노티 정보를 갱신하기 위해서 호출
		g_highlightData:setDirty(true)

        -- 구글 평점 유도 팝업 : 테이머 레벨 7 달성 업적 클리어시 1회 노출
        if (tonumber(qid) == 10106) then
            UI_CheersPopup()
        end

        if (cb_func) then
            -- 업적, 스페셜 : 마지막 퀘스트인지 체크하여 아니라면 다음 qid로 진행
            if (quest['quest_type'] == TableQuest.CHALLENGE) 
			or (quest['quest_type'] == TableQuest.SPECIAL) then
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


-------------------------------------
-- function isSubscriptionActive
-- @brief 구독 중인지 여부 리턴
-- @return boolean
-------------------------------------
function ServerData_Quest:isSubscriptionActive()
    if (not self.m_dailyQuestSubscription) then
        return false
    end

    local is_active = self.m_dailyQuestSubscription['active']
    return is_active -- boolean
end

-------------------------------------
-- function subscriptionDayInfo
-- @brief 구독 중인 날짜 정보 리턴
-- @return number, number
-------------------------------------
function ServerData_Quest:subscriptionDayInfo()
    if (not self.m_dailyQuestSubscription) then
        return false
    end

    local cur_day = self.m_dailyQuestSubscription['cur_day'] or 0
    local max_day = self.m_dailyQuestSubscription['max_day'] or 0
    return cur_day, max_day
end

