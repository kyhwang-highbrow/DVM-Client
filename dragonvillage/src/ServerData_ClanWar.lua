-------------------------------------
-- class ServerData_ClanWar
-- @instance g_clanWarData
-------------------------------------
ServerData_ClanWar = class({
    m_isMyClanLeft = 'boolean', -- Test API에서만 사용
	m_isLeague = 'boolean',

    m_tClanInfo = 'table - StructClanRank',

    m_clanWarDay = 'number',
    m_clanWarTodayRound = 'number', -- 토너먼트 기간일 경우 : 현재 N강
    m_tournamentStartDay = 'number', -- 토너먼트 시작하는 날짜 

	m_clanWarDayData = 'table',
    m_clanWarRountType = 'ServerData_ClanWar.ROUNT_TYPE',
    m_myClanGroup = 'number', -- 내 클랜 그룹

    m_myClanGroupStageInfo = 'table', -- info API에서 내 클랜의 조별리그 정보를 매번 받는다.
    --"my_clan_league_info":{
    --"lose_cnt":0,
    --"win_cnt":5,
    --"rank":1,
    --"id":"5ddf34c6e8919372e1f61804",
    --"member_win_cnt":1,
    --"game_lose":0,
    --"play_member_cnt":2,
    --"game_win":2,
    --"league":26,
    --"season":2,
    --"clan_id":"59fc0797019add5c7aa0f5ea",
    --"group_no":1
    --}
    m_myClanTournamentInfo = 'table', -- info API에서 내 클랜의 토너먼트 정보를 매번 받는다.
    --"my_clan_tournament_info":{
    --"game_lose":0,
    --"member_win_cnt":0,
    --"season":2,
    --"group_stage":64,
    --"play_member_cnt":0,
    --"game_win":0,
    --"group_stage_no":49,
    --"enemy_clan_id":"5ddb49a7970c6204bef3aef0",
    --"clan_id":"59fc0797019add5c7aa0f5ea",
    --"id":"5ddf8371e8919372e1f64569"
    --}

    -- 실제 전투하는 나의/상대 유저 정보+덱
    m_playerUserInfo = 'StructUserInfoClanWar',
    m_OpponentUserInfo = 'StructUserInfoClanWar',

    m_myMatchInfo = 'table', -- 현재 진행 중인 내 클랜의 매치 정보(간단한 정보. 로비 배너에 사용)
    --"my_match_info":{
    --  "clan_b":{
    --    "mark":"",
    --    "set_score":0
    --  },
    --  "clan_a":{
    --    "mark":"30;25;2;2",
    --    "set_score":0
    --  },
    --  "my_attack_status":0
    --}
	m_mySetInfo = 'StructClanWarMatchItem', -- lobby통신에서 받는 내 유저 정보(로비 배너에 사용)

    today_end_time = 'number',          -- 오늘 경기 끝나는 시간
    today_start_time = 'number' ,
    season_start_time = 'number',       -- 시즌 시작하는 시간
    next_season_start_time = 'number',  -- 다 시즌 시작하는 시간
    today_calc_end_time = 'number',     -- 정산 끝나는 시간
    open = 'boolean',                   -- 경기 시작 가능 여부

	m_season = 'number', -- 시즌 정보

	m_tSeasonRewardInfo = 'table', -- 시즌보상
    m_gameKey = 'number',
})


ServerData_ClanWar.ROUNT_TYPE = {}
ServerData_ClanWar.ROUNT_TYPE['GROUPSTAGE'] = 1
ServerData_ClanWar.ROUNT_TYPE['TOURNAMENT'] = 2

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanWar:init()
    self.m_tClanInfo = {}
    self.m_clanWarDay = 0

	self.today_end_time = 0
    self.today_start_time = 0
    self.season_start_time = 0
    self.next_season_start_time = 0
    self.open = false
end

ServerData_ClanWar.CLANWAR_STATE = {
	['DONE'] = 1,   -- 시즌 종료
	['OPEN'] = 2,   -- 전투 가능
    ['BREAK'] = 3,  -- 전투 불가능, 클랜전 화면에 접근 가능
    ['LOCK'] = 4,   -- 전투 불가능, 클랜전 화면에 접근 불가능 
}

