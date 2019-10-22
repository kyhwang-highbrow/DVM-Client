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
		m_matchListScrollMenu = 'ScrollMenu',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeague:init(vars)
    self.vars = vars
    self.m_teamCnt = 16 -- 임시
	self.m_selctedTeam = 1 -- 임시
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
end

-------------------------------------
-- function setRankList
-------------------------------------
function UI_ClanWarLeague:setRankList(struct_league)
    local vars = self.vars
    local struct_clanwar_league = struct_league or self.m_structLeague
	
    -- 랭크 출력
	local l_rank = struct_clanwar_league:getClanWarLeagueRankList()
	vars['rankNode']:removeAllChildren()

    local struct_clanwar_league = self.m_structLeague
	local uic_extend_list_item = UIC_ExtendList_Image()
    
	for idx, data in ipairs(l_rank) do
        local clan_id = data['league_info']['clan_id']
        local total_win, total_lose = struct_clanwar_league:getTotalScore(clan_id)
        data['total_score_win'] = total_win
        data['total_score_lose'] = total_lose
        data['my_clan_id'] = struct_clanwar_league.m_nMyClanId
		uic_extend_list_item:addMainBtn(idx, UI_ClanWarLeagueRankListItem, data)
	end
	uic_extend_list_item:setMainBtnHeight(70)
	uic_extend_list_item:setSubBtnHeight(70)
	uic_extend_list_item:setExtendHeight(130)
	uic_extend_list_item:create(vars['rankNode'])

end

-------------------------------------
-- function setMatchList
-------------------------------------
function UI_ClanWarLeague:setMatchList()
    local vars = self.vars
	local is_first = false
	vars['leagueListNode']:removeAllChildren()

    local struct_clanwar_league = self.m_structLeague
	local uic_extend_list_item = UIC_ExtendList_Image()
    local l_match = {}
    for day = 1, 5 do		
		local l_league = struct_clanwar_league:getClanWarLeagueList(day)
        for idx, data in ipairs(l_league) do
            data['my_clan_id'] = struct_clanwar_league.m_nMyClanId
	        uic_extend_list_item:addMainBtn(day*10 + idx, UI_ClanWarLeagueMatchListItem, data)		
        end
    end
	uic_extend_list_item:setMainBtnHeight(70)
	uic_extend_list_item:setSubBtnHeight(70)
	uic_extend_list_item:setExtendHeight(100)
    uic_extend_list_item:setGroup(3)
	uic_extend_list_item:create(vars['leagueListNode'])


	if (not self.m_matchListScrollMenu) then
		local scroll_node = self.vars['leagueListScrollNode']
		local scroll_menu = self.vars['leagueListScrollMenu']

		local all_height = uic_extend_list_item:getAllHeight()
		-- 컨테이너에 세로크기 적용
		local ori_size = scroll_menu:getContentSize()
		ori_size['height'] = all_height + 900 -- 임시로 여유분까지
		scroll_menu:setContentSize(ori_size)

		-- ScrollView 사이즈 설정 (ScrollNode 사이즈)
		local size = scroll_node:getContentSize()
		local scroll_view = cc.ScrollView:create()
		scroll_view:setNormalSize(size)
		scroll_node:setSwallowTouch(false)
		scroll_node:addChild(scroll_view)

		-- ScrollView 에 달아놓을 컨텐츠 사이즈(ScrollMenu)
		local target_size = scroll_menu:getContentSize()
		scroll_view:setDockPoint(cc.p(0.5, 1.0))
		scroll_view:setAnchorPoint(cc.p(0.5, 1.0))

		scroll_view:setContentSize(target_size)
		scroll_view:setPosition(ZERO_POINT)
		scroll_view:setTouchEnabled(true)

		-- ScrollMenu를 부모에서 분리하여 ScrollView에 연결
		-- 분리할 부모가 없을 때 에러 없음
		scroll_menu:removeFromParent()
		scroll_view:addChild(scroll_menu)

		scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

        local container_node = scroll_view:getContainer()
        container_node:setPositionY(-1400)

		self.m_matchListScrollMenu = scroll_menu
	end
