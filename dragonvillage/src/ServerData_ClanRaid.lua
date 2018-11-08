-------------------------------------
-- class ServerData_ClanRaid
-------------------------------------
ServerData_ClanRaid = class({
        m_serverData = 'ServerData',

        -- 오픈/종료 시간
        m_startTime = 'number',
        m_endTime = 'number',

        -- 현재 진행중인 스테이지 ID
        m_challenge_stageID = 'number',

        -- 현재 진행중 혹은 선택한 던전 정보
        m_structClanRaid = 'StructClanRaid',

        -- 누적 기여 랭킹 리스트 (현재 진행중인 기여도 랭킹 리스트는 StructClanRaid 에서 받아옴)
        m_lRankList = 'list',

        -- 여의주 사용횟수
        m_use_cash = 'number',

        -- 클랜 보상 정보
        m_tClanRewardInfo = 'table', 

        -- 클랜던전 갱신
        m_bossLv = 'number',
        m_bossRemainHp = 'number',

        -- 오픈상태 
        m_bOpen = 'boolean',

        -- 보상에 적용되는 실제 기여도 (서버에서 넘겨줌)
        m_mapRewardContribution = 'map',
    })

local USE_CASH_LIMIT = 1 -- 하루 최대 여의주 사용 입장횟수
local USE_CASH_CNT = 200
local BOSS_GOLD_REWARD = 100000 -- 보스 처치시 받는 골드 고정

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanRaid:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getClanRaidStruct
-------------------------------------
function ServerData_ClanRaid:getClanRaidStruct()
    return self.m_structClanRaid
end

-------------------------------------
-- function getChallengStageID
-------------------------------------
function ServerData_ClanRaid:getChallengStageID()
    return self.m_challenge_stageID
end

-------------------------------------
-- function getRankList
-------------------------------------
function ServerData_ClanRaid:getRankList()
    return self.m_lRankList
end

-------------------------------------
-- function getUseCashCnt
-------------------------------------
function ServerData_ClanRaid:getUseCashCnt()
    return USE_CASH_CNT
end

-------------------------------------
-- function setBossStatus
-- @brief 현재 진행중인 던전 보스의 레벨, 남은 체력 던전 갱신 체크를 위해 저장
-------------------------------------
function ServerData_ClanRaid:setBossStatus()
    local struct_clan_raid = self.m_structClanRaid
    self.m_bossLv = struct_clan_raid and struct_clan_raid:getLv() or 0
    self.m_bossRemainHp = struct_clan_raid and struct_clan_raid:getHp() or 0
end

-------------------------------------
-- function checkBossStatus
-- @brief 가지고 있는 던전 정보와 진행중인 실제 던전 정보가 다른 경우 false 리턴
-------------------------------------
function ServerData_ClanRaid:checkBossStatus()
    local hp = self.m_structClanRaid:getHp()
    local lv = self.m_structClanRaid:getLv()

    if (self.m_bossRemainHp ~= hp) or (self.m_bossLv ~= lv) then
        self:setBossStatus()
        return false
    end

    return true
end

-------------------------------------
-- function getTotalGoldReward
-- @brief 보스 처치 골드 누적량 (서버에서 따로 받지 않음, 클라에서 레벨로 계산)
-------------------------------------
function ServerData_ClanRaid:getTotalGoldReward()
    if (not self.m_challenge_stageID) then
        return 0
    end

    local curr_lv = self.m_challenge_stageID % 1000
    return math_max(0, curr_lv - 1) * BOSS_GOLD_REWARD
end

-------------------------------------
-- function isOpenClanRaid
-- @breif 던전 오픈 여부
-------------------------------------
function ServerData_ClanRaid:isOpenClanRaid()
    local curr_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
	return (self.m_bOpen) and (start_time <= curr_time) and (curr_time <= end_time)
end

-------------------------------------
-- function isOpenClanRaid_OnlyTime
-- @breif 던전 오픈 여부 (시간만 체크)
-------------------------------------
function ServerData_ClanRaid:isOpenClanRaid_OnlyTime()
    local curr_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
	return (start_time <= curr_time) and (curr_time <= end_time)
end

-------------------------------------
-- function isClanRaidStageID
-------------------------------------
function ServerData_ClanRaid:isClanRaidStageID(stage_id)
    if (not stage_id) then return false end
    local game_mode = g_stageData:getGameMode(stage_id)
    return (game_mode == GAME_MODE_CLAN_RAID)
end

-------------------------------------
-- function isPossibleUseCash
-- @brief 여의주 사용하여 던전 시작 가능한 상태인지 (파이널 블로우거나 하루 제한에 걸리지않거나)
-------------------------------------
function ServerData_ClanRaid:isPossibleUseCash()
    local clan_raid_data = self.m_structClanRaid
    if (not clan_raid_data) then return false end

    -- 파이널 블로우인 상태 가능
    if (clan_raid_data:getState() == CLAN_RAID_STATE.FINALBLOW) then
        return true
    
    -- 하루 제한에 걸리지 않았다면 가능
    elseif (self.m_use_cash < USE_CASH_LIMIT) then
        return true

    else
        return false
    end
end

