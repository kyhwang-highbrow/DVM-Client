
-------------------------------------
-- class StructClanWarLeague
-------------------------------------
StructClanWarLeague = class({
	m_lClanId = 'list',
	m_lWinInfo = 'list',
	m_lRank = 'list',

    m_nMyClanTeam = 'number', -- n조
})

-------------------------------------
-- function init
-------------------------------------
function StructClanWarLeague:init(data)
	self.m_lClanId = {}
	self.m_lWinInfo = {}
	self.m_lRank = {}
	
	if (not data) then
		return
	end

	local t_clan_id = data['clan_id']
	if (not t_clan_id) then
		return
	end

	-- 클랜 정보
	-- self.m_lclanId = {[클랜 넘버] = 클랜 Id, ...)
	for clan_id, clan_number in pairs(t_clan_id) do
		self.m_lClanId[clan_number] = clan_id
	end

	-- 이긴 정보
	-- self.m_lwinInfo = {[win1] = {1, 4, 6}, ...) -- n 경기 = 이긴 클랜 넘버
	for idx = 1, 6 do
		self.m_lWinInfo[idx] = data['win' .. idx]
	end

	-- 랭크 정보
	-- self.m_rank[idx] = {['clan_number'] = 5, ['clan_score'] = 400}, ...
	local l_rank = data['rank']
	if (l_rank) then
		for idx = 1, 6 do
			local str_score = l_rank[idx] or ''
			local l_rank_info = plSplit(str_score, ';') or {}
			self.m_lRank[idx] = {
				['clan_number'] = l_rank_info[1] or 999,
				['clan_score'] = l_rank_info[2] or 0 
			}
		end
	end

	local sort_func = function(a, b)
		return a['clan_score']  < b['clan_score']
	end
	table.sort(self.m_lRank, sort_func)
end

-------------------------------------
-- function getClanWarLeagueList
-- @brief 날짜별 진행되는 경기 정보
-------------------------------------
function StructClanWarLeague:getClanWarLeagueList(day) -- 1일차 2일차 등등...
	local l_clan = self.m_lClanId or {}
	local l_match = {}
    local day = day or 1

	for idx = 1, 6 do
        local cur_idx = idx + day
		local t_clan = {}
		t_clan['clan_A'] = l_clan[cur_idx]
		local next_idx = cur_idx + 1
		if (next_idx > 6) then
			next_idx = next_idx - 6
		end
		t_clan['clan_B'] = l_clan[next_idx]
		table.insert(l_match, t_clan)
	end

	return l_match
end

-------------------------------------
-- function getClanWarLeagueRankList
-- @brief 랭킹 정보
-------------------------------------
function StructClanWarLeague:getClanWarLeagueRankList()
	return self.m_lRank
end

-------------------------------------
-- function getClanId
-------------------------------------
function StructClanWarLeague:getClanId(clan_number)
	local clan_number = tonumber(clan_number)
	return self.m_lClanId[clan_number] or ''
end

-------------------------------------
-- function getMyClanTeam
-------------------------------------
function StructClanWarLeague:getMyClanTeam()
    return self.m_nMyClanTeam
end

-------------------------------------
-- function makeDummy
-------------------------------------
function StructClanWarLeague.makeDummy()
	local ret =
	{
		['clan_id'] = 
		{
			['1_clanid'] = 1, -- 클랜 id =  클랜 넘버
			['2_clanid'] = 2,
			['3_clanid'] = 3,
			['4_clanid'] = 4,
			['5_clanid'] = 5,
			['6_clanid'] = 6,
		},
		['wins_1'] = {1, 3, 5}, -- n 경기에 이긴 클랜 넘버
		['rank'] = {'1;200', '4;180', '3;120', '2;100', '5;80', '6;50'} -- 클랜넘버;클랜 점수
	}
	
	return ret	
end
