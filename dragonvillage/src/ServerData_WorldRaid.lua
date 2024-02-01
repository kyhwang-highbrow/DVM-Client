-------------------------------------
--- @class ServerData_WorldRaid
-- g_worldRaidData
-------------------------------------
ServerData_WorldRaid = class({
	m_includeRewardTableReq = 'boolean',
	m_rankingUpdateAt = '',
	m_rankList = '',
	m_myRank = '',

    m_complimentCount = 'number',
    m_isAvailableCompliment = 'boolean',
    m_rankReward = 'number',
    m_testScoreFix = 'number',

	m_tableWorldRaidRank = 'Table',
	m_tableWorldRaidSchedule = 'Table',
    m_tableWorldRaidScoreReward = 'Table',
	m_curWorldRaidInfo = 'Table',

    -- 이벤트 객체
    m_eventDispatcher = 'Lobby',

    -- 지구전 관련(구 league_raid) 
    -- 여기다가 전투 관련 변수를 만들면 안되는데 시간이 없어서 그냥 똑같이 만듦
    m_curDeckIndex = 'number',
    m_attackedChar_A = 'List<dragon>',
    m_attackedChar_B = 'List<dragon>',
    m_attackedChar_C = 'List<dragon>',
})

-------------------------------------
--- @function init
-------------------------------------
function ServerData_WorldRaid:init()
	self.m_includeRewardTableReq = true
	self.m_rankingUpdateAt = ExperationTime()
	self.m_tableWorldRaidRank = {}
	self.m_rankList = {}
	self.m_myRank = nil
	self.m_tableWorldRaidSchedule = {}
	self.m_curWorldRaidInfo = nil
    self.m_curDeckIndex = 1
    self.m_eventDispatcher = EventDispatcher()

    self.m_complimentCount = 0
    self.m_isAvailableCompliment = false
    self.m_rankReward = {}
end

-------------------------------------
--- @function isExpiredRankingUpdate
-------------------------------------
function ServerData_WorldRaid:isExpiredRankingUpdate()
  if self.m_rankingUpdateAt:isExpired() == true then
      self.m_rankingUpdateAt:setUpdatedAt()
      self.m_rankingUpdateAt:applyExperationTime_SecondsLater(10)
      return true
  end

  return false
end

-------------------------------------
--- @function isActive
-------------------------------------
function ServerData_WorldRaid:isActive()
	return g_hotTimeData:isActiveEvent('world_raid')
end

-------------------------------------
--- @function isAvailableWorldRaid
-------------------------------------
function ServerData_WorldRaid:isAvailableWorldRaid()
	-- 핫타임 설정
	if self:isActive() == false then
		return false
	end

	-- 현제 월드 레이드 정보가 존재하는지 여부
	if self.m_curWorldRaidInfo == nil then
		return false
	end

	-- 월드 레이드 시간이 유효한지?
	if self:checkWorldRaidTime(self.m_curWorldRaidInfo) == false then
		return false
	end

    return true
end

-------------------------------------
--- @function isWorldRaidRewardPeriod
-------------------------------------
function ServerData_WorldRaid:isWorldRaidRewardPeriod()
	if self:isActive() == false then
		return false
	end

    if self:getPrevSeasonId() <= 0 then
        return false
    end

    return true
end

-------------------------------------
--- @function isAvailableWorldRaidReward
-------------------------------------
function ServerData_WorldRaid:isAvailableWorldRaidReward()
    if self:isAvailableWorldRaidRewardRanking() == true then
        return true
    end

    if self:isAvailableWorldRaidRewardCompliment() == true then
        return true
    end

    return false
end

-------------------------------------
--- @function isAvailableWorldRaidRewardRanking
-------------------------------------
function ServerData_WorldRaid:isAvailableWorldRaidRewardRanking()
    if self:isWorldRaidRewardPeriod() == false then
        return false
    end

    local wrid = self:getPrevSeasonId()
    local reward = self.m_rankReward[tostring(wrid)] or -1
    return reward == 0
end

-------------------------------------
--- @function isAvailableWorldRaidRewardCompliment
-------------------------------------
function ServerData_WorldRaid:isAvailableWorldRaidRewardCompliment()
    if self:isWorldRaidRewardPeriod() == false then
        return false
    end

    return self.m_isAvailableCompliment
end

