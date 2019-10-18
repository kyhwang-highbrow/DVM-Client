
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
                    ['league']=1;
                    ['clan_id']='5a02e73b019add152c890157';
                    ['group_no']=1;
                    }
                ['clan_info'] = StructClanRank()
            }
    --]]
    m_nMyClanTeam = 'number', -- n조
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

    self.m_clanCnt = #l_league_info

    -- 클랜 정보
    local l_clan_info = data['clan_info']
	if (not l_clan_info) then
		return
	end

	for _, t_clan in ipairs(l_clan_info) do
        local struct_clan_rank = StructClanRank(t_clan)
        local clan_id = struct_clan_rank:getClanObjectID()
        self.m_tClanInfo[clan_id]['clan_info'] = struct_clan_rank
    end
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
        local struct_clan_rank = a['clan_info']
        local a_score = 0
        if (struct_clan_rank) then
            a_score = struct_clan_rank:getClanScore_number()
        end

        local struct_clan_rank = b['clan_info']
        local b_score = 0
        if (struct_clan_rank) then
            b_score = struct_clan_rank:getClanScore_number()
        end

        return a_score < b_score
    end

    table.sort(l_clan_info, sort_func)

    return l_clan_info
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
-- function getMyClanTeam
-------------------------------------
function StructClanWarLeague:getMyClanTeam()
    return self.m_nMyClanTeam
end

-------------------------------------
-- function getMyClanTeamNumber
-------------------------------------
function StructClanWarLeague:getMyClanTeamNumber()
    return self.m_nMyClanTeam or 1
end

-------------------------------------
-- function isWin
-- @return A가 B를 이겼다면 return true
-------------------------------------189
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