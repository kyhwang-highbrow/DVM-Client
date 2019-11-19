-------------------------------------
-- class UI_ClanWarLeague
-------------------------------------
UI_ClanWarLeague = class({
        m_teamCnt = 'number',
        vars = '',

        m_structLeague = 'StructClanWarLeague',

		-- 버튼으로 누른 팀 정보
        m_selctedTeam = 'number',
        
		-- 1조 ~ N조까지 누르는 테이블뷰
		m_scrollBtnTableView = 'UIC_TableView',

		-- N일차 경기
		m_todayMatch = 'number',

		m_closeCB = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeague:init(vars, root)
    self.vars = vars
	self.m_selctedTeam = 1
    self.m_todayMatch = 1
	self.m_teamCnt = 0

    -- 초기화
    self:initUI()
    self:refresh() -- 여기서 m_structLeague을 받음
	self:initButton()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarLeague:initButton()
	local vars = self.vars

    vars['allRankTabBtn']:registerScriptTapHandler(function() self:click_allBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_gotoMatch() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarLeague:initUI()
	local vars = self.vars
end

-------------------------------------
-- function setRankList
-------------------------------------
function UI_ClanWarLeague:setRankList(struct_league)
    local vars = self.vars

    vars['rankListScrollNode']:removeAllChildren()

    local struct_clanwar_league = struct_league or self.m_structLeague
	local l_rank = struct_clanwar_league:getClanWarLeagueRankList()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['rankListScrollNode'])
    table_view.m_defaultCellSize = cc.size(660, 60 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarLeagueRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank, false)
end

-------------------------------------
-- function setMatchList
-------------------------------------
function UI_ClanWarLeague:setMatchList()
    local vars = self.vars

    vars['leagueListScrollNode']:removeAllChildren()

    local struct_clanwar_league = self.m_structLeague
    local l_day_list = g_clanWarData:getVaildDate()
	local l_list = {}
	local list_idx = 1
    for i, day in ipairs(l_day_list) do
		if (day > 7) then
			break
		end
		local l_league = struct_clanwar_league:getClanWarLeagueList(day)
        for idx, data in ipairs(l_league) do
            data['my_clan_id'] = g_clanWarData:getMyClanId()
            data['day'] = day 
            data['idx'] = list_idx
            data['match_day'] = struct_clanwar_league.m_matchDay
	        table.insert(l_list, data)
			list_idx = list_idx + 1
        end
        
        -- 날짜 사이마다 간격이 있는 것 처럼 보여주기위해  더미 UI를 하나 찍음
        table.insert(l_list, {['my_clan_id'] = 'blank'})
		list_idx = list_idx + 1
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['leagueListScrollNode'])
    --self.m_tableView:setUseVariableSize(true)
    table_view.m_defaultCellSize = cc.size(660, 55 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarLeagueMatchListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_list, false)

	-- 6일째 후는 토너먼트, 토너먼트에서 리그를 호출했다는 것은 지난 리그 정보 보여주기 위함
	-- 맨 위를 포커싱해줌
	local day = struct_clanwar_league.m_matchDay
	if (not g_clanWarData:getIsLeague()) then
		day = 1
	end

    -- 일단 하드코딩
    local l_pos_y = {-774, -530, -284, -40, -40}
    local match_day = math.max(day, 2)
    match_day = math.min(match_day, 6)
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view.m_scrollView:setContentOffset(cc.p(0, l_pos_y[match_day - 1]), animated)
end

-------------------------------------
-- function setScrollButton
-------------------------------------
function UI_ClanWarLeague:setScrollButton()
    local vars = self.vars

    -- 버튼 테이블 뷰는 한 번만 생성
    if (self.m_scrollBtnTableView) then
        return
    end
    
    local scroll_node = vars['tableViewNode']
    local l_button = {}

	-- N조 갯수대로 버튼 생성
    for i = 1, self.m_teamCnt do
        table.insert(l_button, {['idx'] = i, ['selected_team'] = self.m_selctedTeam})
    end

    local create_cb = function(ui, data)
        ui.vars['teamTabBtn']:getParent():setSwallowTouch(false)

        -- 선택된 버튼 표시
		if (self.m_selctedTeam == ui.m_idx) then
			ui.vars['teamTabBtn']:setEnabled(false)
			ui.vars['teamTabLabel']:setColor(COLOR['BLACK'])		
		end

        ui.vars['teamTabBtn']:registerScriptTapHandler(function()
            -- 버튼 클릭하면 화면 갱신
            local team_idx = ui.m_idx
            self.m_selctedTeam = team_idx
            self:refresh(team_idx)
        end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(scroll_node)
    table_view:setCellUIClass(UI_ClanWarLeagueBtnListItem, create_cb)
    table_view.m_defaultCellSize = cc.size(110, 71)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_button, false)

    self.m_scrollBtnTableView = table_view
	self.m_scrollBtnTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
	self.m_scrollBtnTableView:relocateContainerFromIndex(0)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarLeague:refresh(team)    
    local vars = self.vars
	
	local success_cb = function(ret)
		self:refreshUI(team, ret)
        self:setRewardBtn()
	end

	-- param team을 nil로 보냈을 때, 자신의 클랜이 경기 중일 때는 자신 클랜의 리그, 없다면 전체 랭크를 보내준다.
    g_clanWarData:request_clanWarLeagueInfo(team, success_cb)
end

-------------------------------------
-- function refreshUI
-------------------------------------
function UI_ClanWarLeague:refreshUI(team, ret, show_only_my_league)
	local vars = self.vars

	if (show_only_my_league) then
		self.m_structLeague = ret
    else
		self.m_structLeague = StructClanWarLeague(ret)
	end
	self.m_todayMatch = g_clanWarData.m_clanWarDay
	self.m_teamCnt = g_clanWarData:getEntireGroupCnt()

	-- 새로운 조 정보 받을 때마다 아이템들 모두 삭제
	vars['allRankTabMenu']:removeAllChildren()
	
	local is_all = false
	if (not show_only_my_league) then
		local l_clan_info = ret['league_clan_info'] 
		if (not l_clan_info) then
			return
		end
		
		-- 한 번에 12이상 내려왔을 경우 전체가 내려온 것으로 판단
		is_all = false
		if (#l_clan_info > 12) then -- 임시
		    is_all = true
		end
	else
		is_all = false
	end

	if (is_all) then
		self:refreshAllLeagueUI()
	else
		self:refreshLeagueUI()
	end

    vars['allRankTabMenu']:setVisible(is_all)
    vars['teamTabMenu']:setVisible(not is_all)
    
    -- 모든 랭킹 보여주기 버튼 활성화
    vars['allRankTabBtn']:setEnabled(not is_all)
	vars['allRankTabSprite2']:setVisible(is_all)
    vars['allRankTabSprite1']:setVisible(not is_all)

    if (not is_all) then
        vars['allRankTabLabel']:setColor(COLOR['WHITE'])
    else
        vars['allRankTabLabel']:setColor(COLOR['BLACK'])       
    end

    if (self.m_scrollBtnTableView) then
        -- 선택했던 버튼들 초기화
	    local l_btn = self.m_scrollBtnTableView.m_itemList
	    for _, data in ipairs(l_btn) do
		    if (data['ui']) then
				if (data['ui'].m_idx == self.m_selctedTeam) and (not is_all) then
					data['ui'].vars['teamTabBtn']:setEnabled(false)
                    data['ui'].vars['teamTabLabel']:setColor(COLOR['BLACK'])
				else
					data['ui'].vars['teamTabBtn']:setEnabled(true)
					data['ui'].vars['teamTabLabel']:setColor(COLOR['WHITE'])
				end
			end
	    end
    end
    self:refreshButtonList(team)
end
-------------------------------------
-- function refreshButtonList
-------------------------------------
function UI_ClanWarLeague:refreshButtonList(team)
	-- 처음 들어왔을 때에는 자신의 조로 버튼을 세팅
    if (not team) then
        self.m_selctedTeam = self.m_structLeague:getMyClanTeamNumber()
    end
    self:setScrollButton()
end

-------------------------------------
-- function refreshLeagueUI
-------------------------------------
function UI_ClanWarLeague:refreshLeagueUI()
	local vars = self.vars

    -- 랭크, 일정, 버튼 정보 갱신
    self:setRankList()
    self:setMatchList()

    -- Test용
    -- 내 클랜이 속한 화면일 때에만 활성화
    local is_myClanTeam = false
    local my_clan_id = g_clanWarData:getMyClanId()
    if (self.m_structLeague:isContainClan(my_clan_id)) then
        is_myClanTeam = true
    end

    local cb_func = function(data)
        local total_score = data['match'] or 0
        local win = data['win'] or 0
        local lose = data['lose'] or 0

        local league, match, is_left = self.m_structLeague:getMyClanInfo(self.m_todayMatch)
        if (not is_left) then
            UIManager:toastNotificationRed('내 클랜 정보가 없음')
            return
        end
        g_clanWarData:request_testSetWinLose(league, match, is_left, win, lose, total_score)
        UIManager:toastNotificationRed('점수 반영이 완료되었습니다. ESC로 나갔다가 다시 진입해주세요')
    end

    -- 내 클랜일 경우에만 start 가능
    -- 조별리그 기간에만 start 가능
    vars['startBtn']:setVisible(is_myClanTeam)
    if (g_clanWarData:getIsLeague()) then
        vars['startBtn']:setVisible(false)
    end

    -- 점수 조작 관련 정보 입력하는 팝업 여는 버튼
    vars['testBtn']:setVisible(is_myClanTeam)
    vars['testBtn']:registerScriptTapHandler(function() UI_ClanWarTest(cb_func, true) end)
    vars['testTomorrowBtn']:setVisible(true)
    vars['testTomorrowBtn']:registerScriptTapHandler(function() 
        g_clanWarData:request_testNextDay() 
        UIManager:toastNotificationRed('점수 반영이 완료되었습니다. ESC로 나갔다가 다시 진입해주세요')
    end)  
end


-------------------------------------
-- function refreshAllLeagueUI
-------------------------------------
function UI_ClanWarLeague:refreshAllLeagueUI()
	local vars = self.vars
	vars['allRankTabMenu']:removeAllChildren()
	  
	self:setAllRank(struct_clan_war)  
end

-------------------------------------
-- function click_allBtn
-------------------------------------
function UI_ClanWarLeague:click_allBtn()
	local vars = self.vars
    local success_cb = function(ret)
        self:refreshUI(nil, ret)
    end

    g_clanWarData:request_clanWarLeagueInfo(99, success_cb) -- param 99, 모든 클랜 정보 요청
end

-------------------------------------
-- function setAllRank
-------------------------------------
function UI_ClanWarLeague:setAllRank()
    local vars = self.vars
	local struct_clan_war = self.m_structLeague

	local l_team = struct_clan_war:getClanWarLeagueAllRankList()
	
	-- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(vars['allRankTabMenu'])
    table_view_td.m_cellSize = cc.size(420, 316)
    table_view_td.m_nItemPerCell = 3
	table_view_td:setCellUIClass(UI_ClanWarAllRankListItem)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_team)
end

-------------------------------------
-- function closeUI
-------------------------------------
function UI_ClanWarLeague:closeUI()
	local vars = self.vars
	self.m_closeCB()
end

-------------------------------------
-- function click_gotoMatch
-------------------------------------
function UI_ClanWarLeague:click_gotoMatch()    
	local is_open, msg = g_clanWarData:checkClanWarState_League()
	if (not is_open) then
		MakeSimplePopup(POPUP_TYPE.OK, msg)
		return
	end

	local struct_league = self.m_structLeague
    local my_win_cnt, enemy_win_cnt = struct_league:getMyClanMatchScore()

    local success_cb = function(t_my_struct_match)
        local t_clan = t_my_struct_match:getEnemyMatchData()
        for _, v in pairs(t_clan) do
            struct_match_item = v
            break
        end

        if (not struct_match_item) then
            return
        end

        local clan_id = struct_match_item:getClanId()
        if (not clan_id) then
            return
        end

        if (clan_id == 'loser') then
            return
        end

        local ui_clan_war_matching = UI_ClanWarMatchingScene(t_my_struct_match)
        ui_clan_war_matching:setScore(my_win_cnt, enemy_win_cnt)
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb)
end

-------------------------------------
-- function setRewardBtn
-------------------------------------
function UI_ClanWarLeague:setRewardBtn()
    local vars = self.vars
    local my_struct_league_item = nil
    local struct_clanwar_league = self.m_structLeague
	local my_rank = struct_clanwar_league:getMyLeagueRank()

    vars['rewardBtn']:registerScriptTapHandler(function() UI_ClanwarRewardInfoPopup(true, my_rank) end)
end

-------------------------------------
-- function showOnlyMyLeague
-------------------------------------
function UI_ClanWarLeague:showOnlyMyLeague()
    local vars = self.vars
    vars['allRankTabBtn']:setVisible(false)
    vars['leagueBtnMenu']:setVisible(false)
    vars['startBtn']:setVisible(false)
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