ServerData_ClanWar.CLANWAR_CLAN_STATE = {
	['NOT_PARTICIPATING'] = -1, -- 미참가
	['PARTICIPATING'] = 1, -- 참가 중
    ['LEAVING_OUT'] = 2, -- 토너먼트 진출 못함
    ['DEFEAT_IN_TOURNAMENT'] = 3, -- 토너먼트 도중 탈락
}

-------------------------------------
-- function applyClanWarReward
-- @brief 보상 정보
-------------------------------------
function ServerData_ClanWar:applyClanWarReward(ret)
	-- 보상이 있다면 들어오는 값
    if (ret['reward_clan_info']) then
		
		self.m_tSeasonRewardInfo = {}
		self.m_tSeasonRewardInfo['reward_clan_info'] = ret['reward_clan_info']
		
        -- 내려온 rank값이 조별리그 값인지 토너먼트 값인지 ex) 4위 : 토너먼트 4강 or 조별리그 4위
        if (ret['is_tournament']) then
			self.m_tSeasonRewardInfo['is_tournament'] = ret['is_tournament']
		end

		if (ret['last_clanwar_rank']) then
			self.m_tSeasonRewardInfo['last_clanwar_rank'] = ret['last_clanwar_rank']
		end
	end
end

-------------------------------------
-- function request_clanWarLeagueInfo
-- @brief 클랜전 첫 통신 (토너먼트 or 조별리그 정보 받음)
-------------------------------------
function ServerData_ClanWar:request_clanWarLeagueInfo(team, success_cb)
    local league = team

	local finish_cb = function(ret)
        g_clanWarData.m_clanWarDay = ret['clanwar_day'] or 0
        g_clanWarData.m_tournamentStartDay = ret['tournament_start_day'] or 0
        g_clanWarData.m_clanWarTodayRound = ret['clanwar_today_groupstage']
		g_clanWarData.m_clanWarDayData = ret['clan_data']
		g_clanWarData.m_season = ret['clanwar_season']

		g_clanWarData:applyClanWarInfo(ret['clanwar_info'])
		g_clanWarData:applyClanWarReward(ret)

        if (g_clanWarData.m_clanWarDay < self.m_tournamentStartDay) then
            g_clanWarData:setIsLeague(true)
        else
            g_clanWarData:setIsLeague(false)
        end

        -- 내 클랜 정보
        do
            -- 그룹 스테이지 정보
            self.m_myClanGroupStageInfo = ret['my_clan_league_info'] or nil

            -- 토너먼트 정보
            self.m_myClanTournamentInfo= ret['my_clan_tournament_info'] or nil
        end

        -- 1~7일은 조별리그 (8~14일은 토너먼트)
		if (g_clanWarData.m_clanWarDay <= 7) then
			g_clanWarData:setClanInfo(ret['league_clan_info'])
            self.m_clanWarRountType = ServerData_ClanWar.ROUNT_TYPE['GROUPSTAGE']
		else
			g_clanWarData:setClanInfo(ret['tournament_clan_info'])
            g_clanWarData:setClanInfo(ret['league_clan_info'])
            self.m_clanWarRountType = ServerData_ClanWar.ROUNT_TYPE['TOURNAMENT']
		end

        -- 내가 속한 그룹 저장
        local my_clan_oid = g_clanData:getMyClanObjectID()
        for _, t_clan_data in pairs(ret['league_info']) do
            if (my_clan_oid == t_clan_data['clan_id']) then
                self.m_myClanGroup = t_clan_data['league']
                break
            end
        end

        success_cb(ret)
	end

    local uid = g_userData:get('uid')
    
    local ui_network = UI_Network()
    ui_network:setUrl('/clanwar/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('league', team) -- 서버에서 처리가 안되어 있어서 임시로 고정
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
-- function setClanInfo
-------------------------------------
function ServerData_ClanWar:setClanInfo(l_clan_info)
    if (not l_clan_info) then
        return
    end

    for _, data in ipairs(l_clan_info) do
        local clan_id = data['id']
        self.m_tClanInfo[clan_id] = StructClanRank(data)
    end
end

-------------------------------------
-- function getClanInfo
-------------------------------------
function ServerData_ClanWar:getClanInfo(clan_id)
    if (not clan_id) then
        return
    end
    return self.m_tClanInfo[clan_id]
end

-------------------------------------
-- function request_testSetWinLose
-- @brief 조별리그 점수 세팅하는 TestAPI
-------------------------------------
function ServerData_ClanWar:request_testSetWinLose(league, match, is_left, win, lose, total_win)
    local league = team

    local uid = g_userData:get('uid')
    
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/clanwar_setscore')
    ui_network:setParam('uid', uid)
    ui_network:setParam('win', win)
    ui_network:setParam('lose', lose)
    ui_network:setParam('member_win', total_win)
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
-- function request_testNextDay
-- @brief 다음날로 이동
-------------------------------------
function ServerData_ClanWar:request_testNextDay()
    local uid = g_userData:get('uid')
    
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/clanwar_nextday')
    ui_network:setParam('uid', uid)
    ui_network:setParam('plus_day', 1)
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
-- @brief TestAPI에서 내 클랜이 왼쪽/오른쪽인지 판단 - 이제 사용 안함
-------------------------------------
function ServerData_ClanWar:setIsMyClanLeft(is_left)
    self.m_isMyClanLeft = is_left
end

-------------------------------------
-- function getIsMyClanLeft
-- @brief TestAPI에서 내 클랜이 왼쪽/오른쪽인지 판단 - 이제 사용 안함
-------------------------------------
function ServerData_ClanWar:getIsMyClanLeft()
    return self.m_isMyClanLeft
end

-------------------------------------
-- function request_clanWarMatchInfo
-- @brief 전투하는 두 클랜의 유저 정보
-- @param clan_id
-------------------------------------
function ServerData_ClanWar:request_clanWarMatchInfo(success_cb, clan_id)
    local finish_cb = function(ret)
        return success_cb(StructClanWarMatch(ret), ret['match_info'])
    end
    
    local uid = g_userData:get('uid')
    local clan_id = (clan_id or self:getMyClanId())
    
	local response_status_cb = function(ret)
		return g_clanWarData:responseStatusCB(ret)		
	end

    local ui_network = UI_Network()
    ui_network:setUrl('/clanwar/match_info')
    ui_network:setParam('day', g_clanWarData.m_clanWarDay)
	ui_network:setParam('season', g_clanWarData.m_season)
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
-- function request_clanWarTournamentSetScore
-------------------------------------
function ServerData_ClanWar:request_clanWarTournamentSetScore(left_score, right_score)    
    local finish_cb = function()
        self:request_testNextDay()
    end
    
    local uid = g_userData:get('uid')
    
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
-- @brief 유저 정보 갱신
-------------------------------------
function ServerData_ClanWar:refresh_playerUserInfo(t_deck)
	if (not self.m_playerUserInfo) then
		local struct_user_info = StructUserInfoClanWar()
    
		struct_user_info.m_uid = g_userData:get('uid')
		struct_user_info.m_lv = g_userData:get('lv')
		struct_user_info.m_nickname = g_userData:get('nick')

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
-- function getPlayerUserInfo
-------------------------------------
function ServerData_ClanWar:getPlayerUserInfo()   
    return self.m_playerUserInfo
end

-------------------------------------
-- function requestEnemyUserInfo
-- @brief 전투 상대 유저 정보
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
function ServerData_ClanWar:getEnemyUserInfo()
    return self.m_OpponentUserInfo
end

-------------------------------------
-- function makeEnemyUserInfo
-- @brief
-------------------------------------
function ServerData_ClanWar:makeEnemyUserInfo(data)
    if not (data) then
        g_clanWarData:setEnemyUserInfo(nil)
        return
    end
    
    local struct_user_info = StructUserInfoClanWar()
    struct_user_info.m_uid = data['uid']
    struct_user_info.m_nickname = data['nick']
    struct_user_info.m_lv = data['lv']
    struct_user_info.m_tamerID = data['tamer']
    struct_user_info.m_leaderDragonObject = StructDragonObject(data['leader'])
    struct_user_info.m_tier = data['tier']
    if (data['debris'] and data['debris']['tier']) then struct_user_info.m_tier = data['debris']['tier'] end

    struct_user_info.m_rank = data['rank']
    struct_user_info.m_rankPercent = data['rate']

    struct_user_info.m_rp = data['rp']
    struct_user_info.m_matchResult = data['match']
    struct_user_info.m_lairStats = data['lair_stats']
    
    struct_user_info:applyRunesDataList(data['runes'])
    struct_user_info:applyDragonsDataList(data['dragons'])
    
    -- 덱 정보
    struct_user_info:applyPvpDeckData(data['deck'])
    
    if (data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(data['clan_info'])
        struct_user_info:setStructClan(struct_clan)
    end
    
    g_clanWarData:setEnemyUserInfo(struct_user_info)
end

-------------------------------------
-- function setEnemyUserInfo
-------------------------------------
function ServerData_ClanWar:setEnemyUserInfo(opponent_info)   
    self.m_OpponentUserInfo = opponent_info
end

-------------------------------------
-- function getStructUserInfo_Player
-------------------------------------
function ServerData_ClanWar:getStructUserInfo_Player()
    local t_data = g_deckData:getDeck_lowData('clanwar')
    self:refresh_playerUserInfo(t_data) -- m_playerUserInfo 없으면 만드는 단계, 있다면 덱 갱신

    local struct_user_info = g_clanWarData:getPlayerUserInfo()
    return struct_user_info
end

-------------------------------------
-- function request_clanWarStart
-------------------------------------
function ServerData_ClanWar:request_clanWarStart(enemy_uid, finish_cb)
    local uid = g_userData:get('uid')
    
    local function success_cb(ret)
        -- 재화 갱신
        g_serverData:networkCommonRespone(ret)
        g_accessTimeData:startCheckTimer()

        -- 게임키 저장
        g_clanWarData.m_gameKey = ret['gamekey']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 이미 전투 시작한 유저가 있다면 정보 갱신을 위해 밖으로 보내줌
    local ok_cb = function()
        UINavigatorDefinition:goTo('clan_war', true)
    end
    
	local response_status_cb = function(ret)
		-- 가입한 당일 유저 select 통신 요청했을 경우 
        if (ret['status'] == -1138) then
            local msg = '매치 시작 이후 클랜에 가입한 유저는 해당 매치에 참여할 수 없습니다.'
            MakeSimplePopup(POPUP_TYPE.OK, msg, function() 
                if (refresh_cb) then
                    refresh_cb()
                end
            end)
            return true
        end

        if (ret['status'] == -1108) then
            local msg = '잘못된 요청입니다.'
            MakeSimplePopup(POPUP_TYPE.OK, msg, function() 
                if (refresh_cb) then
                    refresh_cb()
                end
            end)
            return true
        end
        
		return g_clanWarData:responseStatusCB(ret)		
	end

    local ui_network = UI_Network()
    ui_network:setUrl('/clanwar/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('day', g_clanWarData.m_clanWarDay)
	ui_network:setParam('season', g_clanWarData.m_season)
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

    -- 라테아 
    token = token .. g_lairData:getLairStatsStringData()

    --cclog('token = ' .. token)
    token = HEX(AES_Encrypt(HEX2BIN(CONSTANT['AES_KEY']), token))
    
    return token
end

-------------------------------------
-- function request_clanWarSelect
-- @breif
-------------------------------------
function ServerData_ClanWar:request_clanWarSelect(enemy_uid, finish_cb, refresh_cb)
    local success_cb = function(ret)
        if (finish_cb) then
            finish_cb()
        end
    end

    local response_status_cb = function(ret)
		if (ret['status'] == -3871) then
            local msg = '이미 전투 중인 대상입니다.'
            MakeSimplePopup(POPUP_TYPE.OK, msg, function() 
                if (refresh_cb) then
                    refresh_cb() 
                end
            end)
            return true
        end
		
		-- 가입한 당일 유저 select 통신 요청했을 경우 
        if (ret['status'] == -1138) then
            local msg = '매치 시작 이후 클랜에 가입한 유저는 해당 매치에 참여할 수 없습니다.'
            MakeSimplePopup(POPUP_TYPE.OK, msg, function() 
                if (refresh_cb) then
                    refresh_cb()
                end
            end)
            return true
        end

        if (ret['status'] == -1108) then
            local msg = '잘못된 요청입니다.'
            MakeSimplePopup(POPUP_TYPE.OK, msg, function() 
                if (refresh_cb) then
                    refresh_cb()
                end
            end)
            return true
        end
        return false
	end

    local uid = g_userData:get('uid')
    local ui_network = UI_Network()
    ui_network:setUrl('/clanwar/select')
    ui_network:setParam('uid', uid)
	ui_network:setParam('enemy_uid', enemy_uid)
	ui_network:setParam('day', g_clanWarData.m_clanWarDay)
    ui_network:setParam('season', g_clanWarData.m_season)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function request_clanWarFinish
-- @breif
-------------------------------------
function ServerData_ClanWar:request_clanWarFinish(is_win, play_time, next_func)
    local uid = g_userData:get('uid')
	local _play_time = play_time or 0
    local function success_cb(ret)
        -- 전투 후 공격자 기록 갱신 (전투 결과, 남은 시간 등등)
        local struct_user_info = g_clanWarData:getStructUserInfo_Player()
        local struct_match_item = struct_user_info:getClanWarStructMatchItem()
        local struct_match_info = ret['clanwar_member_info']

        if (struct_match_info) then
            if (struct_match_info['attack_game_history']) then
                struct_match_item:setAttackHistory(struct_match_info['attack_game_history'])
            end
            if (struct_match_info['attack_enddate']) then
                struct_match_item:setEndDate(struct_match_info['attack_enddate'])
            end
            if (struct_match_info['end']) then
                struct_match_item:setIsEnd(struct_match_info['end'])
            end
        end
        
        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)

        if next_func then
            next_func()
        end
    end

	local response_status_cb = function(ret)
		return g_clanWarData:responseStatusCB(ret, 'finish')
	end

    local api_url = '/clanwar/finish'

    local _is_win
    if (is_win) then
        _is_win = 1
    else
        _is_win = 0
    end

    local ui_network = UI_Network()
    local save_time = g_accessTimeData:getSaveTime()
    if (save_time) then
        ui_network:setParam('access_time', save_time)
    end
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
	ui_network:setParam('day', g_clanWarData.m_clanWarDay)
	ui_network:setParam('season', g_clanWarData.m_season)
    ui_network:setParam('gamekey', g_clanWarData.m_gameKey)
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
    local _uid = uid or g_userData:get('uid')
    
    local function success_cb(ret)
        if (finish_cb) then
            finish_cb(ret['deck_info'])
        end
    end

    local my_uid = g_userData:get('uid')

    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_deck_clanwar')
    ui_network:setParam('uid', my_uid)
    ui_network:setParam('search_uid', _uid)
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

    local uid = g_userData:get('uid')

    local function success_cb(ret)
        local t_data = nil
        local t_deck = ret['deck']
        self:refresh_playerUserInfo(t_deck)
        g_deckData:setDeck_usedDeckPvp('clan_war', l_deck)

        if finish_cb then
            finish_cb(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/set_deck')
    ui_network:setParam('uid', uid)

    ui_network:setParam('deck_name', _deckname)
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
-- function request_clanWarMySetInfo
-- @brief 나의 StructClanWarMatchItem 를 받음 - 해당 값은 로비에서 받고 따로 요청하는 통신은 사용 안하고 있음
-------------------------------------
function ServerData_ClanWar:request_clanWarMySetInfo(finish_cb)
    local _uid = uid or g_userData:get('uid')
    
    local function success_cb(ret)
        self.m_mySetInfo = StructClanWarMatchItem(ret['my_set_info'])
		if (finish_cb) then
			finish_cb()
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/clanwar/my_set_info')
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
-- function isMyClanWarMatchAttackingState
-- @brief 나의 현재 공격 상태 (로비에서 배너 찍을 때 사용)
-------------------------------------
function ServerData_ClanWar:isMyClanWarMatchAttackingState()
	if (self.m_mySetInfo) then
		local is_attacking = (self.m_mySetInfo:getAttackState() == StructClanWarMatchItem.ATTACK_STATE['ATTACKING'])
		local attack_uid = self.m_mySetInfo:getAttackingUid()
		local end_date = self.m_mySetInfo:getEndDate() or ''
		return is_attacking, attack_uid, end_date
	end
end

-------------------------------------
-- function isShowLobbyBanner
-- @brief 마을(Lobby)에서 클랜전 배너 노출 여부
-------------------------------------
function ServerData_ClanWar:isShowLobbyBanner()
    if (not self.m_myMatchInfo) then
        return false
    end

    -- https://perplelab.atlassian.net/wiki/x/aAA3QQ

    --"my_match_info":{
    --  "clan_b":{
    --    "mark":"",
    --    "set_score":0
    --  },
    --  "clan_a":{
    --    "mark":"30;25;2;2",
    --    "set_score":0
    --  },
    --  "my_attack_status":0
    --}

    -- 서버에서 매치를 진행 중인 경우만 my_match_info데이터를 보내준다.
    -- 따라서 오픈 시간 등의 조건은 클라이언트에서 추가로 검사하지 않는다.

    -- 공격 상태 (0:공격 가능, 1:공격 중, 9:공격 완료)
    local my_attack_status = self.m_myMatchInfo['my_attack_status']
    if (my_attack_status == 0) then
        return true
    end

    return false
end

-------------------------------------
-- function getMyClanMatchInfoForBanner
-- @brief 마을(Lobby)에서 클랜전 배너 노출에 필요한 정보 리턴
-------------------------------------
function ServerData_ClanWar:getMyClanMatchInfoForBanner()
    return self.m_myMatchInfo or {}
end


-------------------------------------
-- function readyMatch
-- @brief MatchInfo 통신
-------------------------------------
function ServerData_ClanWar:readyMatch(finish_cb)
    local success_cb = function(struct_match)
        if (finish_cb) then
            finish_cb(struct_match)
        end
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb)
end

-------------------------------------
-- function click_gotoBattle
-- @brief 클랜전 로비에서 전투 시작하기 눌렀을 때 1.매치 레디 씬으로 이동  2. 선택씬으로 이동
-------------------------------------
function ServerData_ClanWar:click_gotoBattle(my_struct_match_item, opponent_struct_match_item, goto_select_scene_cb)
    local attacking_uid = nil
    if (my_struct_match_item) then
        local is_do_all_game = my_struct_match_item:isDoAllGame()
        if (is_do_all_game) then
            UIManager:toastNotificationRed(Str('공격 기회를 모두 사용하였습니다.'))
            return
        end
        attacking_uid = my_struct_match_item:getAttackingUid()
    end
    
    -- 이미 공격한 상대가 있는 경우
    -- 1. 매치 레디 씬으로 이동 
    if (attacking_uid) then
        local finish_cb = function()
            if (not g_clanWarData:getEnemyUserInfo()) then
                UIManager:toastNotificationRed(Str('설정된 덱이 없는 상대 클랜원입니다.'))
                return
            end
            UI_MatchReadyClanWar(opponent_struct_match_item, my_struct_match_item)
        end

        g_clanWarData:requestEnemyUserInfo(attacking_uid, finish_cb)
    
    -- 2.선택씬으로 이동
    else
        if (goto_select_scene_cb) then
            goto_select_scene_cb()
        end
    end
end

-------------------------------------
-- function showPromoteGameStartPopup
-- @brief 전투 상대가 정해졌을 경우 클랜전 화면에서 MatchReay까지 보내주는 팝업
-------------------------------------
function ServerData_ClanWar:showPromoteGameStartPopup()    
    local success_cb = function(struct_match)
        local my_uid = g_userData:get('uid')
        local my_struct_match_item = struct_match:getMatchMemberDataByUid(my_uid)
        if (not my_struct_match_item) then
            return
        end
        
        local attack_uid = my_struct_match_item:getAttackingUid()
        
        if (not attack_uid) then
            return
        end

        local ui =  UI()
        ui:load('clan_war_popup_rival.ui')
        UIManager:open(ui, UIManager.POPUP)
        g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'clan_war_popup_rival')

		
		-- @UI_ACTION
		ui:doActionReset()
		ui:doAction(nil, false)

	    local attacking_struct_match = struct_match:getMatchMemberDataByUid(attack_uid)
        
        local ui_item = UI_ClanWarSelectSceneListItem(attacking_struct_match)
        ui_item:setNoTime()
        ui_item:setStructMatch()
        ui.vars['rivalItemNode']:addChild(ui_item.root)

        local end_time_text = my_struct_match_item:getRemainEndTimeText()
        ui.vars['timeLabel']:setString(end_time_text)

        ui.vars['okBtn']:registerScriptTapHandler(function() 
            local goto_select_scene_cb = function()
                UI_ClanWarSelectScene(struct_match)
            end

            g_clanWarData:click_gotoBattle(my_struct_match_item, attacking_struct_match, goto_select_scene_cb)
        end)
        ui.vars['cancelBtn']:registerScriptTapHandler(function() ui:close() end)
    end

    g_clanWarData:readyMatch(success_cb)
end

-------------------------------------
-- function responseStatusCB
-- @return true를 리턴하면 처리를 직접 했다는 뜻, false 라면 기존 에러메세지 처리 방법을 따름
-------------------------------------
function ServerData_ClanWar:responseStatusCB(ret, api_name)
    local ok_cb = function()
        UINavigatorDefinition:goTo('clan_war')
    end

    local invald_season_code = -1364
    local invald_day_code = -1351

    if (api_name == 'finish') then
        local msg = Str('제한 시간 초과로 패배하였습니다.')
        local sub_msg = Str('공격 제한 시간 2시간을 초과하거나, 날짜가 변경된 후 게임이 종료되면 패배로 처리됩니다.')
        if (ret['status'] == invald_day_code) then
            MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg, ok_cb)
            return true
        end

        if (ret['status'] == invald_season_code) then
            MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg, ok_cb)
            return true
        end

        return false
    end
    
    if (ret['status'] == invald_day_code) then
        local msg = Str('날짜가 변경되었습니다.')
        local sub_msg = Str('클랜전 정보가 갱신됩니다.')
        MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg, ok_cb)
        return true
    end

    if (ret['status'] == invald_season_code) then
        local msg = Str('시즌이 종료되었습니다.')
        local sub_msg = Str('클랜전 정보가 갱신됩니다.')
        MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg, ok_cb)
        return true
    end

    return false
