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


    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanWarLobby')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 초기화
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
            UI_ClanWarTournamentTree(vars)
            is_tournament = true
        end
        
        vars['tournamentMenu']:setVisible(is_tournament)
        vars['leagueMenu']:setVisible(not is_tournament)
    end
    g_clanWarData:request_clanWarLeagueInfo(nil, success_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanWarLobby:click_exitBtn()
    local scene = SceneLobby()
    scene:runScene()
end
