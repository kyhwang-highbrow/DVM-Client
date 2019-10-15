-------------------------------------
-- class Serverdata_ClanWar
-- @instance g_clanWarData
-------------------------------------
Serverdata_ClanWar = class({
    -- ����/���� �ð�
    m_startTime = 'number',
    m_endTime = 'number',

    m_myClan = 'StructClanWar',
    m_opponentClan = 'StructClanWar',

    -- ��
    m_myDefenceDeck = 'list',

    -- ex)32��
    m_curRound = 'number',
    
    -- ex)3���
    m_curPlay = 'number',

    -- ex)3��
    m_curClanTeam = 'number',
})


-------------------------------------
-- function request_clanWarInfo
-------------------------------------
function Serverdata_ClanWar:request_clanWarInfo()

end

-------------------------------------
-- function request_clanWarTournamentTree
-------------------------------------
function Serverdata_ClanWar:request_clanWarTournamentTree()

end

-------------------------------------
-- function request_clanWarTeamChart
-------------------------------------
function Serverdata_ClanWar:request_clanWarTeamChart(team, day)
    local l_day_match
    local l_rank
    
    local success_cb = function(ret)
        local l_day_match =  ret['day_match_list']
        local l_rank = ret['rank_list']
    end
    -- ���� ID
    local uid = g_userData:get('uid')
    
    -- ��Ʈ��ũ ���
    local ui_network = UI_Network()
    ui_network:setUrl('/clan_war/team_league')
    ui_network:setParam('uid', uid)
    ui_network:setParam('day', day)
    ui_network:setParam('team', team)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end
