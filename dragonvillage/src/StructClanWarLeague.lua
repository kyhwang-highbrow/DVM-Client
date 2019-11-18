
-------------------------------------
-- class StructClanWarLeague
-------------------------------------
StructClanWarLeague = class({
	m_tClanInfo = 'list',
    --[[
       ['clan_id'] = {
                StructClanWarLeagueItem()
            }
    --]]
	m_matchDay = 'numnber',
	m_tDate = 'table',
	--[[
	"clan_data":{
		"table":{
			"server":"dev",
			"day_9":1,
			"id":100001,
			"day_14":"",
			"day_3":1,
			"group_clan":6,
	--]]
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
            self.m_tClanInfo[clan_id] = StructClanWarLeagueItem()
		    self.m_tClanInfo[clan_id]:setLeagueInfo(t_clan)
	    end
    end

    -- 클랜 정보
    local l_clan_info = data['league_clan_info']
	if (not l_clan_info) then
		return
	end

	for _, t_clan in ipairs(l_clan_info) do
        local struct_clan_rank = StructClanRank(t_clan)
        local clan_id = struct_clan_rank:getClanObjectID()
        if (clan_id) then
            self.m_tClanInfo[clan_id]:setClanInfo(t_clan)
        end
    end

	self.m_matchDay = data['clanwar_day']

	self.m_tDate = data['clan_data']
end

-------------------------------------
-- function getClanWarLeagueList
-- @brief 날짜별 진행되는 경기 정보
-------------------------------------
function StructClanWarLeague:getClanWarLeagueList(day) -- 1일차 2일차 등등...
	local l_match = {}
    local day = day or 1

    local l_group = self:getMatchGroup(day) -- 1;2,3;4 .. 1그룹;2그룹, 3그룹, 4그룹 ..
	for _, data in ipairs(l_group) do
        local l_group = pl.stringx.split(data, ';')
        if (l_group) then
            local group_number_1 = tonumber(l_group[1])
            local struct_league_item_1 = self:getClanInfo_byGroupNumber(group_number_1)
            local group_number_2 = tonumber(l_group[2])
            local struct_league_item_2 = self:getClanInfo_byGroupNumber(group_number_2)
            local t_match = {}
            t_match['clan1'] = struct_league_item_1 or {}
            t_match['clan2'] = struct_league_item_2 or {}
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
				-- 1일차에 1,2그룹, 3,4, 5,6 그룹 붙는다
                ['day']=1;
                ['group_2']='1;2';
                ['group_3']='3;4';
                ['group_1']='5;6';
        };
        {
                ['day']=2;
                ['group_2']='1;2';
                ['group_3']='3;4';
                ['group_1']='5;6';
        };
        {
    --]]

    day = tonumber(day)
    local table_clanwar_group = TABLE:get('table_clanwar_group')
    local clan_cnt = g_clanWarData:getGroupCnt()
    local l_match = {}
    for group_idx = 1, 3 do
        local idx = clan_cnt * 10 + day + 100000 -- 테이블 인덱스
        t_clanwar_group = table_clanwar_group[idx]
        if (t_clanwar_group) then
            local str_group = t_clanwar_group['group_' .. group_idx] -- '1;2'
            if (str_group) and (str_group ~= '') then
                table.insert(l_match, str_group)
            end
        end
    end

    --[[
        -- @OUTPUT
        {'1;2', '3;4', '5;6'}
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
    
	-- 클랜정보가 없는 클랜은 유령클랜으로, 리스트에서 제거
    for idx, struct_league_item in ipairs(l_clan_info) do
        local clan_info = struct_league_item:getClanInfo()
		if (not clan_info) then
            table.remove(l_clan_info, idx)
        elseif (clan_info['id'] == 'loser') then
            table.remove(l_clan_info, idx)
        end
    end
    
	-- 랭킹 순으로 정렬
    local sort_func = function(a, b)
        local rank_a = a:getLeagueRank()
        local rank_b = b:getLeagueRank()
        
        return rank_a < rank_b
    end

    table.sort(l_clan_info, sort_func)

    return l_clan_info
end

-------------------------------------
-- function getClanWarLeagueAllRankList
-- @brief 전체 랭킹 정보
-------------------------------------
function StructClanWarLeague:getClanWarLeagueAllRankList()
	local t_clan_info = self.m_tClanInfo    
    local t_rank_clan_info = {}

	-- 전체 랭킹 출력하기 위해서
	-- 각 조 이름을 key로 만든 맵으로 변환
	for _, struct_league_item in pairs(t_clan_info) do
		local league = struct_league_item:getLeague()
		if (not t_rank_clan_info[league]) then
			t_rank_clan_info[league] = {}
		end

		local clan_info = struct_league_item:getClanInfo()
		if (clan_info) then
			table.insert(t_rank_clan_info[league], struct_league_item)
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

-------------------------------------
-- function getClanInfo_byGroupNumber
-- @brief 하루에 한 조에서 1;2랑 붙는 경우 1 = group_number, 2 = group_number
-------------------------------------
function StructClanWarLeague:getClanInfo_byGroupNumber(group_number)
    for _, struct_league_item in pairs(self.m_tClanInfo) do
        if (group_number == struct_league_item:getGroupNumber()) then
            return struct_league_item
        end
    end
end

-------------------------------------
-- function getMyClanTeamNumber
-- @brief 서버에서 league로 오는 값이 사실상 teamNumber
-------------------------------------
function StructClanWarLeague:getMyClanTeamNumber()
    local my_clan_id = g_clanWarData:getMyClanId()

    if (not my_clan_id) then
        return 0
    end
    local struct_league_item = self.m_tClanInfo[my_clan_id]

    if (not struct_league_item) then
        return 0
    end
    return struct_league_item:getLeague()
end

-------------------------------------
-- function getMyClanInfo
-- @brief 내 클랜이 A인지 B인지 판별
-------------------------------------
function StructClanWarLeague:getMyClanInfo(day)
    local t_clan_info = self.m_tClanInfo   
    if (not t_clan_info) then
        return
    end

    local my_clan_id = g_clanWarData:getMyClanId()
    if (not my_clan_id) then
        return
    end

    local struct_league_item = self.m_tClanInfo[my_clan_id]
    local my_group_no = struct_league_item:getGroupNumber()
    local is_left = nil
    local match_idx = 1
    local l_group = self:getMatchGroup(tonumber(day))
    local enemy_group_no

	-- 1;2, 2;3 ... 조 매치 정보 가져와서 자신의 조가 A인지 B인지 판별
	for idx, data in ipairs(l_group) do
        local l_group = pl.stringx.split(data, ';')
        if (l_group) then
            local group_number_left = tonumber(l_group[1])
            if (group_number_left == my_group_no) then
                is_left = 1
                enemy_group_no = tonumber(l_group[2])
                match_idx = idx
                break
            end
            local group_number_right = tonumber(l_group[2])
            if (group_number_right == my_group_no) then
                is_left = 2
                match_idx = idx
                enemy_group_no = tonumber(l_group[1])
                break
            end
        end
    end

    if (is_left == nil) then
        return nil
    end

    local league = struct_league_item:getLeague()
    local match = match_idx
    local is_left = is_left

    return league, match, is_left, enemy_group_no
end

-------------------------------------
-- function getTotalScore
-------------------------------------
function StructClanWarLeague:getTotalScore(clan_id)
    local t_clan_info = self.m_tClanInfo   
    if (not t_clan_info) then
        return
    end

    local struct_league_item = self.m_tClanInfo[clan_id]
    if (not struct_league_item) then
        return
    end

    local total_win_score = 0
    local total_lose_score = 0
    for day = 1, 5 do
        local win, lose = struct_league_item:getMatchSetScore(day)
        total_win_score = total_win_score + win
        total_lose_score = total_lose_score + lose
    end
    

    return total_win_score, total_lose_score
end

-------------------------------------
-- function getWinCnt
-------------------------------------
function StructClanWarLeague:getTotalWinCount(clan_id)
    local t_clan_info = self.m_tClanInfo   
    if (not t_clan_info) then
        return
    end

    local struct_league_item = self.m_tClanInfo[clan_id]
    if (not struct_league_item) then
        return
    end

    return struct_league_item:getTotalWinCount() or 0
end

-------------------------------------
-- function isContainClan
-------------------------------------
function StructClanWarLeague:isContainClan(clan_id)
    return self.m_tClanInfo[clan_id]
end

-------------------------------------
-- function getEntireGroupCnt
-------------------------------------
function StructClanWarLeague:getGroupCnt()
   return g_clanWarData:getGroupCnt()
end

-------------------------------------
-- function getMyClanMatchScore
-------------------------------------
function StructClanWarLeague:getMyClanMatchScore(_day)
    local day = _day or self.m_matchDay 

    local league, match, is_left, enemy_group_no = self:getMyClanInfo(day)
    local my_clan_id = g_clanWarData:getMyClanId() 
    local enemy_struct_league_item = self:getClanInfo_byGroupNumber(enemy_group_no)
    local my_struct_league_item = self.m_tClanInfo[my_clan_id]

    local my_win_cnt = 0
    local enemy_win_cnt = 0
    if (my_struct_league_item) then
        my_win_cnt = my_struct_league_item:getMatchWinCnt(day)
    end

    if (enemy_struct_league_item) then
        enemy_win_cnt = enemy_struct_league_item:getMatchWinCnt(day)
    end
    return my_win_cnt, enemy_win_cnt
end

-------------------------------------
-- function getMyLeagueRank
-------------------------------------
function StructClanWarLeague:getMyLeagueRank()
    local l_rank = self:getClanWarLeagueRankList()
    for _, struct_league_item in ipairs(l_rank) do
       local my_clan_id = g_clanWarData:getMyClanId()
       local clan_id = struct_league_item:getClanId()
       if (my_clan_id == clan_id) then
            my_struct_league_item = struct_league_item
			my_rank = struct_league_item:getLeagueRank()
            break
       end
    end

    return my_rank or 0
end