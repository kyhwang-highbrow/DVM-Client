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
        m_isMakeRightUI = 'boolean',
        m_isMakeLeftUI = 'boolean',

        m_preRefreshTime = 'time', -- 새로고침 쿨타임 체크용
     })

-- 가지 세로 길이
local BRUNCH_HEIGHT = 72
-- 가지 세로 길이 간격
local BRUNCH_HEIGHT_TERM = 10

-- 잎 세로길이
local LEAF_HEIGHT = 72
-- 잎 세로 길이 간격
local LEAF_HEIGHT_TERM = 10

local WIN_COLOR = cc.c3b(127, 255, 212)
local SCROLL_MENU_HEIGHT = 1250 -- 64강일 때 스크롤 사이즈
local FOCUS_POS_Y = 0 -- 스크롤메뉴 사이즈가 가변적이라서 함수에서 정의



local L_ROUND = {64, 32, 16, 8, 4, 2}
-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTree:init()
    local vars = self:load('clan_war_tournament_scene.ui')
    UIManager:open(self, UIManager.SCENE)
    
    self.m_page = 1
    self.m_lPosY = {}
    self.m_isMakeRightUI = false
    self.m_isMakeLeftUI = false
    self.m_preRefreshTime = 0

    -- 초기화
    self:initUI()
	self:initButton()

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarTournamentTree')

    -- 시즌 보상 팝업, 결과 화면은 동시에 뜸, 순차적으로 뜨게 만들어야함
	self:sceneFadeInAction(function()
        self:showResultPopup()

        local is_attacking, attacking_uid, end_date = g_clanWarData:isMyClanWarMatchAttackingState()
        if (is_attacking) then
            g_clanWarData:showPromoteGameStartPopup()
        end

        -- 시즌 보상 팝업 (보상이 있다면)
		if (g_clanWarData.m_tSeasonRewardInfo) then
		    local t_info = g_clanWarData.m_tSeasonRewardInfo
		    UI_ClanWarRewardPopup(t_info)
		    
		    g_clanWarData.m_tSeasonRewardInfo = nil
		end
    end)
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end


-------------------------------------
-- function update
-------------------------------------
function UI_ClanWarTournamentTree:update()
    local vars = self.vars
    local remain_time_text = g_clanWarData:getRemainTimeText()
    vars['timeLabel']:setString(remain_time_text)
    vars['timeLabel2']:setString(remain_time_text)

    if (g_clanWarData.m_clanWarDay == 14) then
        vars['timeLabel']:setString('-')
        vars['timeLabel2']:setString('-')      
    end
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
    vars['startBtn']:registerScriptTapHandler(function() self:click_gotoMatch() end)
    vars['startBtn2']:registerScriptTapHandler(function() self:click_gotoMatch() end)
    vars['matchTypeBtn']:registerScriptTapHandler(function() self:showGroupStagePopup() end)

    -- 시즌이 끝났을 경우, 전투시작 버튼 보여주지 않음
	if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['DONE']) then
		vars['startBtn']:setVisible(false)
	end

    vars['setDeckBtn']:registerScriptTapHandler(function() UI_ClanWarDeckSettings(CLAN_WAR_STAGE_ID) end)
    vars['helpBtn']:registerScriptTapHandler(function() UI_HelpClan('clan_war') end)
    vars['rewardBtn']:registerScriptTapHandler(function() UI_ClanwarRewardInfoPopup:OpneWithMyClanInfo() end)
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    vars['refreshBtn']:setVisible(true) -- 추가된 버튼으로 ui파일에서 visible이 false로 설정되어 있을 수 있다.
end

