
-------------------------------------
-- class UI_ClanWarTournamentTree
-------------------------------------
UI_ClanWarTournamentTree = class({
        vars = 'vars',
        m_scrollMenu = 'ScrollMenu',
        m_scrollView = 'ScrollView',

        m_lPosY = 'list',

        m_structTournament = 'StructClanWarTournament',

		m_page = 'number',
        m_isLeagueMode = 'boolean',
		m_makeLastLeague = 'boolean',
     })

local leaf_width = 260 + 45
local leaf_height = 100
local leaf_height_term = 30
local win_color = cc.c3b(127, 255, 212)

local L_ROUND = {64, 32, 16, 8, 4, 2}
-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTree:init(vars, root)
    self.vars = vars 
    self.m_page = 1
    self.m_lPosY = {}
    self.m_isLeagueMode = false

    -- 초기화
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarTournamentTree:initButton()
	local vars = self.vars
	vars['rightMoveBtn']:registerScriptTapHandler(function() self:click_moveBtn(1) end)
	vars['leftMoveBtn']:registerScriptTapHandler(function() self:click_moveBtn(-1) end)
    vars['testBtn']:registerScriptTapHandler(function() UI_ClanWarTest(cb_func, false) end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_gotoMatch() end)
    vars['matchTypeBtn']:registerScriptTapHandler(function() self:showLastLeague() end)

    -- 시즌이 끝났을 경우, 전투시작 버튼 보여주지 않음
	if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['DONE']) then
		vars['startBtn']:setVisible(false)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarTournamentTree:initUI()
	local vars = self.vars
    self:initScroll()

    vars['matchTypeBtn']:setVisible(true)
	vars['matchTypeLabel']:setString(Str('조별리그'))
end

-------------------------------------
-- function showLastLeague
-------------------------------------
function UI_ClanWarTournamentTree:showLastLeague()
	local vars = self.vars
    
    if (self.m_isLeagueMode) then
        self.m_isLeagueMode = false
    else
        self.m_isLeagueMode = true
    end 

    vars['leagueMenu']:setVisible(self.m_isLeagueMode)
	vars['tournamentMenu']:setVisible(not self.m_isLeagueMode)
	vars['startBtn']:setVisible(not self.m_isLeagueMode)
    vars['myClanSprite']:setVisible(self.m_isLeagueMode)

	self:checkStartBtn()
	
	local my_clan_id = g_clanWarData:getMyClanId()
    local struct_league = self.m_structTournament:getStructClanWarLeague()    
	local struct_league_item = struct_league:getLeagueInfo(my_clan_id)
	local team_number = struct_league_item:getLeague()
	vars['myClanLabel']:setString(Str('{1}조', team_number))
	
	if (not self.m_isLeagueMode) then
		vars['matchTypeLabel']:setString(Str('조별리그'))
	else
		vars['matchTypeLabel']:setString(Str('토너먼트'))
	end

	-- 한 번 만들었다면 더 이상 만들지 않는다.
	if (self.m_makeLastLeague) then
		return
	end
    
    if (struct_league) then
        ui = UI_ClanWarLeague(vars)
        ui:refreshUI_fromTournament(struct_league)
        ui:showOnlyMyLeague()
    end

	self.m_makeLastLeague = true
end

-------------------------------------
-- function setTournamentData
-------------------------------------
function UI_ClanWarTournamentTree:setTournamentData(ret)
	local vars = self.vars
	self.m_structTournament = StructClanWarTournament(ret)
    
    -- Test Mode에서 내 클랜 승리시키기 위해 필요한 코드
    local is_my_clan_left = self.m_structTournament:getMyClanLeft()
    g_clanWarData:setIsMyClanLeft(is_my_clan_left)
    
	-- 현재 라운드에 포커싱
    -- 현재 라운드에 내가 있다면 포커싱
    local today_round = g_clanWarData:getTodayRound()
    if (today_round <= 8) then
        self.m_page = 2
    else
        -- 오른쪽/왼쪽 페이지인지 판별
        -- 인덱스가 절반보다 클 경우 오른쪽
        local data, idx = self.m_structTournament:getMyInfoInCurRound(today_round)
        if (idx) then
            if (idx > today_round/4) then
                self.m_page = 3
            else
                self.m_page = 1
            end           
        end
    end

    self:showPage()
	self:checkStartBtn()
