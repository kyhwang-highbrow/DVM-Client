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
        m_myLeagueInfo = 'table',

		m_closeCB = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeague:init(vars, root)
    self.vars = vars
	self.m_selctedTeam = nil
	self.m_teamCnt = g_clanWarData:getEntireGroupCnt()

    -- 초기화
    self:initUI()
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

    vars['rankListNode']:removeAllChildren()

    local struct_clanwar_league = struct_league or self.m_structLeague
	local l_rank = struct_clanwar_league:getClanWarLeagueRankList()
    
    -- 세트 점수는 더해서  struct_league에 강제로 넣어줌
    for i, data in ipairs(l_rank) do
        local clan_id = data['clan_id']
        data['total_win_cnt'] = struct_clanwar_league:getTotalSetScore(clan_id) or 0
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['rankListNode'])
    table_view.m_defaultCellSize = cc.size(660, 60 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarLeagueRankListItem)
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
    local l_league = struct_clanwar_league:getClanWarLeagueMatchList()
    local group_cnt = g_clanWarData:getGroupCnt()/2
    local list_idx = 1
	local l_list = {}
    for idx, data in ipairs(l_league) do
        data['idx'] = list_idx
        table.insert(l_list, data)
        list_idx = list_idx + 1

        -- 날짜 사이마다 간격이 있는 것 처럼 보여주기위해  더미 UI를 하나 찍음
        if (idx%group_cnt == 0) then
            table.insert(l_list, {['my_clan_id'] = 'blank'})
            list_idx = list_idx + 1
        end
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
	local day = g_clanWarData.m_clanWarDay
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
		local struct_league_item = self.m_structLeague:getLeagueInfo()
		if (struct_league_item) then
			if (struct_league_item:getLeague() == ui.m_idx) then
				ui.vars['myClanSprite']:setVisible(true)
			end
		end

        -- 선택된 버튼 표시
		if (self.m_selctedTeam == ui.m_idx) then
			ui.vars['teamTabBtn']:setEnabled(false)
			ui.vars['teamTabLabel']:setColor(COLOR['BLACK'])		
		end

        ui.vars['teamTabBtn']:registerScriptTapHandler(function()
            -- 버튼 클릭하면 화면 갱신
            local team_idx = ui.m_idx
            self.m_selctedTeam = team_idx
            self:request_teamInfo(team_idx)
        end)
        -- 자신의 조 버튼 표시
        local my_league_number = self:getMyLeagueNumber()
        ui.vars['myClanSprite']:setVisible(ui.m_idx == my_league_number)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(scroll_node)
    table_view:setCellUIClass(UI_ClanWarLeagueBtnListItem, create_cb)
    table_view.m_defaultCellSize = cc.size(110, 71)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_button, false)

    self.m_scrollBtnTableView = table_view
	self.m_scrollBtnTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.

    local idx = self:getMyLeagueNumber() or 0
	self.m_scrollBtnTableView:relocateContainerFromIndex(0)
end

-------------------------------------
-- function request_teamInfo
-- @brief 통신 요청
-------------------------------------
function UI_ClanWarLeague:request_teamInfo(team, finish_cb)    
    local vars = self.vars
	
	local success_cb = function(ret)
		self:refreshUI(team, ret)

        if (finish_cb) then
            finish_cb()
        end
	end

	-- param team을 nil로 보냈을 때, 자신의 클랜이 경기 중일 때는 자신 클랜의 리그, 없다면 전체 랭크를 보내준다.
    g_clanWarData:request_clanWarLeagueInfo(team, success_cb)
end

