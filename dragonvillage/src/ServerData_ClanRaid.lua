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
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanRaid:init(server_data)
    self.m_serverData = server_data
    
    -- 메인덱은 로컬에 저장
    self.m_main_deck = g_localData:get('clan_raid', 'main_deck') or 'up'
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
        g_localData:applyLocalData(mode, 'clan_raid', 'main_deck')
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
-- function getAnotherDeckName
-- @breif 선택한 다른 모드 덱 네임 가져옴 (상단 -> 하단, 하단 -> 상단)
-------------------------------------
function ServerData_ClanRaid:getAnotherDeckName(mode)
    local another_mode = self:getAnotherMode(mode)
    local deck_name = 'clan_raid_' .. another_mode
    return deck_name
end

-------------------------------------
-- function getTeamName
-- @breif up - 1 공격대, down - 2 공격대
-------------------------------------
function ServerData_ClanRaid:getTeamName(mode)
    local mode = mode or 'up' -- or 'down'
    local team_name = (mode == 'up') and 
                      Str('1 공격대') or
                      Str('2 공격대') 
    return team_name
end

-------------------------------------
-- function isOpenClanRaid
-- @breif 던전 오픈 여부
-------------------------------------
function ServerData_ClanRaid:isOpenClanRaid()
    local curr_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
	
	return (start_time <= curr_time) and (curr_time <= end_time)
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
        self.m_startTime = ret['start_time']
        self.m_endTime = ret['endtime']

        self.m_challenge_stageID = ret['cur_stage']

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