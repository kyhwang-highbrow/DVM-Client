-------------------------------------
-- class Serverdata_ClanWar
-- @instance g_clanWarData
-------------------------------------
Serverdata_ClanWar = class({
    -- 오픈/종료 시간
    m_startTime = 'number',
    m_endTime = 'number',

    m_myClan = 'StructClanWar',
    m_opponentClan = 'StructClanWar',

    -- 방어덱
    m_myDefenceDeck = 'list',

    -- ex)32강
    m_curRound = 'number',
    
    -- ex)3경기
    m_curPlay = 'number',

    -- ex)3조
    m_curClanTeam = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function Serverdata_ClanWar:init()

end

-------------------------------------
-- function request_clanWarInfo
-------------------------------------
function Serverdata_ClanWar:request_clanWarInfo()

end

-------------------------------------
-- function request_clanWarTournamentTree
-------------------------------------
function Serverdata_ClanWar:request_clanWarTournamentTree()

	local ret = StructClanWarTournament.makeDummy()
    --local success_cb = function(ret)
		return StructClanWarTournament(ret)
    --end
	--[[
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clan_war/league_info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
	--]]
end

-------------------------------------
-- function request_clanWarLeagueInfo
-------------------------------------
function Serverdata_ClanWar:request_clanWarLeagueInfo(team)
	local ret = StructClanWarLeague.makeDummy()

    --local success_cb = function(ret)
		return StructClanWarLeague(ret)
    --end
	--[[
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clan_war/league_info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
	--]]
end

