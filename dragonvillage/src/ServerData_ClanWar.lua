-------------------------------------
-- class ServerData_ClanWar
-- @instance g_clanWarData
-------------------------------------
ServerData_ClanWar = class({
    m_isMyClanLeft = 'boolean', -- Test API?癒?퐣筌??????롫뮉 揶?
	m_isLeague = 'boolean',

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

	m_tSeasonRewardInfo = 'table', -- 시즌보상
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
-- function applyClanWarReward
-------------------------------------
function ServerData_ClanWar:applyClanWarReward(ret)
	if (ret['reward_clan_info']) then
		
		self.m_tSeasonRewardInfo = {}
		self.m_tSeasonRewardInfo['reward_clan_info'] = ret['reward_clan_info']
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
-------------------------------------
function ServerData_ClanWar:request_clanWarLeagueInfo(team, success_cb)
    local league = team
	local finish_cb = function(ret)
        -- ?⑤벉猷??곗쨮 ServerData_ClanWar?????貫由???類ｋ궖??
		
        self.m_clanWarDay = ret['clanwar_day'] or 0
		self.m_clanWarDayData = ret['clan_data']
		g_clanWarData:applyClanWarInfo(ret['clanwar_info'])
		g_clanWarData:applyClanWarReward(ret)

		if (self.m_clanWarDay < 7) then
			g_clanWarData:setClanInfo(ret['league_clan_info'])
		else
			g_clanWarData:setClanInfo(ret['tournament_clan_info'])
            g_clanWarData:setClanInfo(ret['league_clan_info'])
		end
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
-- function request_nextDay
-------------------------------------
function ServerData_ClanWar:request_testNextDay()
    -- ?醫? ID
    local uid = g_userData:get('uid')
    
    -- ??쎈뱜??곌쾿 ???뻿
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
    
    local struct_user_info = StructUserInfoClanWar()

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

    -- 이미 전투 시작한 유저가 있다면 정보 갱신을 위해 밖으로 보내줌
    local ok_cb = function()
        UINavigatorDefinition:goTo('clan_war', true)
    end
    
    -- 응답 상태 처리 함수
    local t_error = {
        [-3871] = Str('이미 클랜 던전에 입장한 유저가 있습니다.'),
    }
    local response_status_cb = MakeResponseCB(t_error, ok_cb)


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
        -- 전투 후 공격자 기록 갱신
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
            MakeSimplePopup(POPUP_TYPE.OK, Str('클랜전 시즌이 종료되었습니다.'), ok_cb)
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
    ui_network:setParam('gamekey', g_gameScene.m_gameKey)
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
-- function isMyClanWarMatchAttackingState
-- @warning! 嚥≪뮆??癒?퐣 ???뻿?????춸 揶쏄퉮???롫뮉 ?類ｋ궖??
-- @brief 獄쏄퀡瑗?筌〓씭????袁⑹뒄???類ｋ궖 ?귐뗪쉘
-------------------------------------
function ServerData_ClanWar:isMyClanWarMatchAttackingState()
	if (self.m_myMatchInfo) then
		local is_attacking = (self.m_myMatchInfo:getAttackState() == StructClanWarMatchItem.ATTACK_STATE['ATTACKING'])
		local attack_uid = self.m_myMatchInfo:getAttackingUid()
		local end_date = self.m_myMatchInfo:getEndDate() or ''
		return is_attacking, attack_uid, end_date
	end
end

-------------------------------------
-- function readyMatch
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
-------------------------------------
function ServerData_ClanWar:click_gotoBattle(my_struct_match_item, opponent_struct_match_item, goto_select_scene_cb)
    local is_do_all_game = my_struct_match_item:isDoAllGame()
    if (is_do_all_game) then
        UIManager:toastNotificationRed(Str('공격 기회를 모두 사용하였습니다.'))
        return
    end

    local attacking_uid = my_struct_match_item:getAttackingUid()
    -- 이미 공격한 상대가 있는 경우
    if (attacking_uid) then
        local finish_cb = function()
            if (not g_clanWarData:getEnemyUserInfo()) then
                UIManager:toastNotificationRed(Str('설정된 덱이 없는 상대 클랜원입니다.'))
                return
            end
            UI_MatchReadyClanWar(opponent_struct_match_item, my_struct_match_item)
        end

        g_clanWarData:requestEnemyUserInfo(attacking_uid, finish_cb)
    else
        if (goto_select_scene_cb) then
            goto_select_scene_cb()
        end
    end
end

-------------------------------------
-- function showPromoteGameStartPopup
-------------------------------------
function ServerData_ClanWar:showPromoteGameStartPopup()    
    local success_cb = function(struct_match)
        local my_uid = g_userData:get('uid')
        local my_struct_match_item = struct_match:getMatchMemberDataByUid(my_uid)
        local attack_uid = my_struct_match_item:getAttackingUid()

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
        ui_item:setStructMatch(struct_match)
        ui.vars['rivalItemNode']:addChild(ui_item.root)

        local end_time = my_struct_match_item:getEndDate()
        local cur_time = Timer:getServerTime_Milliseconds()
        local remain_time = (end_time - cur_time)/1000
        local hour = math.floor(remain_time / 3600)
        local min = math.floor(remain_time / 60) % 60
        if (remain_time > 0) then
            ui.vars['timeLabel']:setString(Str('남은 공격 시간 {1}:{2} 남음', hour, min))    
        else
            ui.vars['timeLabel']:setString('')
        end

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