-------------------------------------
-- function initUI
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
    
	-- 현재 라운드에 포커싱 or 현재 라운드에 내가 있다면 포커싱
    -- 8강 이하는 무조건 결승전 페이지에 포커싱
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

    local use_primary_btn = true
    -- 1. 클랜전에 참여 중이 아닌 경우
    if (g_clanWarData:getMyClanState() ~= ServerData_ClanWar.CLANWAR_CLAN_STATE['PARTICIPATING']) then
        use_primary_btn = false

    -- 2. 클랜전이 오픈 상태가 아닌 경우
    elseif (g_clanWarData:getClanWarState() ~= ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
        use_primary_btn = false
    end

    -- 3. 내 클랜이 토너먼트 진출하지 못했을 경우, 전투시작 버튼 보여주지 않음
    local today_round = g_clanWarData:getTodayRound()
    local data, idx = self.m_structTournament:getMyInfoInCurRound(today_round)
	if (not data) then
        use_primary_btn = false
    end

    do -- 사용하는 버튼 설정
        vars['startBtn']:setVisible(use_primary_btn)
        vars['startBtn2']:setVisible(not use_primary_btn)
    end

    if (g_clanWarData.m_clanWarDay == 14) then
        vars['startBtnLabel']:setString(Str('시즌 종료'))
        vars['startBtnLabel2']:setString(Str('시즌 종료'))
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
-- @param skip_focus_reset(boolean) 상하 스크롤 위치 리셋 여부
-------------------------------------
function UI_ClanWarTournamentTree:showPage(skip_focus_reset)
	local page_number = self.m_page
	local vars = self.vars

    -- 페이지 초기화
	vars['finalNode']:setVisible(false)
	vars['rightScrollMenu']:setVisible(false)
    vars['leftScrollMenu']:setVisible(false)
    vars['tournamentTitle']:setVisible(true)
    vars['rightTitleNode']:setVisible(false)
    vars['leftTitleNode']:setVisible(false)

	-- 페이지 표시하는 동그라미 스프라이트 초기화
    vars['01_PageSelectSprite']:setVisible(false)
    vars['02_PageSelectSprite']:setVisible(false)
    vars['03_PageSelectSprite']:setVisible(false)

	-- 포커싱 초기화(맨 위)
    if (not skip_focus_reset) then
        self:initTableViewFocus()
    end

	local has_right
	local has_left
	if (page_number == 1) then
		has_right = true
		has_left = false
        vars['leftScrollMenu']:setVisible(true)
        vars['leftTitleNode']:setVisible(true)
	    if (not self.m_isMakeLeftUI) then
            self:showSidePage(skip_focus_reset)
            self.m_isMakeLeftUI = true
        end
	-- 결승전 페이지
	elseif (page_number == 2) then
        self:showCenterPage()
		has_right = true
		has_left = true
        vars['finalNode']:setVisible(true)
        vars['tournamentTitle']:setVisible(false)
	else
		has_right = false
		has_left = true
        vars['rightScrollMenu']:setVisible(true)
        vars['rightTitleNode']:setVisible(true)
        if (not self.m_isMakeRightUI) then
            self:showSidePage(skip_focus_reset)
            self.m_isMakeRightUI = true
        end
	end

	vars['moveBtn1']:setVisible(has_left)
	vars['moveBtn2']:setVisible(has_right)

	-- 해당 페이지 표시
    vars['0' .. page_number .. '_PageSelectSprite']:setVisible(true)
end

-------------------------------------
-- function showSidePage
-- @param skip_focus_reset(boolean) 상하 스크롤 위치 리셋 여부
-------------------------------------
function UI_ClanWarTournamentTree:showSidePage(skip_focus_reset)
	local vars = self.vars

	local struct_clan_war_tournament = self.m_structTournament
	local is_right = (self.m_page == 3) -- 페이지 넘버가 3이라면 오른쪽 페이지라고 판단

    -- 기존에 생성되어 있을 수 있는 UI 제거
    if (is_right == true) then
        vars['rightTitleNode']:removeAllChildren()
        vars['rightScrollMenu']:removeAllChildren()
    else--if (is_right == false) then
        vars['leftTitleNode']:removeAllChildren()
        vars['leftScrollMenu']:removeAllChildren()
    end
    
    local l_round = {}
	if (g_clanWarData:getMaxRound() == 64) then
		l_round = {64, 32, 16} -- 64강 부터 시작한다면 1,3 페이지에 64, 32, 16강을 찍는다.
	else
        l_round = {32, 16} -- 32강 부터 시작한다면 1,3 페이지에 32, 16강을 찍는다.
    end
	
    local max_idx = #l_round + 1
	for round_idx, round in ipairs(l_round) do
        -- 라운드에 해당하는 매치 잎들을 생성
		self:setTournament(round_idx, round, skip_focus_reset) -- param : ex) 1,64/ 2,32/ 3,16
		-- N강 표시하는 타이틀
        self:makeTitleItem(round_idx, round, max_idx)
    end
