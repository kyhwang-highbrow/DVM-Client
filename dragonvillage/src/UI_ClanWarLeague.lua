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

		m_matchListScrollView = 'ScrollView',
		m_matchListNode = 'Node',

		m_rankListScrollView = 'ScrollView',
		m_rankListNode = 'Node',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeague:init(vars)
    self.vars = vars
    self.m_teamCnt = 16 -- 임시
	self.m_selctedTeam = 1
    self.m_todayMatch = 1

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
	for idx, data in ipairs(l_rank) do
        local clan_id = data['league_info']['clan_id']
        local total_win, total_lose = struct_clanwar_league:getTotalScore(clan_id)
        data['total_score_win'] = total_win
        data['total_score_lose'] = total_lose
        data['my_clan_id'] = g_clanWarData:getMyClanId()
		uic_extend_list_item:addMainBtn(idx, UI_ClanWarLeagueRankListItem, data)
	end

	uic_extend_list_item:setMainBtnHeight(70)
	uic_extend_list_item:setExtendHeight(130)
	self.m_rankListNode:removeAllChildren()
	uic_extend_list_item:create(self.m_rankListNode)
	self.m_rankListNode:setPosition(230, 50)	

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

	local node, scroll_view = UIC_ExtendList_Image.initScroll(self.vars['leagueListScrollNode'], self.vars['leagueListScrollMenu'])
	self.m_matchListScrollView = scroll_view
	self.m_matchListNode = node
end

-------------------------------------
-- function initRankScroll
-------------------------------------
function UI_ClanWarLeague:initRankScroll()
	local vars = self.vars

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
    -- 5일동안 3경기씩 하는 메인메뉴 버튼 생성
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
    container_node:setPositionY(-256 * (match_day-1))

	local focus_idx = 1 + (match_day-2) * 3
	uic_extend_list_item:setFocusIdx(focus_idx)

	self.m_matchListNode:removeAllChildren()
	uic_extend_list_item:create(self.m_matchListNode)
	self.m_matchListNode:setPosition(350, 70)	

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
        -- 새로운 조 정보 받을 때마다 아이템들 모두 삭제
		self.m_matchListNode:removeAllChildren()
		self.m_rankListNode:removeAllChildren()
		vars['allRankTabMenu']:removeAllChildren()
        
		self.m_structLeague = StructClanWarLeague(ret)
        self.m_todayMatch = ret['clanwar_day']

        -- 랭크, 일정, 버튼 정보 갱신
        self:setRankList()
        self:setMatchList()

        -- 처음 들어왔을 때에는 자신의 조로 버튼을 세팅
        if (not team) then
            self.m_selctedTeam = self.m_structLeague:getMyClanTeamNumber()
        end
    	self:setScrollButton()


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
        vars['testTomorrowBtn']:setVisible(is_myClanTeam)
        vars['testBtn']:registerScriptTapHandler(function() UI_ClanWarLeagueTest(cb_func) end)
        vars['testTomorrowBtn']:registerScriptTapHandler(function() 
            g_clanWarData:request_testNextDay() 
            UIManager:toastNotificationRed('점수 반영이 완료되었습니다. ESC로 나갔다가 다시 진입해주세요')
        end)
	end

    g_clanWarData:request_clanWarLeagueInfo(team, success_cb) --team 을 nil로 요청하면 자신 클랜이 속한 조 정보가 내려옴
end

-------------------------------------
-- function click_allBtn
-------------------------------------
function UI_ClanWarLeague:click_allBtn()
	local vars = self.vars
    local success_cb = function(ret)
        -- 랭킹, 일정에 만든 아이템들 모두 삭제
		self.m_matchListNode:removeAllChildren()
		self.m_rankListNode:removeAllChildren()
		vars['allRankTabMenu']:removeAllChildren()
        
        vars['allRankTabBtn']:setEnabled(false)

        local struct_clan_war = StructClanWarLeague(ret)      
        self:setAllRank(struct_clan_war)
    end    
    g_clanWarData:request_clanWarLeagueInfo(99, success_cb) -- param 99, 모든 클랜 정보 요청
end

