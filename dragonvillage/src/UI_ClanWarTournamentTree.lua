
-------------------------------------
-- class UI_ClanWarTournamentTree
-------------------------------------
UI_ClanWarTournamentTree = class({
        vars = 'vars',
        m_scrollMenu = 'ScrollMenu',
        m_lPosY = 'list',

        m_structTournament = 'StructClanWarTournament',
        m_maxRound = 'number',

		m_page = 'number',
     })

local leaf_width = 260 + 45
local leaf_height = 100
local leaf_height_term = 30
local win_color = cc.c3b(127, 255, 212)

local L_ROUND = {64, 32, 16, 8, 4, 2}
-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTree:init(vars)
    self.vars = vars
    self.m_maxRound = 32
    self.m_page = 1
    self.m_lPosY = {}
	
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
    
    self:showPage()
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
	vars['listItemNode']:removeAllChildren()
	self.m_scrollMenu:removeAllChildren()

	if (page_number == 1) then
		self:showSidePage(false)
	elseif (page_number == 2) then
		self:showCenterPage()
	else
		self:showSidePage(true)
	end
end

-------------------------------------
-- function showSidePage
-------------------------------------
function UI_ClanWarTournamentTree:showSidePage(is_right)
	local vars = self.vars

	local func_get_pos_x = function(round_idx, leaf_width)
		local pos_x = 0
		if (is_right) then
			pos_x = 160 - (round_idx-1) * (leaf_width)
		else
			pos_x = -200 + (round_idx-1) * (leaf_width)
		end
		return pos_x
	end

	local l_round = {32, 16, 8}
	for round_idx, round in ipairs(l_round) do
        self:setTournament(round_idx, round, is_right)
		
		-- N강 표시하는 타이틀
		local ui_title_item = UI_ClanWarTournamentTreeListItem(round)
		local pos_x = func_get_pos_x(round_idx, leaf_width)
		ui_title_item.root:setPositionX(pos_x)
		vars['listItemNode']:addChild(ui_title_item.root)

		local today_round = self.m_structTournament:getTodayRound()
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
    
    local y = (self.m_lPosY[1] + self.m_lPosY[2])/2
    local pos_y = { y , y , y}
    local pos_x = {-250,  -250 + leaf_width*2, -250 + leaf_width}
    local vars = self.vars
    local struct_clan_war_tournament = self.m_structTournament

    local l_list = struct_clan_war_tournament:getTournamentListByRound(4)
    local total_y = 300
    local term = 0
    
    local clan1 = {}
    local clan2 = {}
    local item_idx = 1
    for idx, data in ipairs(l_list) do
        if (idx%2 == 1) then
            clan1 = data
        else
            clan2 = data
            local ui = self:makeTournamentLeaf(4, item_idx, clan1, clan2)
            if (ui) then
                ui.root:setPosition(pos_x[item_idx], pos_y[item_idx])
                self.m_scrollMenu:addChild(ui.root)
                item_idx = item_idx + 1
            end
        end
    end

    local l_list = struct_clan_war_tournament:getTournamentListByRound(2)
    local total_y = 300
    local term = 0
    
    local clan1 = {}
    local clan2 = {}
    local item_idx = 1
    for idx, data in ipairs(l_list) do
        if (idx%2 == 1) then
            clan1 = data
        else
            clan2 = data
            local ui = self:makeTournamentLeaf(2, item_idx, clan1, clan2)
            if (ui) then
                ui.root:setPosition(pos_x[3], pos_y[3])
                self.m_scrollMenu:addChild(ui.root)
                item_idx = item_idx + 1
            end
        end
    end
end

