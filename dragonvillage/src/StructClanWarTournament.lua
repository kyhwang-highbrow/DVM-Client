
-------------------------------------
-- class StructClanWarTournament
-------------------------------------
StructClanWarTournament = class({
	m_tClanInfo = 'table',
    m_tTournamentInfo = 'table',
    m_clanWarDay = 'number',

})

local L_ROUND = {64, 32, 16, 8, 4, 2, 1}

-------------------------------------
-- function init
-------------------------------------
function StructClanWarTournament:init(data)
	self.m_tTournamentInfo = {}
    self.m_clanWarDay = 0
    self.m_tClanInfo = {}

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
                table.insert(self.m_tTournamentInfo[round], data)
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
