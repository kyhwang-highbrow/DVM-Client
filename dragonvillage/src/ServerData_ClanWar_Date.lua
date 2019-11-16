-------------------------------------
-- function getClanWarState
-------------------------------------
function ServerData_ClanWar:getClanWarState()
	local cur_time = Timer:getServerTime_Milliseconds()
	local state
	
	-- ??뽰サ???ル굝利?怨밴묶?硫? (??뽰삂 ?醫롮?揶쎛 沃섎챶??硫?)
	if (cur_time < self.season_start_time) then
		return ServerData_ClanWar.CLANWAR_STATE['DONE']
	end

	-- ??議?遺? (?癒?젟?봔???袁⑸쵟繹먮슣? 野껊슣????? ??놁벉(?類ㅺ텦 疫꿸퀗而?)
	if (self.open) then
		return ServerData_ClanWar.CLANWAR_STATE['OPEN']
	else
		return ServerData_ClanWar.CLANWAR_STATE['BREAK']
	end
end

-------------------------------------
-- function getRemainSeasonTime
-- @brief ??쇱벉 ??뽰サ繹먮슣? ??? ??볦퍢
-------------------------------------
function ServerData_ClanWar:getRemainSeasonTime()
	local cur_time = Timer:getServerTime_Milliseconds()
	local remain_time = self.season_start_time - cur_time

	if (remain_time < 0) then
		remain_time = 1
	end
	return datetime.makeTimeDesc(remain_time/1000)
end

-------------------------------------
-- function getRemainGameTime
-- @brief ??멸돌疫?繹먮슣? ??? ??볦퍢
-------------------------------------
function ServerData_ClanWar:getRemainGameTime()
	local cur_time = Timer:getServerTime_Milliseconds()
	local remain_time = self.today_end_time - cur_time

	if (remain_time < 0) then
		remain_time = 1
	end
	return datetime.makeTimeDesc(remain_time/1000)
end

-------------------------------------
-- function getRemainStartGameTime
-- @brief ??뽰삂??띾┛繹먮슣? ??? ??볦퍢
-------------------------------------
function ServerData_ClanWar:getRemainStartGameTime()
	local cur_time = Timer:getServerTime_Milliseconds()
	local remain_time = self.today_start_time - cur_time
	
	if (remain_time < 0) then
		remain_time = 0
	end	
	return datetime.makeTimeDesc(remain_time/1000)
end

-------------------------------------
-- function checkClanWarState
-------------------------------------
function ServerData_ClanWar:checkClanWarState()
	local clanwar_state = g_clanWarData:getClanWarState()
	local msg = ''
	if (clanwar_state == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
		return true, msg
	end
end

-------------------------------------
-- function checkClanWarState_Tournament
-------------------------------------
function ServerData_ClanWar:checkClanWarState_Tournament()
	local is_open, msg = self:checkClanWarState()

	if (is_open) then
		return true, msg
	end

	if (self.m_clanWarDay == 14) then
		local remain_time = g_clanWarData:getRemainSeasonTime()
		msg = Str('클랜전 시즌이 종료되었습니다.') .. Str('다음 클랜전까지 {1} 남음', g_clanWarData:getRemainSeasonTime()) -- 14일째 시즌 시자가 시간이 이상하게 내려온다
		return false, msg
	end

	-- 토너먼트 진행 안 하는 날
	if (not g_clanWarData:isMatchDay(self.m_clanWarDay)) then
		local round = g_clanWarData:getTodayRound(1)
		-- 일본 서버의 경우 이틀 뒤 시작한다
		if (not g_clanWarData:isMatchDay(self.m_clanWarDay+1)) then
			cclog(g_clanWarData:isMatchDay(self.m_clanWarDay+1), self.m_clanWarDay+1)
			round = g_clanWarData:getTodayRound(2)
		end
		
		local game_name = Str('토너먼트') .. ' ' .. Str('{1}강', round)
		msg = Str('{@YELLOW}{1} 준비중 {@GREEN}{2} 남음', game_name, g_clanWarData:getRemainStartGameTime())
		return false, msg
	end

	-- 자정 ~ 10시
	local clanwar_state = g_clanWarData:getClanWarState()
	if (clanwar_state == ServerData_ClanWar.CLANWAR_STATE['BREAK']) then
		local round = g_clanWarData:getTodayRound()
		local game_name = Str('토너먼트') .. ' ' .. Str('{1}강', round)
		msg = Str('{1} 준비중 {2} 남음', game_name, g_clanWarData:getRemainStartGameTime())
		return false, msg
	end

	return false, ''
end

-------------------------------------
-- function checkClanWarState_League
-------------------------------------
function ServerData_ClanWar:checkClanWarState_League()
	local is_open, msg = self:checkClanWarState()

	if (is_open) then
		return true, ''
	end
	
	if (not g_clanWarData:isMatchDay()) then
		msg = Str('전투 시간이 아닙니다.')
	end

	local clanwar_state = g_clanWarData:getClanWarState()
	local cur_time = Timer:getServerTime()
	local date = pl.Date()
	date:set(cur_time)
	local hour = date:hour()
	if (self.m_clanWarDay == 1) and (hour < 10) then
		msg = Str('클랜전 시즌이 종료되었습니다.') .. ' ' .. Str('다음 클랜전까지 {1} 남음', g_clanWarData:getRemainSeasonTime())
		return false, msg
	elseif (self.m_clanWarDay == 1) and (hour >= 10) then
		msg = Str('조별리그를 준비중입니다.') .. ' ' .. Str('다음 전투까지 {1} 남음', g_clanWarData:getRemainStartGameTime())
		return false, msg	
	end

	if (self.m_clanWarDay == 7) then
		msg = Str('조별리그가 종료 되었습니다.') .. ' ' .. Str('토너먼트 시작까지 {1} 남음', g_clanWarData:getRemainStartGameTime())	
		return false, msg
	end
	
	if (clanwar_state == ServerData_ClanWar.CLANWAR_STATE['BREAK']) then
		msg = Str('전투 시간이 아닙니다.')
		return false, msg
	end

	return false, ''
end

-------------------------------------
-- function getCurStateText_League
-------------------------------------
function ServerData_ClanWar:getCurStateText_League()
	local open, msg = g_clanWarData:checkClanWarState()
	if (not open) then
		return g_clanWarData:checkClanWarState_League()
	end
	
	local match_day = g_clanWarData.m_clanWarDay
	local l_list = g_clanWarData:getVaildDate()
	local cur_match_day = g_clanWarData.m_clanWarDay
	local match_cnt = 1
	for i, match_day in ipairs(l_list) do
		if (match_day == cur_match_day) then
			match_cnt = i
		end
	end
	local game_name = Str('조별리그') .. ' ' .. Str('{1}차 경기', match_cnt)
	msg = Str('{1} 진행중 {2} 남음', game_name, 0)
	return open, msg
end

-------------------------------------
-- function getCurStateText_Tournament
-------------------------------------
function ServerData_ClanWar:getCurStateText_Tournament()
	local open, msg = g_clanWarData:checkClanWarState()
	if (not open) then
		return g_clanWarData:checkClanWarState_Tournament()
	end

	local today_round = g_clanWarData:getTodayRound()
	local game_name = Str('토너먼트') .. ' ' .. Str('{1}강', today_round)
	msg = Str('{1} 진행중 {2} 남음', game_name, g_clanWarData:getRemainTimeForGameEnd())
	return open, msg
end

-------------------------------------
-- function getRemainTimeForNextGame
-------------------------------------
function ServerData_ClanWar:getRemainTimeForNextGame()
	--[[
	-- 클라에서 노가다로 계산한 것
	local cur_match_day = g_clanWarData.m_clanWarDay
	local l_day = g_clanWarData:getVaildDate()

	local match_start_day = 0
	for i = cur_match_day, 14 do
		if (g_clanWarData:isMatchDay(i)) then
			break
		else
			match_start_day = match_start_day + 1
		end
	end

	local cur_time = Timer:getServerTime()
	local date = pl.Date()
	date:set(cur_time)
	date:hour(10)
	local time = date['time']
	local remain_time = 0
	if (time) then
		return datetime.makeTimeDesc(time - cur_time)
	else
		return '-'
	end
	--]]
end

-------------------------------------
-- function getRemainTimeForGameEnd
-------------------------------------
function ServerData_ClanWar:getRemainTimeForGameEnd()
	
	local cur_match_day = g_clanWarData.m_clanWarDay
	local l_day = g_clanWarData:getVaildDate()

	local match_start_day = 0
	for i = cur_match_day, 14 do
		if (g_clanWarData:isMatchDay(i)) then
			break
		else
			match_start_day = match_start_day + 1
		end
	end

	local cur_time = Timer:getServerTime()
	local date = pl.Date()
	date:set(cur_time)
	date:hour(12)
	local time = date['time']
	local remain_time = 0
	if (time) then
		return datetime.makeTimeDesc(time - cur_time)
	else
		return '-'
	end
end

-------------------------------------
-- function getIsLeague
-- @brief 조별리그 기간인지, 토너먼트 기간인지
-------------------------------------
function ServerData_ClanWar:getIsLeague(is_league)
	self.m_isLeague = is_league
end

-------------------------------------
-- function setIsLeague
-- @brief 조별리그 기간인지, 토너먼트 기간인지
-------------------------------------
function ServerData_ClanWar:setIsLeague()
	return self.m_isLeague
end

-------------------------------------
-- function getVaildDate
-- @brief 경기를 하는 날 리스트
-------------------------------------
function ServerData_ClanWar:getVaildDate()
	local data = self.m_clanWarDayData
	if (not self.m_clanWarDayData) then
		return {}
	end

	if (not self.m_clanWarDayData['table']) then
		return {}
	end

	local t_day = self.m_clanWarDayData['table']
	local l_valid_day = {}
	for i = 1, 14 do
		key = 'day_' .. i
		if (t_day[key] == 1) then
			table.insert(l_valid_day, i)
		end
	end

	return l_valid_day
end


-------------------------------------
-- function getGroupCnt
-- @brief 한 그룹에 클랜 몇 개씩 있는지
-------------------------------------
function ServerData_ClanWar:getGroupCnt()
    if (not self.m_clanWarDayData) then
		return 0
	end    
	
	if (not self.m_clanWarDayData['table']) then
		return 0
	end

	return self.m_clanWarDayData['table']['group_clan'] or 0
end

-------------------------------------
-- function getEntireGroupCnt
-------------------------------------
function ServerData_ClanWar:getEntireGroupCnt()
    if (not self.m_clanWarDayData) then
		return 0
	end    
	
	if (not self.m_clanWarDayData['table']) then
		return 0
	end

	return self.m_clanWarDayData['table']['group'] or 0
end

-------------------------------------
-- function applyClanWarInfo
-------------------------------------
function ServerData_ClanWar:applyClanWarInfo(ret)
    if (ret['my_match_info']) then
        self.m_myMatchInfo = StructClanWarMatchItem(ret['my_match_info'])
    else
        self.m_myMatchInfo = nil
    end

    if (ret['today_end_time']) then
        self.today_end_time = ret['today_end_time']      -- 24:00
    end

    if (ret['open']) then
        self.open = ret['open']      -- 10:00 ~ 24:00
    else
		self.open = false
	end

    if (ret['season_start_time']) then
        self.season_start_time = ret['season_start_time']      -- ?袁⑹삺癰귣????臾믪몵筌???뽰サ 筌욊쑵六얌빳? ??????뽰サ ??뽰삂??
    end

    if (ret['today_start_time']) then
        self.today_start_time = ret['today_start_time']      -- 10:00
    end

end

-------------------------------------
-- function isMatchDay
-------------------------------------
function ServerData_ClanWar:isMatchDay(_day)
	if (not self.m_clanWarDayData) then
		return false
	end

	if (not self.m_clanWarDayData['table']) then
		return false
	end

	local day = _day or self.m_clanWarDay
	if (self.m_clanWarDayData['table']['day_' .. day]) then
		return (self.m_clanWarDayData['table']['day_' .. day] == 1)
	end
end

-------------------------------------
-- function getMaxRound
-------------------------------------
function ServerData_ClanWar:getMaxRound()
	if (not self.m_clanWarDayData) then
		return 0
	end

	if (not self.m_clanWarDayData['table']) then
		return 0
	end

	local total_match = self.m_clanWarDayData['table']['group'] or 0
    return total_match * 2
end

-------------------------------------
-- function getMaxGroup
-------------------------------------
function ServerData_ClanWar:getMaxGroup()
	if (not self.m_clanWarDayData) then
		return 0
	end

	if (not self.m_clanWarDayData['table']) then
		return 0
	end

	return self.m_clanWarDayData['table']['group_clan'] or 0
end

-------------------------------------
-- function getTodayRound
-------------------------------------
function ServerData_ClanWar:getTodayRound(next_day)
	local day = self.m_clanWarDay + (next_day or 0)
	-- 8??깃컧??64揶? 7??깃컧??32揶?...
	local t_day = {[8] = 64, [9] = 32, [10] = 16, [11] = 8, [12] = 4, [13] = 2, [14] = 1}
	return t_day[day]
end