-------------------------------------
-- function setTournament
-------------------------------------
function UI_ClanWarTournamentTree:setTournament(round_idx, round, is_right)
    local vars = self.vars
    local struct_clan_war_tournament = self.m_structTournament

    local l_list = struct_clan_war_tournament:getTournamentListByRound(round)
    
    local clan1 = {}
    local clan2 = {}
    local item_idx = 1

	local func_get_pos_x = function(round_idx, leaf_width)
		local pos_x = 0
		if (is_right) then
			pos_x = 150 - (round_idx-1) * (leaf_width)
		else
			pos_x = -200 + (round_idx-1) * leaf_width
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
        if (idx%2 == 1) then
            clan1 = data
        else
            clan2 = data

            -- 클랜 2개를 묶어서 하나의 아이템 생성 (토너먼트 트리 잎)
            if (func_get_is_valid(idx)) then
                local ui = self:makeTournamentLeaf(round, item_idx, clan1, clan2)
                if (ui) then
					local pos_x = func_get_pos_x(round_idx, leaf_width)
                    ui.root:setPositionX(pos_x)
                    self.m_scrollMenu:addChild(ui.root)
                    item_idx = item_idx + 1

                    -- 가지 세팅 : 가로
                    ui:setLine(self.m_maxRound == round) -- is_both 마지막 라운드만 왼쪽에 가로 선이 없음

					-- 왼쪽 페이지 기준으로 만든 가지를 X축 기준으로 뒤집음
					if (is_right) then
						ui.vars['lineMenu']:setScaleX(-1)
					end

                    -- 가지 세팅 : 세로
                    local line_height = leaf_height * round_idx + math.floor(round_idx/3) * leaf_height + leaf_height_term * (round_idx-1) --100, 230, 460
                    ui:setRightHeightLine(idx/2, line_height/2)
                end
            end
        end
    end
end

-------------------------------------
-- function makeTournamentLeaf
-------------------------------------
function UI_ClanWarTournamentTree:makeTournamentLeaf(round, item_idx, clan1, clan2)
    local vars = self.vars
    local term = 30
    local width = 100

    local struct_clan_war_tournament = self.m_structTournament
    local clan1_id = clan1['clan_id']
    local clan2_id = clan2['clan_id']

    local struct_clan_rank_1 = struct_clan_war_tournament:getClanInfo(clan1_id)
    local struct_clan_rank_2 = struct_clan_war_tournament:getClanInfo(clan2_id)

    local ui = UI_ClanWarTournamentTreetLeafItem()
    local clan_name1 = ''
    local clan_name2 = ''
    
    if (struct_clan_rank_1) then
        clan_name1 = struct_clan_rank_1:getClanName() .. clan1['group_stage_no']
    end
    ui.vars['clanNameLabel1']:setString(clan_name1)
    
    if (struct_clan_rank_2) then
        clan_name2 = struct_clan_rank_2:getClanName().. clan2['group_stage_no']
    end
    ui.vars['clanNameLabel2']:setString(clan_name2)

	local clan_1_is_win = StructClanWarTournament.isWin(clan1)
	local clan_2_is_win = StructClanWarTournament.isWin(clan2)
	ui.vars['defeatSprite1']:setVisible(not clan_1_is_win)
	ui.vars['defeatSprite2']:setVisible(not clan_2_is_win)
    ui:setWin(clan_1_is_win, clan_2_is_win)

	local today_round = struct_clan_war_tournament:getTodayRound()
	if (today_round == round) then
		ui.vars['leftHorizontalSprite']:setColor(win_color)
        ui.vars['defeatSprite1']:setVisible(false)
		ui.vars['defeatSprite2']:setVisible(false)	
	
	elseif (today_round >= round) then
		ui.vars['defeatSprite1']:setVisible(false)
		ui.vars['defeatSprite2']:setVisible(false)		
	
	else
		ui.vars['leftHorizontalSprite']:setColor(win_color)
		ui.vars['defeatSprite1']:setVisible(clan_1_is_win)
		ui:setWinLineColor(clan_1_is_win)
	end

    local pos_y = 0
    -- 첫 경기일 경우
    if (round == self.m_maxRound) then
        pos_y = 400 + -math.ceil(item_idx/2 - 1) * term + -(item_idx - 1) * width  
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

	local round_text = vars['roundLabel']:getString()
	round_text = round_text .. ' - ' .. Str('진행중')
	vars['roundLabel']:setString(round_text)
end