end

-------------------------------------
-- function makeTitleItem
-------------------------------------
function UI_ClanWarTournamentTree:makeTitleItem(round_idx, round, max_idx)
    local vars = self.vars
    local ui_title_item = UI_ClanWarTournamentTreeListItem(round)
    local max_round = g_clanWarData:getMaxRound()
    local is_right = (self.m_page == 3) -- 페이지 넘버가 3이라면 오른쪽 페이지라고 판단

    if (is_right) then
        local title_lua_name = max_round .. '_0' .. max_idx-round_idx .. 'TitleMenu'
        if (vars[title_lua_name]) then
            local pos_x = vars[title_lua_name]:getPositionX()
            ui_title_item.root:setPositionX(pos_x)
            vars['rightTitleNode']:addChild(ui_title_item.root)
        end
    else
        local title_lua_name = max_round .. '_0' .. round_idx .. 'TitleMenu'
        if (vars[title_lua_name]) then
            local pos_x = vars[title_lua_name]:getPositionX()
            ui_title_item.root:setPositionX(pos_x)
            vars['leftTitleNode']:addChild(ui_title_item.root)
        end
    end
    
    -- 현재 진행중인 타이틀에 표시
    local today_round = g_clanWarData:getTodayRound()
    if (round == today_round) then
    	ui_title_item:setInProgress()
    end
end

-------------------------------------
-- function showCenterPage
-------------------------------------
function UI_ClanWarTournamentTree:showCenterPage()
	-- 한번 만들었다면 또 만들지 않는다
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
    local ui = UI_ClanWarTournamentTreeFinalItem(self.m_structTournament)
    vars['finalNode']:removeAllChildren()
    vars['finalNode']:addChild(ui.root)

    self:makeFinalItemByRound(ui, 8, true) -- 8강 아이템들 생성
    self:makeFinalItemByRound(ui, 4, true) -- 4강 아이템들 생성

    self.m_isMakeFinalUI = true

    do -- 버튼 동작을 다른 라운드와 동일하게 UI_ClanWarTournamentTree 클래스에서 관리하도록 변경
        local struct_clan_war_tournament = self.m_structTournament
        local l_list = struct_clan_war_tournament:getTournamentListByRound(2)
        local final_data = l_list[1]
        if (not final_data) then
            return
        end

        local clan1_id = final_data['a_clan_id']
        local clan2_id = final_data['b_clan_id']

        -- 내 클랜 강조
	    local my_clan_id = g_clanWarData:getMyClanId()
        local include_my_clan = false
        if (clan1_id == my_clan_id) or (clan2_id == my_clan_id) then
            include_my_clan = true
        end

        -- 매치 아이템 눌렀을 때 상세 팝업
        local today_round = g_clanWarData:getTodayRound()
        local round = 2 -- final이기 때문에 하드코딩
        ui.vars['finalInfoBtn']:registerScriptTapHandler(function()
		    if (round < today_round) then
                UIManager:toastNotificationRed(Str('아직 진행되지 않은 경기입니다.'))
            elseif (round == today_round) then
                if include_my_clan then
                    self:click_gotoMatch()
                else
                    require('UI_ClanWarMatchingWatching')
                    UI_ClanWarMatchingWatching.OPEN(clan1_id)                
                end
            else
                UI_ClanWarMatchInfoDetailPopup.createMatchInfoPopup(final_data)
            end
        end)
    end
