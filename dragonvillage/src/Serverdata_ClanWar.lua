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
function Serverdata_ClanWar:makerequest_clanWarTournamentTreeDump()
	--[[
	local ret =
	{
		['round_64'] = 
		{
			{
				['1_clanid'] = 1, -- Ŭ�� id =  Ŭ�� �ѹ�
				['2_clanid'] = 2,
				['win'] = 1		  -- �̱� Ŭ�� �ѹ�
			},
			{
				['1_clanid'] = 1, -- Ŭ�� id =  Ŭ�� �ѹ�
				['2_clanid'] = 2,
				['win'] = 1
			},.....
		},
		['round_32'] = 
		{
				['1_clanid'] = 1, -- Ŭ�� id =  Ŭ�� �ѹ�
				['2_clanid'] = 2,
				['win'] = 1
		},.....

	}
	--]]
	local make_round_func = function(table, round)
		for i=1,round do
			table['round_' .. round] = {}
			local t_round = {
				['1_clanid'] = 1, -- Ŭ�� id =  Ŭ�� �ѹ�
				['2_clanid'] = 2,
				['win'] = 1	
			}
			table.insert(table['round_' .. round], t_round)
		end

		return table['round_' .. round]
	end

	local ret = {}
	local l_round = {2,4,8,16,32,64}
	for _, round in ipairs(l_round) do
		make_round_func(ret, round)
	end
	return ret

end

-------------------------------------
-- function request_clanWarTournamentTree
-------------------------------------
function Serverdata_ClanWar:request_clanWarTournamentTree()

	local ret = self:makerequest_clanWarTournamentTreeDump()
    --local success_cb = function(ret)
		return ret
    --end
	--[[
    -- ���� ID
    local uid = g_userData:get('uid')
    
    -- ��Ʈ��ũ ���
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
    -- ���� ID
    local uid = g_userData:get('uid')
    
    -- ��Ʈ��ũ ���
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