-------------------------------------
-- function getClanRaidStatusText
-------------------------------------
function ServerData_ClanRaid:getClanRaidStatusText()
    local curr_time = Timer:getServerTime()

    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)

    local str = ''
    if (not self:isOpenClanRaid()) then
        local time = (start_time - curr_time)
        if (time < 0) then
            str = Str('오픈시간이 아닙니다.')
        else
            str = Str('{1} 남았습니다.', datetime.makeTimeDesc(time, true))
        end

    elseif (curr_time < start_time) then
        local time = (start_time - curr_time)
        str = Str('{1} 후 열림', datetime.makeTimeDesc(time, true))

    elseif (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true))

    else
        str = Str('시즌이 종료되었습니다.')
    end

    return str
end

-------------------------------------
-- function getNextStageID
-- @brief
-------------------------------------
function ServerData_ClanRaid:getNextStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id + 1)

    if t_drop then
        return stage_id + 1
    else
        return nil
    end
end

-------------------------------------
-- function getSimplePrevStageID
-- @brief
-------------------------------------
function ServerData_ClanRaid:getSimplePrevStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id - 1)

    if t_drop then
        return stage_id - 1
    else
        return nil
    end
end

-------------------------------------
-- function setRewardInfo
-------------------------------------
function ServerData_ClanRaid:setRewardInfo(ret)
    if (not ret['reward']) then
        return
    end
    
    -- 클랜
    if (ret['last_clan_info']) then
        self.m_tClanRewardInfo = {}

        -- 최종 순위 유저 정보
        self.m_tClanRewardInfo['user_info'] = StructUserInfoClanRaid:create_forRanking(ret['last_scores'][1])
        self.m_tClanRewardInfo['contribution'] = ret['ratio'] 
        self.m_tClanRewardInfo['rank'] = StructClanRank(ret['last_clan_info'])
        self.m_tClanRewardInfo['reward_info'] = ret['reward_clan_info']
		self.m_tClanRewardInfo['clan_exp'] = ret['clan_exp']
    end
end

-------------------------------------
-- function request_info
-------------------------------------
function ServerData_ClanRaid:request_info(stage_id, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
    
    -- 콜백 함수
    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        -- 클랜 UI가 아닌 battle menu에서 진입시 클랜정보도 받아와야함
        if (not g_clanData.m_structClan) and (ret['clan']) then
            g_clanData.m_structClan = StructClan(ret['clan'])
            g_clanData.m_bClanGuest = false 
        end

        -- 클랜 던전 오픈/종료 시간
        self.m_bOpen = ret['open']
        self.m_startTime = ret['start_time']
        self.m_endTime = ret['endtime']

        self.m_challenge_stageID = ret['cur_stage']

        self.m_use_cash = ret['use_cash'] or 0

        -- 시즌 보상
        self:setRewardInfo(ret)

        -- 누적 기여도 랭킹
        local rank_list = ret['scores']
        if (rank_list) then
            self.m_lRankList = {}

            local total_score = 0

            for _, user_data in ipairs(rank_list) do
                local user_info = StructUserInfoClanRaid:create_forRanking(user_data)
                total_score = total_score + user_info.m_score
                table.insert(self.m_lRankList, user_info)
            end

            for _, user_data in ipairs(self.m_lRankList) do
                user_data:setContribution(total_score)
            end
        end
        
        -- 실제 보상에 적용되는 기여도 정보
        self.m_mapRewardContribution = {}
        if (ret['cweek_info']) then
            self.m_mapRewardContribution = ret['cweek_info']
        end 

        -- 클랜 던전 정보
        if (ret['dungeon']) then
            self.m_structClanRaid = StructClanRaid(ret['dungeon'])
        else
            self.m_structClanRaid = nil
        end

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/dungeon_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function requestGameStart
-------------------------------------
function ServerData_ClanRaid:requestGameStart(stage_id, deck_name, combat_power, finish_cb, is_cash)
    local uid = g_userData:get('uid')
    local is_cash = is_cash or false
    local api_url = '/clans/dungeon_start'

    -- 응답 상태 처리 함수
    local t_error = {
        [-3871] = Str('이미 클랜 던전에 입장한 유저가 있습니다.'),
        [-1371] = Str('유효하지 않은 던전입니다.'), 
    }
    local response_status_cb = MakeResponseCB(t_error)

    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        local game_key = ret['gamekey']
        finish_cb(game_key)

        -- 스피드핵 방지 실제 플레이 시간 기록
        g_accessTimeData:startCheckTimer()
    end

    local attr = TableStageData:getStageAttr(stage_id) 
    local multi_deck_mgr = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)
    local deck_name1 = multi_deck_mgr:getDeckName('up')
    local deck_name2 = multi_deck_mgr:getDeckName('down')

    local token1 = g_stageData:makeDragonToken(deck_name1)
    local token2 = g_stageData:makeDragonToken(deck_name2)
    local teambonus1 = g_stageData:getTeamBonusIds(deck_name1)
    local teambonus2 = g_stageData:getTeamBonusIds(deck_name2)

    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setParam('deck_name1', deck_name1)
    ui_network:setParam('deck_name2', deck_name2)
    ui_network:setParam('token1', token1)
    ui_network:setParam('token2', token2)
    ui_network:setParam('combat_power', combat_power)
    ui_network:setParam('team_bonus1', teambonus1)
    ui_network:setParam('team_bonus2', teambonus2)

    if (is_cash) then ui_network:setParam('is_cash', is_cash) end
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end