end

-------------------------------------
-- function makeFinalItemByRound
-- @brief 파이널은 위치가 박혀있기 때문에 따로 y 위치를 계산하지 않는다. 그래서 분리
-------------------------------------
function UI_ClanWarTournamentTree:makeFinalItemByRound(ui_final, round)
    local vars = self.vars
    local struct_clan_war_tournament = self.m_structTournament
        
    local l_list = struct_clan_war_tournament:getTournamentListByRound(round)
    for idx, data in ipairs(l_list) do
        local ui = self:makeTournamentLeaf(round, idx, data)
        ui.root:setPositionY(0)
        ui.vars['lineMenu']:setVisible(false)
		
        -- final UI에 아이템을 붙인다
		local node_lua_name = 'round' .. round .. '_' .. idx .. 'Node'
		if (ui_final.vars[node_lua_name]) then
			ui_final.vars[node_lua_name]:addChild(ui.root)
		end

        -- 이긴 클랜 가지에 색상 표시
        local is_clan_1_win = false
        if (data['win_clan']) then
            if (data['win_clan'] == data['a_clan_id']) then
                is_clan_1_win = true
            end

            -- 8강 2번째 아이템의 첫번째가 이겼을 경우 2*2 -1 3번째가지에 이긴 색상 표시
            local win_idx = idx*2
            if (is_clan_1_win) then
                win_idx = idx*2 -1
            end

            local lua_name = 'round' .. round .. '_' .. win_idx
            if (ui_final.vars[lua_name]) then
                ui_final.vars[lua_name]:setVisible(true)
            end
        end   
    end
end

-------------------------------------
-- function setTournament
-- @brief 해당 라운드의 매치들을 생성
-- @param skip_focus_reset(boolean) 상하 스크롤 위치 리셋 여부
-------------------------------------
function UI_ClanWarTournamentTree:setTournament(round_idx, round, skip_focus_reset)
    local vars = self.vars

	local is_right = (self.m_page == 3)
    local struct_clan_war_tournament = self.m_structTournament
    local l_list = struct_clan_war_tournament:getTournamentListByRound(round)
    local my_clan_idx = nil
    local my_clan_id = g_clanWarData:getMyClanId()

    local clan1 = {}
    local clan2 = {}
    local item_idx = 1
    local max_round = g_clanWarData:getMaxRound()

    -- title 1,2,3,4 -> title 4,3,2,1
    -- 오른쪽 페이지는 반대로 찍어야 해서 하드코딩..
    local max_idx = 4
    if (max_round == 32) then
        max_idx = 3
    end

    -- 타이틀이 posX를 각 매치 잎을의 posX로 사용
	local func_get_pos_x = function(round_idx)
		local pos_x = 0
		if (is_right) then
            local title_lua_name = max_round .. '_0' .. max_idx-round_idx .. 'TitleMenu'
			if (vars[title_lua_name]) then
                pos_x = vars[title_lua_name]:getPositionX()
		    end
        else
            local title_lua_name = max_round .. '_0' .. round_idx .. 'TitleMenu'
            if (vars[title_lua_name]) then
                pos_x = vars[title_lua_name]:getPositionX()
		    end
        end
		return pos_x
	end

    -- 오른쪽 페이지의 경우 매치 넘버가 절반보다 높은 아이템들만 생성
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

            -- 매치 잎 생성
            local ui = self:makeTournamentLeaf(round, idx, data, is_right)
            -- 내 클랜이 몇 번째 매치 잎에 있는지 계산 - 포커싱에 사용
            if (data['a_clan_id'] == my_clan_id) or (data['b_clan_id'] == my_clan_id) then
                my_clan_idx = idx
            end
            
            if (ui) then
	    		local pos_x = func_get_pos_x(round_idx)
                ui.root:setDockPoint(TOP_CENTER)
	    		ui.root:setPositionX(pos_x)
                if (is_right) then
                    vars['rightScrollMenu']:addChild(ui.root)
                else
                    vars['leftScrollMenu']:addChild(ui.root)
                end
                -- 가지 세팅 : 가로
                ui:setLine(g_clanWarData:getMaxRound() == round) -- param : is_both, 마지막 라운드만 왼쪽에 가로 선이 없음

	    		-- 오른쪽 페이지의 경우, 왼쪽 페이지 기준으로 만든 가지를 X축 기준으로 뒤집음
	    		if (is_right) then
	    			ui.vars['lineMenu']:setScaleX(-1)
	    		end

                -- 가지의 세로 길이
                local line_height = BRUNCH_HEIGHT * round_idx + math.floor(round_idx/3) * BRUNCH_HEIGHT + BRUNCH_HEIGHT_TERM * (round_idx-1) --100, 230, 460
                ui:setRightHeightLine(idx, line_height/2)
            end
        end
    end

    -- 내 클랜이 있다면 포커싱, 없다면 해주지 않음
    if (not skip_focus_reset) and (my_clan_idx) then
        self:focusMyClan(my_clan_idx, is_right, round)
    end

