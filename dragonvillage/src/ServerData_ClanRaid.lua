-------------------------------------
-- class ServerData_ClanRaid
-------------------------------------
ServerData_ClanRaid = class({
        m_serverData = 'ServerData',

        -- 오픈/종료 시간
        m_startTime = 'number',
        m_endTime = 'number',

        -- 현재 진행중인 스테이지 ID
        m_curr_stageID = 'number',

        -- 현재 진행중 혹은 선택한 던전 정보
        m_structClanRaid = 'StructClanRaid',

        -- 던전 참여한 유저 랭킹 리스트
        m_lRank = 'list',
    })

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
-- function getDeckName
-------------------------------------
function ServerData_ClanRaid:getDeckName(pos)
    local pos = pos or 'main' -- or 'sub'
    local deck_name = 'clan_raid_' .. pos
    return deck_name
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

        self.m_curr_stageID = ret['cur_stage']

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