-------------------------------------
--- @function getPrevSeasonId
-------------------------------------
function ServerData_WorldRaid:getPrevSeasonId()
    local world_raid_id = self:getWorldRaidId()
    if world_raid_id == 0 then
        return 0
    end

    for id, v in pairs(self.m_tableWorldRaidSchedule) do
        if v['wrid'] == world_raid_id then
            local find_id = id - 1
            local world_raid_info = self.m_tableWorldRaidSchedule[find_id]

            if world_raid_info == nil then
                return 0
            end
            
            return world_raid_info['wrid'] or 0
        end
    end

    return 0
end

-------------------------------------
--- @function getCurrentMyRanking
-------------------------------------
function ServerData_WorldRaid:getCurrentMyRanking()
    return self.m_myRank and self.m_myRank or g_userData:makeDummyProfileRankingData()
    -- return {
    --     lv = 31,
    --     tier = "bronze_3",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110002,
    --     costume = 730204,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = false,
    --     un = 9463,
    --     score = -1,
    --     total = 0,
    --     nick = "ksjang3",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 0,
    --       grade = 6,
    --       rlv = 6,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 121854,
    --       transform = 3,
    --       mastery_skills = { },
    --       evolution = 3,
    --       mastery_point = 0
    --     },
    --     uid = "ksjang3",
    --     rank = -1
    --   }
end

-------------------------------------
--- @function getCurrentRankingList
-------------------------------------
function ServerData_WorldRaid:getCurrentRankingList()
    return self.m_rankList
end

-------------------------------------
--- @function getComplimentCount
-------------------------------------
function ServerData_WorldRaid:getComplimentCount()
    return self.m_complimentCount
end

-------------------------------------
--- @function getTableWorldRaidRank
-------------------------------------
function ServerData_WorldRaid:getTableWorldRaidRank()
  return self.m_tableWorldRaidRank or {}
end

-------------------------------------
--- @function getTableWorldRaidScoreReward
-------------------------------------
function ServerData_WorldRaid:getTableWorldRaidScoreReward()
    return self.m_tableWorldRaidScoreReward or {}
  end

-------------------------------------
--- @function applyCurrentRankingList
-------------------------------------
function ServerData_WorldRaid:applyCurrentRankingList(t_ret)
	-- 랭크 리스트
	if t_ret['list'] ~= nil then
		self.m_rankList = clone(t_ret['list'])
	end

	-- 내 랭킹
	if t_ret['my_info'] ~= nil then
		self.m_myRank = t_ret['my_info']
	end
end

-------------------------------------
--- @function applyResponse
-------------------------------------
function ServerData_WorldRaid:applyResponse(t_ret)
  -- 랭크 리스트
	if t_ret['table_world_raid_rank'] ~= nil then
		self.m_tableWorldRaidRank = clone(t_ret['table_world_raid_rank'])
    end

	-- 랭크 리스트
	if t_ret['table_world_raid'] ~= nil then
		self.m_tableWorldRaidSchedule = clone(t_ret['table_world_raid'])
	end

    -- 스코어 보상 리스트
	if t_ret['table_world_raid_reward'] ~= nil then
		self.m_tableWorldRaidScoreReward = clone(t_ret['table_world_raid_reward'])
    end

    -- 전시즌 랭킹 1위 축하받은 횟수
	if t_ret['compliment_cnt'] ~= nil then
		self.m_complimentCount = t_ret['compliment_cnt']
    end

    -- 축하하고 보상 받는거 가능한지
	if t_ret['compliment_reward_available'] ~= nil then
		self.m_isAvailableCompliment = t_ret['compliment_reward_available']
    end

    -- 랭킹 보상 여부 수령 가능한지
	if t_ret['rank_reward'] ~= nil then
		self.m_rankReward = t_ret['rank_reward']
    end
end

-------------------------------------
--- @function makeCurrentWorldRaidInfo
-------------------------------------
function ServerData_WorldRaid:makeCurrentWorldRaidInfo()	
	self.m_curWorldRaidInfo = nil
	for _, v in pairs(self.m_tableWorldRaidSchedule) do
		if self:checkWorldRaidTime(v) == true then
			self.m_curWorldRaidInfo = v
			return
		end
	end
end

-------------------------------------
--- @function checkWorldRaidTime
-------------------------------------
function ServerData_WorldRaid:checkWorldRaidTime(info)
	if info == nil then
		return false, 0
	end

	local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
	local date_min = info['date_min']
	local date_max = info['date_max']

    if cur_time > date_min and cur_time < date_max then
		return true, date_max - cur_time
	end

	return false, 0
end