end 


-------------------------------------
-- function getRountType
-- @brief 조별리그, 토너먼트 어떤 기간인지 리턴
-- @return ServerData_ClanWar.ROUNT_TYPE
-------------------------------------
function ServerData_ClanWar:getRountType()
    return self.m_clanWarRountType
end

-------------------------------------
-- function isGroupStage
-- @brief 조별리그 기간인지 여부
-- @return boolean
-------------------------------------
function ServerData_ClanWar:isGroupStage()
    return (self.m_clanWarRountType == ServerData_ClanWar.ROUNT_TYPE['GROUPSTAGE'])
end

-------------------------------------
-- function isTournament
-- @brief 토너먼트 기간인지 여부
-- @return boolean
-------------------------------------
function ServerData_ClanWar:isTournament()
    return (self.m_clanWarRountType == ServerData_ClanWar.ROUNT_TYPE['TOURNAMENT'])
end

-------------------------------------
-- function getMyClanGroup
-- @brief 내 클랜의 그룹
-- @return number 시점에 따라 nil이 리턴될 수 있다.
-------------------------------------
function ServerData_ClanWar:getMyClanGroup()
    return self.m_myClanGroup
end

-------------------------------------
-- function getDayOfWeekString
-- @brief 클랜전에서 사용하는 day로 무슨 요일인지 리턴
-- @param day 1~14 (클랜전 진행 기간)
-- @return string '월요일' ... '일요일'
-------------------------------------
function ServerData_ClanWar:getDayOfWeekString(day)
    local _day = (day % 7)
    if     (_day == 1) then return Str('일요일')
    elseif (_day == 2) then return Str('월요일')
    elseif (_day == 3) then return Str('화요일')
    elseif (_day == 4) then return Str('수요일')
    elseif (_day == 5) then return Str('목요일')
    elseif (_day == 6) then return Str('금요일')
    elseif (_day == 7) then return Str('토요일')
    else return ''
    end
