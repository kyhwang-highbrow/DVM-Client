local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())
-------------------------------------
-- class UI_ClanWarLobby
-------------------------------------
UI_ClanWarLobby = class(PARENT, {
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanWarLobby:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanWarLobby'
    self.m_titleStr = Str('클랜전')
	--self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanWarLobby:click_exitBtn()
    self:close()
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLobby:init(ret)
    local vars = self:load('clan_war_lobby.ui')
    UIManager:open(self, UIManager.SCENE)


    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:closeUI() end, 'UI_ClanWarLobby')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 초기화
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

    -- 1~7일차에는 리그 화면
	if ret['league_info'] then
        local ui_clen_war_league = UI_ClanWarLeague(vars, self.root)
        ui_clen_war_league:refreshUI(nil, ret)

		ui_clen_war_league.m_closeCB = self.closeUI

		g_clanWarData:setIsLeague(true)
    -- 8~14일차에는 토너먼트 화면
	else
        if (#ret['tournament_info'] == 0) then
            return
        end
        
        local ui_clan_war_tournament = UI_ClanWarTournamentTree(vars, self.root)
        ui_clan_war_tournament:setTournamentData(ret)
		g_clanWarData:setIsLeague(false)
    end
    
    vars['tournamentMenu']:setVisible(g_clanWarData:getIsLeague())
    vars['leagueMenu']:setVisible(not g_clanWarData:getIsLeague())

	-- 테스트용 버튼
    vars['testTomorrowBtn']:registerScriptTapHandler(function() 
        g_clanWarData:request_testNextDay() 
        UIManager:toastNotificationRed('다음날이 되었습니다. ESC로 나갔다가 다시 진입해주세요')
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
    vars['helpBtn']:registerScriptTapHandler(function() UI_HelpClan('clan_war') end)
end


