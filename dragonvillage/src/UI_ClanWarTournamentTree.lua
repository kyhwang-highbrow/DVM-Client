local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ClanWarTournamentTree
-------------------------------------
UI_ClanWarTournamentTree = class(PARENT, {
        m_scrollMenu = 'ScrollMenu',
        m_scrollView = 'ScrollView',

        m_lPosY = 'list',

        m_structTournament = 'StructClanWarTournament',

		m_page = 'number',

        m_isMakeFinalUI = 'boolean',
     })

local LEAF_WIDTH = 260 + 45
local BRUNCH_HEIGHT = 100
local BRUNCH_HEIGHT_TERM = 30
local LEAF_HEIGHT = 70
local LEAF_HEIGHT_TERM = 10
local WIN_COLOR = cc.c3b(127, 255, 212)

local L_ROUND = {64, 32, 16, 8, 4, 2}
-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTree:init()
    local vars = self:load('clan_war_tournament_scene.ui')
    UIManager:open(self, UIManager.SCENE)
    
    self.m_page = 1
    self.m_lPosY = {}

    -- 초기화
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanWarTournamentTree:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanWarTournamentTree'
    self.m_titleStr = Str('클랜전') .. '-' .. Str('토너먼트')
	--self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanWarTournamentTree:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarTournamentTree:initButton()
	local vars = self.vars
	vars['moveBtn1']:registerScriptTapHandler(function() self:click_moveBtn(-1) end)
	vars['moveBtn2']:registerScriptTapHandler(function() self:click_moveBtn(1) end)
    vars['testBtn']:registerScriptTapHandler(function() UI_ClanWarTest(cb_func, false) end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_gotoMatch() end)
    vars['matchTypeBtn']:registerScriptTapHandler(function() end) --self:showLastLeague() end)

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
        -- 경기 안하고 있을 때에도 포커싱 해주어야함 32강이 최대일 때 앞에서 한 번 더 찾음
        if (not idx) then
            data, idx = self.m_structTournament:getMyInfoInCurRound(today_round/2)
        end

        if (idx) then
            if (idx >= today_round/4) then
                self.m_page = 3
            else
                self.m_page = 1
            end           
        end
    end

    self:showPage()
	self:checkStartBtn()
    
    -- 지난 결과 팝업
    self:showResultPopup()
end

-------------------------------------
-- function showResultPopup
-------------------------------------
function UI_ClanWarTournamentTree:showResultPopup()
    local show_league_result_popup = false
    local season = g_settingData:getClanWarSeason()

    -- 이번 시즌 조별리그 최종 결과 팝업을 보여주었는 지 판단
	if (season ~= g_clanWarData.m_season) then
		show_league_result_popup = true
	end

    -- 토너먼트 전 날 결과 팝업
    local show_last_rank_popup = function()
        self:showLastRankPopup()
    end

    -- 조별리그 최종 결과 팝업도 보여주어야 한다면, 팝업 닫고 다음 팝업이 열리도록 함
    if (show_league_result_popup) then
        self:showLeagueResultPopup(show_last_rank_popup)
    else
        show_last_rank_popup()
    end
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

    -- 페이지 초기화
	vars['finalNode']:setVisible(false)
	vars['rightScrollMenu']:setVisible(false)
    vars['leftScrollMenu']:setVisible(false)
    vars['tournamentTitle']:setVisible(true)

    vars['01_PageSelectSprite']:setVisible(false)
    vars['02_PageSelectSprite']:setVisible(false)
    vars['03_PageSelectSprite']:setVisible(false)

    self:initTableViewFocus()

	local has_right
	local has_left
	if (page_number == 1) then
		self:showSidePage(true)
		has_right = true
		has_left = false
        vars['rightScrollMenu']:setVisible(true)
	elseif (page_number == 2) then
        self:showCenterPage()
		has_right = true
		has_left = true
        vars['finalNode']:setVisible(true)
        vars['tournamentTitle']:setVisible(false)
	else
		self:showSidePage(false)
		has_right = false
		has_left = true
        vars['leftScrollMenu']:setVisible(true)
	end

	vars['moveBtn1']:setVisible(has_left)
	vars['moveBtn2']:setVisible(has_right)
    vars['0' .. page_number .. '_PageSelectSprite']:setVisible(true)
end

