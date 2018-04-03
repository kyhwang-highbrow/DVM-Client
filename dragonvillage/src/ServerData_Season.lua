-------------------------------------
-- class ServerData_Season
-------------------------------------
ServerData_Season = class({
        m_serverData = 'ServerData',

        m_clandungeonWeek = 'number',   -- 클랜던전 주차(모든 서버 공통)
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Season:init(server_data)
    self.m_serverData = server_data
    
    self.m_clandungeonWeek = 0
end

-------------------------------------
-- function applyInfo
-- @brief 정보 갱신하기
-------------------------------------
function ServerData_Season:applyInfo(ret)
    if (ret['clandungeon_week']) then
        self.m_clandungeonWeek = ret['clandungeon_week']

        NEW_CLAN_DUNGEON = (self.m_clandungeonWeek > 201814) 
    end
end