-------------------------------------
-- function refreshUI
-------------------------------------
function UI_ClanWarLeague:refreshUI(team, ret, first_request)
	local vars = self.vars
	self.m_structLeague = StructClanWarLeague(ret)
	
    -- 처음 들어왔을 때에는 자신의 조로 버튼을 세팅
    -- team 이 nil로 들어오는 경우 첫 화면/전체 랭킹
    if (not team) then
        local my_clan_id = g_clanWarData:getMyClanId()
		local struct_league_item = self.m_structLeague:getLeagueInfo(my_clan_id)
		if (struct_league_item) then
			self.m_selctedTeam = struct_league_item:getLeague()
            self.m_myLeagueInfo = struct_league_item
		end
    end

    -- param team을 nil로 보냈을 때, 자신의 클랜이 경기 중일 때는 자신 클랜의 리그, 없다면 전체 랭킹를 보내준다.
    local is_all = false
    if (first_request) then
	    if (not self.m_structLeague:getMyLeagueRank()) then
            is_all = true
        end
    else
        if (team == nil) then
            is_all = true
        end
    end

    -- 전체 랭킹 버튼, 리그 UI, 버튼 스위칭
    do
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

        -- 버튼 한 번만 생성 or 초기화
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
        else
            self:setScrollButton()
        end
    end
	
	self:showLastRankPopup()
end

-------------------------------------
-- function refreshUI_fromTournament
-- @brief 토너먼트에서 조별리그 조회할 때만 사용
-------------------------------------
function UI_ClanWarLeague:refreshUI_fromTournament(struct_league)
	local vars = self.vars

	self.m_structLeague = struct_league
	self:refreshLeagueUI()

    vars['allRankTabMenu']:setVisible(is_all)
    vars['teamTabMenu']:setVisible(not is_all)
end

-------------------------------------
-- function refreshLeagueUI
-------------------------------------
function UI_ClanWarLeague:refreshLeagueUI()
	local vars = self.vars

    -- 랭크 리스트 다시 만들기
    self:setRankList()

    -- 일정 리스트 다시 만들기
    self:setMatchList()

    -- 전투 시작 버튼 세팅
    do
        local is_myClanTeam = false
        local my_clan_id = g_clanWarData:getMyClanId()
        if (self.m_structLeague:isContainClan(my_clan_id)) then
            is_myClanTeam = true
        end
        
        vars['startBtn']:setVisible(true)
        -- 1.내 클랜일 경우에만 start 가능
        if (is_myClanTeam) then
            vars['startBtnLabel']:setString(Str('전투준비'))
        else
            vars['startBtnLabel']:setString(Str('내 클랜 보기'))
        end

        -- 2.조별리그 기간이 아닐 경우 start 불가능
        if (not g_clanWarData:getIsLeague()) then
            vars['startBtn']:setVisible(false)
        end

        -- 3.내 클랜이 클랜전에 진출하지 않았을 경우 start 불가능
        if (not self:getMyLeagueNumber()) then
            vars['startBtn']:setVisible(false)
        end
    end

    self:setTestBtn()
end

-------------------------------------
-- function setTestBtn
-------------------------------------
function UI_ClanWarLeague:setTestBtn()
    local vars = self.vars
    local cb_func = function(data)
        local total_score = data['match'] or 0
        local win = data['win'] or 0
        local lose = data['lose'] or 0

        local league, match, is_left = self.m_structLeague:getMyClanInfo(g_clanWarData.m_clanWarDay)
        if (not is_left) then
            UIManager:toastNotificationRed('내 클랜 정보가 없음')
            return
        end
        g_clanWarData:request_testSetWinLose(league, match, is_left, win, lose, total_score)
        UIManager:toastNotificationRed('점수 반영이 완료되었습니다. ESC로 나갔다가 다시 진입해주세요')
    end

    --[[
    -- 점수 조작 관련 정보 입력하는 팝업 여는 버튼
    vars['testBtn']:setVisible(is_myClanTeam)
    vars['testBtn']:registerScriptTapHandler(function() UI_ClanWarTest(cb_func, true) end)
    --]]
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
    vars['startBtn']:setVisible(false)
	
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

	local l_team = struct_clan_war:getAllClanWarLeagueRankList()
	
    local create_cb = function(ui, data)
        ui.vars['moveBtn']:registerScriptTapHandler(function() self:click_teamWithFocusBtn(ui.m_leagueNumber) end)
    end
	-- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(vars['allRankTabMenu'])
    table_view_td.m_cellSize = cc.size(420, 316)
    table_view_td.m_nItemPerCell = 3
	table_view_td:setCellUIClass(UI_ClanWarAllRankListItem, create_cb)
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
-- function click_teamWithFocusBtn
-------------------------------------
function UI_ClanWarLeague:click_teamWithFocusBtn(team)
    if (not team) then
        team = 1
    end

    self.m_selctedTeam = team
    self:request_teamInfo(team, function()
        local idx = self.m_selctedTeam or 0
        if (self.m_scrollBtnTableView) then
            self.m_scrollBtnTableView:relocateContainerFromIndex(idx)
        end
    end)
