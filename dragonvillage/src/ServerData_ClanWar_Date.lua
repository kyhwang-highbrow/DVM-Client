-------------------------------------
-- function getClanWarState
-------------------------------------
function ServerData_ClanWar:getClanWarState()
	local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
	local state

	-- 클랜전 시즌 시작전이라면 시즌 종료 처리 (self.season_start_time - 다음 시즌까지 남은 시간)
	if (cur_time < self.season_start_time) then
		return ServerData_ClanWar.CLANWAR_STATE['DONE']
	end

	-- 경기 시작이 가능한지
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
-- @brief 다음 시즌까지 남은 시간
-------------------------------------
function ServerData_ClanWar:getRemainSeasonTime()
	local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
	local remain_time = self.season_start_time - cur_time

	if (remain_time < 0) then
		remain_time = 1
	end
	return datetime.makeTimeDesc(remain_time/1000)
end

-------------------------------------
-- function getRemainNextSeasonTime
-- @brief 다다음 시즌까지 남은 시간
-- @brief 14일 째의 경우 현재 시즌은 끝나지 않았는데 다음 시즌 시작 시간이 필요함
-------------------------------------
function ServerData_ClanWar:getRemainNextSeasonTime()
	local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
	local remain_time = self.next_season_start_time - cur_time

	if (remain_time < 0) then
		remain_time = 1
	end
	return datetime.makeTimeDesc(remain_time/1000)
end

-------------------------------------
-- function getRemainGameTime
-- @brief 오늘 경기 끝나기까지 남은 시간
-------------------------------------
function ServerData_ClanWar:getRemainGameTime()
	local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
	local remain_time = self.today_end_time - cur_time

	if (remain_time < 0) then
		remain_time = 1
	end
	return datetime.makeTimeDesc(remain_time/1000)
end

-------------------------------------
-- function getRemainStartGameTime
-- @brief 오늘 경기 시작까지 남은 시간
-------------------------------------
function ServerData_ClanWar:getRemainStartGameTime()
	local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
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
-- @return 현재 토너먼트 open 상태, 상태 메세지, 남은 시간 
-------------------------------------
function ServerData_ClanWar:checkClanWarState_Tournament()
	local is_open, msg = self:checkClanWarState()

	if (is_open) then
		return true, msg
	end

	-- 경기 중이 아닐 경우
	local clanwar_state = g_clanWarData:getClanWarState()
	if (clanwar_state ~= ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
		local round = g_clanWarData:getTodayRoundText()
		local game_name = round
        msg = game_name .. ' ' ..Str('토너먼트를 준비중입니다.') .. '\n{@green}' .. Str('다음 전투까지 {1} 남음', g_clanWarData:getRemainStartGameTime())
		return false, msg
	end

	return false, ''
end

-------------------------------------
-- function checkClanWarState_League
-- @return 현재 조별리그 open 상태, 상태 메세지, 남은 시간
-------------------------------------
function ServerData_ClanWar:checkClanWarState_League()
	local is_open, msg = self:checkClanWarState()

	if (is_open) then
		return true, ''
	end

	if (self.m_clanWarDay == 7) then
		msg = Str('조별리그가 종료 되었습니다.') .. '\n{@green}' .. Str('토너먼트 시작까지 {1} 남음', g_clanWarData:getRemainStartGameTime())	
		return false, msg
	end
	
	msg = Str('조별리그를 준비중입니다.') .. '\n{@green}' .. Str('다음 전투까지 {1} 남음', g_clanWarData:getRemainStartGameTime())
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
	
    -- 경기 안하는 날도 있기 때문에 오늘 경기가 몇 번째인지 테이블 참조해서 계산
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
	msg = game_name .. ' ' .. Str('진행중') .. '\n{@green}' .. Str('{1} 남음', g_clanWarData:getRemainGameTime())
	return open, msg
end

-------------------------------------
-- function getCurStateText_Tournament
-------------------------------------
function ServerData_ClanWar:getCurStateText_Tournament()
    if (self.m_clanWarDay == 14) then
        return true, Str('클랜전 시즌이 종료되었습니다.') .. '{@green}' .. Str('다음 클랜전까지 {1} 남음', g_clanWarData:getRemainSeasonTime())
    end	

	local open, msg = g_clanWarData:checkClanWarState()
	if (not open) then
		return g_clanWarData:checkClanWarState_Tournament()
	end

	local today_round = g_clanWarData:getTodayRoundText()
	local game_name = Str('토너먼트') .. ' ' .. today_round
	msg = game_name .. ' ' .. Str('진행중') .. '\n{@green}' .. Str('{1} 남음', g_clanWarData:getRemainTimeForNextGameEnd())
	return open, msg
end

-------------------------------------
-- function getRemainTimeForNextGame
-------------------------------------
function ServerData_ClanWar:getRemainTimeForNextGame()
	-- 클라에서 노가다로 계산한 것 
    -- 현재 사용 안함
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

	local cur_time = ServerTime:getInstance():getCurrentTimestampSeconds()
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
    -- 현재 사용안함
	local cur_time = ServerTime:getInstance():getCurrentTimestampSeconds()
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

	local cur_time = ServerTime:getInstance():getCurrentTimestampSeconds()
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
-- @brief 전체 몇개 조에서 시작하는지
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
        self.m_myMatchInfo = ret['my_match_info']
    else
        self.m_myMatchInfo = nil
    end

    if (ret['my_set_info']) then
        self.m_mySetInfo = StructClanWarMatchItem(ret['my_set_info'])
    else
        self.m_mySetInfo = nil
    end

    if (ret['today_end_time']) then
        self.today_end_time = ret['today_end_time']      -- ~ 24:00
    end

    if (ret['open']) then
        self.open = ret['open']      -- 10:00 ~ 24:00
    else
		self.open = false
	end

    if (ret['season_start_time']) then
        self.season_start_time = ret['season_start_time']
    end

    if (ret['next_season_start_time']) then
        self.next_season_start_time = ret['next_season_start_time']
    end

    if (ret['today_start_time']) then
        self.today_start_time = ret['today_start_time']      -- 10:00 ~
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
-- @brief 시작하는 라운드 (64 or 32)
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
-- function getTodayRound
-------------------------------------
function ServerData_ClanWar:getTodayRound()
    return self.m_clanWarTodayRound
end

-------------------------------------
-- function getTodayRoundText
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

-------------------------------------
-- function getRemainTimeText
-------------------------------------
function ServerData_ClanWar:getRemainTimeText()
    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local milliseconds

    -- 경기 진행 중 (경기 종료까지 남은 시간 표시)
    if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
        milliseconds = (g_clanWarData.today_end_time - cur_time)

    -- 경기 진행 중이 아닌 경우 (다음 경기 시작까지 남은 시간 표시)
    else
        milliseconds = (g_clanWarData.today_start_time - cur_time)
    end


    local hour = math.floor(milliseconds / 3600000)
    milliseconds = milliseconds - (hour * 3600000)

    local min = math.floor(milliseconds / 60000)
    milliseconds = milliseconds - (min * 60000)

    local sec = math.floor(milliseconds / 1000)
    milliseconds = milliseconds - (sec * 1000)

    local str = string.format('%.2d:%.2d:%.2d',  hour, min, sec)
    return str
end