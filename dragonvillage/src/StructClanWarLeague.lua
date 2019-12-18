
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
      "win_cnt":0,
      "rank":0,
      "id":"5dd6034a970c6204b0f7e7a3",
      "member_win_cnt":0,
      "game_lose":0,
      "play_member_cnt":0,
      "game_win":0,
      "league":1,
      "season":201947,
      "clan_id":"5ad9519fe891932d9abe6940",
      "group_no":1
    },{
      "lose_cnt":0,
      "win_cnt":0,
      "rank":0,
      "id":"5dd6034a970c6204b0f7e7a4",
      "member_win_cnt":0,
      "game_lose":0,
      "play_member_cnt":0,
      "game_win":0,
      "league":1,
      "season":201947,
      "clan_id":"5a167756e891934ac612c399",
      "group_no":2
    },{
    --]]
        local l_total_league = {}
        if (data['league_info']) then
	        l_total_league = data['league_info']
        end

	    for _, _data in ipairs(l_total_league) do
            local struct_league_item = StructClanWarLeagueItem(_data)
            local clan_id = _data['clan_id']
            
            -- 1. 클랜 정보가 있어야
            -- 2. 유령 클랜이 아닐 경우에만 리스트에 추가해줌
            if (g_clanWarData:getClanInfo(clan_id)) then
                if (not struct_league_item:isGoastClan()) then
                    table.insert(self.m_lLeagueTotalMatch, struct_league_item)
                end
            end
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
-- function getTodayMyMatchInfo
-------------------------------------
function StructClanWarLeague:getTodayMyMatchInfo()
    --[[
        data['a_win_cnt'] = 0
        data['id'] = '5ddf34c6e8919372e1f618bb'
        data['b_lose_cnt'] = 9
        data['a_member_win_cnt'] = 0
        data['b_play_member_cnt'] = 0
        data['b_member_win_cnt'] = 0
        data['win_clan'] = 0
        data['league'] = 0
        data['a_clan_id'] = 0
        data['day'] = 0
        data['win_condition'] = 0
        data['b_win_cnt'] = 0
        data['season'] = 0
        data['b_clan_id'] = '5ddb4947970c6204bef38cf7'
        data['a_play_member_cnt'] = 0
        data['match_no'] = 0
        data['a_lose_cnt'] = 0
    --]]
    local l_league = self.m_lLeagueMatch
    local my_clan_id = g_clanWarData:getMyClanId()
	local cur_day = g_clanWarData.m_clanWarDay
	for _, data in ipairs(l_league) do
		if (data['day'] == cur_day) then
			if (data['a_clan_id'] == my_clan_id) then
				return data
			end
			if (data['b_clan_id'] == my_clan_id) then
				return data
			end
		end
	end
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

-------------------------------------
-- function getAllClanWarLeagueRankList
-------------------------------------
function StructClanWarLeague:getAllClanWarLeagueRankList(clan_id)
    local l_clan = self:getClanWarLeagueRankList()    
    local t_rank_clan_info = {}

	-- 전체 랭킹 출력하기 위해서
	-- 각 조 이름을 key로 만든 맵으로 변환
	for _, struct_league_item in pairs(l_clan) do
		local league = struct_league_item:getLeague()
		if (not t_rank_clan_info[league]) then
			t_rank_clan_info[league] = {}
		end

        local clan_id = struct_league_item:getClanId()
		local clan_info = g_clanWarData:getClanInfo(clan_id)
		-- 1. 클랜 정보가 있어야
        -- 2. 유령 클랜이 아닐 경우에만 리스트에 추가해줌
        if (clan_info) then
            if (not struct_league_item:isGoastClan()) then
                table.insert(t_rank_clan_info[league], struct_league_item)
            end
        end
		
	end

    -- 랭킹 순서로 정렬
    local sort_func = function(a, b)
        local rank_a = a:getLeagueRank()
        local rank_b = b:getLeagueRank()
        
        return rank_a < rank_b
    end

	for _, l_data in pairs(t_rank_clan_info) do
		table.sort(l_data, sort_func)
	end

    return t_rank_clan_info
end