local PARENT = UI

-------------------------------------
-- class UI_ClanwarRewardInfoPopup
-------------------------------------
UI_ClanwarRewardInfoPopup = class(PARENT, {
        m_tableView = 'UIC_TableView'
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanwarRewardInfoPopup:init(is_league, _league_rank, _tournament_rank)
    local vars = self:load('clan_war_reward_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
	local league_rank = _league_rank or 0
    local tournament_rank = _tournament_rank or 0

	self:initUI()
    if (is_league) then
        self:setLeague(league_rank, tournament_rank)
    else
        self:setTournament(league_rank, tournament_rank)
    end
	
	self:initButton()

	-- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanwarRewardInfoPopup')
end

-------------------------------------
-- function setLeague
-------------------------------------
function UI_ClanwarRewardInfoPopup:setLeague(league_rank)
    local vars = self.vars

    -- 클랜전 보상 정보만
    -- 32부터라면, 32강까지만, 그룹 보상이 4위부터면 4위까지만
    local max_round = g_clanWarData:getMaxRound()
    local max_clan_group = g_clanWarData:getGroupCnt()
    local l_item_list = {}
    for rank_id, t_data in pairs(TABLE:get('table_clan_reward')) do
        if (t_data['category'] == 'clanwar_league') then
            if (t_data['rank_max'] <= max_clan_group) then
                table.insert(l_item_list, t_data)
            end
        end

        if (t_data['category'] == 'clanwar_tournament') then
            if (t_data['rank_max'] <= max_round) then
                table.insert(l_item_list, t_data)
            end
        end
    end

    -- 테이블 정렬
    table.sort(l_item_list, function(a, b)
        return tonumber(a['rank_id']) < tonumber(b['rank_id'])
    end)

    local my_rank = league_rank
    -- 조별리그 1-2등은 토너먼트 랭크에 포커싱
    local category = 'clanwar_tournament'
    if (league_rank <= 2) and (league_rank ~= 0)then
        my_rank = max_round
    else
        category = 'clanwar_league'
    end

    local create_func = function(ui, data)
        if (data['category'] == category) then
			if (data['rank_max'] >= my_rank) and (data['rank_min'] <= my_rank) then
				ui.vars['meSprite']:setVisible(true)
			end
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(550, 45 + 5)
	table_view:setCellUIClass(UI_ClanwarRewardInfoPopupList, create_func)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
   
    self.m_tableView = table_view
    local focus_idx = 0
    for i, t_data in ipairs(l_item_list) do
        if (t_data['category'] == category) then
            if (t_data['rank_min'] <= my_rank) and (t_data['rank_max'] >= my_rank) then
                focus_idx = i
                break
            end
        end
    end

    local my_rank_text = ''
	if (league_rank <= 0) then
		my_rank_text = '-'
	else
		my_rank_text = Str('조별리그') .. ' ' .. Str('{1}위', league_rank)
	end

    -- 조별리그 순위
	vars['leagueRankLabel']:setString(my_rank_text)
	vars['tournamentRankLabel']:setString('-')
	
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanwarRewardInfoPopup:update()
    if (self.m_tableView) then
        self.m_tableView.m_scrollView:setTouchEnabled(false)
    end
end

-------------------------------------
-- function setTournament
-------------------------------------
function UI_ClanwarRewardInfoPopup:setTournament(league_rank, tournament_rank)
    local vars = self.vars

    -- 클랜전 보상 정보만
    -- 32부터라면, 32강까지만, 그룹 보상이 4위부터면 4위까지만
    local max_round = g_clanWarData:getMaxRound()
    local max_clan_group = g_clanWarData:getGroupCnt()
    local l_item_list = {}
    for rank_id, t_data in pairs(TABLE:get('table_clan_reward')) do
        if (t_data['category'] == 'clanwar_league') then
            if (t_data['rank_max'] <= max_clan_group) then
                table.insert(l_item_list, t_data)
            end
        end

        if (t_data['category'] == 'clanwar_tournament') then
            if (t_data['rank_max'] <= max_round) then
                table.insert(l_item_list, t_data)
            end
        end
    end

    -- 테이블 정렬
    table.sort(l_item_list, function(a, b)
        return tonumber(a['rank_id']) < tonumber(b['rank_id'])
    end)

    local my_rank = tournament_rank
    local category = 'clanwar_tournament'
    if (tournament_rank <= 0) then
        my_rank = league_rank
        category = 'clanwar_league'
    end

    local create_func = function(ui, data)
        if (data['category'] == category) then
			if (data['rank_max'] >= my_rank) and (data['rank_min'] <= my_rank) then
				ui.vars['meSprite']:setVisible(true)
			end
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(550, 45 + 5)
	table_view:setCellUIClass(UI_ClanwarRewardInfoPopupList, create_func)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_tableView = table_view

    local focus_idx = 0
    for i, t_data in ipairs(l_item_list) do
        if (t_data['category'] == category) then
            if (t_data['rank_min'] <= my_rank) and (t_data['rank_max'] >= my_rank) then
                focus_idx = i
                break
            end
        end
    end

    local my_rank_text = ''
	if (league_rank <= 0) then
		my_rank_text = '-'
	else
		my_rank_text = Str('조별리그') .. ' ' .. Str('{1}위', league_rank)
	end

    -- 조별리그 순위
	vars['leagueRankLabel']:setString(my_rank_text)

    -- 토너먼트 순위
    local tournament_rank_str = g_clanWarData:getRoundText(tournament_rank)
    if (tournament_rank == 2) then
        tournament_rank_str = Str('준우승')
    end
    if (tournament_rank == 1) then
        tournament_rank_str = Str('우승')
    end
    vars['tournamentRankLabel']:setString(tournament_rank_str)
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanwarRewardInfoPopup:initUI()
    local vars = self.vars
	local struct_clan = g_clanData:getClanStruct()

	-- 클랜 이름
	local clan_name = struct_clan:getClanName()
	vars['clanNameLabel']:setString(clan_name)

    -- 클랜 마스터 닉네임
    local clan_master = struct_clan:getMasterNick() or ''
    vars['masterNameLabel']:setString(clan_master)
	
	-- 클랜 마크 
	local clan_icon = struct_clan:makeClanMarkIcon()
	if (clan_icon) then
		vars['clanMarkNode']:addChild(clan_icon)
	end

	--맴버 수
    local member_cnt = struct_clan.member_cnt or 0
	local member_max = struct_clan.member_max or 0
    vars['clanNumLabel']:setString(member_cnt .. '/' .. member_max)

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end








local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanwarRewardInfoPopupList
-------------------------------------
UI_ClanwarRewardInfoPopupList = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanwarRewardInfoPopupList:init(data)
    local vars = self:load('clan_war_reward_info_popup_item.ui')
    
	self:initUI(data)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanwarRewardInfoPopupList:initUI(data)
    local vars = self.vars

    -- 랭킹
    local rank = data['t_name']
    vars['rankLabel']:setString(Str(rank))
    
    -- 보상1
    local reward = data['reward']
    local l_reward = pl.stringx.split(reward, ';')
    local reward = l_reward[2]
    if (reward) then
        vars['rewardLabel1']:setString(comma_value(reward))
    end

    -- 보상2
    local clan_exp = data['clan_exp']
    vars['rewardLabel2']:setString(comma_value(clan_exp))
end


-------------------------------------
-- function OpneWithMyClanInfo
-- @brief 클랜전 보상 팝업을 연다. (내 클랜의 현재 순위를 반영해서)
-------------------------------------
function UI_ClanwarRewardInfoPopup:OpneWithMyClanInfo()
    local is_group_stage = g_clanWarData:isGroupStage()

    -- 조별리그 순위 (클랜전에 참여하지 않은 유저일 수도 있다)
    local group_stage_rank = 0
    if g_clanWarData.m_myClanGroupStageInfo then
        group_stage_rank = (g_clanWarData.m_myClanGroupStageInfo['rank'] or 0)
    end

    local tournament_rank = 0
    if g_clanWarData.m_myClanTournamentInfo then
        tournament_rank = (g_clanWarData.m_myClanTournamentInfo['group_stage'] or 0)
    end

    UI_ClanwarRewardInfoPopup(is_group_stage, group_stage_rank, tournament_rank) -- param : is_league, _league_rank, _tournament_rank
end