-------------------------------------
-- function showSidePage
-------------------------------------
function UI_ClanWarTournamentTree:showSidePage(is_right)
	local vars = self.vars
	local struct_clan_war_tournament = self.m_structTournament
    local max_round = g_clanWarData:getMaxRound()
	local l_round = {32, 16, 8}
	if (g_clanWarData:getMaxRound() == 64) then
		l_round = {64, 32, 16}
	end
	
	for round_idx, round in ipairs(l_round) do
        self:setTournament(round_idx, round, is_right)
		
		-- N강 표시하는 타이틀
		local ui_title_item = UI_ClanWarTournamentTreeListItem(round)

        -- 64_01TitleMenu
        -- round .. '_0' .. idx .. 'TitleMenu'
        -- max_round .. '_0' .. idx .. 'TitleMenu'
        
        if (is_right) then
            local title_lua_name = max_round .. '_0' .. round_idx .. 'TitleMenu'
            if (vars[title_lua_name]) then
                vars[title_lua_name]:removeAllChildren()
		        vars[title_lua_name]:addChild(ui_title_item.root)
            end
        else
            local title_lua_name = max_round .. '_0' .. 4-round_idx .. 'TitleMenu'
            if (vars[title_lua_name]) then
                vars[title_lua_name]:removeAllChildren()
		        vars[title_lua_name]:addChild(ui_title_item.root)
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
	if (self.m_isMakeFinalUI) then
        return
    end
    
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

    if (today_round <= 8) then
        ui.vars['round16LineSprite1']:setColor(WIN_COLOR)
        ui.vars['round16LineSprite2']:setColor(WIN_COLOR)
        ui.vars['round16LineSprite3']:setColor(WIN_COLOR)
        ui.vars['round16LineSprite4']:setColor(WIN_COLOR)
    end

    if (today_round <= 4) then
        ui.vars['round8LineSprite1']:setColor(WIN_COLOR)
        ui.vars['round8LineSprite2']:setColor(WIN_COLOR)
    end

    if (today_round <= 2) then
        ui.vars['round4LineSprite']:setColor(WIN_COLOR)
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

    self.m_isMakeFinalUI = true
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
    local max_round = g_clanWarData:getMaxRound()

	local func_get_pos_x = function(round_idx, LEAF_WIDTH)
		local pos_x = 0
		if (is_right) then
            local title_lua_name = max_round .. '_0' .. round_idx .. 'TitleMenu'
			pos_x = vars[title_lua_name]:getPositionX()
		else
            local title_lua_name = max_round .. '_0' .. 4-round_idx .. 'TitleMenu'
			pos_x = vars[title_lua_name]:getPositionX()
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
	    		local pos_x = func_get_pos_x(round_idx, LEAF_WIDTH)
                ui.root:setDockPoint(TOP_CENTER)
	    		ui.root:setPositionX(pos_x)
                if (is_right) then
                    vars['rightScrollMenu']:addChild(ui.root)
                else
                    vars['leftScrollMenu']:addChild(ui.root)
                end
                -- 가지 세팅 : 가로
                ui:setLine(g_clanWarData:getMaxRound() == round) -- is_both 마지막 라운드만 왼쪽에 가로 선이 없음

	    		-- 왼쪽 페이지 기준으로 만든 가지를 X축 기준으로 뒤집음
	    		if (not is_right) then
	    			ui.vars['lineMenu']:setScaleX(-1)
	    		end

                -- 세로 길이
                local line_height = BRUNCH_HEIGHT * round_idx + math.floor(round_idx/3) * BRUNCH_HEIGHT + BRUNCH_HEIGHT_TERM * (round_idx-1) --100, 230, 460
                ui:setRightHeightLine(idx, line_height/2)
            end
        end
    end

    local first_pos_y = -680
    if (g_clanWarData:getMaxRound() == 32) then
        first_pos_y = -340
    end

    local container_node = self.m_scrollView:getContainer()
    if (my_clan_idx) then
        if (is_right) then
            my_clan_idx = my_clan_idx - round/4
        end
	    local pos_y = self.m_lPosY[my_clan_idx] or 0
        local focus_y = first_pos_y - (pos_y) + -210
        focus_y = math.max(focus_y, first_pos_y)
        container_node:setPositionY(focus_y)
    else
        container_node:setPositionY(first_pos_y)
    end
end