end

-------------------------------------
-- function checkStartBtn
-------------------------------------
function UI_ClanWarTournamentTree:checkStartBtn()
	local vars = self.vars

	-- 내 클랜이 토너먼트 진출하지 못했을 경우, 전투시작 버튼 보여주지 않음
    local today_round = g_clanWarData:getTodayRound()
    local data, idx = self.m_structTournament:getMyInfoInCurRound(today_round)
	if (not data) then
		vars['startBtn']:setVisible(false)
	end
end

-------------------------------------
-- function click_moveBtn
-------------------------------------
function UI_ClanWarTournamentTree:click_moveBtn(value)
	local vars = self.vars

	self.m_page = self.m_page + value
	
	if (self.m_page > 3) then
		self.m_page = 3
	elseif (self.m_page < 1) then
		self.m_page = 1
	end

	self:showPage()
end

-------------------------------------
-- function showPage
-------------------------------------
function UI_ClanWarTournamentTree:showPage()
	local page_number = self.m_page
	local vars = self.vars
	vars['finalNode']:removeAllChildren()
	self.m_scrollMenu:removeAllChildren()
    vars['listItemNode']:setVisible(true)
    self:initTableViewFocus()

	local has_right
	local has_left
	if (page_number == 1) then
		self:showSidePage(false)
		has_right = true
		has_left = false
	elseif (page_number == 2) then
		vars['listItemNode']:setVisible(false)
        self:showCenterPage()
		has_right = true
		has_left = true
	else
		self:showSidePage(true)
		has_right = false
		has_left = true
	end

	vars['rightMoveBtn']:setVisible(has_right)
	vars['leftMoveBtn']:setVisible(has_left)
end

-------------------------------------
-- function showSidePage
-------------------------------------
function UI_ClanWarTournamentTree:showSidePage(is_right)
	local vars = self.vars
	local struct_clan_war_tournament = self.m_structTournament

	local l_round = {32, 16, 8}
	if (g_clanWarData:getMaxRound() == 64) then
		l_round = {64, 32, 16}
	end
	
	for round_idx, round in ipairs(l_round) do
        self:setTournament(round_idx, round, is_right)
		
		-- N강 표시하는 타이틀
		local ui_title_item = UI_ClanWarTournamentTreeListItem(round)

        if (not is_right) then
            if (vars['titleItemNode'..round_idx]) then
                vars['titleItemNode'..round_idx]:removeAllChildren()
		        vars['titleItemNode'..round_idx]:addChild(ui_title_item.root)
            end
        else
            if (vars['titleItemNode'..4-round_idx]) then
                vars['titleItemNode'..4-round_idx]:removeAllChildren()
		        vars['titleItemNode'..4-round_idx]:addChild(ui_title_item.root)
            end
        end

		local today_round = g_clanWarData:getTodayRound()
		if (round == today_round) then
			ui_title_item:setInProgress()
		end
    end
end

-------------------------------------
-- function showCenterPage
-------------------------------------
function UI_ClanWarTournamentTree:showCenterPage()
	self:setFinal()
end

