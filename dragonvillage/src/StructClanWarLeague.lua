
-------------------------------------
-- class StructClanWarLeague
-------------------------------------
StructClanWarLeague = class({
	m_tClanInfo = 'list',
    m_clanCnt = 'number',
    --[[
       ['clan_id'] = {
                ['league_info'] = {
                    ['lose_cnt']=0;
                    ['id']='5da81c22970c6206220884f7';
                    ['win_cnt']=0;
                    ['total_score']=0;
                    ['total_history']=0;
                    ['league']=1;
                    ['clan_id']='5a02e73b019add152c890157';
                    ['group_no']=1;
                    }
                ['clan_info'] = StructClanRank()
            }
    --]]
    m_nMyClanId = 'number',
	m_matchDay = 'numnber',
})

-------------------------------------
-- function init
-------------------------------------
function StructClanWarLeague:init(data)
	self.m_tClanInfo = {}
	
	if (not data) then
		return
	end

	local l_league_info = data['league_info']
	if (not l_league_info) then
		return
	end

	-- 클랜 리그 정보
	-- [클랜 아이디] = 리그결과
	for _, t_clan in ipairs(l_league_info) do
        local clan_id = t_clan['clan_id']
        if (clan_id) then
            self.m_tClanInfo[clan_id] = {}
		    self.m_tClanInfo[clan_id]['league_info'] = t_clan
	    end
    end

    local cnt = 0
    for _, data in pairs(self.m_tClanInfo) do
        cnt = cnt + 1
    end
    self.m_clanCnt = cnt

    -- 클랜 정보
    local l_clan_info = data['clan_info']
	if (not l_clan_info) then
		return
	end

	for _, t_clan in ipairs(l_clan_info) do
        local struct_clan_rank = StructClanRank(t_clan)
        local clan_id = struct_clan_rank:getClanObjectID()
        if (clan_id) then
            self.m_tClanInfo[clan_id]['clan_info'] = struct_clan_rank
        end
    end

    self.m_nMyClanId = data['my_clan_id']

	self.m_matchDay = data['clanwar_day']
end

-------------------------------------
-- function getClanWarLeagueList
-- @brief 날짜별 진행되는 경기 정보
-------------------------------------
function StructClanWarLeague:getClanWarLeagueList(day) -- 1일차 2일차 등등...
	local l_match = {}
    local day = day or 1

    local t_order = {['A'] = 1, ['B'] = 2, ['C'] = 3, ['D'] = 4, ['E'] = 5, ['F'] = 6, ['G'] = 7, ['H'] = 8}
    local l_group = self:getMatchGroup(day)

	for _, data in ipairs(l_group) do
        local l_group = pl.stringx.split(data, ';')
        if (l_group) then
            local group_number_1 = t_order[l_group[1]]
            local t_clan_info_1 = self:getClanInfo_byGroupNumber(group_number_1)
            local group_number_2 = t_order[l_group[2]]
            local t_clan_info_2 = self:getClanInfo_byGroupNumber(group_number_2)
            local t_match = {}
            t_match['clan1'] = t_clan_info_1
            t_match['clan2'] = t_clan_info_2
            table.insert(l_match, t_match)
        end
    end
	return l_match
end