end

-------------------------------------
-- function click_gotoMatch
-------------------------------------
function UI_ClanWarLeague:click_gotoMatch()
    -- 다른 팀 버튼을 누르고 있을 경우 내 팀으로 돌아옴
    if (self.m_selctedTeam ~= self:getMyLeagueNumber()) then
        local my_clan_id = g_clanWarData:getMyClanId()
        local my_clan_league_info = self.m_structLeague:getLeagueInfo(my_clan_id)
        if (not my_clan_league_info) then
            self:click_teamWithFocusBtn(self:getMyLeagueNumber())
            return
        end
    end
    
    -- 1.오픈 여부 확인
	local is_open, msg = g_clanWarData:checkClanWarState_League()
	if (not is_open) then
		MakeSimplePopup(POPUP_TYPE.OK, msg)
		return
	end

    local success_cb = function(struct_match)
        local t_clan = struct_match:getEnemyMatchData()
        -- 2.상대 클랜이 유령 클랜일 경우 확인
        local is_ghost = self:isGhostClan(t_clan)
        if (is_ghost) then
            local ghost_msg = Str('대전 상대가 없어 부전승 처리 되었습니다.')
            MakeSimplePopup(POPUP_TYPE.OK, ghost_msg)
            return
        end

        local ui_clan_war_matching = UI_ClanWarMatchingScene(struct_match)

        -- 리그 통신에서 들고 있더 클랜 세트 승리수 전달
        local struct_league = self.m_structLeague
        local my_win_cnt, enemy_win_cnt = struct_league:getMyClanMatchScore()
        ui_clan_war_matching:setScore(my_win_cnt, enemy_win_cnt)
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb)
end

-------------------------------------
-- function isGhostClan
-------------------------------------
function UI_ClanWarLeague:isGhostClan(t_clan)
    local struct_match_item
    for _, v in pairs(t_clan) do
        struct_match_item = v
        break
    end

    if (not struct_match_item) then
        MakeSimplePopup(POPUP_TYPE.OK, ghost_msg)
        return true
    end

    local clan_id = struct_match_item:getClanId()
    if (not clan_id) then
        MakeSimplePopup(POPUP_TYPE.OK, ghost_msg)
        return true
    end

    if (clan_id == 'loser') then
        MakeSimplePopup(POPUP_TYPE.OK, ghost_msg)
        return true
    end

    return false
end

-------------------------------------
-- function showOnlyMyLeague
-- @brief 토너먼트에서 나의 조별리그 조회할 떄에만 사용
-------------------------------------
function UI_ClanWarLeague:showOnlyMyLeague()
    local vars = self.vars
    vars['allRankTabBtn']:setVisible(false)
    vars['leagueBtnMenu']:setVisible(false)
    vars['startBtn']:setVisible(false)
end

-------------------------------------
-- function getMyLeagueNumber
-------------------------------------
function UI_ClanWarLeague:getMyLeagueNumber()
    if (not self.m_myLeagueInfo) then
        return
    end

    return self.m_myLeagueInfo:getLeague()
end

-------------------------------------
-- function showLastRankPopup
-------------------------------------
function UI_ClanWarLeague:showLastRankPopup()
	local day = g_settingData:getClanWarLastRecordPopup()
	if (day == g_clanWarData.m_clanWarDay) then
		return
	end

	local my_clan_id = g_clanWarData:getMyClanId()
	local l_league = self.m_structLeague:getClanWarLeagueMatchList()
	local last_match_data = nil
	for i, data in ipairs(l_league) do
		if (data['day'] == g_clanWarData.m_clanWarDay - 1) then
			if (data['a_clan_id'] == my_clan_id) or (data['b_clan_id'] == my_clan_id) then
				last_match_data = data
				break
			end
		end
	end

	if (not last_match_data) then
		return
	end
	UI_ClanWarMatchInfoDetailPopup(last_match_data, true)
	g_settingData:setClanWarLastRecordPopup(g_clanWarData.m_clanWarDay)
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