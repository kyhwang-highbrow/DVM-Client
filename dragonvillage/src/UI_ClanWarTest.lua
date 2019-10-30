local PARENT = UI

-------------------------------------
-- class UI_ClanWarTest
-------------------------------------
UI_ClanWarTest = class(PARENT, {
        m_data = ''
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTest:init(cb_func, is_league)
    local vars = self:load('clan_war_set_score_test.ui')
    UIManager:open(self, UIManager.POPUP)

    if (is_league) then
        self:setLeagueTest(cb_func)
    else
        self:setTournamentTest()
    end
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarTest')

    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function setLeagueTest
-------------------------------------
function UI_ClanWarTest:setTournamentTest()
    local vars = self.vars

    vars['tournamentTabMenu']:setVisible(true)
    vars['leagueTabMenu']:setVisible(false)
    vars['applyBtn']:setVisible(false)

    local is_left = g_clanWarData:getIsMyClanLeft()
    vars['resultWinBtn']:registerScriptTapHandler(function() g_clanWarData:request_myClanResult(is_left) end)
    vars['resultLoseBtn']:registerScriptTapHandler(function() g_clanWarData:request_myClanResult(not is_left) end)
end

-------------------------------------
-- function setLeagueTest
-------------------------------------
function UI_ClanWarTest:setLeagueTest(cb_func)
    local vars = self.vars

    vars['tournamentTabMenu']:setVisible(false)
    vars['leagueTabMenu']:setVisible(true)

    self.m_data = {}
    self.m_data['match'] = 0
    self.m_data['win'] = 0
    self.m_data['lose'] = 0


    local l_key = {'match', 'win', 'lose'}
    for _, key in ipairs(l_key) do
        vars[key .. 'NumberLabel']:setString(self.m_data[key])
        vars[key .. 'DownBtn']:registerScriptTapHandler(function() self.m_data[key] = self.m_data[key] - 1 self:leagueRefresh() end)
        vars[key .. 'UpBtn']:registerScriptTapHandler(function() self.m_data[key] = self.m_data[key] + 1 self:leagueRefresh() end)
    end

    vars['applyBtn']:registerScriptTapHandler(function() cb_func(self.m_data) self:close()  end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close()  end)
end

-------------------------------------
-- function leagueRefresh
-------------------------------------
function UI_ClanWarTest:leagueRefresh(data)
    local vars = self.vars
    local l_key = {'match', 'win', 'lose'}
    for _, key in ipairs(l_key) do
        vars[key .. 'NumberLabel']:setString(self.m_data[key])
    end
end