-------------------------------------
-- function setFinal
-------------------------------------
function UI_ClanWarTournamentTree:setFinal()
    local vars = self.vars

    local ui = UI()
    ui:load('clan_war_tournament_final_item.ui')
    vars['finalNode']:addChild(ui.root)

    self:makeFinalItemByRound(ui, 8, true) -- is_round_menu
    self:makeFinalItemByRound(ui, 4, true)

    local today_round = g_clanWarData:getTodayRound()
    local round_text = Str('결승전')

    if (today_round <= 16) then
        ui.vars['round16LineSprite1']:setColor(win_color)
        ui.vars['round16LineSprite2']:setColor(win_color)
        ui.vars['round16LineSprite3']:setColor(win_color)
        ui.vars['round16LineSprite4']:setColor(win_color)
    end

    if (today_round <= 8) then
        ui.vars['round8LineSprite1']:setColor(win_color)
        ui.vars['round8LineSprite2']:setColor(win_color)
    end

    if (today_round <= 4) then
        ui.vars['round4LineSprite']:setColor(win_color)
    end

    if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
	    if (today_round == 2) then
	        round_text = round_text .. ' - ' .. Str('진행중')
            ui.vars['todaySprite']:setVisible(true)
            ui.vars['roundLabel']:setColor(COLOR['black'])
            ui.vars['attackVisual']:setVisible(true)
	    else
            ui.vars['normalIconSprite']:setVisible(true)
        end 
    end

    ui.vars['roundLabel']:setString(round_text)
    if (today_round > 2) then
        ui.vars['finalClanLabel1']:setString(Str('{1}강', 4) .. ' ' .. Str('승리 클랜'))
        ui.vars['finalClanLabel2']:setString(Str('{1}강', 4) .. ' ' .. Str('승리 클랜'))
        ui.vars['finalClanLabel1']:setColor(COLOR['gray'])
        ui.vars['finalClanLabel2']:setColor(COLOR['gray'])
    else
        local l_list = self.m_structTournament:getTournamentListByRound(2)
        local final_data = l_list[1]
        if (not final_data) then
            return
        end
        local struct_clan_rank_1 = g_clanWarData:getClanInfo(final_data['a_clan_id'])
        local struct_clan_rank_2 = g_clanWarData:getClanInfo(final_data['b_clan_id'])
        if (not struct_clan_rank_1) then
            struct_clan_rank_1 = StructClanRank()
        end

        if (not struct_clan_rank_2) then
            struct_clan_rank_2 = StructClanRank()
        end

        local final_name_1 = struct_clan_rank_1:getClanName()
        local final_name_2 = struct_clan_rank_2:getClanName()
        ui.vars['finalClanLabel1']:setString(final_name_1)
        ui.vars['finalClanLabel2']:setString(final_name_2)

        if (today_round == 1) then
            ui.vars['winVisual']:setVisible(true)
            ui.vars['clanMarkNode']:setVisible(true)

            local is_clan_1_win = false
            if (final_data['win_clan']) then
                if (final_data['win_clan'] == clan1_id) then
                    is_clan_1_win = true
                end
            end
            local clan_win_1 = is_clan_1_win
            ui.vars['winMenu1']:setVisible(clan_win_1)
            ui.vars['winMenu2']:setVisible(not clan_win_1)
            ui.vars['defeatSprite1']:setVisible(not clan_win_1)
            ui.vars['defeatSprite2']:setVisible(clan_win_1)

            local mark_icon = nil
            if (clan_win_1) then
                mark_icon = struct_clan_rank_1:makeClanMarkIcon()
            else
                mark_icon = struct_clan_rank_2:makeClanMarkIcon()
            end
            if (mark_icon) then
                ui.vars['clanMarkNode']:addChild(mark_icon)
            end
        end
    end
end

-------------------------------------
-- function makeFinalItemByRound
-------------------------------------
function UI_ClanWarTournamentTree:makeFinalItemByRound(ui_final, round)
    local vars = self.vars
    local struct_clan_war_tournament = self.m_structTournament
        
    local l_list = struct_clan_war_tournament:getTournamentListByRound(round)
    for idx, data in ipairs(l_list) do
        local ui = self:makeTournamentLeaf(round, idx, data)
        ui.root:setPositionY(0)
        ui.vars['lineMenu']:setVisible(false)
        ui.vars['roundMenu']:setVisible(true)

        local round_text = g_clanWarData:getRoundText(round)
        if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
            local today_round = g_clanWarData:getTodayRound()
	        if (round == today_round) then
		        round_text = round_text .. ' - ' .. Str('진행중')
                ui.vars['todaySprite']:setVisible(true)
                ui.vars['roundLabel']:setColor(COLOR['black'])
	        end 
        end

        ui.vars['roundLabel']:setString(round_text)
        ui_final.vars['round' .. round .. '_' .. idx .. 'Node']:addChild(ui.root)
    end    
end

