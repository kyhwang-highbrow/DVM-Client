-------------------------------------
-- class UI_ClanWarLeague
-------------------------------------
UI_ClanWarLeague = class({
        m_teamCnt = 'number',
        vars = ''
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
    --self:refresh()
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
    
    self:setScrollButton()
    self:setRankList()
    self:setMatchList()
end

-------------------------------------
-- function setRankList
-------------------------------------
function UI_ClanWarLeague:setRankList()
    local vars = self.vars
    --vars['rankListNode']
end

-------------------------------------
-- function setMatchList
-------------------------------------
function UI_ClanWarLeague:setMatchList()
    local vars = self.vars
    --vars['rankListNode']
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

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(scroll_node)
    table_view:setCellUIClass(UI_ClanWarLeagueBtnListItem)
    table_view.m_defaultCellSize = cc.size(110, 71)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_button, true)
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
	    	local clan_a = data['clanA'] or ''
	    	local clan_b = data['clanB'] or ''
	    	str_match = str_match .. clan_a .. ' VS ' .. clan_b
	    	str_match = str_match .. '\n'
	    end  
    end
    vars['matchLabel']:setString(str_match)

	-- 랭크 출력
	local str = ''
	local l_rank = struct_clanwar_league:getClanWarLeagueRankList()
	for rank, data in ipairs(l_rank) do
		local clan_number = data['clan_number']
		local clan_id = struct_clanwar_league:getClanId(clan_number)
		str = str .. rank .. '등 : ' .. clan_id
		str = str .. '\n'
	end
	vars['rankLabel']:setString(str)
end








local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarLobby
-------------------------------------
UI_ClanWarLeagueBtnListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueBtnListItem:init(data)
    local vars = self:load('clan_war_lobby_item_btn.ui')
    vars['teamTabLabel']:setString(data['idx'] .. '조')
end