-------------------------------------
-- class UI_ClanWarLeague
-------------------------------------
UI_ClanWarLeague = class({
        m_teamCnt = 'number',
        vars = '',

        m_structLeague = 'StructClanWarLeague',

        m_selctedTeam = 'number',
        m_scrollBtnTableView = 'TableView'
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeague:init(vars)
    self.vars = vars
    self.m_teamCnt = 32 -- 임시
	self.m_selctedTeam = 1 -- 임시

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
function UI_ClanWarLeague:setRankList()
    local vars = self.vars
    
    local struct_clanwar_league = self.m_structLeague
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
        ui:setResult(1)
    end

    vars['leagueListNode']:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['leagueListNode'])
    table_view:setCellUIClass(UI_ClanWarLeagueMatchListItem, create_func)
    table_view.m_defaultCellSize = cc.size(460, 65)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_match, false)

    --table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    --table_view:relocateContainerFromIndex(100)
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
            self:refresh(team_idx)
            self.m_selctedTeam = team_idx
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
        
        self:setScrollButton()
        self:setRankList()
        self:setMatchList()
    end

    g_clanWarData:request_clanWarLeagueInfo(team, success_cb)
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
    local clan_score = struct_clan_rank:getClanScore()
    vars['clanNameLabel']:setString(Str(clan_name))
    vars['rankLabel']:setString(clan_rank)
    vars['winRoundLabel']:setString(Str(clan_score))

    local mark_icon = struct_clan_rank:makeClanMarkIcon()
    vars['clanMarkNode']:addChild(mark_icon)
end




local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarLeagueMatchListItem
-------------------------------------
UI_ClanWarLeagueMatchListItem = class(PARENT, {
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