end

-------------------------------------
-- function focusMyClan
-------------------------------------
function UI_ClanWarTournamentTree:focusMyClan(my_clan_idx, is_right, round)
    local first_pos_y = FOCUS_POS_Y

    local container_node = self.m_scrollView:getContainer()
    if (is_right) then
        my_clan_idx = my_clan_idx - round/4
    end
	local pos_y = self.m_lPosY[my_clan_idx] or 0

    -- 기준 y 위치에서 얼마나 내려온 값인지 distance 구함
    local dist = self:getFirstPosY() - pos_y
    local focus_y = first_pos_y + dist - 100 -- 중간에 위치시키기 위해 100 빼줌
    focus_y = math.max(focus_y, first_pos_y)
    focus_y = math.min(focus_y, 0)
    container_node:setPositionY(focus_y)
end

-------------------------------------
-- function makeTournamentLeaf
-------------------------------------
function UI_ClanWarTournamentTree:makeTournamentLeaf(round, item_idx, data, is_right)
    local vars = self.vars

    local struct_clan_war_tournament = self.m_structTournament
    local clan1_id = data['a_clan_id']
    local clan2_id = data['b_clan_id']

    -- 세트 스코어
    local clan1_set_score = tonumber(data['a_member_win_cnt']) or 0
    local clan2_set_score = tonumber(data['b_member_win_cnt']) or 0

    local struct_clan_rank_1 = g_clanWarData:getClanInfo(clan1_id)
    local struct_clan_rank_2 = g_clanWarData:getClanInfo(clan2_id)

    local ui = UI_ClanWarTournamentTreeLeaf()
    local clan_name1 = ''
    local clan_name2 = ''
    local clan_node1
    local clan_node2

    -- 내 클랜 강조
	local my_clan_id = g_clanWarData:getMyClanId()
    local include_my_clan = false
    if (clan1_id == my_clan_id) or (clan2_id == my_clan_id) then
        ui.vars['meClanSprite']:setVisible(true)
        include_my_clan = true
    end

    -- 매치 아이템 눌렀을 때 상세 팝업
    local today_round = g_clanWarData:getTodayRound()
    ui.vars['detailBtn']:registerScriptTapHandler(function()
		if (round < today_round) then
            UIManager:toastNotificationRed(Str('아직 진행되지 않은 경기입니다.'))
        elseif (round == today_round) then
            if include_my_clan then
                self:click_gotoMatch()
            else
                require('UI_ClanWarMatchingWatching')
                UI_ClanWarMatchingWatching.OPEN(clan1_id)                
            end
        else
            UI_ClanWarMatchInfoDetailPopup.createMatchInfoPopup(data)
        end
    end)

    local get_clan_node_pos_x = function(label)
        local string_width = label:getStringWidth()
        local pos_x = -(string_width / 2)
        return pos_x - 20
    end

    -- 이름, 클랜 마크
    do      
        if (clan1_id == 'loser') then
            clan_name1 = Str('대전 상대가 없음')
            ui.vars['clanNameLabel1']:setColor(COLOR['gray'])
        elseif (struct_clan_rank_1) then
            local clan_name = struct_clan_rank_1:getClanName() or ''
            clan_name1 = clan_name .. '  ' .. tostring(clan1_set_score)
            clan_node1 = struct_clan_rank_1:makeClanMarkIcon()
        else
            clan_name1 = Str('대전 상대가 없음')
            ui.vars['clanNameLabel1']:setColor(COLOR['gray'])
        end

        ui.vars['clanNameLabel1']:setString(clan_name1)
        if (clan_node1) then
            ui.vars['clanMarkNode1']:addChild(clan_node1)
            local pos_x = get_clan_node_pos_x(ui.vars['clanNameLabel1'])
            ui.vars['clanMarkNode1']:setPositionX(pos_x)
        end
         
        if (clan2_id == 'loser') then
            clan_name2 = Str('대전 상대가 없음')
            ui.vars['clanNameLabel2']:setColor(COLOR['gray'])
        elseif (struct_clan_rank_2) then
            local clan_name = struct_clan_rank_2:getClanName() or ''
            clan_name2 = clan_name .. '  ' .. tostring(clan2_set_score)
            clan_node2 = struct_clan_rank_2:makeClanMarkIcon()
        else
            clan_name2 = Str('대전 상대가 없음')
            ui.vars['clanNameLabel2']:setColor(COLOR['gray'])
        end
        ui.vars['clanNameLabel2']:setString(clan_name2)
        if (clan_node2) then
            ui.vars['clanMarkNode2']:addChild(clan_node2)
            local pos_x = get_clan_node_pos_x(ui.vars['clanNameLabel2'])
            ui.vars['clanMarkNode2']:setPositionX(pos_x)
        end
    end

    local is_clan_1_win = false
    if (data['win_clan']) then
        if (data['win_clan'] == clan1_id) then
            is_clan_1_win = true
        end
    end

	ui.vars['defeatSprite1']:setVisible(false)
	ui.vars['defeatSprite2']:setVisible(false)
    ui:setWin(is_clan_1_win, not is_clan_1_win)

    -- 현재 진행중인 라운드의 경우
    -- 승패 표시 안함, 뒷 막대기 표시
    if (today_round == round) then
		ui.vars['leftHorizontalSprite']:setColor(WIN_COLOR)
        ui.vars['todayVisual']:setVisible(true)

    -- 진행 안한 라운드의 경우
    -- 승패 표시 안함, 뒷 막대기 표시 안함
	elseif (today_round >= round) then
		-- 마지막 라운드는 항상 닉네임만 세팅된 상태
        if (round ~= g_clanWarData:getMaxRound()) then
            local last_round = round*2
            ui.vars['clanNameLabel1']:setString(Str('미정'))
            ui.vars['clanNameLabel2']:setString(Str('미정'))
        end    
        ui.vars['clanNameLabel1']:setColor(COLOR['gray'])
        ui.vars['clanNameLabel2']:setColor(COLOR['gray'])
    -- 지나간 라운드의 경우
    -- 승패 표시함, 뒷 막대기 표시
	else
		ui.vars['leftHorizontalSprite']:setColor(WIN_COLOR)
		ui.vars['defeatSprite1']:setVisible(not is_clan_1_win)
        ui.vars['defeatSprite2']:setVisible(is_clan_1_win)
		ui:setWinLineColor(is_clan_1_win)
	end

    -- 중앙 페이지에는 위치 세팅할 필요가 없음
    if (self.m_page == 2) then
        return ui
    end

    local pos_y = 0
	local first_pos = self:getFirstPosY()
	-- 오른쪽 페이지의 매치 잎들은 64강의 경우 17, 18, 19 .. 절반보다 높은 인덱스 부터 시작함, 
	-- 높이 함수는 왼쪽 페이지와 같은 것을 사용하기 때문에 item_idx = (item_idx - 16) 해줌
    if (is_right) then
        item_idx = item_idx - round/4
    end

    -- 결승전으로 이어지는 오른쪽 라인 생성
    if (round == 16) then
        ui:setLineConnectedToFinal()
        if (today_round < round) then
            ui:setColorConnectedToFinal()
        end
    end

    -- 첫 경기일 경우
	-- 2개 생성하고 간격 + 아이템 높이
    if (round == g_clanWarData:getMaxRound()) then
        pos_y = first_pos + -math.ceil(item_idx/2 - 1) * LEAF_HEIGHT_TERM + -(item_idx - 1) * LEAF_HEIGHT  
        self.m_lPosY[item_idx] = pos_y
        ui.root:setPositionY(pos_y)
        return ui
    end
	
    -- 그 다음 경기 부터는 첫 경기에 만들어진 y 위치 기반으로 위치를 계산
    -- 이전 경기 2개의 중앙값
	local idx = item_idx * 2
    local pos_1 = self.m_lPosY[idx] or 0
    local pos_2 = self.m_lPosY[idx - 1] or 0
    pos_y = (pos_1 + pos_2)/2

    self.m_lPosY[item_idx] = pos_y
    ui.root:setPositionY(pos_y)    
    return ui