-------------------------------------
-- function setTournament
-------------------------------------
function UI_ClanWarTournamentTree:setTournament(round_idx, round, is_right)
    local vars = self.vars
    local struct_clan_war_tournament = self.m_structTournament
    local l_list = struct_clan_war_tournament:getTournamentListByRound(round)
    local my_clan_idx = nil
    local my_clan_id = g_clanWarData:getMyClanId()

    local clan1 = {}
    local clan2 = {}
    local item_idx = 1

	local func_get_pos_x = function(round_idx, leaf_width)
		local pos_x = 0
		if (is_right) then
			pos_x = vars['leafItemNode' .. 4-round_idx]:getPositionX()
		else
			pos_x = vars['leafItemNode' .. round_idx]:getPositionX()
		end
		return pos_x
	end

    local func_get_is_valid = function(idx)
		local is_valid_item = false
        if (is_right) then
            if (idx > (#l_list)/2) then
                is_valid_item = true
            else
                is_valid_item = false
            end
        else
            if (idx <= (#l_list)/2) then
                is_valid_item = true
            else
                is_valid_item = false
            end        
        end

		return is_valid_item
	end

	-- N강 치르는 개별 클랜 리스트 = l_list
    for idx, data in ipairs(l_list) do
        if (func_get_is_valid(idx)) then
            local ui = self:makeTournamentLeaf(round, idx, data, is_right)
            if (data['a_clan_id'] == my_clan_id) or (data['b_clan_id'] == my_clan_id) then
                my_clan_idx = idx
            end
            
            if (ui) then
	    		local pos_x = func_get_pos_x(round_idx, leaf_width)
                ui.root:setDockPoint(TOP_CENTER)
	    		ui.root:setPositionX(pos_x)
                self.m_scrollMenu:addChild(ui.root)

                -- 가지 세팅 : 가로
                ui:setLine(g_clanWarData:getMaxRound() == round) -- is_both 마지막 라운드만 왼쪽에 가로 선이 없음

	    		-- 왼쪽 페이지 기준으로 만든 가지를 X축 기준으로 뒤집음
	    		if (is_right) then
	    			ui.vars['lineMenu']:setScaleX(-1)
	    		end

                -- 가지 세팅 : 세로
                local line_height = leaf_height * round_idx + math.floor(round_idx/3) * leaf_height + leaf_height_term * (round_idx-1) --100, 230, 460
                ui:setRightHeightLine(idx, line_height/2)
            end
        end
    end

    local first_pos_y = -1500
    if (g_clanWarData:getMaxRound() == 32) then
        first_pos_y = -500
    end

    if (my_clan_idx) then
        if (is_right) then
            my_clan_idx = my_clan_idx - round/4
        end
	    local container_node = self.m_scrollView:getContainer()
	    local pos_y = self.m_lPosY[my_clan_idx] or 0
        local focus_y = first_pos_y - (pos_y) + -210
        focus_y = math.max(focus_y, first_pos_y)
        container_node:setPositionY(focus_y)
	    --container_node:setPositionY(first_pos_y - (pos_y) + -110)
    end
end

-------------------------------------
-- function makeTournamentLeaf
-------------------------------------
function UI_ClanWarTournamentTree:makeTournamentLeaf(round, item_idx, data, is_right)
    local vars = self.vars
    local term = 30
    local width = 100

    local struct_clan_war_tournament = self.m_structTournament
    local clan1_id = data['a_clan_id']
    local clan2_id = data['b_clan_id']

    local struct_clan_rank_1 = g_clanWarData:getClanInfo(clan1_id)
    local struct_clan_rank_2 = g_clanWarData:getClanInfo(clan2_id)

    local ui = UI_ClanWarTournamentTreetLeafItem()
    local clan_name1 = ''
    local clan_name2 = ''
    
	local my_clan_id = g_clanWarData:getMyClanId()
    if (clan1_id == my_clan_id) or (clan2_id == my_clan_id) then
        ui.vars['meClanSprite']:setVisible(true)
    end

    local today_round = g_clanWarData:getTodayRound()
    ui.vars['detailBtn']:registerScriptTapHandler(function()
        if (round < today_round) then
            UIManager:toastNotificationRed(Str('기록 없음'))
        else
            UI_ClanWarMatchInfoDetailPopup(data) 
        end
    end)

    if (struct_clan_rank_1) then
        local clan_name = struct_clan_rank_1:getClanName() or ''
        clan_name1 = clan_name
    end
    ui.vars['clanNameLabel1']:setString(clan_name1)
    
    if (struct_clan_rank_2) then
        local clan_name = struct_clan_rank_2:getClanName() or ''
        clan_name2 = clan_name
    end
    ui.vars['clanNameLabel2']:setString(clan_name2)

    local is_clan_1_win = false
    if (data['win_clan']) then
        if (data['win_clan'] == clan1_id) then
            is_clan_1_win = true
        end
    end

	ui.vars['defeatSprite1']:setVisible(false)
	ui.vars['defeatSprite2']:setVisible(false)
	ui.vars['winSprite1']:setVisible(false)
	ui.vars['winSprite2']:setVisible(false)
    ui:setWin(is_clan_1_win, not is_clan_1_win)
	
    -- 현재 진행중인 라운드의 경우
    -- 승패 표시 안함, 뒷 막대기 표시
    if (today_round == round) then
		ui.vars['leftHorizontalSprite']:setColor(win_color)
    -- 진행 안한 라운드의 경우
    -- 승패 표시 안함, 뒷 막대기 표시 안함
	elseif (today_round >= round) then
		    
        local last_round = round*2
        ui.vars['clanNameLabel1']:setString(Str('{1}강', last_round) .. ' ' .. Str('승리 클랜'))
        ui.vars['clanNameLabel2']:setString(Str('{1}강', last_round) .. ' ' .. Str('승리 클랜'))
        ui.vars['clanNameLabel1']:setColor(COLOR['gray'])
        ui.vars['clanNameLabel2']:setColor(COLOR['gray'])
    -- 지나간 라운드의 경우
    -- 승패 표시함, 뒷 막대기 표시
	else
		ui.vars['leftHorizontalSprite']:setColor(win_color)
		ui.vars['defeatSprite1']:setVisible(not is_clan_1_win)
        ui.vars['defeatSprite2']:setVisible(is_clan_1_win)
	    ui.vars['winSprite1']:setVisible(is_clan_1_win)
	    ui.vars['winSprite2']:setVisible(not is_clan_1_win)
		ui:setWinLineColor(is_clan_1_win)
	end

    -- 중앙 페이지에는 위치 세팅할 필요가 없음
    if (self.m_page == 2) then
        return ui
    end

    local pos_y = 0
	local first_pos = -60
    if (is_right) then
        item_idx = item_idx - round/4
    end

    -- 첫 경기일 경우
    if (round == g_clanWarData:getMaxRound()) then
        pos_y = first_pos + -math.ceil(item_idx/2 - 1) * term + -(item_idx - 1) * width  
        self.m_lPosY[item_idx] = pos_y
        ui.root:setPositionY(pos_y)
        return ui
    end
	
    local idx = item_idx * 2
    pos_y = (self.m_lPosY[idx] + self.m_lPosY[idx - 1])/2

    self.m_lPosY[item_idx] = pos_y
    ui.root:setPositionY(pos_y)    
    return ui
end


-------------------------------------
-- function initScroll
-------------------------------------
function UI_ClanWarTournamentTree:initScroll()
    local vars = self.vars
    local scroll_node = self.vars['tournamentScrollNode']
    local scroll_menu = self.vars['tournamentScrollMenu']
	
	local ori_size = scroll_menu:getContentSize()
	if (g_clanWarData:getMaxRound() == 64) then
		ori_size['height'] = 2000
    else
		ori_size['height'] = 1000
	end
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
    scroll_menu:retain()
    scroll_menu:removeFromParent()
    scroll_view:addChild(scroll_menu)
    scroll_menu:release()

    local size_y = size.height - target_size.height
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.m_scrollMenu = scroll_menu
    self.m_scrollView = scroll_view

	self:initTableViewFocus()
end

-------------------------------------
-- function initTableViewFocus
-------------------------------------
function UI_ClanWarTournamentTree:initTableViewFocus()
    if (self.m_scrollView) then
	    local container_node = self.m_scrollView:getContainer()
	    if (g_clanWarData:getMaxRound() == 64) then
	    	container_node:setPositionY(-1500)
	    else
	    	container_node:setPositionY(-500)		
	    end
    end
end

-------------------------------------
-- function click_gotoMatch
-------------------------------------
function UI_ClanWarTournamentTree:click_gotoMatch()    
    local is_open, msg = g_clanWarData:checkClanWarState_Tournament()
	if (not is_open) then	
		MakeSimplePopup(POPUP_TYPE.OK, msg)
		return
	end

	local struct_clan_war_tournament = self.m_structTournament
    local my_clan_id = g_clanWarData:getMyClanId()
    local data = struct_clan_war_tournament:getTournamentInfo(my_clan_id)
    if (not data) then
        return
    end
    
    local my_win_cnt, enemy_win_cnt = data['a_member_win_cnt'], data['b_member_win_cnt']
    
	local success_cb = function(t_my_struct_match, t_enemy_struct_match)
        local ui_clan_war_matching = UI_ClanWarMatchingScene(t_my_struct_match, t_enemy_struct_match)
        ui_clan_war_matching:setScore(my_win_cnt, enemy_win_cnt)
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb)
end










-------------------------------------
-- class UI_ClanWarTournamentTreetLeafItem
-------------------------------------
UI_ClanWarTournamentTreetLeafItem = class(UI, {
    m_clan1Win = 'boolean',
    m_clan2Win = 'boolean',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTreetLeafItem:init()
    local vars = self:load('clan_war_tournament_item_leaf.ui')
    
	vars['lineMenu']:setVisible(true)
end

-------------------------------------
-- function setWin
-------------------------------------
function UI_ClanWarTournamentTreetLeafItem:setWin(is_clan1_win, is_clan2_win)
    self.m_clan1Win = is_clan1_win
    self.m_clan2Win = is_clan2_win
end

-------------------------------------
-- function setLine
-------------------------------------
function UI_ClanWarTournamentTreetLeafItem:setLine(is_both)
    local vars = self.vars

    vars['leftHorizontalSprite']:setVisible(not is_both)
end

-------------------------------------
-- function setRightHeightLine
-------------------------------------
function UI_ClanWarTournamentTreetLeafItem:setRightHeightLine(idx, height)
    local vars = self.vars

    if (idx%2 == 0) then
        vars['rightLine2']:setScale(1, -1)
    else
    end
    vars['rightLine2']:setNormalSize(2, height)
end

-------------------------------------
-- function setWinLineColor
-------------------------------------
function UI_ClanWarTournamentTreetLeafItem:setWinLineColor(is_up_win)
    local vars = self.vars

	if (is_up_win) then
		vars['topClanLine1']:setColor(win_color)
		vars['topClanLine2']:setColor(win_color)
	else
		vars['bottomClanLine1']:setColor(win_color)
		vars['bottomClanLine2']:setColor(win_color)		
	end
    vars['rightLine1']:setColor(win_color)
	vars['rightLine2']:setColor(win_color)
end

-------------------------------------
-- function getMyInfoInCurRound
-------------------------------------
function UI_ClanWarTournamentTreetLeafItem:getMyInfoInCurRound(today_round)
    local l_list = self.m_structTournament:getTournamentListByRound(today_round)
    local my_clan_id = g_clanWarData:getMyClanId()
    for idx, data in ipairs(l_list) do
        if (my_clan_id == data['clan_id']) then
            return data, idx
        end
    end
    return nil
end







-------------------------------------
-- class UI_ClanWarTournamentTreeListItem
-------------------------------------
UI_ClanWarTournamentTreeListItem = class(UI, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTreeListItem:init(round)
    local vars = self:load('clan_war_tournament_item_title.ui')
    vars['roundLabel']:setString(Str('{1}강전', round))
end

-------------------------------------
-- function setInProgress
-------------------------------------
function UI_ClanWarTournamentTreeListItem:setInProgress()
	local vars = self.vars
    vars['todaySprite']:setVisible(false)

	local round_text = vars['roundLabel']:getString()
	if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
		round_text = round_text .. ' - ' .. Str('진행중')
        vars['todaySprite']:setVisible(true)
        vars['roundLabel']:setColor(COLOR['black'])
	end
	vars['roundLabel']:setString(round_text)
end