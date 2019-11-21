
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

    if (data['tournament_info']) then
        self:makeTournamentTable(data['tournament_info'])
    end

    self.m_structClanWarLeague = StructClanWarLeague(data)
end

-------------------------------------
-- function makeTournamentTable -- makeTournamentData랑 통합 필요
-------------------------------------
function StructClanWarTournament:makeTournamentTable(l_tournament)
    for idx, data in ipairs(l_tournament) do
        local clan_id = data['clan_id'] -- N강
        self.m_tTournament[clan_id] = data
    end
end

-------------------------------------
-- function makeTournamentTable -- makeTournamentData랑 통합 필요
-------------------------------------
function StructClanWarTournament:getTournamentInfoByClanId(clan_id)
    return self.m_tTournament[clan_id]
end

-------------------------------------
-- function makeTournamentData
-------------------------------------
function StructClanWarTournament:makeTournamentData(l_tournament)
	for idx, data in ipairs(l_tournament) do
        local group_stage = data['group_stage']
        for _, round in ipairs(L_ROUND) do
            if (group_stage <= round) then
				local _data = clone(data)
				_data['is_win'] = (group_stage ~= round)
                table.insert(self.m_tTournamentInfo[round], _data)		
            end	
        end
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
        for i = 1, round do
            table.insert(l_tournament, {})
        end
    end
    return l_tournament
end

-------------------------------------
-- function makeDummy
-------------------------------------
function StructClanWarTournament.makeDummy()
	--[[
	local ret =
	{
		['round_64'] = 
		{
			{
				['1_clanid'] = 1, -- 클랜 id =  클랜 넘버
				['2_clanid'] = 2,
				['win'] = 1		  -- 이긴 클랜 넘버
			},
			{
				['1_clanid'] = 1, -- 클랜 id =  클랜 넘버
				['2_clanid'] = 2,
				['win'] = 1
			},.....
		},
		['round_32'] = 
		{
				['1_clanid'] = 1, -- 클랜 id =  클랜 넘버
				['2_clanid'] = 2,
				['win'] = 1
		},.....

	}
	--]]
	local make_round_func = function(t_data, round)
		t_data['round_' .. round] = {}
        for i = 1, round do
			local t_round = {
				['1_clanid'] = '1' .. i, -- 클랜 id =  클랜 넘버
				['2_clanid'] = '2' .. i,
				['win'] = 1	
			}
			table.insert(t_data['round_' .. round], t_round)
		end

		return table['round_' .. round]
	end

	local ret = {}
	local l_round = {2, 4 ,8, 16, 32, 64}
	for _, round in ipairs(l_round) do
		make_round_func(ret, round)
	end
	return ret
end

-------------------------------------
-- function getClanInfo
-------------------------------------
function StructClanWarTournament:getClanInfo(clan_id)
    return self.m_tClanInfo[clan_id]
end

-------------------------------------
-- function isWin
-------------------------------------
function StructClanWarTournament.isWin(tournament_data)
	if (not tournament_data) then
		return false
	end

	if (not tournament_data['is_win']) then
		return false
	end

	return tournament_data['is_win']
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
function StructClanWarTournament:isContainClan(clan_id)
	if (not self.m_tTournamentInfo) then
        return false
    end
    
    if (not clan_id) then
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
        if (clan_id == data['clan_id']) then
            return true
        end
    end

   return false
end

-------------------------------------
-- function getMaxRound
-------------------------------------
function StructClanWarTournament:getMaxRound()
	return self.m_maxRound
end

-------------------------------------
-- function getMyClanMatchScore
-------------------------------------
function StructClanWarTournament:getMyClanMatchScore()
    local cur_round =  g_clanWarData:getTodayRound()
    local l_tournament = self.m_tTournamentInfo[cur_round]
    local my_clan_id = g_clanWarData:getMyClanId()
    local enemy_clan_id
    local my_win_cnt = 0
    local enemy_win_cnt = 0
    for _, data in ipairs(l_tournament) do
        if (data['clan_id'] == my_clan_id) then
            my_win_cnt = data['member_win_cnt']
            enemy_clan_id = data['enemy_clan_id']
        end
    end

    for _, data in ipairs(l_tournament) do
        if (data['clan_id'] == enemy_clan_id) then
            enemy_win_cnt = data['member_win_cnt']
        end
    end

    return my_win_cnt, enemy_win_cnt
end

-------------------------------------
-- function getStructClanWarLeague
-------------------------------------
function StructClanWarTournament:getStructClanWarLeague()
    return self.m_structClanWarLeague
end

-------------------------------------
-- function isPlayingGame
-------------------------------------
function StructClanWarTournament:isPlayingGame()
    local cur_round = g_clanWarData:getTodayRound()
	local l_tournament = self.m_tTournamentInfo[cur_round]
    if (not l_tournament) then
        return
    end
	
    local my_clan_id = g_clanWarData:getMyClanId()
    for _, data in ipairs(l_tournament) do
		if (data['clan_id'] == my_clan_id) then
			return true
		end
	end

	return false
end

-------------------------------------
-- function getMemberWinCnt
-------------------------------------
function StructClanWarTournament.getMemberWinCnt(struct_tournament_item)
	if (not struct_tournament_item) then
		return 0
	end
    return struct_tournament_item['member_win_cnt'] or 0
end

-------------------------------------
-- function getMemberWinCnt_history
-------------------------------------
function StructClanWarTournament.getMemberWinCnt_history(struct_tournament_item, round)
	if (not struct_tournament_item) then
		return 0
	end

    local l_history = struct_tournament_item['win_history'] or {}
	local max_round = g_clanWarData:getMaxRound()
	if (max_round == round) then
		return StructClanWarTournament.getMemberWinCnt(struct_tournament_item)
	end

	local idx = 1
	for i = 1,6 do
		if (max_round == round) then
			idx = i
			break
		end
		max_round = max_round/2
	end

	return l_history[idx] or 0
end

-------------------------------------
-- function getMemberWinCnt_history
-------------------------------------
function StructClanWarTournament.getScore_history(struct_tournament_item, round)
	if (not struct_tournament_item) then
		return 0
	end
    local l_history = struct_tournament_item['score_history'] or {}
	local max_round = g_clanWarData:getMaxRound()
	if (max_round == round) then
		return struct_tournament_item['score'] or 0
	end
	
	local idx = 1
	for i = 1,6 do
		if (max_round == round) then
			idx = i
			break
		end
		max_round = max_round/2
	end

	return l_history[idx] or 0
end