-------------------------------------
-- function makeTournamentLeaf
-------------------------------------
function UI_ClanWarTournamentTree:makeTournamentLeaf(round, item_idx, data, is_right)
    local vars = self.vars

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
            UIManager:toastNotificationRed(Str('아직 진행되지 않은 경기입니다.'))
        else
            UI_ClanWarMatchInfoDetailPopup.createMatchInfoPopup(data)
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
		ui.vars['leftHorizontalSprite']:setColor(WIN_COLOR)

    -- 진행 안한 라운드의 경우
    -- 승패 표시 안함, 뒷 막대기 표시 안함
	elseif (today_round >= round) then
		-- 마지막 라운드는 항상 닉네임만 세팅된 상태
        if (round ~= g_clanWarData:getMaxRound()) then
            local last_round = round*2
            ui.vars['clanNameLabel1']:setString(Str('{1}강', last_round) .. ' ' .. Str('승리 클랜'))
            ui.vars['clanNameLabel2']:setString(Str('{1}강', last_round) .. ' ' .. Str('승리 클랜'))
        end    
        ui.vars['clanNameLabel1']:setColor(COLOR['gray'])
        ui.vars['clanNameLabel2']:setColor(COLOR['gray'])
    -- 지나간 라운드의 경우
    -- 승패 표시함, 뒷 막대기 표시
	else
		ui.vars['leftHorizontalSprite']:setColor(WIN_COLOR)
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
	local first_pos = vars['scrollPosY']:getPositionY()
    if (is_right) then
        item_idx = item_idx - round/4
    end

    -- 첫 경기일 경우
    if (round == g_clanWarData:getMaxRound()) then
        pos_y = first_pos + -math.ceil(item_idx/2 - 1) * LEAF_HEIGHT_TERM + -(item_idx - 1) * LEAF_HEIGHT  
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
		ori_size['height'] = 1250
    else
		ori_size['height'] = 600
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
    
	local success_cb = function(t_my_struct_match, t_enemy_struct_match)
        UI_ClanWarMatchingScene(t_my_struct_match, t_enemy_struct_match)
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb)
end

-------------------------------------
-- function showLastRankPopup
-------------------------------------
function UI_ClanWarTournamentTree:showLastRankPopup()
	local day = g_settingData:getClanWarDay()
	if (day == g_clanWarData.m_clanWarDay) then
		return
	end

	local round = g_clanWarData:getTodayRound()
	if (not round) then
		return
	end

    local last_round = round * 2
	local l_list = self.m_structTournament:getTournamentListByRound(last_round)
    if (not l_list) then
        return
    end

	local my_clan_id = g_clanWarData:getMyClanId()
	local last_match_data = nil
	for i, data in ipairs(l_list) do
		if (data['group_stage'] == last_round) then
			if (data['a_clan_id'] == my_clan_id) or (data['b_clan_id'] == my_clan_id) then
				last_match_data = data
				break
			end
		end
	end

    if (not last_match_data) then
        return
    end

	UI_ClanWarMatchInfoDetailPopup.createYesterdayResultPopup(last_match_data)
	g_settingData:setClanWarDay(g_clanWarData.m_clanWarDay)
end

-------------------------------------
-- function showLeagueResultPopup
-------------------------------------
function UI_ClanWarTournamentTree:showLeagueResultPopup(close_cb)
    local season = g_settingData:getClanWarSeason()
    if (season == g_clanWarData.m_season) then
		return
	end

    -- 토너먼트는 마지막 리그 정보를 보여줌
    local struct_league = self.m_structTournament:getStructClanWarLeague()
    if (not struct_league) then
    	return
    end

    local l_rank = struct_league:getClanWarLeagueRankList()
    local my_clan_match_data = nil
    for i, data in ipairs(l_rank) do
    	if (data['clan_id'] == g_clanWarData:getMyClanId()) then
    		my_clan_match_data = data
    		break
    	end
    end
    
    if (not my_clan_match_data) then
    	return
    end
    
    local ui = UI_ClanWarLeagueResultPopup(struct_league)
    ui:initDetailRankUI(my_clan_match_data)
    ui:setCloseCB(close_cb)
    g_settingData:setClanWarSeason(g_clanWarData.m_season)
    return
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
    end
    vars['rightLine2']:setNormalSize(2, height)
end

-------------------------------------
-- function setWinLineColor
-------------------------------------
function UI_ClanWarTournamentTreetLeafItem:setWinLineColor(is_up_win)
    local vars = self.vars

	if (is_up_win) then
		vars['topClanLine1']:setColor(WIN_COLOR)
		vars['topClanLine2']:setColor(WIN_COLOR)
	else
		vars['bottomClanLine1']:setColor(WIN_COLOR)
		vars['bottomClanLine2']:setColor(WIN_COLOR)		
	end
    vars['rightLine1']:setColor(WIN_COLOR)
	vars['rightLine2']:setColor(WIN_COLOR)
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