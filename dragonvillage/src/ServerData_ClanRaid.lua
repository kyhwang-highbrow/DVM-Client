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

        -- 메인 (수동으로 전투가 가능한) 덱 (up or down)
        m_main_deck = 'string',

        -- 클랜던전 덱 map (임시 저장)
        m_tDeckMap_1 = 'map',
        m_tDeckMap_2 = 'map',

        -- 여의주 사용횟수
        m_use_cash = 'number',

        -- 클랜 보상 정보
        m_tClanRewardInfo = 'table', 

        -- 오픈상태 
        m_bOpen = 'boolean',
    })

local USE_CASH_LIMIT = 1 -- 하루 최대 여의주 사용 입장횟수
local USE_CASH_CNT = 200

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanRaid:init(server_data)
    self.m_serverData = server_data
    
    -- 메인덱은 로컬에 저장
    self.m_main_deck = g_settingData:get('clan_raid', 'main_deck') or 'up'
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
-- function getClanRaidStruct
-- @brief 메인 (수동으로 전투가 가능한) 덱 (up or down)
-------------------------------------
function ServerData_ClanRaid:getMainDeck()
    return self.m_main_deck
end

-------------------------------------
-- function setMainDeck
-------------------------------------
function ServerData_ClanRaid:setMainDeck(mode)
    if (mode == 'up' or mode == 'down') then
        self.m_main_deck = mode
        g_settingData:applySettingData(mode, 'clan_raid', 'main_deck')
    else
        error('ServerData_ClanRaid:setMainDeck - 정의된 mode가 아닙니다.')
    end
end

-------------------------------------
-- function getAnotherMode
-------------------------------------
function ServerData_ClanRaid:getAnotherMode(mode)
    local mode = (mode == 'up') and 'down' or 'up'
    return mode
end

-------------------------------------
-- function getDeckName
-------------------------------------
function ServerData_ClanRaid:getDeckName(mode)
    local mode = mode or 'up' -- or 'down'
    local deck_name = 'clan_raid_' .. mode
    return deck_name
end

-------------------------------------
-- function getUseCashCnt
-------------------------------------
function ServerData_ClanRaid:getUseCashCnt()
    return USE_CASH_CNT
end

-------------------------------------
-- function getDeck
-- @breif 선택한 모드 덱 가져옴 (서버에 저장된 덱)
-------------------------------------
function ServerData_ClanRaid:getDeck(mode)
    local deck_name = 'clan_raid_' .. mode
    return g_deckData:getDeck(another_deck_name)
end

-------------------------------------
-- function getAnotherDeck
-- @breif 선택한 다른 모드 덱 가져옴 (서버에 저장된 덱, 상단 -> 하단, 하단 -> 상단)
-------------------------------------
function ServerData_ClanRaid:getAnotherDeck(mode)
    local another_mode = self:getAnotherMode(mode)
    local deck_name = 'clan_raid_' .. another_mode
    return g_deckData:getDeck(another_deck_name)
end

-------------------------------------
-- function getTeamName
-------------------------------------
function ServerData_ClanRaid:getTeamName(mode)
    local mode = mode or 'up' -- or 'down'
    local team_name = (mode == 'up') and 
                      Str('1 공격대') or
                      Str('2 공격대') 
    return team_name
end

-------------------------------------
-- function makeDeckMap
-- @breif 클랜던전 덱 map 형태로 임시 저장 (리스트일 경우 sort 시간 오래걸림)
-------------------------------------
function ServerData_ClanRaid:makeDeckMap()
    self.m_tDeckMap_1 = {}
    self.m_tDeckMap_2 = {}

    -- 1 공격대
    do
        local deck_name = self:getDeckName('up')
        local l_deck = g_deckData:getDeck(deck_name)
        for i, v in ipairs(l_deck) do
            self.m_tDeckMap_1[v] = i
        end
    end

    -- 2 공격대
    do
        local deck_name = self:getDeckName('down')
        local l_deck = g_deckData:getDeck(deck_name)
        for i, v in ipairs(l_deck) do
            self.m_tDeckMap_2[v] = i
        end
    end
end

-------------------------------------
-- function getDeckMap
-- @breif 선택한 모드 덱 Map (임시로 저장된 덱)
-------------------------------------
function ServerData_ClanRaid:getDeckMap(mode)
    return (mode == 'up') and self.m_tDeckMap_1 or self.m_tDeckMap_2
end

-------------------------------------
-- function getAnotherDeckMap
-- @breif 선택한 다른 모드 덱 Map (임시로 저장된 덱, 상단 -> 하단, 하단 -> 상단)
-------------------------------------
function ServerData_ClanRaid:getAnotherDeckMap(mode)
    return (mode == 'up') and self.m_tDeckMap_2 or self.m_tDeckMap_1
end

-------------------------------------
-- function addDeckMap
-- @breif 클랜던전 덱 Map 추가 (임시로 저장된 덱)
-------------------------------------
function ServerData_ClanRaid:addDeckMap(mode, doid)
    local target = mode == 'up' and self.m_tDeckMap_1 or self.m_tDeckMap_2
    target[doid] = 1
end

-------------------------------------
-- function deleteDeckMap
-- @breif 클랜던전 덱 Map 삭제 (임시로 저장된 덱)
-------------------------------------
function ServerData_ClanRaid:deleteDeckMap(mode, doid)
    local target = mode == 'up' and self.m_tDeckMap_1 or self.m_tDeckMap_2
    target[doid] = nil
end

-------------------------------------
-- function clearDeckMap
-- @breif 클랜던전 덱 Map 초기화 (임시로 저장된 덱)
-------------------------------------
function ServerData_ClanRaid:clearDeckMap(mode)
    if (mode == 'up') then
        self.m_tDeckMap_1 = {}
    else
        self.m_tDeckMap_2 = {}
    end
end

-------------------------------------
-- function getDeckDragonCnt
-- @breif 클랜던전 덱 셋팅된 드래곤 수
-------------------------------------
function ServerData_ClanRaid:getDeckDragonCnt(mode)
    local target = mode == 'up' and self.m_tDeckMap_1 or self.m_tDeckMap_2
    local cnt = 0
    for _, k in pairs(target) do
        cnt = cnt + 1
    end

    return cnt
end

-------------------------------------
-- function isSettedClanRaidDeck
-- @breif 클랜던전 덱인지
-------------------------------------
function ServerData_ClanRaid:isSettedClanRaidDeck(doid)
    local is_setted = self.m_tDeckMap_1[doid] or nil
    -- 1 공격대
    if (is_setted) then
        return is_setted, 1
    end

    -- 2 공격대
    local is_setted = self.m_tDeckMap_2[doid] or nil
    if (is_setted) then
        return is_setted, 2
    end

    return false, 99
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
        str = Str('{1} 남았습니다.', datetime.makeTimeDesc(time, true))

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
        self.m_tClanRewardInfo['rank'] = StructClanRank(ret['last_clan_info'])
        self.m_tClanRewardInfo['reward_info'] = ret['reward_clan_info']
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
            for _, user_data in ipairs(rank_list) do
                local user_info = StructUserInfoClanRaid:create_forRanking(user_data)
                table.insert(self.m_lRankList, user_info)
            end
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
        [-3871] = Str('이미 클랜던전에 입장한 유저가 있습니다.'),
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

    local deck_name1 = self:getDeckName('up')
    local deck_name2 = self:getDeckName('down')

    local token1 = g_stageData:makeDragonToken(deck_name1)
    local token2 = g_stageData:makeDragonToken(deck_name2)

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
    if (is_cash) then ui_network:setParam('is_cash', is_cash) end
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end