-------------------------------------
-- class UI_ClanWarLeague
-------------------------------------
UI_ClanWarLeague = class({
        m_teamCnt = 'number',
        vars = '',

        m_structLeague = 'StructClanWarLeague',

        m_selctedTeam = 'number',
        m_scrollBtnTableView = 'TableView',
        m_todayMatch = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeague:init(vars)
    self.vars = vars
    self.m_teamCnt = 16 -- 임시
	self.m_selctedTeam = 1 -- 임시
    self.m_todayMatch = 3

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

    vars['startBtn']:registerScriptTapHandler(function() UI_MatchReadyClanWar() end)
    vars['allRankTabBtn']:registerScriptTapHandler(function() self:click_allBtn() end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarLeague:initUI()
	local vars = self.vars
    self:setScrollButton()
end

-------------------------------------
-- function setRankList
-------------------------------------
function UI_ClanWarLeague:setRankList(struct_league)
    local vars = self.vars
    
    local struct_clanwar_league = struct_league or self.m_structLeague
    local l_rank_item = {}
	
    -- 랭크 출력
	local l_rank = struct_clanwar_league:getClanWarLeagueRankList()

    vars['rankListNode']:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['rankListNode'])
    table_view:setCellUIClass(UI_ClanWarLeagueRankListItem)
    table_view.m_defaultCellSize = cc.size(460, 65)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank, false)
    return table_view
end

-------------------------------------
-- function setMatchList
-------------------------------------
function UI_ClanWarLeague:setMatchList()
    local vars = self.vars

    local struct_clanwar_league = self.m_structLeague

    local l_match = {}
    for day = 1, 5 do
        -- 경기 리스트 출력
	    local l_league = struct_clanwar_league:getClanWarLeagueList(day)
	    for _, data in ipairs(l_league) do
            data['day'] = day
	    	table.insert(l_match, data)
	    end  
    end

    local create_func = function(ui, data)
        local is_win = struct_clanwar_league:isWin(ui.m_clanA, ui.m_clanB)
        ui:setResult(is_win)
    end

    vars['leagueListNode']:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['leagueListNode'])
    table_view:setCellUIClass(UI_ClanWarLeagueMatchListItem, create_func)
    table_view.m_defaultCellSize = cc.size(460, 65)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_match, false)

    local first_y = -446
    local cnt_block = 3 * (self.m_todayMatch-1)
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view.m_scrollView:setContentOffset(cc.p(0, first_y + 64*cnt_block), animated)
end

-------------------------------------
-- function setScrollButton
-------------------------------------
function UI_ClanWarLeague:setScrollButton()
    local vars = self.vars
    local scroll_node = vars['tableViewNode']
    local l_button = {}

    for i = 1, self.m_teamCnt do
        table.insert(l_button, {['idx'] = i, ['selected_team'] = self.m_selctedTeam})
    end

    local create_cb = function(ui, data)
        ui.vars['teamTabBtn']:getParent():setSwallowTouch(false)
        ui.vars['teamTabBtn']:registerScriptTapHandler(function()
            local team_idx = ui.m_idx
            self.m_selctedTeam = team_idx
            self:refresh(team_idx)
        end)
    end

    scroll_node:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(scroll_node)
    table_view:setCellUIClass(UI_ClanWarLeagueBtnListItem, create_cb)
    table_view.m_defaultCellSize = cc.size(110, 71)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_button, false)

    self.m_scrollBtnTableView = table_view
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarLeague:refresh(team)    
    local success_cb = function(ret)
        self.m_structLeague = StructClanWarLeague(ret)
        --self.m_selctedTeam = self.m_structLeague:getMyClanTeamNumber()
        self.m_todayMatch = ret['clanwar_day']
        
        self:setScrollButton()
        self:setRankList()
        self:setMatchList()
    end

    g_clanWarData:request_clanWarLeagueInfo(team, success_cb) --team 을 nil로 요청하면 자신 클랜이 속한 조 정보가 내려옴
end

-------------------------------------
-- function click_allBtn
-------------------------------------
function UI_ClanWarLeague:click_allBtn()
    local success_cb = function(ret)
        local l_struct_clan_war = {}
        for _, data in ipairs(ret) do
            table.insert(l_struct_clan_war,  StructClanWarLeague(data))
        end
        
        self:setAllRank(l_struct_clan_war)
    end    
    g_clanWarData:request_clanWarLeagueInfo(99, success_cb) -- 모든 클랜 정보 요청