-------------------------------------
-- function getMatchGroup
-- @brief 날짜별 진행되는 경기 정보
-------------------------------------
function StructClanWarLeague:getMatchGroup(day) -- 1일차 2일차 등등...
    --[[
        {
                ['day']=1;
                ['group_2']='C;D';
                ['group_3']='E;F';
                ['group_1']='A;B';
        };
        {
                ['day']=2;
                ['group_2']='B;F';
                ['group_3']='D;E';
                ['group_1']='A;C';
        };
        {
    --]]
    local table_clanwar_group = TABLE:get('table_clanwar_group')
    local clan_cnt = self.m_clanCnt
    local l_match = {}
    for group_idx = 1, 3 do
        local idx = clan_cnt * 10 + day
        t_clanwar_group = table_clanwar_group[idx]
        if (t_clanwar_group) then
            local str_group = t_clanwar_group['group_' .. group_idx] -- 'B;F'
            if (str_group) and (str_group ~= '') then
                table.insert(l_match, str_group)
            end
        end
    end

    --[[
        -- @OUTPUT
        {'A;B', 'E;F', 'C;D'}
    --]]
    return l_match
end

-------------------------------------
-- function getClanWarLeagueRankList
-- @brief 랭킹 정보
-------------------------------------
function StructClanWarLeague:getClanWarLeagueRankList()
	local t_clan_info = self.m_tClanInfo    
    local l_clan_info = table.MapToList(t_clan_info)

    for idx, data in ipairs(l_clan_info) do
        if (not data['clan_info']) then
            table.remove(l_clan_info, idx)
        end
    end
    
    local sort_func = function(a, b)
        local rank_a = a['league_info']['rank']
        local rank_b = b['league_info']['rank']
        
        return rank_a < rank_b
    end

    table.sort(l_clan_info, sort_func)

    return l_clan_info
end

-------------------------------------
-- function getClanWarLeagueAllRankList
-- @brief 랭킹 정보
-------------------------------------
function StructClanWarLeague:getClanWarLeagueAllRankList()
	local t_clan_info = self.m_tClanInfo    
    local t_rank_clan_info = {}
	for _, data in pairs(t_clan_info) do
		local league = StructClanWarLeague.getLeague(data)
		if (not t_rank_clan_info[league]) then
			t_rank_clan_info[league] = {}
		end

		if (data['clan_info']) then
			table.insert(t_rank_clan_info[league], data)
		end
	end

    
    local sort_func = function(a, b)
        local rank_a = a['league_info']['rank']
        local rank_b = b['league_info']['rank']
        
        return rank_a < rank_b
    end

	for _, l_data in pairs(t_rank_clan_info) do
		table.sort(l_data, sort_func)
	end

    return t_rank_clan_info
end

-------------------------------------
-- function getClanInfo_byGroupNumber
-------------------------------------
function StructClanWarLeague:getClanInfo_byGroupNumber(group_number)
    for _, data in pairs(self.m_tClanInfo) do
        if (group_number == data['league_info']['group_no']) then
            return data
        end
    end
end

-------------------------------------
-- function getMyClanTeamNumber
-------------------------------------
function StructClanWarLeague:getMyClanTeamNumber()
    if (not self.m_nMyClanId) then
        return
    end
    local data = self.m_tClanInfo[self.m_nMyClanId]

    return StructClanWarLeague.getLeague(data)
end

-------------------------------------
-- function isWin
-- @return A가 B를 이겼다면 return true
-------------------------------------
function StructClanWarLeague:isWin(a, b)
    local league_info_a = StructClanWarLeague.getLeagueInfo(a)
    local history_str = league_info_a['history']

    if (not history_str) then
        return -1
    end

    local league_info_b = StructClanWarLeague.getLeagueInfo(b)
    local b_number = league_info_b['group_no']

    local l_history = pl.stringx.split(history_str, ';')
    for i, result_str in ipairs(l_history) do
        l_data = pl.stringx.split(result_str, ',')
        local memeber = l_data[1]
        if (tostring(memeber) == tostring(b_number)) then
            if (l_data[2] == '1') then
                return 1
            else
                return 0
            end
        end 
    end

    return -1
end

-------------------------------------
-- function getWinCount
-------------------------------------
function StructClanWarLeague.getWinCount(data)
    local t_league = StructClanWarLeague.getLeagueInfo(data)
    return t_league['win_cnt'] or 0
end

-------------------------------------
-- function getLoseCount
-------------------------------------
function StructClanWarLeague.getLoseCount(data)
    local t_league = StructClanWarLeague.getLeagueInfo(data)
    return t_league['lose_cnt'] or 0
end

-------------------------------------
-- function getClanWarRank
-------------------------------------
function StructClanWarLeague.getClanWarRank(data)
    local t_league = StructClanWarLeague.getLeagueInfo(data)
    if (t_league['rank'] == 0) then
        return '-'
    end
    return tostring(t_league['rank']) or '-'
end

-------------------------------------
-- function getTotalWinCount
-------------------------------------
function StructClanWarLeague.getTotalWinCount(data)
    local t_league = StructClanWarLeague.getLeagueInfo(data)
    return tostring(t_league['total_win_cnt']) or '-'
end

-------------------------------------
-- function getTotalLoseCount
-------------------------------------
function StructClanWarLeague.getTotalLoseCount(data)
    local t_league = StructClanWarLeague.getLeagueInfo(data)
	local win_cnt = StructClanWarLeague.getWinCount(data)
	local total_cnt = tonumber(t_league['total_score']) or 0
    return total_cnt - win_cnt
end

-------------------------------------
-- function getLeagueInfo
-------------------------------------
function StructClanWarLeague.getLeagueInfo(data)
    if (not data) then
        return
    end

    if (not data['league_info']) then
        return
    end

    return data['league_info']
end

-------------------------------------
-- function getLeague
-------------------------------------
function StructClanWarLeague.getLeague(data)
    local t_league = StructClanWarLeague.getLeagueInfo(data)
	if (not t_league) then
		return
	end

	return t_league['league']
end

-------------------------------------
-- function getClanInfo
-------------------------------------
function StructClanWarLeague.getClanInfo(data)
    if (not data) then
        return
    end

    if (not data['clan_info']) then
        return
    end

    return data['clan_info']
end

-------------------------------------
-- function getClanId_byData
-------------------------------------
function StructClanWarLeague.getClanId_byData(data)
    if (not data) then
        return
    end

    if (not data['league_info']) then
        return
    end

    if (not data['league_info']['clan_id']) then
        return
    end

    return data['league_info']['clan_id']
end

-------------------------------------
-- function getGroupNumber_byData
-------------------------------------
function StructClanWarLeague.getGroupNumber_byData(data)
    if (not data) then
        return
    end

    if (not data['league_info']) then
        return
    end

    if (not data['league_info']['clan_id']) then
        return
    end

    return data['league_info']['group_no']
end

-------------------------------------
-- function getMyClanInfo
-------------------------------------
function StructClanWarLeague:getMyClanInfo()
    local t_clan_info = self.m_tClanInfo   
    if (not t_clan_info) then
        return
    end

    if (not self.m_nMyClanId) then
        return
    end

    local data = self.m_tClanInfo[self.m_nMyClanId]
    local l_match = self:getClanWarLeagueList(self.m_matchDay)
    local is_left = nil
    local match_idx = 1
    for idx, data in ipairs(l_match) do
        if (data['clan1']['league_info']['clan_id'] == self.m_nMyClanId) then
            is_left = 1
            match_idx = idx
        end
        
        if (data['clan2']['league_info']['clan_id'] == self.m_nMyClanId) then
            is_left = 2
            match_idx = idx
        end
    end

    if (not is_left) then
        return nil
    end

    local league = StructClanWarLeague.getLeague(data)
    local match = match_idx
    local is_left = is_left

    return league, match, is_left
end

-------------------------------------
-- function getTotalScore
-------------------------------------
function StructClanWarLeague:getTotalScore(clan_id)
    local t_clan_info = self.m_tClanInfo   
    if (not t_clan_info) then
        return
    end

    local data = self.m_tClanInfo[clan_id]
    if (not data) then
        return
    end

    local win_score = 0
    local lose_score = 0

    for i = 1, 5 do
        local l_match = self:getClanWarLeagueList(i)
        for idx, data in ipairs(l_match) do
            if (data['clan1']['league_info']['clan_id'] == clan_id) then
                local data_1 = data['clan1']
                local win, lose = StructClanWarLeague.getScoreHistoryNumber(data_1)
                if (win) then
                    win_score = win_score + win
                    lose_score = lose_score + lose
                end
            end

            if (data['clan2']['league_info']['clan_id'] == clan_id) then
                local data_2 = data['clan2']
                local win, lose = StructClanWarLeague.getScoreHistoryNumber(data_2)
                if (win) then
                    win_score = win_score + win
                    lose_score = lose_score + lose
                end
            end
            
        end
    end

    return win_score, lose_score
end

-------------------------------------
-- function getScoreHistoryNumber
-------------------------------------
function StructClanWarLeague.getScoreHistoryNumber(data)
    if (not data) then
        return
    end

    if (not data['league_info']) then
        return
    end
    local set_score_str = data['league_info']['score_history'] or ''
    
    local is_list = string.find(set_score_str, ';')
    if (is_list) then
        local l_list = pl.stringx.split(set_score_str, ';')
        set_score_str = l_list[1]
    end

    local l_score = pl.stringx.split(set_score_str, '-')
    local win_score = tonumber(l_score[1]) or 0
    local lose_score = tonumber(l_score[2]) or 0
    
    return win_score, lose_score
end