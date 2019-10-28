
-------------------------------------
-- class StructClanWarTournament
-------------------------------------
StructClanWarTournament = class({
	m_tClanInfo = 'table',
    m_tTournamentInfo = 'table'

})

local L_ROUND = {64, 32, 16, 8, 4, 2}

-------------------------------------
-- function init
-------------------------------------
function StructClanWarTournament:init(data)
	self.m_tTournamentInfo = {}

    if (not data) then
		return
	end

    if (data['tounament_info']) then
        self:makeTournamentData()
    end
end

-------------------------------------
-- function makeTournamentData
-------------------------------------
function StructClanWarTournament:makeTournamentData(l_tournament)
    for idx, data in ipairs(l_tournament) do
    end
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
-- function getRoundInfo
-------------------------------------
function StructClanWarTournament:getRoundInfo(round)
end
