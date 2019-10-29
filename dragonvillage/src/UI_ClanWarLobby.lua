local PARENT = UI

-------------------------------------
-- class UI_ClanWarLobby
-------------------------------------
UI_ClanWarLobby = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLobby:init()
    local vars = self:load('clan_war_lobby.ui')
    UIManager:open(self, UIManager.SCENE)


    -- �� ��ȯ ȿ��
    self:sceneFadeInAction()

    -- backkey ����
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanWarLobby')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- �ʱ�ȭ
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarLobby:initUI()
    local vars = self.vars

    local is_tournament = false
    local success_cb = function(ret)
        if ret['league_info'] then
            local ui_clen_war_league = UI_ClanWarLeague(vars)
            ui_clen_war_league:setLeagueData(ret)
            is_tournament = false
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
    end
    g_clanWarData:request_clanWarLeagueInfo(nil, success_cb)

    
    vars['testBtn']:registerScriptTapHandler(function() UI_ClanWarLeagueTest(cb_func) end)
    vars['testTomorrowBtn']:registerScriptTapHandler(function() 
        g_clanWarData:request_testNextDay() 
        UIManager:toastNotificationRed('�������� �Ǿ����ϴ�. ESC�� �����ٰ� �ٽ� �������ּ���')
    end)  
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanWarLobby:click_exitBtn()
    local scene = SceneLobby()
    scene:runScene()
end