-------------------------------------
-- function setAllRank
-------------------------------------
function UI_ClanWarLeague:setAllRank(struct_clan_war)
    local vars = self.vars

	local l_team = struct_clan_war:getClanWarLeagueAllRankList()
	
	-- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(vars['allRankTabMenu'])
    table_view_td.m_cellSize = cc.size(420, 316)
    table_view_td.m_nItemPerCell = 3
	table_view_td:setCellUIClass(UI_ClanWarAllRankListItem)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_team)
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
    local struct_clan_war = data['league_info']

    -- 전체 5일동안 이루어진 경기에서 얼마나 이겼는지
    local clan_id = StructClanWarLeague.getClanId_byData(data)
    local lose_cnt = StructClanWarLeague.getLoseCount(data)
    local win_cnt = StructClanWarLeague.getWinCount(data)
    vars['winRoundLabel']:setString(Str('{@green}{1}{@apricot}-{@red}{2}', win_cnt, lose_cnt))


    -- 세트 스코어 모두 더한 값
    local total_set_win_cnt = data['total_score_win']
    local total_set_lose_cnt = data['total_score_lose']
    local score_history = total_set_win_cnt .. '-' .. total_set_lose_cnt
    vars['setScoreLabel']:setString(score_history)

    -- 전체 처치수
    local total_kill_cnt = struct_clan_war['total_win_cnt']
    vars['killLabel']:setString(tostring(total_kill_cnt))
	
    -- 클랜 정보 (이름 랭크)
    local clan_name = struct_clan_rank:getClanName()
    local clan_rank = StructClanWarLeague.getClanWarRank(data)
    vars['clanNameLabel']:setString(Str(clan_name))
    vars['rankLabel']:setString(clan_rank)

    -- 클랜 정보 (레벨, 경험치, 참여 인원, 생성일)
	local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, struct_clan_rank['exp']/10000)
    vars['clanLvLabel']:setString(clan_lv_exp)

    local max_member = struct_clan_war['play_member_cnt'] or '-'
    vars['partLabel']:setString(tostring(max_member))
    
    local create_at = struct_clan_rank['create_date'] or '-'
	vars['clanCreationLabel']:setString(create_at)


    -- 1, 2등은 토너먼트 진출 가능 표시
    if (tonumber(clan_rank)) then
        if (tonumber(clan_rank) <= 2) then
            vars['finalSprite']:setVisible(true)
            vars['finalSprite']:setVisible(true)
        end
    end
    if (data['my_clan_id'] == struct_clan_war['clan_id']) then
        vars['rankMeSprite']:setVisible(true)
    end
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
    
    if (not data) then
        return
    end

    -- 클랜 상세 정보 입력
    for idx = 1, 2 do
        self:setClanInfo(idx, data)
    end

    local match_number = data['day'] + 1

    -- 끝난 경기만 승/패 표시
    if (match_number < tonumber(data['match_day'])) then
        -- 왼쪽, 오른쪽 클랜중 어느쪽 클랜이 이겼는지 표시
	    local is_win = StructClanWarLeague.isMatchWin(match_number, data['clan1']) -- 첫 번째 클랜 기준
	    self:setResult(is_win)
    end

    -- 현재 날짜, N번째 경기 정보 표기
    local cur_time = Timer:getServerTime()
    local t_day = {'월', '화', '수', '목', '금', '토', '일'}

    -- 총 5개를 찍어주는데 월요일은 경기를 안해서 화요일 부터 찍어야함
	local week_str = (tostring(match_number) - 1) .. '차 경기(' .. Str(t_day[tonumber(match_number)]) .. ')' -- 2차 경기 (수요일)

    -- n번째 날짜의 경기
    if (data['day'] == tonumber(data['match_day'])) then
        vars['todaySprite']:setVisible(true)
		week_str = week_str .. ' - 경기 진행중'
		vars['dateLabel']:setColor(COLOR['BLACK'])
    end

    -- 하루에 치뤄지는 3개의 경기 중 첫번째 경기에만 날짜 정보 표시하는 menu 활성화
    if (data['idx'] == 1) then
        vars['dateMenu']:setVisible(true)
    else
        vars['dateMenu']:setVisible(false)   
    end

    -- 날짜 정보 라벨 세팅
    vars['dateLabel']:setString(week_str)
end

