-------------------------------------
-- class ServerData_ClanWar
-- @instance g_clanWarData
-------------------------------------
ServerData_ClanWar = class({
    m_isMyClanLeft = 'boolean', -- Test API������ ���Ǵ� ��
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanWar:init()

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
        local struct_matching_my_clan = StructClanWarMatch(ret['clanwar_match_info'])
        local struct_matching_enemy_clan = StructClanWarMatch(ret['clanwar_match_info_enemy'])

        return success_cb(struct_matching_my_clan, struct_matching_enemy_clan)
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