end

-------------------------------------
-- function getFirstPosY
-------------------------------------
function UI_ClanWarTournamentTree:getFirstPosY()
    local vars = self.vars
    local first_pos = vars['scrollPosY']:getPositionY()
    return first_pos
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
		ori_size['height'] = SCROLL_MENU_HEIGHT
    else
		ori_size['height'] = SCROLL_MENU_HEIGHT/2
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

	local _container = scroll_view:getContainer()
    local size = _container:getContentSize()

	local viewSize = scroll_view:getViewSize()
    local x = viewSize['width'] - size['width']
    local y = viewSize['height'] - size['height']

	FOCUS_POS_Y = y
end

-------------------------------------
-- function initTableViewFocus
-------------------------------------
function UI_ClanWarTournamentTree:initTableViewFocus()
    if (self.m_scrollView) then
	    local container_node = self.m_scrollView:getContainer()
	    container_node:setPositionY(FOCUS_POS_Y)
    end
end

-------------------------------------
-- function click_gotoMatch
-------------------------------------
function UI_ClanWarTournamentTree:click_gotoMatch()    
    -- 마지막 날의 경우
    if (g_clanWarData.m_clanWarDay == 14) then
        local msg = Str('다음 시즌 오픈까지 {1}', g_clanWarData:getRemainNextSeasonTime())
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end
    
    -- 열려있는지 확인
	local is_open, msg = g_clanWarData:checkClanWarState_Tournament()
	if (not is_open) then	
		MakeSimplePopup(POPUP_TYPE.OK, msg)
		return
	end

    --1.클랜전 미참가
    if (g_clanWarData:getMyClanState() == ServerData_ClanWar.CLANWAR_CLAN_STATE['NOT_PARTICIPATING']) then
        local msg = Str('소속된 클랜이 클랜전에 참가하지 못했습니다.')
        local sub_msg = Str('각종 클랜 활동 기록으로 참가 클랜이 결정됩니다.\n꾸준한 클랜 활동을 이어가 주시기 바랍니다.')
        MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
        return
    end
    
    --2.토너먼트 진출 실패
    if (g_clanWarData:getMyClanState() == ServerData_ClanWar.CLANWAR_CLAN_STATE['LEAVING_OUT']) then
        local msg = Str('토너먼트에서 탈락했습니다.')
        local sub_msg = Str('다음 시즌에서 더 높은 순위를 노려보세요.')
        MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
        return
    end
    
    --3.토너먼트 중 탈락
    if (g_clanWarData:getMyClanState() == ServerData_ClanWar.CLANWAR_CLAN_STATE['DEFEAT_IN_TOURNAMENT']) then
        local msg = Str('소속된 클랜이 다음 라운드에 진출하지 못했습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end
	
    -- 매치에 내 클랜 정보가 있는지 확인
	local struct_clan_war_tournament = self.m_structTournament
    local my_clan_id = g_clanWarData:getMyClanId()
    local data = struct_clan_war_tournament:getTournamentInfo(my_clan_id)
    if (not data) then
        return
    end
    
	local success_cb = function(struct_match, match_info)
        -- 상대가 유령클랜이거나 클랜 정보가 없을 경
		if (match_info) then
            local no_clan_func = function()
                local msg = Str('대전 상대가 없어 부전승 처리되었습니다.')
                MakeSimplePopup(POPUP_TYPE.OK, msg)
            end
            
            local clan_id_a = match_info['a_clan_id']
            local clan_id_b = match_info['b_clan_id']
            if (clan_id_a == 'loser') then
                 no_clan_func()
                return               
            end
            
            if (clan_id_b == 'loser') then
                 no_clan_func()
                return               
            end

            local my_clan_info = g_clanWarData:getClanInfo(clan_id_a)
            if (not my_clan_info) then         
                no_clan_func()
                return
            end

            local enemy_clan_info = g_clanWarData:getClanInfo(clan_id_b)
            if (not enemy_clan_info) then
                no_clan_func()
                return
            end
        end
        
        UI_ClanWarMatchingScene(struct_match)
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb)
end

