-------------------------------------
-- class ServerData_Season
-------------------------------------
ServerData_Season = class({
        m_serverData = 'ServerData',

        m_clandungeonWeek = 'number',   -- 클랜던전 주차(모든 서버 공통)

        m_bArenaOpen = 'boolean', -- 콜로세움 (신규 모드) 오픈 여부 

        m_ArenaNewSeason = 'number',
        m_ArenaNewOpen = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Season:init(server_data)
    self.m_serverData = server_data
    
    self.m_clandungeonWeek = 0
    self.m_ArenaNewSeason = 0
    self.m_bArenaOpen = false
    self.m_ArenaNewOpen = false
end

-------------------------------------
-- function applyInfo
-- @brief 정보 갱신하기
-------------------------------------
function ServerData_Season:applyInfo(ret)
    if (ret['clandungeon_week']) then
        self.m_clandungeonWeek = ret['clandungeon_week']
    end

    if (ret['arena_new_season']) then
        self.m_ArenaNewSeason = ret['arena_new_season']
    end

    if (ret['arena_new_open']) then
        self.m_ArenaNewOpen = ret['arena_new_open']
    end

    if (ret['arena_week']) then
        local server_name = g_localData:getServerName()
        if (server_name == 'DEV') then
            self.m_bArenaOpen = true
        else
            -- 주차 정보로 판단
            -- open 여부로 판단하면 락타임일때 문제 생길 여지 있음.
            self.m_bArenaOpen = (ret['arena_week'] >= 201821) and true or false
        end
    end
end