end

-------------------------------------
-- function getRoundOfWeekString
-- @brief 클랜전에서 사용하는 round로 무슨 요일인지 리턴
-- @param round 64 ~ 1 (클랜전 토너먼트 진행 기간)
-- @return string '월' ... '일'
-------------------------------------
function ServerData_ClanWar:getRoundOfWeekString(round)
    if     (round >= 64) then return Str('일')
    elseif (round == 32) then return Str('월')
    elseif (round == 16) then return Str('화')
    elseif (round == 8) then return Str('수')
    elseif (round == 4) then return Str('목')
    elseif (round == 2) then return Str('금')
    elseif (round == 1) then return Str('토')
    else return ''
    end
end

-------------------------------------
-- function getClancoinRewardCount_atGroupStage
-- @brief 클랜전 조별리그에서 순위별 보상
-- @param rank 1~6
-- @return string '100' ... '350'
-------------------------------------
function ServerData_ClanWar:getClancoinRewardCount_atGroupStage(rank)
    if     (rank >= 5) then return Str('100')
    elseif (rank == 4) then return Str('110')
    elseif (rank == 3) then return Str('120')
    elseif (rank == 2) then return Str('180')
    elseif (rank == 1) then return Str('180')
    elseif (rank <= 0) then return '-'
    else return ''
    end