-------------------------------------
-- function showLastRankPopup
-------------------------------------
function UI_ClanWarTournamentTree:showLastRankPopup()
	-- 1.이미 기록된 day라면 return
	local day = g_settingData:getClanWarDay()
	if (day == g_clanWarData.m_clanWarDay) then
		return
	end

	-- 2.라운드 정보가 없다면 return
	local round = g_clanWarData:getTodayRound()
	if (not round) then
		return
	end

	-- 3.이전날 경기 정보가 없다면 return
    local last_round = round * 2
	local l_list = self.m_structTournament:getTournamentListByRound(last_round)
    if (not l_list) then
        return
    end

	-- 4.이전날 내 경기 정보가 없다면 return
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
-- function showGroupStagePopup
-------------------------------------
function UI_ClanWarTournamentTree:showGroupStagePopup()
    UI_ClanWarLastGroupStagePopup.open()
end

-------------------------------------
-- function click_refreshBtn
-- @brief 현재 화면을 최신으로 갱신
-------------------------------------
function UI_ClanWarTournamentTree:click_refreshBtn()
    local func_check_cooldown -- 1. 쿨타임 체크
    local func_request_info -- 2. 통신
    local func_refresh -- 3. 갱신 (현재 페이지를 갱신)

    -- 1. 쿨타임 체크
    func_check_cooldown = function()
        -- 갱신 가능 시간인지 체크한다
	    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local RENEW_INTERVAL = 10
	    if (curr_time - self.m_preRefreshTime > RENEW_INTERVAL) then
		    self.m_preRefreshTime = curr_time
		    -- 일반적인 갱신
		    func_request_info()
	
	    -- 시간이 되지 않았다면 몇초 남았는지 토스트 메세지를 띄운다
	    else
		    local ramain_time = math_ceil(RENEW_INTERVAL - (curr_time - self.m_preRefreshTime) + 1)
		    UIManager:toastNotificationRed(Str('{1}초 후에 갱신 가능합니다.', ramain_time))
	    end
    end

    -- 2. 통신
    func_request_info = function()
        g_clanWarData:request_clanWarLeagueInfo(nil, func_refresh) -- param : team, success_cb
    end

    -- 3. 갱신 (현재 페이지를 갱신)
    func_refresh = function(ret)
        --self:setTournamentData(ret)
        self.m_structTournament = StructClanWarTournament(ret)

        -- 페이지별 UI를 다시 생성하기 위해 초기화
        self.m_isMakeFinalUI = false
        self.m_isMakeRightUI = false
        self.m_isMakeLeftUI = false

        self:showPage(true) -- param : skip_focus_reset
	    self:checkStartBtn()
    end


    -- 시작 함수 호출
    func_check_cooldown()
end









