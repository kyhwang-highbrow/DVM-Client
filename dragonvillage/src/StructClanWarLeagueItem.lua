
-------------------------------------
-- class StructClanWarLeagueItem
-------------------------------------
StructClanWarLeagueItem = class({
	league_info = 'table',
    clan_info = 'table',
    --[[
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

	-- 편의를 위하여 동적으로 할당되는 값
	-- 랭킹 테이블 뷰 만들 때에만 사용
	total_score_win = 'number',
	total_score_lose = 'number',
	my_clan_id = 'number',
})

-------------------------------------
-- function setLeagueInfo
-------------------------------------
function StructClanWarLeagueItem:setLeagueInfo(data)
	self['league_info'] = data
end

-------------------------------------
-- function getLeagueInfo
-------------------------------------
function StructClanWarLeagueItem:getLeagueInfo(data)
	if (not self['league_info']) then
		return {}
	end

	return self['league_info']
end

-------------------------------------
-- function setLeaguInfo
-------------------------------------
function StructClanWarLeagueItem:getLeagueRank()
	local league_info = self:getLeagueInfo()
	
	if (not league_info['rank']) then
		return 999
	end

	return tonumber(league_info['rank'])
end

-------------------------------------
-- function getLeague
-------------------------------------
function StructClanWarLeagueItem:getLeague()
	local league_info = self:getLeagueInfo()
	
	if (not league_info['league']) then
		return 0
	end

	return tonumber(league_info['league'])
end

-------------------------------------
-- function getGroupNumber
-------------------------------------
function StructClanWarLeagueItem:getGroupNumber()
	local league_info = self:getLeagueInfo()
	
	if (not league_info['group_no']) then
		return 0
	end

	return tonumber(league_info['group_no'])
end

-------------------------------------
-- function getPlayMemberCnt
-------------------------------------
function StructClanWarLeagueItem:getPlayMemberCnt()
	local league_info = self:getLeagueInfo()
	
	if (not league_info['play_member_cnt']) then
		return 0
	end

	return tostring(league_info['play_member_cnt']) or '-'
end

-------------------------------------
-- function getWinCount
-------------------------------------
function StructClanWarLeagueItem:getWinCount()
	local league_info = self:getLeagueInfo()
	
	if (not league_info['win_cnt']) then
		return 0
	end

	return tonumber(league_info['win_cnt'])
end

-------------------------------------
-- function getLoseCount
-------------------------------------
function StructClanWarLeagueItem:getLoseCount()
	local league_info = self:getLeagueInfo()
	
	if (not league_info['lose_cnt']) then
		return 0
	end

	return tonumber(league_info['lose_cnt'])
end

-------------------------------------
-- function getClanWarRankText
-------------------------------------
function StructClanWarLeagueItem:getClanWarRankText()
    local t_league = self:getLeagueInfo()
    if (t_league['rank'] == 0) then
        return '-'
    end
    return tostring(Str('{1}위', t_league['rank'])) or '-'
end

-------------------------------------
-- function getTotalWinCount
-------------------------------------
function StructClanWarLeagueItem:getTotalWinCount()
	local league_info = self:getLeagueInfo()
	
	if (not league_info['game_win']) then
		return '-'
	end

	return tostring(league_info['game_win']) or '-'
end

-------------------------------------
-- function setClanInfo
-------------------------------------
function StructClanWarLeagueItem:setClanInfo(data)
	self['clan_info'] = StructClanRank(data)
end

-------------------------------------
-- function setCLanInfo
-------------------------------------
function StructClanWarLeagueItem:getClanInfo()
	if (not self['clan_info']) then
		return
	end
	
	return self['clan_info'] -- StructClanRank
end

-------------------------------------
-- function getClanId
-------------------------------------
function StructClanWarLeagueItem:getClanId()
	local league_info = self:getLeagueInfo()
	
	if (not league_info['clan_id']) then
		return
	end

	return tostring(league_info['clan_id'])
end

-------------------------------------
-- function getClanWarDayInfo
-------------------------------------
function StructClanWarLeagueItem:getClanWarDayInfo()
    local league_info = self:getLeagueInfo()
	
	if (not league_info['clanwarDayInfo']) then
		return {}
	end

    --[[
     [2] = {
            ["win"] = "23",
            ["isWin"] = "1",
            ["score"] = "1-1"
        },
    --]]
    return league_info['clanwarDayInfo'] or {}
end

-------------------------------------
-- function getMatchWinCnt
-------------------------------------
function StructClanWarLeagueItem:getMatchWinCnt(day)
    local t_clanwar_day = self:getClanWarDayInfo()
    -- 해당 경기의 정보
    -- 없다면 아직 진행되지 않은 경기
    local t_data = t_clanwar_day[tostring(day)]
    if (not t_data) or (t_data == {}) then
        return 0
    end

    local score = t_data['win']
    return tonumber(score) or 0
end

-------------------------------------
-- function isMatchWin
-------------------------------------
function StructClanWarLeagueItem:isMatchWin(day)
    local t_clanwar_day = self:getClanWarDayInfo()

    -- 해당 경기의 정보
    -- 없다면 아직 진행되지 않은 경기
    local t_data = t_clanwar_day[tostring(day)]
    if (not t_data) or (t_data == {}) then
        return false
    end

    local is_win = t_data['isWin']
    return (is_win == '1')
end

-------------------------------------
-- function StructClanWarLeagueItem
-------------------------------------
function StructClanWarLeagueItem:getMatchSetScore(day)
    local t_clanwar_day = self:getClanWarDayInfo()

    -- 해당 경기의 정보
    -- 없다면 아직 진행되지 않은 경기
    local t_data = t_clanwar_day[tostring(day)]
    if (not t_data) or (t_data == {}) then
        return 0, 0
    end

    local score_str = t_data['score'] or ''
    local l_score = pl.stringx.split(score_str, '-')
    local win, lose = l_score[1], l_score[2]
    return tonumber(win) or 0, tonumber(lose) or 0
end
