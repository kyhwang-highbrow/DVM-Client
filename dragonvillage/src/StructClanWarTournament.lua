
-------------------------------------
-- class StructClanWarTournament
-------------------------------------
StructClanWarTournament = class({
    m_tTournamentInfo = 'table',
    m_tTournament = 'table',

    m_structClanWarLeague = 'StructClanWarLeague',
})

local L_ROUND = {64, 32, 16, 8, 4, 2, 1}

-------------------------------------
-- function init
-------------------------------------
function StructClanWarTournament:init(data)
	self.m_tTournamentInfo = {}
    self.m_tTournament = {}

    for i, round in ipairs(L_ROUND) do
        self.m_tTournamentInfo[round] = {}
    end

    if (not data) then
		return
	end

    if (data['tournament_info']) then
        self:makeTournamentData(data['tournament_info'])
    end

    self.m_structClanWarLeague = StructClanWarLeague(data)
end

-------------------------------------
-- function makeTournamentData
-------------------------------------
function StructClanWarTournament:makeTournamentData(l_tournament)
	for idx, data in ipairs(l_tournament) do
        local group_stage = data['group_stage']
        table.insert(self.m_tTournamentInfo[group_stage], data)	
    end


    -- N강 마다 group_stage_no 순으로 정렬
    local sort_func = function(a, b)
        return a['group_stage_no'] < b['group_stage_no']
    end

    for _, round in ipairs(L_ROUND) do
        table.sort(self.m_tTournamentInfo[round], sort_func)
    end
end 

-------------------------------------
-- function getTournamentListByRound
-------------------------------------
function StructClanWarTournament:getTournamentListByRound(round)
    local t_tournament = self.m_tTournamentInfo
    if (not t_tournament) then
        return
    end

    if (not t_tournament[round]) then
        return
    end

    local l_tournament = t_tournament[round]
    if (#l_tournament == 0) then
        for i = 1, round/2 do
            table.insert(l_tournament, {})
        end
    end
    return l_tournament
end

-------------------------------------
-- function getMyClanLeft
-- @brief 내 클랜 없다면 무조건 오른쪽 반환, 테스트 용이라 그래도 됨
-------------------------------------
function StructClanWarTournament:getMyClanLeft()
	if (not self.m_tTournamentInfo) then
        return false
    end
    
    local my_clan_id = g_clanWarData:getMyClanId()
    if (not my_clan_id) then
        return false
    end

    local today_round = g_clanWarData:getTodayRound()
    -- 돌면서 나의 클랜을 찾는다.
    local t_data = self.m_tTournamentInfo[today_round]
    if (not t_data) then
        return false
    end

    local idx = 1
	for _, data in ipairs(t_data) do
        if (my_clan_id == data['clan_id']) then
            return (idx%2 == 1)
        end
        idx = idx + 1
    end

   return false
end

-------------------------------------
-- function isContainClan
-------------------------------------
function StructClanWarTournament:getTournamentInfo(clan_id)
	if (not self.m_tTournamentInfo) then
        return 
    end
    
    if (not clan_id) then
        return 
    end

    local today_round = g_clanWarData:getTodayRound()
    -- 돌면서 나의 클랜을 찾는다.
    local t_data = self.m_tTournamentInfo[today_round]
    if (not t_data) then
        return 
    end

    local idx = 1
	for _, data in ipairs(t_data) do
        if (clan_id == data['a_clan_id']) or (clan_id == data['b_clan_id']) then
            return data
        end
    end

   return 
end

-------------------------------------
-- function getTournamentRank
-------------------------------------
function StructClanWarTournament:getTournamentRank(clan_id)
	if (not self.m_tTournamentInfo) then
        return 
    end
    
    if (not clan_id) then
        return 
    end

    local L_ROUND = {64, 32, 16, 8, 4, 2, 1}
    local my_rank = nil
    for idx, round in ipairs(L_ROUND) do
        -- 돌면서 나의 클랜을 찾는다.
        local t_data = self.m_tTournamentInfo[round]
        if (not t_data) then
            break 
        end

        local idx = 1
	    for _, data in ipairs(t_data) do
            if (clan_id == data['a_clan_id']) or (clan_id == data['b_clan_id']) then
                my_rank = round
            end
        end
    end

   return my_rank
end

-------------------------------------
-- function getStructClanWarLeague
-------------------------------------
function StructClanWarTournament:getStructClanWarLeague()
    return self.m_structClanWarLeague
end

-------------------------------------
-- function getMyInfoInCurRound
-------------------------------------
function StructClanWarTournament:getMyInfoInCurRound()
    local cur_round = g_clanWarData:getTodayRound()
	local l_tournament = self.m_tTournamentInfo[cur_round]
    if (not l_tournament) then
        
    end
	
    local my_clan_id = g_clanWarData:getMyClanId()
    for idx, data in ipairs(l_tournament) do
		if (data['a_clan_id'] == my_clan_id) or  (data['b_clan_id'] == my_clan_id) then
			return data, idx
		end
	end

	return 
end