end

-------------------------------------
-- function setAllRank
-------------------------------------
function UI_ClanWarLeague:setAllRank(l_struct_clan_war)
    local vars = self.vars

    vars['leagueListNode']:removeAllChildren()
    vars['rankListNode']:removeAllChildren()

    for i, struct_clan_war_league in ipairs(l_struct_clan_war) do
        local table_view = self:setRankList(struct_clan_war_league)
        table_view.m_node:setScale(0.5)
        table_view.m_node:setPositionY(50)
    end
end


























local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarLobby
-------------------------------------
UI_ClanWarLeagueBtnListItem = class(PARENT, {
        m_idx = 'number'
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueBtnListItem:init(data)
    local vars = self:load('clan_war_lobby_item_btn.ui')
    if (not data) then
        return
    end
    
    self.m_idx = data['idx'] or ''
    vars['teamTabLabel']:setString(self.m_idx .. '조')
    if (tonumber(self.m_idx) == tonumber(data['selected_team'])) then
        vars['teamTabEnabledBtn']:setVisible(true)
        vars['teamTabEnabledLabel']:setString(self.m_idx .. '조')
    end
end





local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarLeagueRankListItem
-------------------------------------
UI_ClanWarLeagueRankListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueRankListItem:init(data)
    local vars = self:load('clan_war_lobby_item_rank.ui')

    local struct_clan_rank = data['clan_info']
    local clan_name = struct_clan_rank:getClanName()
    local clan_rank = struct_clan_rank:getClanRank()

    local clan_id = StructClanWarLeague.getClanId_byData(data)
    local win_cnt = StructClanWarLeague.getWinCount(data)
    local lose_cnt = StructClanWarLeague.getLoseCount(data)

    vars['clanNameLabel']:setString(Str(clan_name))
    vars['rankLabel']:setString(clan_rank)
    vars['winRoundLabel']:setString(Str('{1} - {2}', win_cnt, lose_cnt))

    local mark_icon = struct_clan_rank:makeClanMarkIcon()
    vars['clanMarkNode']:addChild(mark_icon)
end




local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarLeagueMatchListItem
-------------------------------------
UI_ClanWarLeagueMatchListItem = class(PARENT, {
        m_clanA = '',
        m_clanB = ''
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueMatchListItem:init(data)
    local vars = self:load('clan_war_lobby_item_league.ui')

    for idx = 1, 2 do
        self:setClanInfo(idx, data)
    end

    -- N 일차 경기
    vars['dayLabel']:setString('MATCH ' .. data['day'])
end

-------------------------------------
-- function setClanInfo
-------------------------------------
function UI_ClanWarLeagueMatchListItem:setClanInfo(idx, data)
     local vars = self.vars
     local clan_data = data['clan' .. idx]

     local blank_clan = function()
        if (vars['clanNameLabel'..idx]) then
            vars['clanNameLabel'..idx]:setString('-')
        end
        if (vars['defeatSprite'..idx]) then
            vars['defeatSprite'..idx]:setVisible(true)
        end
     end
     
     if (not clan_data) then
        blank_clan()
        return
     end

     local struct_clan_rank = clan_data['clan_info']
     if (not struct_clan_rank) then
        blank_clan()
        return
     end

     -- 클랜 이름
     local clan_name = struct_clan_rank:getClanName() or ''
     if (vars['clanNameLabel'..idx]) then
        vars['clanNameLabel'..idx]:setString(clan_name)
     end

     -- 클랜 마크
     local clan_icon = struct_clan_rank:makeClanMarkIcon()
     if (clan_icon) then
        if (vars['clanMarkNode'..idx]) then
            vars['clanMarkNode'..idx]:addChild(clan_icon)
        end
    end

    if (idx == 1) then
        self.m_clanA = clan_data
    else
        self.m_clanB = clan_data
    end
end

-------------------------------------
-- function setResult
-------------------------------------
function UI_ClanWarLeagueMatchListItem:setResult(result) -- A가 win : 1,  lose : 0, none = -1
    local vars = self.vars
    if (result == 1) then
        vars['defeatSprite1']:setVisible(true)
    elseif (result == 0) then
        vars['defeatSprite2']:setVisible(true)
    end
end