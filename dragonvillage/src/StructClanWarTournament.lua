
-------------------------------------
-- class StructClanWarTournament
-------------------------------------
StructClanWarTournament = class({
	m_lRoundInfo = 'list',
    m_tMyClanInfo = 'table',
})

local L_ROUND = {64, 32, 16, 8, 4, 2}

-------------------------------------
-- function init
-------------------------------------
function StructClanWarTournament:init(data)
	self.m_lRoundInfo = {}

    if (not data) then
		return
	end

    -- n강 마다 정보 수령
    for _, round in ipairs(L_ROUND) do
        local round_key = 'round_' .. round
        self.m_lRoundInfo[round] = data[round_key]
    end

    if (data['my_clan']) then
        self.m_tMyClanInfo = data['my_clan']
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
    local round = tonumber(round)
    return self.m_lRoundInfo[round]
end
