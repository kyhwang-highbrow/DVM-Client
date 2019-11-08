-------------------------------------
-- class ServerData_ClanWar
-- @instance g_clanWarData
-------------------------------------
ServerData_ClanWar = class({
    m_isMyClanLeft = 'boolean', -- Test API������ ���Ǵ� ��

    m_tClanInfo = 'table - StructClanRank',

    m_clanWarDay = 'number',

    -- Ŭ�������� �ºٴ� �÷��̾�/��� �÷��̾� ���� ����
    m_playerUserInfo = 'StructArenaUserInfo',
    m_OpponentUserInfo = 'StructArenaUserInfo',
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
	local t_day = {[7] = 128, [8] = 64, [9] = 32, [10] = 16, [11] = 8, [12] = 4, [13] = 2, [14] = 1}
	return t_day[self.m_clanWarDay] or 0
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
        local l_matching_my_clan = ret['clanwar_match_info']
        local l_matching_enemy_clan = ret['clanwar_match_info_enemy']

        local t_matching_my_clan = self:responseClanwarMatchInfo(l_matching_my_clan)
        local t_matching_enemy_clan = self:responseClanwarMatchInfo(l_matching_enemy_clan)

        -- ���� ���� ������� ��� �������� ä����
        local _t_matching_my_clan = StructClanWarMatch.makeDefendInfo(t_matching_my_clan, t_matching_enemy_clan)
        local _t_matching_enemy_clan = StructClanWarMatch.makeDefendInfo(t_matching_enemy_clan, t_matching_my_clan)
        return success_cb(_t_matching_my_clan, _t_matching_enemy_clan)
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
		local struct_user_info = StructUserInfoArena()
    
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

		local t_deck_data = g_deckData:getDeck_lowData(DECK_CHALLENGE_MODE)
		struct_user_info:applyPvpDeckData(t_deck_data)

		self.m_playerUserInfo = struct_user_info
	end

    -- �� ����
    if t_deck then
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
-- function getStructUserInfo_Player
-------------------------------------
function ServerData_ClanWar:getStructUserInfo_Player()
    local l_deck, formation, deckname, leader, tamer_id = g_deckData:getDeck('clan_war')
    local t_data = {}
    t_data['formation'] = formation
    t_data['leader'] = leader
    t_data['tamer'] = tamer_id
    t_data['deck'] = l_deck
    g_clanWarData:refresh_playerUserInfo(t_data)
    
    local struct_user_info = g_clanWarData:getPlayerUserInfo()
    return struct_user_info
end

-------------------------------------
-- function request_arenaStart
-------------------------------------
function ServerData_ClanWar:request_arenaStart(enemy_uid, finish_cb)
    -- ���� ID
    local uid = g_userData:get('uid')

    -- �������� �ݷμ��� ������ ����
    local combat_power = g_clanWarData.m_playerUserInfo:getDeckCombatPower(true)
    
    -- ���� �ݹ�
    local function success_cb(ret)

        -- staminas, cash ����ȭ
        g_serverData:networkCommonRespone(ret)

        self.m_gameKey = ret['gamekey']
        --vs_dragons
        --vs_runes
        --vs_deck
        --vs_info

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

    local l_deck = self.m_playerUserInfo:getDeck_dragonList(true)

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