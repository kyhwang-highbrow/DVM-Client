-------------------------------------
-- class ServerData_ClanWar
-- @instance g_clanWarData
-------------------------------------
ServerData_ClanWar = class({
    m_isMyClanLeft = 'boolean', -- Test API������ ���Ǵ� ��

    m_tClanInfo = 'table - StructClanRank',

    m_clanWarDay = 'number',

    -- Ŭ�������� �ºٴ� �÷��̾�/��� �÷��̾� ���� ����
    m_playerUserInfo = 'StructUserInfoClanWar',
    m_OpponentUserInfo = 'StructUserInfoClanWar',

    m_gameKey = 'string',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanWar:init()
    self.m_tClanInfo = {}
    self.m_clanWarDay = 0
end

-------------------------------------
-- function request_clanWarInfo
-------------------------------------
function ServerData_ClanWar:request_clanWarInfo()

end

-------------------------------------
-- function request_myClanResult
-------------------------------------
function ServerData_ClanWar:request_myClanResult(my_clan_is_left)
    local left_score, right_score = 0, 0 
    -- �� Ŭ���� �¸��ϵ��� ���� ����
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
        -- �������� ServerData_ClanWar�� ����Ǵ� ������
		g_clanWarData:setClanInfo(ret['clan_info'])
        self.m_clanWarDay = ret['clanwar_day']
        
		-- 1 ~ 7�ϱ����� StructClanWarLeague
		-- 8 ~ 14�ϱ����� StructClanWarTournament ���·� �����
        success_cb(ret)
	end

    -- ���� ID
    local uid = g_userData:get('uid')
    
    -- ��Ʈ��ũ ���
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
-- function getTodayRound
-------------------------------------
function ServerData_ClanWar:getTodayRound()
	-- 8������ 64��, 7������ 32�� ...
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

    -- ���� ID
    local uid = g_userData:get('uid')
    
    -- ��Ʈ��ũ ���
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
    -- ���� ID
    local uid = g_userData:get('uid')
    
    -- ��Ʈ��ũ ���
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
    
    -- ���� ID
    local uid = g_userData:get('uid')
    local clan_id = self:getMyClanId()
    
    -- ��Ʈ��ũ ���
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
    
    -- ���� ID
    local uid = g_userData:get('uid')
    
    -- ��Ʈ��ũ ���
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
-- @brief �÷��̾� ���� ����
-------------------------------------
function ServerData_ClanWar:refresh_playerUserInfo(t_deck)
	if (not self.m_playerUserInfo) then
		local struct_user_info = StructUserInfoClanWar()
    
		struct_user_info.m_uid = g_userData:get('uid')
		struct_user_info.m_lv = g_userData:get('lv')
		struct_user_info.m_nickname = g_userData:get('nick')	

		-- Ŭ��
		local struct_clan = g_clanData:getClanStruct()
		if (struct_clan) then
			struct_user_info.m_userData = struct_clan:getClanName()
		else
			struct_user_info.m_userData = ''
		end
		self.m_playerUserInfo = struct_user_info
	end

    if (t_deck) then
	    self.m_playerUserInfo:applyPvpDeckData(t_deck)
    end
end

-------------------------------------
-- function getUserInfo
-- @brief �÷��̾� ���� ����
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
        return
    end
    
    local struct_user_info = StructUserInfoArena()

    -- �⺻ ���� ����
    struct_user_info.m_uid = data['uid']
    struct_user_info.m_nickname = data['nick']
    struct_user_info.m_lv = data['lv']
    struct_user_info.m_tamerID = data['tamer']
    struct_user_info.m_leaderDragonObject = StructDragonObject(data['leader'])
    struct_user_info.m_tier = data['tier']
    struct_user_info.m_rank = data['rank']
    struct_user_info.m_rankPercent = data['rate']
    
    -- �ݷμ��� ���� ����
    struct_user_info.m_rp = data['rp']
    struct_user_info.m_matchResult = data['match']
    
    struct_user_info:applyRunesDataList(data['runes']) --�ݵ�� �巡�� ���� ���� ���� �����ؾ���
    struct_user_info:applyDragonsDataList(data['dragons'])
    
    -- �� ���� (��ġ����Ʈ�� �Ѿ���� ���� �ش� ������ ��)
    struct_user_info:applyPvpDeckData(data['deck'])
    
    -- Ŭ��
    if (data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(data['clan_info'])
        struct_user_info:setStructClan(struct_clan)
    end
    
    g_clanWarData:setEnemyUserInfo(struct_user_info)
end

-------------------------------------
-- function setEnemyUserInfo
-- @brief �÷��̾� ���� ����
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
    -- ���� ID
    local uid = g_userData:get('uid')
    
    -- ���� �ݹ�
    local function success_cb(ret)

        -- staminas, cash ����ȭ
        g_serverData:networkCommonRespone(ret)

        self.m_gameKey = ret['gamekey']

        -- ���� �÷��� �ð� �α׸� ���� üũ Ÿ�� ����
        g_accessTimeData:startCheckTimer()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- ��Ʈ��ũ ���
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

    local function success_cb(ret)
        if next_func then
            next_func()
        end
    end

    -- true�� �����ϸ� ��ü������ ó���� �Ϸ��ߴٴ� ��
    local function response_status_cb(ret)
        -- invalid season
        if (ret['status'] == -1364) then
            -- �κ�� �̵�
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('������ ����Ǿ����ϴ�.'), ok_cb)
            return true
        end
        return false
    end

    -- ��庰 API �ּ� �б�ó��
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
    ui_network:setParam('clear_time', play_time)
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

    -- ���� ID
    local _uid = uid or g_userData:get('uid')
    
    -- ���� �ݹ�
    local function success_cb(ret)
        if (finish_cb) then
            finish_cb(ret['deck_info'])
        end
    end

    -- ��Ʈ��ũ ���
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

    -- ���� ID
    local uid = g_userData:get('uid')

    -- ���� �ݹ�
    local function success_cb(ret)
        local t_data = nil
        local t_deck = ret['deck']
        self:refresh_playerUserInfo(t_deck)
        g_deckData:setDeck_usedDeckPvp('clan_war', l_deck)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- ��Ʈ��ũ ���
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