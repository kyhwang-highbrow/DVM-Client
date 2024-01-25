-------------------------------------
--- @class ServerData_WorldRaid
-- g_worldRaidData
-------------------------------------
ServerData_WorldRaid = class({
	m_includeRewardTableReq = 'boolean',
	m_rankingUpdateAt = '',
	m_rankList = '',
	m_myRank = '',
	m_tableWorldRaidRank = 'Table',
	m_tableWorldRaidSchedule = 'Table',
	m_curWorldRaidInfo = 'Table',
})

-------------------------------------
--- @function init
-------------------------------------
function ServerData_WorldRaid:init()
	self.m_includeRewardTableReq = true
	self.m_rankingUpdateAt = ExperationTime:createWithUpdatedAyInitialized()
	self.m_tableWorldRaidRank = {}
	self.m_rankList = {}
	self.m_myRank = {}
	self.m_tableWorldRaidSchedule = {}
	self.m_curWorldRaidInfo = nil
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
--- @function isAvailableWorldRaidReward
-------------------------------------
function ServerData_WorldRaid:isAvailableWorldRaidReward()
	return g_hotTimeData:isActiveEvent('world_raid_reward')
end

-------------------------------------
--- @function getCurrentMyRanking
-------------------------------------
function ServerData_WorldRaid:getCurrentMyRanking()
    return self.m_myRank
end

-------------------------------------
--- @function getCurrentRankingList
-------------------------------------
function ServerData_WorldRaid:getCurrentRankingList()
    return self.m_rankList
end

-------------------------------------
--- @function getTableWorldRaidRank
-------------------------------------
function ServerData_WorldRaid:getTableWorldRaidRank()
  return self.m_tableWorldRaidRank or {}
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
		self.m_myRank = StructUserInfoArena:create_forRanking(t_ret['my_info'])
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
    return Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
end

-------------------------------------
--- @function getWorldRaidStageMode
-------------------------------------
function ServerData_WorldRaid:getWorldRaidStageMode(stage_id)
    return (stage_id % 10)
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
function ServerData_WorldRaid:request_WorldRaidStart(wrid, stage_id, deck_name, _success_cb, _fail_cb)
    local uid = g_userData:get('uid')
    local token = g_stageData:makeDragonToken(deck_name)

    local function success_cb(ret)
        --self.m_gameState = true
        SafeFuncCall(_success_cb, ret)
    end

    local function response_status_cb(ret)
        -- 요일에 맞지 않는 속성
        if (ret['status'] == -2150) then
            -- 로비로 이동
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 

            MakeSimplePopup(POPUP_TYPE.OK, Str('이미 종료된 던전입니다.'), ok_cb)
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
    ui_network:setParam('deck_name', deck_name)    
    ui_network:setParam('token', token)
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