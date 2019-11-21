
-------------------------------------
-- class StructClanWarLeague
-------------------------------------
StructClanWarLeague = class({
    m_lLeagueMatch = 'list',
    m_lLeagueTotalMatch = 'list',
})

-------------------------------------
-- function init
-------------------------------------
function StructClanWarLeague:init(data)
	self.m_lLeagueMatch = {}
    self.m_lLeagueTotalMatch = {}

	if (not data) then
		return
	end

    -- 각 경기마다 정보
    do
        local l_league_match = {}
        if (data['league_match_history']) then
            l_league_match = data['league_match_history']
        end

	    for _, _data in ipairs(l_league_match) do
            table.insert(self.m_lLeagueMatch, _data)
        end

        -- 경기 순으로 정렬
        local sort_func = function(a, b)
            return a['match_no'] < b['match_no']
        end
        table.sort(self.m_lLeagueMatch, sort_func)
    end

    -- 토탈 조별 리그 정보 (랭킹 정보)
    do
	--[[
	  "a_win_cnt":0,
      "b_play_member_cnt":0,
      "id":"5dd56886e8919372e1f01248",
      "b_member_win_cnt":0,
      "b_lose_cnt":0,
      "a_clan_id":"5ad9519fe891932d9abe6940",
      "a_member_win_cnt":0,
      "day":2,
      "league":1,
      "b_win_cnt":0,
      "season":201947,
      "a_lose_cnt":0,
      "a_play_member_cnt":0,
      "match_no":1,
      "b_clan_id":"5a167756e891934ac612c399"
	--]]
        local l_total_league = {}
        if (data['league_info']) then
	        l_total_league = data['league_info']
        end

	    for _, _data in ipairs(l_total_league) do
            local struct_league_item = StructClanWarLeagueItem(_data)
            table.insert(self.m_lLeagueTotalMatch, struct_league_item)
        end

        -- 그룹 오더 순으로 정렬
        local sort_func = function(a, b)
            return a:getLeagueRank() < b:getLeagueRank()
        end
        table.sort(self.m_lLeagueTotalMatch, sort_func)
    end
end

-------------------------------------
-- function getClanWarLeagueRankList
-- @brief 랭킹 정보
-------------------------------------
function StructClanWarLeague:getClanWarLeagueRankList()
    return self.m_lLeagueTotalMatch
end

-------------------------------------
-- function getClanWarLeagueMatchList
-- @brief 조별 리그 일정
-------------------------------------
function StructClanWarLeague:getClanWarLeagueMatchList()
    return self.m_lLeagueMatch
end

-------------------------------------
-- function getClanWarLeagueMatchList
-- @brief 조별 리그 일정
-------------------------------------
function StructClanWarLeague:getMyLeagueRank()
	local l_total_match = self.m_lLeagueTotalMatch
	local my_clan_id = g_clanWarData:getMyClanId()
	for _, struct_league_item in ipairs(l_total_match) do
		if (my_clan_id == struct_league_item:getClanId()) then
			return struct_league_item:getLeagueRank()
		end
	end

	return nil
end

-------------------------------------
-- function isContainClan
-------------------------------------
function StructClanWarLeague:isContainClan(clan_id)
	local l_total_match = self.m_lLeagueTotalMatch
	for _, struct_league_item in ipairs(l_total_match) do
		if (clan_id == struct_league_item:getClanId()) then
			return true
		end
	end

	return false
end

-------------------------------------
-- function getLeagueInfo
-------------------------------------
function StructClanWarLeague:getLeagueInfo(clan_id)
	local l_total_match = self.m_lLeagueTotalMatch
	for _, struct_league_item in ipairs(l_total_match) do
		if (clan_id == struct_league_item:getClanId()) then
			return struct_league_item
		end
	end

	return nil
end

-------------------------------------
-- function getMyClanMatchScore
-------------------------------------
function StructClanWarLeague:getMyClanMatchScore()
	local my_clan_id = g_clanWarData:getMyClanId()
	local cur_day = g_clanWarData.m_clanWarDay
	for _, data in ipairs(self.m_lLeagueMatch) do
		if (data['day'] == cur_day) then
			if (data['a_clan_id'] == my_clan_id) then
				return data['a_member_win_cnt'], data['b_member_win_cnt']
			end
			if (data['b_clan_id'] == my_clan_id) then
				return data['b_member_win_cnt'], data['a_member_win_cnt']
			end
		end
	end
end

-------------------------------------
-- function getTotalSetScore
-------------------------------------
function StructClanWarLeague:getTotalSetScore(clan_id)
    local total_win_cnt = 0
	for _, data in ipairs(self.m_lLeagueMatch) do
		if (data['a_clan_id'] == clan_id) then
		    total_win_cnt = total_win_cnt + data['a_member_win_cnt']
		end
		if (data['b_clan_id'] == clan_id) then
			total_win_cnt = total_win_cnt + data['b_member_win_cnt']
		end
	end

    return total_win_cnt
end