local PARENT = Structure

-------------------------------------
-- class StructClanWarLeagueItem
-------------------------------------
StructClanWarLeagueItem = class(PARENT, {
	id = 'string',
    season = 'number',
    league = 'number',
    group_no = 'number',
    clan_id = 'string',
    win_cnt = 'number',
    lose_cnt = 'number',
    game_win = 'number',
    game_lose = 'number',
    member_win_cnt = 'number',
    rank = 'number',
    play_member_cnt = 'number',
    day = 'number',

    -- 서버에서 받는 값이 아니라 중간에 가공하는 값
    total_win_cnt = 'number'
})

local THIS = StructClanWarLeagueItem

-------------------------------------
-- function getClassName
-------------------------------------
function StructClanWarLeagueItem:getClassName()
    return 'StructClanWarLeagueItem'
end

-------------------------------------
-- function getDay
-------------------------------------
function StructClanWarLeagueItem:getDay()
    return tonumber(self['day']) or 0
end

-------------------------------------
-- function getThis
-------------------------------------
function StructClanWarLeagueItem:getThis()
    return THIS
end

-------------------------------------
-- function getLeagueRank
-------------------------------------
function StructClanWarLeagueItem:getLeagueRank()
	return tonumber(self['rank']) or 0
end

-------------------------------------
-- function getMatchNumber
-------------------------------------
function StructClanWarLeagueItem:getMatchNumber()
	return tonumber(self['match_no']) or 0
end

-------------------------------------
-- function getLeague
-------------------------------------
function StructClanWarLeagueItem:getLeague()
	return tonumber(self['league']) or 0
end

-------------------------------------
-- function getGroupNumber
-------------------------------------
function StructClanWarLeagueItem:getGroupNumber()
	return tonumber(self['group_no']) or 0
end

-------------------------------------
-- function getPlayMemberCnt
-------------------------------------
function StructClanWarLeagueItem:getPlayMemberCnt()
	return tonumber(self['play_member_cnt']) or 0
end

-------------------------------------
-- function getWinCount
-------------------------------------
function StructClanWarLeagueItem:getWinCount()
	return tonumber(self['win_cnt']) or 0
end

-------------------------------------
-- function getLoseCount
-------------------------------------
function StructClanWarLeagueItem:getLoseCount()
	return tonumber(self['lose_cnt']) or 0
end

-------------------------------------
-- function getClanWarRankText
-------------------------------------
function StructClanWarLeagueItem:getClanWarRankText()
    local rank = self:getLeagueRank()

    if (rank <= 0) then
        return '-'
    end
    return Str('{1}위', rank)
end

-------------------------------------
-- function getTotalWinCount
-------------------------------------
function StructClanWarLeagueItem:getTotalWinCount()
end

-------------------------------------
-- function getTotalGameCount
-------------------------------------
function StructClanWarLeagueItem:getTotalGameCount()
end

-------------------------------------
-- function getClanId
-------------------------------------
function StructClanWarLeagueItem:getClanId()
	return tostring(self['clan_id'])
end

-------------------------------------
-- function getSetScore
-- @brief 승리한 세트 수 (누적)
-------------------------------------
function StructClanWarLeagueItem:getSetScore()
	return tonumber(self['member_win_cnt'])
end

-------------------------------------
-- function getMemberWinCnt
-------------------------------------
function StructClanWarLeagueItem:getMemberWinCnt()
	return tonumber(self['member_win_cnt'])
end

-------------------------------------
-- function getGameWin
-------------------------------------
function StructClanWarLeagueItem:getGameWin()
	return tonumber(self['game_win'])
end

-------------------------------------
-- function getGameLose
-------------------------------------
function StructClanWarLeagueItem:getGameLose()
	return tonumber(self['game_lose'])
end

-------------------------------------
-- function isGoastClan
-------------------------------------
function StructClanWarLeagueItem:isGoastClan()
    local clan_id = self:getClanId()
    if (clan_id == 'loser') then
        return true
    end

    if (not clan_id) then
        return true
    end

    return false
end