-------------------------------------
-- function setClanInfo
-------------------------------------
function UI_ClanWarLeagueMatchListItem:setClanInfo(idx, data)
     local vars = self.vars
     local clan_data = data['clan' .. idx]

     local match_number = data['day'] + 1
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
	
    -- 해당 경기 세트 스코어
	local win, lose = StructClanWarLeague.getMatchSetScore(match_number, clan_data)
    local set_history = tostring(win) .. '-' .. tostring(lose)
	vars['setScoreLabel' .. idx]:setString(set_history)

    -- 그 경기를 몇 처치로 이겼는지
    local win_cnt = StructClanWarLeague.getMatchWinCnt(match_number, clan_data)
	vars['scoreLabel' .. idx]:setString(tostring(win_cnt))

    -- 클랜 정보 (레벨, 경험치, 참여인원)
    local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, clan_data['clan_info']['exp']/10000)
    local max_member = clan_data['league_info']['play_member_cnt'] or '-'
	vars['partLabel' .. idx]:setString(tostring(max_member))
	vars['clanLvLabel' .. idx]:setString(clan_lv_exp) 
	vars['clanCreationLabel' .. idx]:setString(clan_data['clan_info']['create_date'])

    -- 내 클랜 표시
    if (data['my_clan_id'] == clan_data['league_info']['clan_id']) then
        vars['leagueMeNode']:setVisible(true)
    end
end

-------------------------------------
-- function setResult
-------------------------------------
function UI_ClanWarLeagueMatchListItem:setResult(result) -- A가 win : true,  lose : false
    local vars = self.vars
    if (result) then
        vars['defeatSprite1']:setVisible(false)
        vars['defeatSprite2']:setVisible(true)
    else
        vars['defeatSprite1']:setVisible(true)
        vars['defeatSprite2']:setVisible(false)
    end
end





local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarAllRankListItem
-------------------------------------
UI_ClanWarAllRankListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarAllRankListItem:init(data)
    local vars = self:load('clan_war_lobby_item_all_rank_01.ui')

	local league = StructClanWarLeague.getLeague(data[1])
	vars['teamLabel']:setString(Str('{1}조', league))

    -- 각 조마다 랭킹 정보 입력
	for i, t_data in ipairs(data) do
		if (vars['itemNode' .. i]) then
			if (t_data) then
				local ui_item = UI_ClanWarAllRankListItemOfItem(t_data)
				vars['itemNode' .. i]:addChild(ui_item.root)
			end
		end
	end
end








local PARENT = UI

-------------------------------------
-- class UI_ClanWarAllRankListItemOfItem
-------------------------------------
UI_ClanWarAllRankListItemOfItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarAllRankListItemOfItem:init(data)
    local vars = self:load('clan_war_lobby_item_all_rank_02.ui')

    -- 클랜 정보
	local struct_clan_rank = data['clan_info']
    local clan_name = struct_clan_rank:getClanName()
    local clan_rank = tostring(StructClanWarLeague.getClanWarRank(data))
    vars['clanNameLabel']:setString(Str(clan_name))
    vars['rankLabel']:setString(clan_rank)

    -- 전체 5일동안 이루어진 경기에서 얼마나 이겼는지
    local clan_id = StructClanWarLeague.getClanId_byData(data)
    local win_cnt = StructClanWarLeague.getWinCount(data)
    local lose_cnt = StructClanWarLeague.getLoseCount(data)
    vars['scoreLabel']:setString(Str('{1}-{2}', win_cnt, lose_cnt))
end














local PARENT = UI

-------------------------------------
-- class UI_ClanWarLeagueTest
-------------------------------------
UI_ClanWarLeagueTest = class(PARENT, {
        m_data = ''
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueTest:init(cb_func)
    local vars = self:load('clan_war_set_score_test.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_data = {}
    self.m_data['match'] = 0
    self.m_data['win'] = 0
    self.m_data['lose'] = 0


    local l_key = {'match', 'win', 'lose'}
    for _, key in ipairs(l_key) do
        vars[key .. 'NumberLabel']:setString(self.m_data[key])
        vars[key .. 'DownBtn']:registerScriptTapHandler(function() self.m_data[key] = self.m_data[key] - 1 self:refresh() end)
        vars[key .. 'UpBtn']:registerScriptTapHandler(function() self.m_data[key] = self.m_data[key] + 1 self:refresh() end)
    end

    vars['applyBtn']:registerScriptTapHandler(function() cb_func(self.m_data) self:close()  end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close()  end)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarLeagueTest')
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarLeagueTest:refresh(data)
    local vars = self.vars
    local l_key = {'match', 'win', 'lose'}
    for _, key in ipairs(l_key) do
        vars[key .. 'NumberLabel']:setString(self.m_data[key])
    end
end

