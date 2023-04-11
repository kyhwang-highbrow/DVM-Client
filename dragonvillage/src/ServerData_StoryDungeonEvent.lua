-------------------------------------
-- class ServerData_StoryDungeonEvent
-------------------------------------
ServerData_StoryDungeonEvent = class({
    m_serverData = 'ServerData',
    m_cachedStageIdListMap = 'table',
    m_ceilingInfo = 'table',
    m_ceilingMax = 'number',
    m_isAutomaticFarewell = 'boolean',
    m_isItemReplaced = 'boolean',
    m_tableQuest = '',
    m_questList = 'List<StructQuest>',
    m_bDirty = 'false',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_StoryDungeonEvent:init(server_data)
    self.m_serverData = server_data
    self.m_cachedStageIdListMap = {}    
    self.m_isAutomaticFarewell = false
    self.m_ceilingInfo = {}
    self.m_ceilingMax = 100
    self.m_isItemReplaced = false
    self.m_tableQuest = TableEventQuest()
    self.m_questList = {}
    self.m_bDirty = true
end

-------------------------------------
-- function getStoryDungeonSeasonId
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonId()
    local t_stage_clear_info = self.m_serverData:getRef('story_dungeon_stage_info') or {}
    if t_stage_clear_info ~= nil then
        for key, v in pairs(t_stage_clear_info) do
            local season_id = key
            return key, TableStoryDungeonEvent:getStoryDungeonSeasonCode(season_id)
        end
    end

    return nil
end

-------------------------------------
-- function getStoryDungeonStageIdList
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonStageIdList(season_id)
    if self.m_cachedStageIdListMap[season_id] ~= nil then
        return self.m_cachedStageIdListMap[season_id]
    end

    local t_season_info = self:getStoryDungeonSeasonInfo(season_id)
    local t_clear_info = t_season_info['stage_play_count']
    local list = {}

    if t_clear_info == nil then
        return {}
    end

    for stage_id, _ in pairs(t_clear_info) do
        table.insert(list, tonumber(stage_id))
    end

    table.sort(list, function (a, b) 
        return a < b
    end)

    self.m_cachedStageIdListMap[season_id] = list
    return list
end

-------------------------------------
-- function isStoryDungeonEventDoing
-------------------------------------
function ServerData_StoryDungeonEvent:isStoryDungeonEventDoing()
    return self:getStoryDungeonSeasonId() ~= nil    
end

-------------------------------------
-- function isStoryDungeonEventGachaAvailable
-------------------------------------
function ServerData_StoryDungeonEvent:isStoryDungeonEventGachaAvailable()
    if self:isStoryDungeonEventDoing() == true then
        local goods_type = TableStoryDungeonEvent:getStoryDungeonEventTicketKey()
        local goods_value = g_userData:get(goods_type) or 0
        return goods_value > 0
    end
    return false
end

-------------------------------------
-- function isOpenStage
-------------------------------------
function ServerData_StoryDungeonEvent:isOpenStage(stage_id, _season_id)
    local season_id = _season_id or self:getStoryDungeonSeasonId()
    local stage_list = self:getStoryDungeonStageIdList(season_id)

    local prev_stage_id = stage_id - 1
    if (stage_list[1] > prev_stage_id) then
        return true
    else
        local clear_count = self:getStoryDungeonStageClearCount(season_id, prev_stage_id)
        local is_open = (0 < clear_count)
        return is_open
    end
end

-------------------------------------
-- function isClearStage
-------------------------------------
function ServerData_StoryDungeonEvent:isClearStage(stage_id)
    local season_id = self:getStoryDungeonSeasonId()
    local clear_count = self:getStoryDungeonStageClearCount(season_id, stage_id)
    local is_open = (0 < clear_count)
    return is_open
end


-------------------------------------
-- function getLastStageIdx
-------------------------------------
function ServerData_StoryDungeonEvent:getLastStageIdx()
    local season_id = self:getStoryDungeonSeasonId()
    local stage_id_list = self:getStoryDungeonStageIdList(season_id)
    for idx, stage_id in ipairs(stage_id_list) do
        local clear_count = self:getStoryDungeonStageClearCount(season_id, stage_id)
        if clear_count == 0 then
            return idx
        end
    end

    return 1
end

-------------------------------------
-- function getPrevStageID
-------------------------------------
function ServerData_StoryDungeonEvent:getPrevStageID(stage_id)
    local season_id = self:getStoryDungeonSeasonId()
    local stage_list = self:getStoryDungeonStageIdList(season_id)

    if #stage_list == 0 then
        return nil
    end

    local first_stage_id = stage_list[1]
    if first_stage_id > stage_id - 1 then
        return nil
    end
    return stage_id - 1
end

-------------------------------------
-- function getNextStageID
-------------------------------------
function ServerData_StoryDungeonEvent:getNextStageID(stage_id)
    local season_id = self:getStoryDungeonSeasonId()
    local stage_list = self:getStoryDungeonStageIdList(season_id)

    if #stage_list == 0 then
        return nil
    end

    local last_stage_id = stage_list[#stage_list]
    if last_stage_id < stage_id + 1 then
        return nil
    end
    return stage_id + 1
end

-------------------------------------
-- function getStoryDungeonStagePlayCount
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonStagePlayCount(season_id, stage_id)
    local t_season_info = self:getStoryDungeonSeasonInfo(season_id)
    local t_clear_info = t_season_info['stage_play_count']

    if t_clear_info == nil then
        return 0
    end

    local clear_count = t_clear_info[tostring(stage_id)]
    return clear_count
end

-------------------------------------
-- function getStoryDungeonStageClearCount
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonStageClearCount(season_id, stage_id)
    local t_season_info = self:getStoryDungeonSeasonInfo(season_id)
    local t_clear_info = t_season_info['stage_clear_count']

    if t_clear_info == nil then
        return 0
    end

    local clear_count = t_clear_info[tostring(stage_id)]
    return clear_count
end

-------------------------------------
-- function getStoryDungeonSeasonInfo
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonInfo(season_id)
    local t_stage_clear_info = self.m_serverData:getRef('story_dungeon_stage_info', season_id)
    return t_stage_clear_info
end

-------------------------------------
-- function applyStoryDungeonSeasonInfo
-- @brief 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_StoryDungeonEvent:applyStoryDungeonSeasonInfo(t_data)
    if t_data['story_dungeon_stage_info'] ~= nil then
        g_highlightData:setDirty(true)
        self.m_serverData:applyServerData(t_data['story_dungeon_stage_info'] or {}, 'story_dungeon_stage_info')
    end
end

-------------------------------------
-- function applyStoryDungeonSeasonGachaCeilCount
-- @brief 서버에서 전달받은 천장 값
-------------------------------------
function ServerData_StoryDungeonEvent:applyStoryDungeonSeasonGachaCeilCount(t_data)
    if t_data['story_dungeon_ceiling_count'] ~= nil then
        self.m_serverData:applyServerData(t_data['story_dungeon_ceiling_count'] or 0, 'story_dungeon_ceiling_count')
    end
end

-------------------------------------
-- function update_hatcheryInfo
-- @breif 천장 정보 갱신
-------------------------------------
function ServerData_StoryDungeonEvent:applyPickupCeilingInfo(ret)
    local summon_ceiling_info = ret['summon_ceiling_info']

    if summon_ceiling_info then
        self.m_ceilingInfo = summon_ceiling_info['ceiling_info']
        self.m_ceilingMax = summon_ceiling_info['ceiling_max']
    end
end

-------------------------------------
-- function getStoryDungeonSeasonGachaCeilCount
-- @brief 서버에서 전달받은 천장 값
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonGachaCeilCount()
    local ceil_count = self.m_serverData:get('story_dungeon_ceiling_count') or 0
    return ceil_count
end

-------------------------------------
-- function getStoryDungeonSeasonTokenItemType
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonTokenItemType()
    local season_id = self:getStoryDungeonSeasonId()

    if season_id == nil then
        return 'token_event_origingoddragon'
    end

    local season_code = TableStoryDungeonEvent:getStoryDungeonSeasonCode(season_id)
    return string.format('token_event_%s', season_code)
end

-------------------------------------
-- function getStoryDungeonSeasonTicketItemType
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonTicketItemType()
    local season_id = self:getStoryDungeonSeasonId()

    if season_id == nil then
        return 'ticket_event_origingoddragon'
    end

    local season_code = TableStoryDungeonEvent:getStoryDungeonSeasonCode(season_id)
    return string.format('ticket_event_%s', season_code)
end

-------------------------------------
-- function makeAddedDragonTable
-- @breif
-------------------------------------
function ServerData_StoryDungeonEvent:makeAddedDragonTable(org_list, is_bundle)
    local result = {}
    
    if (not self.m_isAutomaticFarewell) or (not is_bundle) then return org_list end

    for key, value in pairs(org_list) do
        if (value['grade'] > 3) then
            result[key] = value
        end
    end

    return result
end

-------------------------------------
-- function getQuestListByType
-- @brief 해당 타입의 진행중인 퀘스트를 리턴한다.
-------------------------------------
function ServerData_StoryDungeonEvent:getQuestListByType(quest_type)
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
-- function getQuestList
-------------------------------------
function ServerData_StoryDungeonEvent:getQuestList()
    return self.m_questList or {}
end

-------------------------------------
-- function applyQuestInfo
-- @breif 테이블 데이타와 서버 데이타를 조합해서 UI에서 활용 가능한 퀘스트 데이타 생성
-------------------------------------
function ServerData_StoryDungeonEvent:applyQuestInfo(t_quest_info)
    local t_data, struct_quest
    local qid_n, rawcnt, reward, clear
    local is_end

    self.m_questList = {}
    local quest_type_list = {'daily', 'main'}

    for _, type in ipairs(quest_type_list) do
        local quest_type = type
        local t_challenge = t_quest_info[quest_type]
		if (t_challenge) then
			-- server_data 분류
			local t_focus = t_challenge['focus']
			local l_reward = t_challenge['reward']

			-- 클라 데이터 생성 (서버 정보 기반)
			local l_quest = {}
			for qid, rawcnt in pairs(t_focus) do
				qid_n = tonumber(qid)
				local t_quest = self.m_tableQuest:get(qid_n)
				reward = table.find(l_reward, qid_n) and true or false
            
				-- 보상도 받았고 달성도 했는데 다음 focus를 안준다면 이미 클리어한것
				is_end = false
				if (rawcnt >= t_quest['clear_value']) and (reward == false) then
					is_end = true
				end

				-- StructQuestData 생성
				t_data ={['qid'] = qid_n, ['rawcnt'] = rawcnt, ['quest_type'] = quest_type, ['reward'] = reward, ['is_end'] = is_end, ['t_quest'] = t_quest}
				struct_quest = StructQuestData(t_data)
				table.insert(self.m_questList, struct_quest)
			end
		end
    end
end

-------------------------------------
-- function replaceStoryDungeonRelatedItems
-- @brief 스토리 던전 관련 아이템을 시즌별로 다르게 보이도록 처리
-- 앱 구동 후 info 받고 한번만 처리
-------------------------------------
function ServerData_StoryDungeonEvent:replaceStoryDungeonRelatedItems()
    if self.m_isItemReplaced == true then
        return
    end

    local season_id = self:getStoryDungeonSeasonId()
    if season_id ~= nil then
        local l_replace_id_list = {}
        table.insert(l_replace_id_list, TableStoryDungeonEvent:getStoryDungeonEventTicketReplaceId(season_id))
        table.insert(l_replace_id_list, TableStoryDungeonEvent:getStoryDungeonEventTokenReplaceId(season_id))
        TableItem:replaceDisplayInfo(l_replace_id_list)
    end
end

-------------------------------------
-- function getStoryDungeonSpecialStageId
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSpecialStageId()
    local season_id = self:getStoryDungeonSeasonId()
    if season_id ~= nil then
        local stage_id = TableStoryDungeonEvent:getStoryDungeonEventSpecialStageId(season_id)
        return stage_id
    end
    return 0
end


-------------------------------------
-- function requestStoryDungeonInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_StoryDungeonEvent:requestStoryDungeonInfo(cb_func, fail_cb)
    local uid = g_userData:get('uid')

    -- 라이브일 경우 요청하지 않도록 하드코딩(검수등록위해)
    if IS_TEST_MODE() == false then
        if cb_func then
            cb_func()
        end
        return
    end

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        -- 스테이지 정보
        self:applyStoryDungeonSeasonInfo(ret)

        -- 스테이지가 없을 경우
        if ret['story_dungeon_stage_info'] == nil then
            self.m_serverData:applyServerData({}, 'story_dungeon_stage_info')
        end
        
        -- 시즌 천장 정보
        self:applyStoryDungeonSeasonGachaCeilCount(ret)

        -- 스토리 던전 관련 아이템을 시즌별로 다르게 보이도록 처리
        self:replaceStoryDungeonRelatedItems()
        self.m_bDirty = true

        if cb_func ~= nil then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/story_dungeon/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function requestStoryDungeonGacha
-- @brief 소환하기
-------------------------------------
function ServerData_StoryDungeonEvent:requestStoryDungeonGacha(season_id, draw_cnt, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        -- cash(캐시) / summon_dragon_ticket(드래곤 소환권) 갱신
        g_serverData:networkCommonRespone(ret)
--[[         -- 추가된 마일리지
        local after_mileage = g_userData:get('mileage')
        local added_mileage = (after_mileage - prev_mileage)
        ret['added_mileage'] = added_mileage ]]
        g_highlightData:setDirty(true)
        
        -- 드래곤들 추가
        local add_dragon_list = self:makeAddedDragonTable(ret['added_dragons'], false)
        g_dragonsData:applyDragonData_list(add_dragon_list)

        -- 슬라임들 추가
        --g_slimesData:applySlimeData_list(ret['added_slimes'])

        -- 신규 드래곤 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

        -- 시즌 천장 정보
        self:applyStoryDungeonSeasonGachaCeilCount(ret)

        --드래곤 획득 패키지 정보 갱신
        g_getDragonPackage:applyPackageList(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/story_dungeon')
    ui_network:setParam('uid', uid)
    ui_network:setParam('sals', false)
    ui_network:setParam('season_id', season_id)
    ui_network:setParam('draw_cnt', draw_cnt)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function requestStoryDungeonQuest
-- @brief 이벤트 정보
-------------------------------------
function ServerData_StoryDungeonEvent:requestStoryDungeonQuest(cb_func, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)       
        if ret['quest_info'] then
            g_serverData:networkCommonRespone(ret)
            self:applyQuestInfo(ret['quest_info'])
        end

        if cb_func then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/story_dungeon/quest_info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function requestStoryDungeonQuestReward
-- @brief 이벤트 업적 보상 받기
-------------------------------------
function ServerData_StoryDungeonEvent:requestStoryDungeonQuestReward(quest, cb_func)
    local uid = g_userData:get('uid')
    local qid = quest['qid']

    
	if (not qid) then 
		error('잘못된 퀘스트 보상 접근')
	end

    -- 성공 시 콜백
    local function success_cb(ret)       
        g_serverData:networkCommonRespone(ret)

        if ret['quest_info'] then
            self:applyQuestInfo(ret['quest_info'])
        end


        -- 바로 지급되는 리워드의 경우 added_items로 들어옴 table_quest의 product_content, mail_content 참고
        local l_reward_item = {}
        if (ret['added_items']) then
            if (ret['added_items']['items_list']) then
                l_reward_item = ret['added_items']['items_list']
            end
        end

        g_serverData:networkCommonRespone_addedItems(ret)

        -- 여기서 highlight 정보가 넘어오긴 하는데.. 어차피 로비에서 다시 통신하는 구조이므로
		-- 노티 정보를 갱신하기 위해서 호출
		g_highlightData:setDirty(true)

        --local t_quest_data = self:getQuest(quest['quest_type'], qid)
        cb_func() -- quest_data, l_reward_item
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/story_dungeon/quest_reward')
    ui_network:setParam('uid', uid)
	ui_network:setParam('qid', qid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function requestStoryDungeonStageClearTicket
-- @brief 스테이지 소탕
-------------------------------------
function ServerData_StoryDungeonEvent:requestStoryDungeonStageClearTicket(stage_id, clear_count, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        local ref_table = {}
        ref_table['user_levelup_data'] = {}
        ref_table['drop_reward_list'] = {}
        

        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        g_userData:response_userInfo(ret, ref_table)
        g_stageData:response_dropItems(ret, ref_table)

        -- 일일 드랍 아이템 획득량 갱신
        g_userData:response_ingameDropInfo(ret)

        g_highlightData:setDirty(true)
        
        finish_cb(ref_table)
    end

    local network = UI_Network()
    network:setUrl('/game/story_dungeon/clear')

    network:setParam('uid', uid)
    network:setParam('stage', stage_id)
    network:setParam('clear_cnt', clear_count)

    network:setSuccessCB(success_cb)
    network:setFailCB(fail_cb)
    network:request()
end