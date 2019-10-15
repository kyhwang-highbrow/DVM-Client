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
    UIManager:open(self, UIManager.POPUP)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarLobby')

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
function UI_ClanWarLobby:initButton()
	local vars = self.vars

	vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['tournamentTreeBtn']:registerScriptTapHandler(function() self:click_tournamentTreeBtn() end)
end

-------------------------------------
-- function click_startBtn
-------------------------------------
function UI_ClanWarLobby:click_startBtn()
	UI_ClanWarListScene()
end

-------------------------------------
-- function click_tournamentTreeBtn
-------------------------------------
function UI_ClanWarLobby:click_tournamentTreeBtn()
	UI_ClanWarTournamentTree()
    --UI_ClanWarTeamChart()
end