end

-------------------------------------
-- function getClancoinRewardCount
-- @brief 클랜전에서 라운드별 보상
-- @param round 64 ~ 1 (클랜전 토너먼트 진행 기간)
-- @return string '100' ... '350'
-------------------------------------
function ServerData_ClanWar:getClancoinRewardCount(round)
    if     (round >= 64) then return Str('180')
    elseif (round == 32) then return Str('200')
    elseif (round == 16) then return Str('220')
    elseif (round == 8) then return Str('240')
    elseif (round == 4) then return Str('270')
    elseif (round == 2) then return Str('300')
    elseif (round == 1) then return Str('350')
    else return ''
    end
end

-------------------------------------
-- function getMyClanState
-- @brief 내가 소속된 클랜의 클랜전 상태
-- @return ServerData_ClanWar.CLANWAR_CLAN_STATE
--
-------------------------------------
function ServerData_ClanWar:getMyClanState()
    -- 1. 조별리그 정보가 없으면 미참가 클랜
    if (self.m_myClanGroupStageInfo == nil) then
        return ServerData_ClanWar.CLANWAR_CLAN_STATE['NOT_PARTICIPATING']
    end

    -- 2. 토너먼트 정보가 없거나, 토너먼트 진행 라운드보다 내 클랜의 진행 정도가 낮으면 탈락
    if (self:isTournament() == true) then
        -- 토너먼트 데이터가 없으면 탈락으로 같주
        if (self.m_myClanTournamentInfo == nil) then
            return ServerData_ClanWar.CLANWAR_CLAN_STATE['LEAVING_OUT']
        end

        -- 오늘 진행되는 라운드 (128강, 64강 등)
        local today_round = self:getTodayRound() -- 오늘 32강이라고 가정
        local my_clan_round = self.m_myClanTournamentInfo['group_stage'] -- 내 클랜은 64강이라고 가정

        -- 오늘 32강인데 내 클랜은 64강이면 탈락
        if (today_round < my_clan_round) then
            return ServerData_ClanWar.CLANWAR_CLAN_STATE['DEFEAT_IN_TOURNAMENT']
        end
    end

    -- 위의 조건에 해당하지 않은 경우 참가 중
    return ServerData_ClanWar.CLANWAR_CLAN_STATE['PARTICIPATING']
end