-------------------------------------
--- @function getWorldRaidId
-------------------------------------
function ServerData_WorldRaid:getWorldRaidId()
	if self.m_curWorldRaidInfo == nil then
		return 0
	end

    return self.m_curWorldRaidInfo['wrid'] or 0
end

-------------------------------------
--- @function getWorldRaidStageId
-------------------------------------
function ServerData_WorldRaid:getWorldRaidStageId()
    local world_raid_id = self:getWorldRaidId()
    return TableWorldRaidInfo:getInstance():getWorldRaidStageId(world_raid_id)
end

-------------------------------------
--- @function getRemainTimeString
-------------------------------------
function ServerData_WorldRaid:getRemainTimeString()
    local _, time = self:checkWorldRaidTime(self.m_curWorldRaidInfo)
    time = math_floor(time/1000)
    return Str('종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
end

-------------------------------------
--- @function getWorldRaidDeckMap
-------------------------------------
function ServerData_WorldRaid:getWorldRaidDeckMap()
    local world_raid_id = self:getWorldRaidId()
    local stage_mode = TableWorldRaidInfo:getInstance():getWorldRaidPartyType(world_raid_id)
    local deck_name_map = {}

    for i = 1, stage_mode do
        deck_name_map['deck_name' .. i]  = 'world_raid_' .. i
    end

    return deck_name_map
end

-------------------------------------
--- @function getWorldRaidPartyType
-------------------------------------
function ServerData_WorldRaid:getWorldRaidPartyType()
    local world_raid_id = self:getWorldRaidId()
    local party_type = TableWorldRaidInfo:getInstance():getWorldRaidPartyType(world_raid_id)    
    return party_type
end


-------------------------------------
--- @function getPossibleReward
--- @brief 획득할 수 있는 보상 데이터를 반환
--- @param integer : 현재 등수
--- @param integer : 현재 랭크 비율 
-------------------------------------
function ServerData_WorldRaid:getPossibleReward(my_rank, my_ratio)
    local my_rank = tonumber(my_rank)
    local my_rank_rate = tonumber(my_ratio) * 100

    local l_rank_list = self.m_tableWorldRaidRank

    -- 한번도 플레이 하지 않은 경우, 최상위 보여줌
    if (my_rank <= 0) then
        return nil, 0
    end

    for i,data in ipairs(l_rank_list) do
        
        local rank_min = tonumber(data['rank_min'])
        local rank_max = tonumber(data['rank_max'])

        local ratio_min = tonumber(data['ratio_min'])
        local ratio_max = tonumber(data['ratio_max'])

        -- 순위 필터
        if (rank_min and rank_max) then
            if (rank_min <= my_rank) and (my_rank <= rank_max) then
                return data, i
            end

        -- 비율 필터
        elseif (ratio_min and ratio_max) then
            if (ratio_min < my_rank_rate) and (my_rank_rate <= ratio_max) then
                return data, i
            end
        end
    end

    -- 마지막 보상 리턴
    local last_ind = #l_rank_list
    return l_rank_list[last_ind], last_ind or 0
end

-------------------------------------
--- @function getWorldRaidBuff
-------------------------------------
function ServerData_WorldRaid:getWorldRaidBuff()
    local world_raid_id = self:getWorldRaidId()
    local buff_key = TableWorldRaidInfo:getInstance():getBuffKey(world_raid_id)
    local bonus_str, map_attr = TableContentAttr:getInstance():getBonusInfo(buff_key, true)
    return bonus_str, map_attr
end

-------------------------------------
--- @function getWorldRaidDebuff
-------------------------------------
function ServerData_WorldRaid:getWorldRaidDebuff()
    local world_raid_id = self:getWorldRaidId()
    local debuff_key = TableWorldRaidInfo:getInstance():getDebuffKey(world_raid_id)
    local penalty_str, map_attr = TableContentAttr:getInstance():getBonusInfo(debuff_key , false)
    return penalty_str, map_attr
end

-------------------------------------
--- @function setEventListener
-------------------------------------
function ServerData_WorldRaid:setEventListener(obj)
    self.m_eventDispatcher:release_EventDispatcher()
	self.m_eventDispatcher:addListener('refresh_milestone', obj)
end

-------------------------------------
--- @function dispatchToMilestone
-------------------------------------
function ServerData_WorldRaid:dispatchToMilestone()
    if self:isAvailableWorldRaidReward() == false then
        return
    end

    self.m_eventDispatcher:dispatch('refresh_milestone')
end

-------------------------------------
--- @function request_WorldRaidInfo
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidInfo(_success_cb, _fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        self:applyResponse(ret)
		self:makeCurrentWorldRaidInfo()

        SafeFuncCall(_success_cb)
        self.m_includeRewardTableReq = false
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/world_raid/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('include_tables', self.m_includeRewardTableReq)

    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(_fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end

-------------------------------------
--- @function request_WorldRaidStart
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidStart(wrid, stage_id, _success_cb, _fail_cb)
    local uid = g_userData:get('uid')
    
    local deck_name_map = self:getWorldRaidDeckMap()
    local function success_cb(ret)
        --self.m_gameState = true
        SafeFuncCall(_success_cb, ret)
    end

    local function response_status_cb(ret)        
        if ret['status'] == -2128 then
            MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'), function () 
                UINavigator:goTo('lobby')
            end)
            return true
        end

        return false
    end

    local ui_network = UI_Network()
    local api_url = '/world_raid/start'
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('wrid', wrid)
    ui_network:setParam('stage', stage_id)

    for key, val in pairs(deck_name_map) do
        ui_network:setParam(key, val)
        local toke_param = string.gsub(key, 'deck_name', 'token')
        local token = g_stageData:makeDragonToken(val)
        ui_network:setParam(toke_param, token)
    end
    
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(_fail_cb)
    ui_network:request()
end

-------------------------------------
--- @function request_WorldRaidRanking
--- @param search_type : 랭킹을 조회할 그룹 (world, clan, friend)
--- @param offset : 랭킹 리스트의 offset 값 (-1 : 내 랭킹 기준, 0 : 상위 랭킹 기준, 20 : 랭킹의 20번째부터 조회..) 
--- @param param_success_cb : 받은 데이터를 이용하여 처리할 콜백 함수
--- @param param_fail_cb : 통신 실패 처리할 콜백 함수
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidRanking(wrid , search_type, offset, limit, param_success_cb, param_fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
		if wrid == self:getWorldRaidId() and search_type == 'world' then
			self:applyCurrentRankingList(ret)
		end

		if param_success_cb then
			param_success_cb(ret)
		end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/world_raid/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('wrid', wrid)
    ui_network:setParam('filter', search_type)
    ui_network:setParam('offset', offset)
    ui_network:setParam('limit', limit)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(param_fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end

-------------------------------------
--- @function request_WorldRaidReward
--- @brief 랭킹 정산 보상 요청
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidReward(wrid, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        self:applyResponse(ret)
        -- 공통 응답
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        self.m_eventDispatcher:dispatch('refresh_milestone')

        if finish_cb then
            finish_cb(ret)
        end
    end
    
    local ui_network = UI_Network()
    ui_network:setUrl('/world_raid/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('wrid', wrid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(fail_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
--- @function request_WorldRaidCompliment
--- @brief 칭찬하기
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidCompliment(wrid, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        
        self.m_isAvailableCompliment = false
        self:applyResponse(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        g_highlightData:setDirty(true)        
        self.m_eventDispatcher:dispatch('refresh_milestone')
        if finish_cb then
            finish_cb(ret)
        end
    end
    
    local ui_network = UI_Network()
    ui_network:setUrl('/world_raid/compliment')
    ui_network:setParam('uid', uid)
    ui_network:setParam('wrid', wrid)

    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(fail_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
--- @function request_WorldRaidUserDeck
--- @brief 유저 덱 상세 정보
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidUserDeck(hoid, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end
    
    local ui_network = UI_Network()
    ui_network:setUrl('/world_raid/ranking/detail')
    ui_network:setParam('uid', uid)
    ui_network:setParam('hoid', hoid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(fail_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
--- @function request_WorldRaidReset
--- @brief 리셋하기(테스트 기능)
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidReset(wrid, type, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        if type == 'compliment' then
            self.m_isAvailableCompliment = true
            self.m_eventDispatcher:dispatch('refresh_milestone')
        elseif type == 'ranking' then
            self.m_rankReward = { [tostring(wrid)] = 0}
            self.m_eventDispatcher:dispatch('refresh_milestone')
        elseif type == 'score' then
            self.m_myRank = nil
        elseif type == 'frame' then
            g_userData:applyServerData({}, 'profile_frames')            
        end
        -- 공통 응답
        g_serverData:networkCommonRespone(ret)        

        if finish_cb then
            finish_cb(ret)
        end
    end
    
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/world_raid/reset')
    ui_network:setParam('uid', uid)
    ui_network:setParam('wrid', wrid)
    ui_network:setParam('type', type)

    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(fail_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end