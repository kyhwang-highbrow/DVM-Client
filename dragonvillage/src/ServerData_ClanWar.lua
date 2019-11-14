-------------------------------------
-- class ServerData_ClanWar
-- @instance g_clanWarData
-------------------------------------
ServerData_ClanWar = class({
    m_isMyClanLeft = 'boolean', -- Test API?癒?퐣筌??????롫뮉 揶?

    m_tClanInfo = 'table - StructClanRank',

    m_clanWarDay = 'number',
	m_clanWarDayData = 'table',

    -- ????袁⑹몵嚥?筌띿쉶??????쟿??곷선/?怨? ???쟿??곷선 ?類ｋ궖 ????
    m_playerUserInfo = 'StructUserInfoClanWar',
    m_OpponentUserInfo = 'StructUserInfoClanWar',

    m_gameKey = 'string',

	m_myMatchInfo = 'StructClanWarMatchItem', -- 嚥≪뮆?????뻿?癒?퐣 獄쏆룆???類ｋ궖, 獄쏄퀡瑗??袁⑹뒻 ???袁⑹뒄

    today_end_time = 'number',
    today_start_time = 'number' ,
    season_start_time = 'number',
    open = 'boolean',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanWar:init()
    self.m_tClanInfo = {}
    self.m_clanWarDay = 0

	self.today_end_time = 0
    self.today_start_time = 0
    self.season_start_time = 0
    self.open = false
end

ServerData_ClanWar.CLANWAR_STATE = {
	['DONE'] = 1,
	['OPEN'] = 2,
    ['BREAK'] = 3,
}

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
		remain_time = 0
	end
	return remain_time/1000
end

-------------------------------------
-- function getRemainGameTime
-- @brief ??멸돌疫?繹먮슣? ??? ??볦퍢
-------------------------------------
function ServerData_ClanWar:getRemainGameTime()
	local cur_time = Timer:getServerTime_Milliseconds()
	local remain_time = self.today_end_time - cur_time

	if (remain_time < 0) then
		remain_time = 0
	end
	return remain_time/1000
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
	return remain_time/1000	
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

	if (self.m_clanWarDay == 7) then
		msg = Str('토너먼트를 준비중입니다. \n 토너먼트 시작까지 {1} 남음')
	end

	if (self.m_clanWarDay == 14) then
		local remain_time = g_clanWarData:getRemainSeasonTime()
		msg = Str('클랜전 시즌이 종료되었습니다. \n 다음 클랜전까지 {1} 남음', datetime.makeTimeDesc(remain_time))
	end

	local clanwar_state = g_clanWarData:getClanWarState()
	if (clanwar_state == ServerData_ClanWar.CLANWAR_STATE['BREAK']) then
		msg = Str('전투 시간이 아닙니다. \n 다음 전투까지 {1} 남음')
	end

	return false, msg
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
		msg = Str('전투 시간이 아닙니다. \n 다음 전투까지 {1} 남음')
	end

	local clanwar_state = g_clanWarData:getClanWarState()
	local cur_time = Timer:getServerTime()
	local date = pl.Date()
	date:set(cur_time)
	local hour = date:hour()
	if (self.m_clanWarDay == 1) and (hour < 10) then
		msg = Str('클랜전 시즌이 종료되었습니다. \n 다음 클랜전까지 {1} 남음')
	else
		msg = Str('조별리그를 준비중입니다. \n 토너먼트 까지 {1} 남았습니다.')		
	end

	if (self.m_clanWarDay == 7) then
		msg = Str('조별리그가 종료 되었습니다. \n 토너먼트 까지 {1} 남았습니다.')	
	end
	
	if (clanwar_state == ServerData_ClanWar.CLANWAR_STATE['BREAK']) then
		msg = Str('전투 시간이 아닙니다. \n 다음 전투까지 {1} 남음')
	end

	return false, msg
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
        self.today_end_time = ret['open']      -- 10:00 ~ 24:00
    end

    if (ret['season_start_time']) then
        self.season_start_time = ret['season_start_time']      -- ?袁⑹삺癰귣????臾믪몵筌???뽰サ 筌욊쑵六얌빳? ??????뽰サ ??뽰삂??
    end

    if (ret['today_start_time']) then
        self.today_start_time = ret['today_start_time']      -- 10:00
    end

end

-------------------------------------
-- function request_myClanResult
-------------------------------------
function ServerData_ClanWar:request_myClanResult(my_clan_is_left)
    local left_score, right_score = 0, 0 
    -- ????????諛멤봺??롫즲嚥??癒?땾 ?紐낅샒
    if (my_clan_is_left) then
        left_score = 1
        right_score = 0
    else
        left_score = 0
        right_score = 1
    end

    g_clanWarData:request_clanWarTournamentSetScore(left_score, right_score)
end

-------------------------------------
-- function request_clanWarLeagueInfo
-------------------------------------
function ServerData_ClanWar:request_clanWarLeagueInfo(team, success_cb)
    local league = team
	local finish_cb = function(ret)
        -- ?⑤벉猷??곗쨮 ServerData_ClanWar?????貫由???類ｋ궖??
		g_clanWarData:setClanInfo(ret['clan_info'])
        self.m_clanWarDay = ret['clanwar_day']
		self.m_clanWarDayData = ret['clan_data']
        
		-- 1 ~ 7??⑦돱筌왖??StructClanWarLeague
		-- 8 ~ 14??⑦돱筌왖??StructClanWarTournament ?類κ묶嚥??????
        success_cb(ret)
	end

    -- ?醫? ID
    local uid = g_userData:get('uid')
    
    -- ??쎈뱜??곌쾿 ???뻿
    local ui_network = UI_Network()
    ui_network:setUrl('/clanwar/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('league', league)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(finish_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function isMatchDay
-------------------------------------
function ServerData_ClanWar:isMatchDay()
	if (not self.m_clanWarDayData) then
		return false
	end

	if (not self.m_clanWarDayData['table']) then
		return false
	end

	local day = self.m_clanWarDay
	if (self.m_clanWarDayData['table']['day_' .. day]) then
		return (self.m_clanWarDayData['table']['day_' .. day] == 1)
	end
end

-------------------------------------
-- function getTodayRound
-------------------------------------
function ServerData_ClanWar:getTodayRound()
	-- 8??깃컧??64揶? 7??깃컧??32揶?...
	local t_day = {[8] = 64, [9] = 32, [10] = 16, [11] = 8, [12] = 4, [13] = 2, [14] = 1}
	return t_day[self.m_clanWarDay]
end

-------------------------------------
-- function setClanInfo
-------------------------------------
function ServerData_ClanWar:setClanInfo(l_clan_info)
    if (not l_clan_info) then
        return
    end

    self.m_tClanInfo = {}
    for _, data in ipairs(l_clan_info) do
        local clan_id = data['id']
        self.m_tClanInfo[clan_id] = StructClanRank(data)
    end
end

-------------------------------------
-- function getClanInfo
-------------------------------------
function ServerData_ClanWar:getClanInfo(clan_id)
    return self.m_tClanInfo[clan_id]
end

-------------------------------------
-- function request_testSetWinLose
-------------------------------------
function ServerData_ClanWar:request_testSetWinLose(league, match, is_left, win, lose, total_win)
    local league = team

    -- ?醫? ID
    local uid = g_userData:get('uid')
    
    -- ??쎈뱜??곌쾿 ???뻿
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/clanwar_setscore')
    ui_network:setParam('uid', uid)
    ui_network:setParam('league', league)
    ui_network:setParam('match', match)
    ui_network:setParam('is_left', is_left)
    ui_network:setParam('win', win)
    ui_network:setParam('lose', lose)
    ui_network:setParam('total_win', total_win)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(finish_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_nextDay
-------------------------------------
function ServerData_ClanWar:request_testNextDay()
    -- ?醫? ID
    local uid = g_userData:get('uid')
    
    -- ??쎈뱜??곌쾿 ???뻿
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/clanwar_nextday')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(finish_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getMyClanId
-------------------------------------
function ServerData_ClanWar:getMyClanId(clan_id)
   local struct_clan = g_clanData:getClanStruct()
   if (struct_clan) then
        return struct_clan:getClanObjectID()
   end

   return nil
end

-------------------------------------
-- function setIsMyClanLeft
-------------------------------------
function ServerData_ClanWar:setIsMyClanLeft(is_left)
    self.m_isMyClanLeft = is_left
end

-------------------------------------
-- function getIsMyClanLeft
-------------------------------------
function ServerData_ClanWar:getIsMyClanLeft()
    return self.m_isMyClanLeft
end

-------------------------------------
-- function request_clanWarMatchInfo
-------------------------------------
function ServerData_ClanWar:request_clanWarMatchInfo(success_cb)    
    
    local finish_cb = function(ret)
        return success_cb(StructClanWarMatch(ret))
    end
    
    -- ?醫? ID
    local uid = g_userData:get('uid')
    local clan_id = self:getMyClanId()
    
    -- ??쎈뱜??곌쾿 ???뻿
    local ui_network = UI_Network()
    ui_network:setUrl('/clanwar/match_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(finish_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function responseClanwarMatchInfo
-------------------------------------
function ServerData_ClanWar:responseClanwarMatchInfo(l_data)
    local t_struct_match = {}
    for i, data in ipairs(l_data) do
        local uid = data['uid']
        if (uid) then
            t_struct_match[uid] = StructClanWarMatch(data)            
        end
    end

    return t_struct_match
end



-------------------------------------
-- function request_clanWarTournamentSetScore
-------------------------------------
function ServerData_ClanWar:request_clanWarTournamentSetScore(left_score, right_score)    
    local finish_cb = function()
        self:request_testNextDay()
    end
    
    -- ?醫? ID
    local uid = g_userData:get('uid')
    
    -- ??쎈뱜??곌쾿 ???뻿
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/clanwar_tournament_score_set')
    ui_network:setParam('uid', uid)
    ui_network:setParam('left_score', left_score)
    ui_network:setParam('right_score', right_score)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(finish_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function refresh_playerUserInfo
-- @brief ???쟿??곷선 ?類ｋ궖 揶쏄퉮??
-------------------------------------
function ServerData_ClanWar:refresh_playerUserInfo(t_deck)
	if (not self.m_playerUserInfo) then
		local struct_user_info = StructUserInfoClanWar()
    
		struct_user_info.m_uid = g_userData:get('uid')
		struct_user_info.m_lv = g_userData:get('lv')
		struct_user_info.m_nickname = g_userData:get('nick')	

		-- ????
		local struct_clan = g_clanData:getClanStruct()
		if (struct_clan) then
			struct_user_info.m_userData = struct_clan:getClanName()
		else
			struct_user_info.m_userData = ''
		end
        struct_user_info:setStructClan(struct_clan)
		self.m_playerUserInfo = struct_user_info
	end

    if (t_deck) then
	    self.m_playerUserInfo:applyPvpDeckData(t_deck)
    end
end

-------------------------------------
-- function getUserInfo
-- @brief ???쟿??곷선 ?類ｋ궖 揶쏄퉮??
-------------------------------------
function ServerData_ClanWar:getPlayerUserInfo()   
    return self.m_playerUserInfo
end

-------------------------------------
-- function requestEnemyUserInfo
-------------------------------------
function ServerData_ClanWar:requestEnemyUserInfo(uid, finish_cb)
    local finish_cb = function(data)
        g_clanWarData:makeEnemyUserInfo(data)
        if (finish_cb) then
            finish_cb()
        end
    end
    
    g_clanWarData:request_clanWarUserDeck(uid, finish_cb)
end

-------------------------------------
-- function getEnemyUserInfo
-------------------------------------
function ServerData_ClanWar:getEnemyUserInfo(uid, finish_cb)
    return self.m_OpponentUserInfo
end

-------------------------------------
-- function refreshFocusUserInfo
-- @brief
-------------------------------------
function ServerData_ClanWar:makeEnemyUserInfo(data)
    if not (data) then
        g_clanWarData:setEnemyUserInfo(nil)
        return
    end
    
    local struct_user_info = StructUserInfoArena()

    -- 疫꿸퀡???醫? ?類ｋ궖
    struct_user_info.m_uid = data['uid']
    struct_user_info.m_nickname = data['nick']
    struct_user_info.m_lv = data['lv']
    struct_user_info.m_tamerID = data['tamer']
    struct_user_info.m_leaderDragonObject = StructDragonObject(data['leader'])
    struct_user_info.m_tier = data['tier']
    struct_user_info.m_rank = data['rank']
    struct_user_info.m_rankPercent = data['rate']
    
    -- ?꾩뮆以?紐? ?醫? ?類ｋ궖
    struct_user_info.m_rp = data['rp']
    struct_user_info.m_matchResult = data['match']
    
    struct_user_info:applyRunesDataList(data['runes']) --獄쏆꼶諭????뺤삋????쇱젟 ?袁⑸퓠 ?롤딆뱽 ??쇱젟??곷튊??
    struct_user_info:applyDragonsDataList(data['dragons'])
    
    -- ???類ｋ궖 (筌띲끉?귞뵳???紐꾨퓠 ??뤿선??삳뮉 ?源? ?????醫???獄쎻뫗堉??
    struct_user_info:applyPvpDeckData(data['deck'])
    
    -- ????
    if (data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(data['clan_info'])
        struct_user_info:setStructClan(struct_clan)
    end
    
    g_clanWarData:setEnemyUserInfo(struct_user_info)
end

-------------------------------------
-- function setEnemyUserInfo
-- @brief ???쟿??곷선 ?類ｋ궖 揶쏄퉮??
-------------------------------------
function ServerData_ClanWar:setEnemyUserInfo(opponent_info)   
    self.m_OpponentUserInfo = opponent_info
end

-------------------------------------
-- function getStructUserInfo_Player
-------------------------------------
function ServerData_ClanWar:getStructUserInfo_Player()
    local t_data = g_deckData:getDeck_lowData('clanwar')
    self:refresh_playerUserInfo(t_data)

    local struct_user_info = g_clanWarData:getPlayerUserInfo()
    return struct_user_info
end

-------------------------------------
-- function request_clanWarStart
-------------------------------------
function ServerData_ClanWar:request_clanWarStart(enemy_uid, finish_cb)
    -- ?醫? ID
    local uid = g_userData:get('uid')
    
    -- ?源껊궗 ?꾩뮆媛?
    local function success_cb(ret)

        -- staminas, cash ??녿┛??
        g_serverData:networkCommonRespone(ret)

        self.m_gameKey = ret['gamekey']

        -- ??쇱젫 ???쟿????볦퍢 嚥≪뮄?뉒몴??袁る퉸 筌ｋ똾寃?????癰귣?源?
        g_accessTimeData:startCheckTimer()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- ??쎈뱜??곌쾿 ???뻿
    local ui_network = UI_Network()
    ui_network:setUrl('/clanwar/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('token', self:makeDragonToken())
    ui_network:setParam('enemy_uid', enemy_uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function makeDragonToken
-------------------------------------
function ServerData_ClanWar:makeDragonToken()
    local token = ''

    local l_deck =  g_deckData:getDeck('clanwar')

    for i = 1, 5 do
        local t_dragon_data
        local doid = l_deck[i]
        if (doid) then
            t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        end

        if (t_dragon_data) then
            token = token .. t_dragon_data:getStringData() 
        else
            token = token .. '0'
        end

        if (i < 5) then
            token = token .. ','
        end
    end

    --cclog('token = ' .. token)

    token = HEX(AES_Encrypt(HEX2BIN(CONSTANT['AES_KEY']), token))
    
    return token
end

-------------------------------------
-- function request_clanWarFinish
-- @breif
-------------------------------------
function ServerData_ClanWar:request_clanWarFinish(is_win, play_time, next_func)
    local uid = g_userData:get('uid')
	local _play_time = play_time or 0
    local function success_cb(ret)
        if next_func then
            next_func()
        end
    end

    -- true???귐뗪쉘??롢늺 ?癒?퍥?怨몄몵嚥?筌ｌ꼶?곭몴??袁⑥┷??덈뼄????
    local function response_status_cb(ret)
        -- invalid season
        if (ret['status'] == -1364) then
            -- 嚥≪뮆?ф에???猷?
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('??뽰サ???ル굝利??뤿???щ빍??'), ok_cb)
            return true
        end
        return false
    end

    -- 筌뤴뫀諭띈퉪?API 雅뚯눘???브쑨由곤㎗?롡봺
    local api_url = '/clanwar/finish'

    local _is_win
    if (is_win) then
        _is_win = 1
    else
        _is_win = 0
    end

    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('gamekey', self.m_gameKey)
    ui_network:setParam('clear_time', _play_time)
    ui_network:setParam('check_time', g_accessTimeData:getCheckTime())
    ui_network:setParam('is_win', _is_win)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function request_clanWarUserDeck
-------------------------------------
function ServerData_ClanWar:request_clanWarUserDeck(uid, finish_cb)

    -- ?醫? ID
    local _uid = uid or g_userData:get('uid')
    
    -- ?源껊궗 ?꾩뮆媛?
    local function success_cb(ret)
        if (finish_cb) then
            finish_cb(ret['deck_info'])
        end
    end

    -- ??쎈뱜??곌쾿 ???뻿
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_deck_clanwar')
    ui_network:setParam('uid', _uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_setDeck
-------------------------------------
function ServerData_ClanWar:request_setDeck(deckname, formation, leader, l_edoid, tamer, finish_cb, fail_cb)
    local _deckname = deckname

    -- ?醫? ID
    local uid = g_userData:get('uid')

    -- ?源껊궗 ?꾩뮆媛?
    local function success_cb(ret)
        local t_data = nil
        local t_deck = ret['deck']
        self:refresh_playerUserInfo(t_deck)
        g_deckData:setDeck_usedDeckPvp('clan_war', l_deck)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- ??쎈뱜??곌쾿 ???뻿
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/set_deck')
    ui_network:setParam('uid', uid)

    ui_network:setParam('deckname', _deckname)
    ui_network:setParam('formation', formation)
    ui_network:setParam('leader', leader)
    ui_network:setParam('tamer', tamer)
    

    for i,doid in pairs(l_edoid) do
        ui_network:setParam('edoid' .. i, doid)
    end

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_clanWarMyMatchInfo
-------------------------------------
function ServerData_ClanWar:request_clanWarMyMatchInfo(finish_cb)

    -- ?醫? ID
    local _uid = uid or g_userData:get('uid')
    
    -- ?源껊궗 ?꾩뮆媛?
    local function success_cb(ret)
        self.m_myMatchInfo = StructClanWarMatchItem(ret['my_match_info'])
		if (finish_cb) then
			finish_cb()
		end
    end

    -- ??쎈뱜??곌쾿 ???뻿
    local ui_network = UI_Network()
    ui_network:setUrl('/clanwar/my_match_info')
    ui_network:setParam('uid', _uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function isMyClanWarMatchAttackingState_byLobby
-- @warning! 嚥≪뮆??癒?퐣 ???뻿?????춸 揶쏄퉮???롫뮉 ?類ｋ궖??
-- @brief 獄쏄퀡瑗?筌〓씭????袁⑹뒄???類ｋ궖 ?귐뗪쉘
-------------------------------------
function ServerData_ClanWar:isMyClanWarMatchAttackingState_byLobby()
	if (self.m_myMatchInfo) then
		local is_attacking = (self.m_myMatchInfo:getAttackState() == StructClanWarMatchItem.ATTACK_STATE['ATTACKING'])
		local attack_uid = self.m_myMatchInfo:getAttackingUid()
		local end_date = self.m_myMatchInfo:getEndDate() or ''
		return is_attacking, attack_uid, end_date
	end
end