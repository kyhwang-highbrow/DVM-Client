
-------------------------------------
-- class StructClanWarTournament
-------------------------------------
StructClanWarTournament = class({
	m_tClanInfo = 'table',
    m_tTournamentInfo = 'table',
    m_clanWarDay = 'number',

	m_maxRound = 'round', -- 몇 강부터 시작하는지, ex) 64
})

local L_ROUND = {64, 32, 16, 8, 4, 2, 1}

-------------------------------------
-- function init
-------------------------------------
function StructClanWarTournament:init(data)
	self.m_tTournamentInfo = {}
    self.m_clanWarDay = 1
    self.m_tClanInfo = {}
	self.m_maxRound = 0

    for i, round in ipairs(L_ROUND) do
        self.m_tTournamentInfo[round] = {}
    end

    if (not data) then
		return
	end

    if (data['tournament_info']) then
        self:makeTournamentData(data['tournament_info'])
    end

    if (data['clan_info']) then
        self:makeClanInfo(data['clan_info'])
    end

    if (data['clanwar_day']) then
        self.m_clanWarDay = data['clanwar_day']
    end
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

		if (self.m_maxRound < group_stage) then
			self.m_maxRound = group_stage
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
-- function makeClanInfo
-------------------------------------
function StructClanWarTournament:makeClanInfo(l_clan)
    for idx, data in ipairs(l_clan) do
        local clan_id = data['id'] -- N강
        self.m_tClanInfo[clan_id] = StructClanRank(data)
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
-- function getMaxRound
-------------------------------------
function StructClanWarTournament:getMaxRound()
	return self.m_maxRound
end