end

-------------------------------------
-- function setScrollButton
-------------------------------------
function UI_ClanWarLeague:setScrollButton()
    local vars = self.vars
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
        ui.vars['teamTabBtn']:registerScriptTapHandler(function()
            local team_idx = ui.m_idx
            self.m_selctedTeam = team_idx
            self:refresh(team_idx)

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
		vars['leagueListNode']:removeAllChildren()
		vars['rankNode']:removeAllChildren()
		vars['allRankTabMenu']:removeAllChildren()
        
		self.m_structLeague = StructClanWarLeague(ret)
        --self.m_selctedTeam = self.m_structLeague:getMyClanTeamNumber()
        self.m_todayMatch = ret['clanwar_day']

        self:setRankList()
        self:setMatchList()
    	self:setScrollButton()


        -- Test용
        local is_myClanTeam = false
        if (self.m_structLeague:getMyClanTeamNumber()) then
            is_myClanTeam = true
        end

        local cb_func = function(data)
            local total_score = data['match'] or 0
            local win = data['win'] or 0
            local lose = data['lose'] or 0

            local league, match, is_left = self.m_structLeague:getMyClanInfo()
            if (not is_left) then
                UIManager:toastNotificationRed('내 클랜 정보가 없음')
                return
            end
            g_clanWarData:request_testSetWinLose(league, match, is_left, win, lose, total_score)
            UIManager:toastNotificationRed('점수 반영이 완료되었습니다. ESC로 나갔다가 다시 진입해주세요')
        end

        vars['testBtn']:setVisible(is_myClanTeam)
        vars['testTomorrowBtn']:setVisible(is_myClanTeam)
        vars['testBtn']:registerScriptTapHandler(function() UI_ClanWarLeagueTest(cb_func) end)
        vars['testTomorrowBtn']:registerScriptTapHandler(function() 
            g_clanWarData:request_testNextDay() 
            UIManager:toastNotificationRed('점수 반영이 완료되었습니다. ESC로 나갔다가 다시 진입해주세요')
        end)

        --[[
        local league, match, is_left = self.m_structLeague:getMyClanInfo()
        vars['testWinBtn']:registerScriptTapHandler(function() g_clanWarData:request_testSetWinLose(league, match, is_left) end)
        vars['testLoseBtn']:registerScriptTapHandler(function() g_clanWarData:request_testSetWinLose(league, match, is_left) end)
        vars['testTomorrowBtn']:registerScriptTapHandler(function() g_clanWarData:request_testNextDay() end)
        --]]
	end

    g_clanWarData:request_clanWarLeagueInfo(team, success_cb) --team 을 nil로 요청하면 자신 클랜이 속한 조 정보가 내려옴
end

-------------------------------------
-- function click_allBtn
-------------------------------------
function UI_ClanWarLeague:click_allBtn()
	local vars = self.vars
    local success_cb = function(ret)
		vars['leagueListNode']:removeAllChildren()
		vars['rankNode']:removeAllChildren()
		vars['allRankTabMenu']:removeAllChildren()
        
        vars['allRankTabBtn']:setEnabled(false)

        local struct_clan_war = StructClanWarLeague(ret)      
        self:setAllRank(struct_clan_war)
    end    
    g_clanWarData:request_clanWarLeagueInfo(99, success_cb) -- 모든 클랜 정보 요청
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
	--[[
    for i, data in ipairs(l_team) do
		local ui_item = UI_ClanWarAllRankListItem(i, data)
		ui_item.root:setPositionX((i-1)* 400)
		vars['allRankTabMenu']:addChild(ui_item.root)
    end
	--]]
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
    local clan_name = struct_clan_rank:getClanName()
    local clan_rank = StructClanWarLeague.getClanWarRank(data)

    if (tonumber(clan_rank)) then
        if (tonumber(clan_rank) < 2) then
            vars['finalSprite']:setVisible(true)
            vars['finalSprite']:setVisible(true)
        end
    end
    if (data['my_clan_id'] == struct_clan_war['clan_id']) then
        vars['rankMeSprite']:setVisible(true)
    end

    local clan_id = StructClanWarLeague.getClanId_byData(data)
    local lose_cnt = StructClanWarLeague.getLoseCount(data)
    local win_cnt = StructClanWarLeague.getWinCount(data)

    vars['clanNameLabel']:setString(Str(clan_name))
    vars['rankLabel']:setString(clan_rank)
    vars['winRoundLabel']:setString(Str('{1}-{2}', win_cnt, lose_cnt))


    local total_win_cnt = data['total_score_win']
    local total_lose_cnt = data['total_score_lose']
	local score_history = total_win_cnt .. '-' .. total_lose_cnt
	local win_cnt = tostring(data['league_info']['win_cnt']) or ''
	local clan_lv = struct_clan_rank:getClanLv() or ''
    local max_member = struct_clan_rank:getMaxMember() or ''
	local clan_max_member = tostring(math.min(max_member, 20)) or ''

	vars['clanCreationLabel']:setString('2019-01-01')
	vars['clanLvLabel']:setString(string.format('Lv.%d', clan_lv))
	vars['partLabel']:setString(clan_max_member)
	vars['setScoreLabel']:setString(score_history)
	vars['killLabel']:setString(tostring(total_win_cnt))
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

	if (type(data) == 'number') then
		vars['openBtn']:setVisible(true)
		vars['dayLabel']:setString(Str('MATCH {1}', data))
		return
	end

    for idx = 1, 2 do
        self:setClanInfo(idx, data)
    end

	local is_win = g_clanWarData.m_structClanWarLeague:isWin(data['clan1'], data['clan2'])
	self:setResult(is_win)
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
	
	local score_history = clan_data['league_info']['score_history'] or ''
	local win_cnt = StructClanWarLeague.getTotalWinCount(clan_data)
	local clan_lv = struct_clan_rank:getClanLv() or ''
    local max_member = struct_clan_rank:getMaxMember() or ''
	local clan_max_member = math.min(max_member, 20) or ''
    vars['setScoreLabel' .. idx]:setString(score_history)
	vars['partLabel' .. idx]:setString(tostring(clan_max_member))
	vars['clanLvLabel' .. idx]:setString(string.format('Lv.%d', clan_lv)) 
	vars['clanCreationLabel' .. idx]:setString('2019-01-01')

	vars['scoreLabel' .. idx]:setString(win_cnt)

    if (data['my_clan_id'] == clan_data['league_info']['clan_id']) then
        vars['leagueMeNode']:setVisible(true)
    end
end

-------------------------------------
-- function setResult
-------------------------------------
function UI_ClanWarLeagueMatchListItem:setResult(result) -- A가 win : 1,  lose : 0, none = -1
    local vars = self.vars
    if (result == 0) then
        vars['defeatSprite1']:setVisible(true)
        vars['defeatSprite2']:setVisible(false)
    elseif (result == 1) then
        vars['defeatSprite1']:setVisible(false)
        vars['defeatSprite2']:setVisible(true)
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

	local struct_clan_rank = data['clan_info']
    local clan_name = struct_clan_rank:getClanName()
    local clan_rank = tostring(StructClanWarLeague.getClanWarRank(data))

    local clan_id = StructClanWarLeague.getClanId_byData(data)
    local win_cnt = StructClanWarLeague.getWinCount(data)
    local lose_cnt = StructClanWarLeague.getLoseCount(data)

    vars['clanNameLabel']:setString(Str(clan_name))
    vars['rankLabel']:setString(clan_rank)
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

