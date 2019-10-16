local PARENT = UI

-------------------------------------
-- class UI_ClanWarLeague
-------------------------------------
UI_ClanWarLeague = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeague:init()
    local vars = self:load('clan_war_tournament_tree.ui')
    UIManager:open(self, UIManager.POPUP)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarLeague')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarLeague:initButton()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarLeague:initUI()
	local vars = self.vars
end

-------------------------------------
-- function setMatchList
-------------------------------------
function UI_ClanWarLeague:refresh(team)
    local vars = self.vars
    local struct_clanwar_league = g_clanWarData:request_clanWarLeagueInfo(team)

    local str_match = ''
    for day = 1, 5 do
        -- 경기 리스트 출력
	    local l_league = struct_clanwar_league:getClanWarLeagueList(day)
	    for _, data in ipairs(l_league) do
	    	local clan_a = data['clan_A'] or ''
	    	local clan_b = data['clan_B'] or ''
	    	str_match = str_match .. clan_a .. ' VS ' .. clan_b
	    	str_match = str_match .. '\n'
	    end  
    end
    vars['matchLabel']:setString(str_match)

	-- 랭크 출력
	local str = ''
	local l_rank = struct_clanwar_league:getClanWarLeagueRankList()
	for rank ,data in ipairs(l_rank) do
		local clan_number = data['clan_number']
		local clan_id = struct_clanwar_league:getClanId(clan_number)
		str = str .. rank .. '등 : ' .. clan_id
		str = str .. '\n'
	end
	vars['rankLabel']:setString(str)
end
