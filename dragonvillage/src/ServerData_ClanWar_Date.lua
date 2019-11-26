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
        -- 경기는 종료되었는데 정산 시간일 경우 아예 막아둠
		if (cur_time < self.today_calc_end_time) then
            return ServerData_ClanWar.CLANWAR_STATE['LOCK']
        -- 경기 종료되었는데 정산 시간 끝난 경우 경기 화면은 보여줌
        else
            return ServerData_ClanWar.CLANWAR_STATE['BREAK']
        end
        
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

    return false, msg
end

-------------------------------------
-- function checkClanWarState_Tournament
-------------------------------------
function ServerData_ClanWar:checkClanWarState_Tournament()
	local is_open, msg = self:checkClanWarState()

	if (is_open) then
		return true, msg
	end

	if (self.m_clanWarDay == 1) then
		local remain_time = g_clanWarData:getRemainSeasonTime()
		msg = Str('클랜전 시즌이 종료되었습니다.') .. '{@green}' .. Str('다음 클랜전까지 {1} 남음', g_clanWarData:getRemainSeasonTime()) -- 14일째 시즌 시자가 시간이 이상하게 내려온다
		return false, msg
	end

	-- 토너먼트 진행 안 하는 날 : 일본 서버의 경우 이틀 뒤 시작한다
	if (not g_clanWarData:isMatchDay(self.m_clanWarDay)) then
		local round = g_clanWarData:getTodayRoundText(1)
        local time = g_clanWarData:getRemainStartGameTime()
        local game_name = round
		msg = game_name .. ' ' .. Str('토너먼트를 준비중입니다.') .. ' {@green}' .. Str('다음 전투까지 {1} 남음', time)
		return false, msg
	end

	-- 자정 ~ 10시
	local clanwar_state = g_clanWarData:getClanWarState()
	if (clanwar_state ~= ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
		local round = g_clanWarData:getTodayRoundText()
		local game_name = round
        msg = game_name .. ' ' ..Str('토너먼트를 준비중입니다.') .. ' {@green}' .. Str('다음 전투까지 {1} 남음', g_clanWarData:getRemainStartGameTime())
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

	local clanwar_state = g_clanWarData:getClanWarState()
	local cur_time = Timer:getServerTime()
	local date = pl.Date()
	date:set(cur_time)
	local hour = date:hour()
	if (self.m_clanWarDay == 1) and (hour < 10) then
		msg = Str('클랜전 시즌이 종료되었습니다.') .. ' {@green}' .. Str('다음 클랜전까지 {1} 남음', g_clanWarData:getRemainSeasonTime())
		return false, msg
	elseif (self.m_clanWarDay == 1) and (hour >= 10) then
		msg = Str('조별리그를 준비중입니다.') .. ' {@green}' .. Str('다음 전투까지 {1} 남음', g_clanWarData:getRemainStartGameTime())
		return false, msg	
	end

	if (self.m_clanWarDay == 7) then
		msg = Str('조별리그가 종료 되었습니다.') .. ' {@green}' .. Str('토너먼트 시작까지 {1} 남음', g_clanWarData:getRemainStartGameTime())	
		return false, msg
	end

    -- 조별리그 진행 안 하는 날 : 일본 서버의 경우 이틀 뒤 시작한다
	if (not g_clanWarData:isMatchDay(self.m_clanWarDay)) then
        local time = g_clanWarData:getRemainTimeForNextGame()
		msg = Str('조별리그를 준비중입니다.') .. ' {@green}' .. Str('다음 전투까지 {1} 남음', g_clanWarData:getRemainStartGameTime())
		return false, msg
	end
	
	msg = Str('조별리그를 준비중입니다.') .. ' {@green}' .. Str('다음 전투까지 {1} 남음', g_clanWarData:getRemainStartGameTime())
	return false, msg
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
	msg = game_name .. ' ' .. Str('진행중') .. ' {@green}' .. Str('{1} 남음', g_clanWarData:getRemainGameTime())
	return open, msg
end

-------------------------------------
-- function getCurStateText_Tournament
-------------------------------------
function ServerData_ClanWar:getCurStateText_Tournament()
	-- 마지막날 닫혀있어도, 경기 결과 보는 날은 열어줌
    if (self.m_clanWarDay == 14) then
        return true, Str('클랜전 시즌이 종료되었습니다.') .. '{@green}' .. Str('다음 클랜전까지 {1} 남음', g_clanWarData:getRemainSeasonTime())
    end	

	local open, msg = g_clanWarData:checkClanWarState()
	if (not open) then
		return g_clanWarData:checkClanWarState_Tournament()
	end

	local today_round = g_clanWarData:getTodayRoundText()
	local game_name = Str('토너먼트') .. ' ' .. today_round
	msg = game_name .. ' ' .. Str('진행중') .. ' {@green}' .. Str('{1} 남음', g_clanWarData:getRemainTimeForNextGameEnd())
	return open, msg
end

-------------------------------------
-- function getRemainTimeForNextGame
-------------------------------------
function ServerData_ClanWar:getRemainTimeForNextGame()
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
	date:hour(9)
    date:hour(59)
	local time = date['time']
	local remain_time = 0
	if (time) then
        remain_time = (time - cur_time) + match_start_day * 60*60*24
		return datetime.makeTimeDesc(remain_time)
	else
		return '-'
	end
end

-------------------------------------
-- function getRemainTimeForNextGameEnd
-------------------------------------
function ServerData_ClanWar:getRemainTimeForNextGameEnd()
	-- 클라에서 노가다로 계산한 것
	local cur_time = Timer:getServerTime()
	local date = pl.Date()
	date:set(cur_time)
	date:hour(23)
    date:min(59)
	local time = date['time']
	local remain_time = 0
	if (time) then
        remain_time = (time - cur_time)
		return datetime.makeTimeDesc(remain_time)
	else
		return '-'
	end
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
function ServerData_ClanWar:getIsLeague()
	return self.m_isLeague
end

-------------------------------------
-- function setIsLeague
-- @brief 조별리그 기간인지, 토너먼트 기간인지
-------------------------------------
function ServerData_ClanWar:setIsLeague(is_league)
	self.m_isLeague = is_league
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
    
    if (ret['today_calc_end_time']) then
        self.today_calc_end_time = ret['today_calc_end_time']   -- 00:00 ~ 10:00
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
    local max_round = g_clanWarData:getMaxRound()
	local t_day = { [6] = max_round, [7] = max_round, [8] = 64, [9] = 32, [10] = 16, [11] = 8, [12] = 4, [13] = 2, [14] = 1}
	return t_day[day]
end

-------------------------------------
-- function getDayByRound
-------------------------------------
function ServerData_ClanWar:getDayByRound(round)
	local max_round = g_clanWarData:getMaxRound()
    local t_day = { [6] = max_round, [7] = max_round, [8] = 64, [9] = 32, [10] = 16, [11] = 8, [12] = 4, [13] = 2, [14] = 1}
	for day, data in pairs(t_day) do
        if (data == round) then
            return day
        end
    end
    
    return 0
end

-------------------------------------
-- function getTodayRound
-------------------------------------
function ServerData_ClanWar:getTodayRoundText()
	local round = g_clanWarData:getTodayRound(next_day)
    if (not round) then
        return Str('조별리그')
    elseif (round <= 2) then
        return Str('결승전')
    else
        return Str('{1}강', round)
    end
end

-------------------------------------
-- function getRoundText
-------------------------------------
function ServerData_ClanWar:getRoundText(round)
    if (round == 0) then
        return '-'
    elseif (round <= 2) then
        return Str('결승전')
    else
        return Str('{1}강', round)
    end
end