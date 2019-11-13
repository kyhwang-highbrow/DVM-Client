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
		m_scrollBtnTableView = 'TableView',
        
		-- N일차 경기
		m_todayMatch = 'number',

		-- 경기 일정 테이블 뷰
		m_matchListScrollView = 'ScrollView',
		m_matchListNode = 'Node',

		-- 랭킹 테이블 뷰
		m_rankListScrollView = 'ScrollView',
		m_rankListNode = 'Node',

		m_closeCB = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeague:init(vars)
    self.vars = vars
	self.m_selctedTeam = 1
    self.m_todayMatch = 1
	self.m_teamCnt = 0

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

    vars['allRankTabBtn']:registerScriptTapHandler(function() self:click_allBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_gotoMatch() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarLeague:initUI()
	local vars = self.vars
	vars['timeLabel']:setString('{@yellow}2차 경기 진행중 {@green}다음 라운드까지 10시간 20분 남음')
	self:initMatchScroll()
	self:initRankScroll()
end

-------------------------------------
-- function setRankList
-------------------------------------
function UI_ClanWarLeague:setRankList(struct_league)
    local vars = self.vars
    local struct_clanwar_league = struct_league or self.m_structLeague
	local uic_extend_list_item = UIC_ExtendList_Image()

    -- 랭크 출력
	local l_rank = struct_clanwar_league:getClanWarLeagueRankList()
	local uic_extend_list_item = UIC_ExtendList_Image()

    -- 각 클랜 랭킹을 UIC_ExtendList_Image로 추가
	for idx, struct_league_item in ipairs(l_rank) do
        local clan_id = struct_league_item:getClanId()
        local total_win, total_lose = struct_clanwar_league:getTotalScore(clan_id)
        struct_league_item['total_score_win'] = total_win
        struct_league_item['total_score_lose'] = total_lose
        struct_league_item['my_clan_id'] = g_clanWarData:getMyClanId()
		uic_extend_list_item:addMainBtn(idx, UI_ClanWarLeagueRankListItem, struct_league_item)
	end

	uic_extend_list_item:setMainBtnHeight(70)
	uic_extend_list_item:setExtendHeight(130)
	self.m_rankListNode:removeAllChildren()
	uic_extend_list_item:create(self.m_rankListNode)
	self.m_rankListNode:setPosition(230, 50)	

	-- 클릭했을 때, 스크롤뷰 사이즈 재정의
	local func = function()
		local ori_size = {}
		local height = uic_extend_list_item:getAllHeight()
		ori_size['width'] = 690
		ori_size['height'] = 200 + height
		self.m_rankListScrollView:setContentSize(ori_size)
		self.m_rankListScrollView:setUpdateChildrenTransform()
	end
	uic_extend_list_item:setClickFunc(func)

	-- 스크롤뷰 사이즈 초기화
	local ori_size = {}
	local height = uic_extend_list_item:getAllHeight()
	ori_size['width'] = 690
	ori_size['height'] = 500
	self.m_rankListScrollView:setContentSize(ori_size)

	-- 컨테이너 위치 초기화
	local container_node = self.m_rankListScrollView:getContainer()
	container_node:setPositionY(0)
end

-------------------------------------
-- function initMatchScroll
-------------------------------------
function UI_ClanWarLeague:initMatchScroll()
	local vars = self.vars

	-- 스크롤뷰 인스턴스는 한 번만 만든다.
	local node, scroll_view = UIC_ExtendList_Image.initScroll(self.vars['leagueListScrollNode'], self.vars['leagueListScrollMenu'])
	self.m_matchListScrollView = scroll_view
	self.m_matchListNode = node
end

-------------------------------------
-- function initRankScroll
-------------------------------------
function UI_ClanWarLeague:initRankScroll()
	local vars = self.vars

	-- 스크롤뷰 인스턴스는 한 번만 만든다.
	local node, scroll_view = UIC_ExtendList_Image.initScroll(self.vars['rankListScrollNode'], self.vars['rankListScrollMenu'])
	self.m_rankListScrollView = scroll_view
	self.m_rankListNode = node
end

-------------------------------------
-- function setMatchList
-------------------------------------
function UI_ClanWarLeague:setMatchList()
    local vars = self.vars
	local uic_extend_list_item = UIC_ExtendList_Image()
	
	local l_match = {}
	local struct_clanwar_league = self.m_structLeague
    
	-- 클릭해서 평쳐지는 메인버튼 생성
    for day = 1, 5 do		
		local l_league = struct_clanwar_league:getClanWarLeagueList(day + 1)
        for idx, data in ipairs(l_league) do
            data['my_clan_id'] = g_clanWarData:getMyClanId()
            data['day'] = day 
            data['idx'] = idx
            data['match_day'] = struct_clanwar_league.m_matchDay
	        uic_extend_list_item:addMainBtn(day*10 + idx, UI_ClanWarLeagueMatchListItem, data) -- key, UI, data		 
        end
    end
	uic_extend_list_item:setMainBtnHeight(70) -- 접는 버튼 높이
	uic_extend_list_item:setExtendHeight(100) -- 늘어난 컨텐츠 높이
    uic_extend_list_item:setGroup(3) -- 몇개씩 묶어서 보여줄 것인가

	-- 현재 진행중인 경기에 포커싱
    local container_node = self.m_matchListScrollView:getContainer()
    local match_day = math.max(struct_clanwar_league.m_matchDay, 2)
    container_node:setPositionY(-256 * (match_day-2))

	local focus_idx = 1 + (match_day-2) * 3
	uic_extend_list_item:setFocusIdx(focus_idx)

	self.m_matchListNode:removeAllChildren()
	uic_extend_list_item:create(self.m_matchListNode)
	self.m_matchListNode:setPosition(350, 70)	

	-- 클릭해서 펼쳐졌을 경우 스크롤 사이즈 재정의
	local func = function()
		local ori_size = {}
		local height = uic_extend_list_item:getAllHeight()
		ori_size['width'] = 690
		ori_size['height'] = 350 + height
		self.m_matchListScrollView:setContentSize(ori_size)
		self.m_matchListScrollView:setUpdateChildrenTransform()
	end
	
	uic_extend_list_item:setClickFunc(func)

	-- 스크롤뷰 사이즈 초기화
	local ori_size = {}
	local height = uic_extend_list_item:getAllHeight()
	ori_size['width'] = 690
	ori_size['height'] = 1300
	self.m_matchListScrollView:setContentSize(ori_size)
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
            
            -- 선택한 버튼 표시
			-- 선택 안된 버튼들은 다 꺼줌
			local l_btn = self.m_scrollBtnTableView.m_itemList
			for _, data in ipairs(l_btn) do
				if (data['ui']) then
					if (data['ui'].m_idx == self.m_selctedTeam) then
						data['ui'].vars['teamTabBtn']:setEnabled(false)
                        data['ui'].vars['teamTabLabel']:setColor(COLOR['BLACK'])
					else
						data['ui'].vars['teamTabBtn']:setEnabled(true)
                        data['ui'].vars['teamTabLabel']:setColor(COLOR['WHITE'])
					end
				end
			end

            -- 모든 랭킹 보여주기 버튼 활성화
            vars['allRankTabBtn']:setEnabled(true)
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
	self.m_scrollBtnTableView:relocateContainerFromIndex(self.m_selctedTeam)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarLeague:refresh(team)    
    local vars = self.vars
	
	local success_cb = function(ret)
		self:refreshUI(team, ret)
	end

	-- param team을 nil로 보냈을 때, 자신의 클랜이 경기 중일 때는 자신 클랜의 리그, 없다면 전체 랭크를 보내준다.
    g_clanWarData:request_clanWarLeagueInfo(team, success_cb)
end

-------------------------------------
-- function refreshUI
-------------------------------------
function UI_ClanWarLeague:refreshUI(team, ret)
	local vars = self.vars

	self.m_structLeague = StructClanWarLeague(ret)
    self.m_todayMatch = ret['clanwar_day']
	self.m_teamCnt = self.m_structLeague:getEntireGroupCnt()

	-- 새로운 조 정보 받을 때마다 아이템들 모두 삭제
	self.m_matchListNode:pause()
	self.m_rankListNode:pause()
	self.m_matchListNode:removeAllChildren()
	self.m_rankListNode:removeAllChildren()
	vars['allRankTabMenu']:removeAllChildren()
	
	local l_clan_info = ret['clan_info'] 
	if (not l_clan_info) then
		return
	end
	
	-- 한 번에 12이상 내려왔을 경우 전체가 내려온 것으로 판단
	if (#l_clan_info > 12) then -- 임시
		self:refreshAllLeagueUI(ret)
	else
		self:refreshLeagueUI(team, ret)
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
function UI_ClanWarLeague:refreshLeagueUI(ret)
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

    -- 점수 조작 관련 정보 입력하는 팝업 여는 버튼
    vars['testBtn']:setVisible(is_myClanTeam)
    vars['testBtn']:registerScriptTapHandler(function() UI_ClanWarTest(cb_func, true) end)
    vars['testTomorrowBtn']:setVisible(false)
    vars['testTomorrowBtn']:registerScriptTapHandler(function() 
        g_clanWarData:request_testNextDay() 
        UIManager:toastNotificationRed('점수 반영이 완료되었습니다. ESC로 나갔다가 다시 진입해주세요')
    end)  
end


-------------------------------------
-- function refreshAllLeagueUI
-------------------------------------
function UI_ClanWarLeague:refreshAllLeagueUI(ret)
	local vars = self.vars
	vars['allRankTabMenu']:removeAllChildren()
	vars['allRankTabBtn']:setEnabled(false)
	  
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

	self.m_matchListNode:pause()
	self.m_rankListNode:pause()
	vars['allRankTabMenu']:pause()

	self.m_closeCB()
end

-------------------------------------
-- function click_gotoMatch
-------------------------------------
function UI_ClanWarLeague:click_gotoMatch()    
	local struct_league = self.m_structLeague
    local my_win_cnt, enemy_win_cnt = struct_league:getMyClanMatchScore()

    local success_cb = function(t_my_struct_match, t_enemy_struct_match)
        local ui_clan_war_matching = UI_ClanWarMatchingScene(t_my_struct_match, t_enemy_struct_match)
        ui_clan_war_matching:setScore(my_win_cnt, enemy_win_cnt)
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb)
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