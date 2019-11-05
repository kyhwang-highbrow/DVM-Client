local PARENT = UI

-------------------------------------
-- class UI_ClanWarLobby
-------------------------------------
UI_ClanWarLobby = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLobby:init(ret)
    local vars = self:load('clan_war_lobby.ui')
    UIManager:open(self, UIManager.SCENE)


    -- �� ��ȯ ȿ��
    self:sceneFadeInAction()

    -- backkey ����
    g_currScene:pushBackKeyListener(self, function() self:closeUI() end, 'UI_ClanWarLobby')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- �ʱ�ȭ
    self:initUI(ret)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarLobby:initUI(ret)
    local vars = self.vars

    local is_tournament = false

    -- 1~7�������� ���� ȭ��
	if ret['league_info'] then
        local ui_clen_war_league = UI_ClanWarLeague(vars)
        ui_clen_war_league:refreshUI(nil, ret)
        is_tournament = false

		ui_clen_war_league.m_closeCB = self.closeUI
    -- 8~14�������� ��ʸ�Ʈ ȭ��
	else
        if (#ret['tournament_info'] == 0) then
            return
        end
        
        local ui_clan_war_tournament = UI_ClanWarTournamentTree(vars)
        ui_clan_war_tournament:setTournamentData(ret)
        is_tournament = true
    end
    
    vars['tournamentMenu']:setVisible(is_tournament)
    vars['leagueMenu']:setVisible(not is_tournament)

	-- �׽�Ʈ�� ��ư
    vars['testTomorrowBtn']:registerScriptTapHandler(function() 
        g_clanWarData:request_testNextDay() 
        UIManager:toastNotificationRed('�������� �Ǿ����ϴ�. ESC�� �����ٰ� �ٽ� �������ּ���')
    end)  
end

-------------------------------------
-- function closeUI
-------------------------------------
function UI_ClanWarLobby:closeUI()
    self:close()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarLobby:initButton()
    local vars = self.vars

    vars['startBtn']:registerScriptTapHandler(function() self:click_gotoMatch() end)
end

-------------------------------------
-- function click_gotoMatch
-------------------------------------
function UI_ClanWarLobby:click_gotoMatch()
    --local success_cb = function(struct_match_my_clan, struct_match_enemy_clan)
        local ui_clan_war_matching = UI_ClanWarMatchingScene(struct_match_my_clan, struct_match_enemy_clan)
    --end

    --g_clanWarData:request_clanWarMatchInfo(success_cb)
end
