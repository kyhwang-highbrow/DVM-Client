-------------------------------------
-- class UI_ClanWarLeague
-------------------------------------
UI_ClanWarLeague = class({
        m_teamCnt = 'number',
        vars = '',

        m_structLeague = 'StructClanWarLeague',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeague:init(vars)
    self.vars = vars
    self.m_teamCnt = 32 -- 임시
	
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

    vars['leagueListNode']:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['leagueListNode'])
    table_view:setCellUIClass(UI_ClanWarLeagueMatchListItem)
    table_view.m_defaultCellSize = cc.size(460, 65)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_match, false)
end

-------------------------------------
-- function setScrollButton
-------------------------------------
function UI_ClanWarLeague:setScrollButton()
    local vars = self.vars
    local scroll_node = vars['tableViewNode']
    local l_button = {}

    for i = 1, self.m_teamCnt do
        table.insert(l_button, {['idx'] = i})
    end


    local create_cb = function(ui, data)
        ui.vars['teamTabBtn']:getParent():setSwallowTouch(false)
        ui.vars['teamTabBtn']:registerScriptTapHandler(function()
            local team_idx = ui.m_idx -- N조 버튼 누름
            self:refresh(team_idx) 
        end)
    end

    scroll_node:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(scroll_node)
    table_view:setCellUIClass(UI_ClanWarLeagueBtnListItem, create_cb)
    table_view.m_defaultCellSize = cc.size(110, 71)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_button, true)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarLeague:refresh(team)    
    local success_cb = function(ret)
        self.m_structLeague = StructClanWarLeague(ret)
        
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

    local struct_clan_rank_a = data['clanA']['clan_info']
    local struct_clan_rank_b = data['clanB']['clan_info']
    local clan_name_a = struct_clan_rank_a:getClanName()
    local clan_name_b = struct_clan_rank_b:getClanName()

    vars['clanNameLabel1']:setString(clan_name_a)
    vars['clanNameLabel2']:setString(clan_name_b)

    vars['dayLabel']:setString('MATCH ' .. data['day'])

    local icon_a = struct_clan_rank_a:makeClanMarkIcon()
    local icon_b = struct_clan_rank_b:makeClanMarkIcon()
    vars['clanMarkNode1']:addChild(icon_a)
    vars['clanMarkNode2']:addChild(icon_b)
end