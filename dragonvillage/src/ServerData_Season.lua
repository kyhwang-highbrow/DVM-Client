-------------------------------------
-- class ServerData_Season
-------------------------------------
ServerData_Season = class({
        m_serverData = 'ServerData',

        m_clandungeonWeek = 'number',   -- 클랜던전 주차(모든 서버 공통)

        m_bArenaOpen = 'boolean', -- 콜로세움 (신규 모드) 오픈 여부 
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Season:init(server_data)
    self.m_serverData = server_data
    
    self.m_clandungeonWeek = 0
    self.m_bArenaOpen = false
end

-------------------------------------
-- function applyInfo
-- @brief 정보 갱신하기
-------------------------------------
function ServerData_Season:applyInfo(ret)
    if (ret['clandungeon_week']) then
        self.m_clandungeonWeek = ret['clandungeon_week']
    end

    if (ret['arena_open']) then
        self.m_bArenaOpen = ret['arena_open']
    end
end