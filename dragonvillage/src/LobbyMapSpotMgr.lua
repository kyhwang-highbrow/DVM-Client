--------------------
-- interface LobbyMapSpotMgr
-- @brief
-------------------------------------
LobbyMapSpotMgr = {
        m_lSpotPos = 'list',
        m_mapUsedSpotPos = 'table',

        m_lobbySpotPos = 'table',
        m_clanLobbySpotPos = 'table',
    }

-------------------------------------
-- function init
-------------------------------------
function LobbyMapSpotMgr:init()
    self.m_lSpotPos = {}
    self.m_lSpotPos[1] = {-1650, -320}
    self.m_lSpotPos[2] = {-1515, -125}
    self.m_lSpotPos[3] = {-1400, -125}
    self.m_lSpotPos[4] = {-1347, -292}
    self.m_lSpotPos[5] = {-1148, -136}
    self.m_lSpotPos[6] = {-989, -218}
    self.m_lSpotPos[7] = {-758, -126}
    self.m_lSpotPos[8] = {-570, -303}
    self.m_lSpotPos[9] = {-450, -303}
    self.m_lSpotPos[10] = {-202, -120}
    self.m_lSpotPos[11] = {50, -80}
    self.m_lSpotPos[12] = {150, -80}
    self.m_lSpotPos[13] = {405, -278}
    self.m_lSpotPos[14] = {505, -137}
    self.m_lSpotPos[15] = {575, -200}
    self.m_lSpotPos[16] = {704, -274}
    self.m_lSpotPos[17] = {921, -115}
    self.m_lSpotPos[18] = {1024, -237}
    self.m_lSpotPos[19] = {1312, -130}
    self.m_lSpotPos[20] = {1792, -214}

    self.m_mapUsedSpotPos = {}

    self.m_lobbySpotPos = {2300, -220} -- 클랜로비 -> 마을 진입점
    self.m_clanLobbySpotPos = {-1740, -220} -- 마을 -> 클랜로비 진입점
end

-------------------------------------
-- function makeRandomSpot
-------------------------------------
function LobbyMapSpotMgr:makeRandomSpot()
    local spot_list = {}
    spot_list[1] = {-1650, -320}
    spot_list[2] = {-1515, -125}
    spot_list[3] = {-1400, -125}
    spot_list[4] = {-1347, -292}
    spot_list[5] = {-1148, -136}
    spot_list[6] = {-989, -218}
    spot_list[7] = {-758, -126}
    spot_list[8] = {-570, -303}
    spot_list[9] = {-450, -303}
    spot_list[10] = {-202, -120}
    spot_list[11] = {50, -80}
    spot_list[12] = {150, -80}
    spot_list[13] = {405, -278}
    spot_list[14] = {505, -137}
    spot_list[15] = {575, -200}
    spot_list[16] = {704, -274}
    spot_list[17] = {921, -115}
    spot_list[18] = {1024, -237}
    spot_list[19] = {1312, -130}
    spot_list[20] = {1792, -214}

    local spot_cnt = #spot_list
    local rand_idx = math_random(1, spot_cnt)
    local ret_pos = spot_list[rand_idx]
    return ret_pos[1], ret_pos[2]
end

-------------------------------------
-- function getRandomSpot
-- @breif 정해진 spot에 한 key만 해당 위치를 가질 수 있도록
-------------------------------------
function LobbyMapSpotMgr:getRandomSpot(key)
    -- 임시로 사용
    if (not key) then
        local spot_cnt = #self.m_lSpotPos
        local rand_idx = math_random(1, spot_cnt)
        local ret_pos = self.m_lSpotPos[rand_idx]
        return ret_pos[1], ret_pos[2]
    end


    local spot_cnt = #self.m_lSpotPos

    -- 남아있는 spot 개수가 없으면 리턴
    if (spot_cnt <= 0) then
        if self.m_mapUsedSpotPos[key] then
            return self.m_mapUsedSpotPos[key]
        else
            return nil
        end
    end

    -- 남아있는 spot 중 랜덤으로 추출
    local rand_idx = math_random(1, spot_cnt)
    local ret_pos = self.m_lSpotPos[rand_idx]
    table.remove(self.m_lSpotPos, rand_idx)

    -- key에 할상된 spot이 있으면 해제
    if self.m_mapUsedSpotPos[key] then
        table.insert(self.m_lSpotPos, self.m_mapUsedSpotPos[key])
    end
    self.m_mapUsedSpotPos[key] = ret_pos

    return ret_pos
end

-------------------------------------
-- function getEntrySpot
-- @breif 로비 전환시 진입 포지션 
-------------------------------------
function LobbyMapSpotMgr:getEntrySpot()
    local lobby_type = g_lobbyChangeMgr:getLobbyType()
    local x, y

    local random_range = 60
    if (lobby_type == LOBBY_TYPE.NORMAL) then
        x = self.m_clanLobbySpotPos[1] + (random_range + 50) 
        y = self.m_clanLobbySpotPos[2] + math_random(-random_range, random_range)

    elseif (lobby_type == LOBBY_TYPE.CLAN) then
        x = self.m_lobbySpotPos[1] - (random_range + 250) 
        y = self.m_lobbySpotPos[2] + math_random(-random_range, random_range)
    end

    return x, y
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function LobbyMapSpotMgr:getCloneTable()
	return clone(LobbyMapSpotMgr)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function LobbyMapSpotMgr:getCloneClass()
	return class(clone(LobbyMapSpotMgr))
end
