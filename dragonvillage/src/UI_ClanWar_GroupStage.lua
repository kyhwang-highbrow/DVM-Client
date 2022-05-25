require('UI_ListItem_ClanWarGroupStage')

local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())
-------------------------------------
-- class UI_ClanWar_GroupStage
-------------------------------------
UI_ClanWar_GroupStage = class(PARENT, {
        -- 외부에서 설정되어야 할 데이터 (ServerData)
        m_groupCount = 'number',    -- 조별리그 조의 수 (32개조, 64개조 ...)
        m_structLeague = 'StructClanWarLeague',
        m_structLeaguecache = 'table[group] = struct',
        m_focusGroup = '',

        -- 8개 조를 1개의 페이지로 묶어서 탭으로 동작
        m_groupPaging = 'UI_ClanWar_GroupPaging',


        m_tableViewAllGroupRank = '',
        m_tableViewGroupRank = '',
        m_tableViewGroupMatch = '',

        m_preRefreshTime = 'time', -- 새로고침 쿨타임 체크용
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanWar_GroupStage:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanWar_GroupStage'
    self.m_titleStr = Str('클랜전') .. '-' .. Str('조별리그')
	--self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanWar_GroupStage:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initVariable
-------------------------------------
function UI_ClanWar_GroupStage:initVariable()
    -- 전체 그룹 수
    self.m_groupCount = g_clanWarData:getEntireGroupCnt()

    self.m_structLeague = nil
    self.m_structLeaguecache = {}
    self.m_focusGroup = nil
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWar_GroupStage:init()
    self:initVariable()

    local vars = self:load('clan_war_group_stage.ui')
    UIManager:open(self, UIManager.SCENE)
    self.m_preRefreshTime = 0

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWar_GroupStage')
	
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()

    -- 씬 전환 효과 (sgkim 리팩토링 하자)
    self:sceneFadeInAction(function()
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
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWar_GroupStage:initUI(ret)
    local vars = self.vars

    self.m_groupPaging = UI_ClanWar_GroupPaging(vars, self.m_groupCount)
    self.m_groupPaging:setGroupChangeCB(function(group) self:onGroupChange(group) end)

    -- 처음에 포커싱될 그룹 지정
    --self.m_groupPaging:setPage(1)
    local group = (g_clanWarData:getMyClanGroup() or 1)
    self.m_groupPaging:setGroup(group)

    -- 개발용 UI off
    vars['testMenu']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWar_GroupStage:initButton()
    local vars = self.vars

    vars['helpBtn']:registerScriptTapHandler(function() UI_HelpClan('clan_war') end)
    vars['rewardBtn']:registerScriptTapHandler(function() UI_ClanwarRewardInfoPopup:OpneWithMyClanInfo() end)
    vars['setDeckBtn']:registerScriptTapHandler(function() UI_ClanWarDeckSettings(CLAN_WAR_STAGE_ID) end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['startBtn2']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    vars['refreshBtn']:setVisible(true) -- 추가된 버튼으로 ui파일에서 visible이 false로 설정되어 있을 수 있다.

    -- 테스트용 버튼
    --[[
    vars['testTomorrowBtn']:registerScriptTapHandler(function() 
        g_clanWarData:request_testNextDay() 
        UIManager:toastNotificationRed('다음날이 되었습니다. ESC로 나갔다가 다시 진입해주세요')
    end)
    --]] 
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWar_GroupStage:refresh()
    local vars = self.vars
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanWar_GroupStage:update()
	local vars = self.vars

    local remain_time_text = g_clanWarData:getRemainTimeText()
    vars['timeLabel']:setString(remain_time_text)
    vars['timeLabel2']:setString(remain_time_text)

    -- 스크롤 방지
    if (self.m_tableViewGroupRank) then
        self.m_tableViewGroupRank.m_scrollView:setTouchEnabled(false)
    end
end

-------------------------------------
-- function onGroupChange
-- @brief 선택된 그룹이 변경된 경우
-------------------------------------
function UI_ClanWar_GroupStage:onGroupChange(group)
    local vars = self.vars
    self.m_focusGroup = group

    local is_all = (group == 'all') or (group == 99)

    -- 전체 보기의 경우
    if (is_all) then
        group = 99
    end

    self:getStructClanWarLeague(group, function(struct)
        self.m_structLeague = struct

        do-- 모든 리스트 삭제
            if self.m_tableViewAllGroupRank then
                self.m_tableViewAllGroupRank:clearItemList()
            end
            if self.m_tableViewGroupRank then
                self.m_tableViewGroupRank:clearItemList()
            end
            if self.m_tableViewGroupMatch then
                self.m_tableViewGroupMatch:clearItemList()
            end
        end

        -- 선택된 탭에 따라 menu on/off
        vars['allRankTabMenu']:setVisible(is_all)
        vars['teamTabMenu']:setVisible(not is_all)

        if (is_all) then
            -- 전체 보기 (모든 그룹 순위)
            self:setAllGroupRankList()
        else
            -- 조별 순위 리스트
            self:setGroupRankList()

            -- 조별 경기(일정) 리스트
            self:setGroupMatchList()
        end

        -- 시작 버튼 상태 갱신
        self:refreshStartBtn()
        
        -- 어제의 경기 결과 팝업
        self:showLastRankPopup()    
    end)
end

-------------------------------------
-- function refreshStartBtn
-- @brief 시작 버튼 상태 갱신
-------------------------------------
function UI_ClanWar_GroupStage:refreshStartBtn()
    local vars = self.vars

    local use_primary_btn = true
    -- 1. 클랜전에 참여 중이 아닌 경우
    if (g_clanWarData:getMyClanState() ~= ServerData_ClanWar.CLANWAR_CLAN_STATE['PARTICIPATING']) then
        use_primary_btn = false

    -- 2. 클랜전이 오픈 상태가 아닌 경우
    elseif (g_clanWarData:getClanWarState() ~= ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
        use_primary_btn = false

    -- 3. 내가 속한 그룹을 보고있지 않은 경우
    elseif (g_clanWarData:getMyClanGroup() ~= self.m_focusGroup) then
        use_primary_btn = false
    end

    do -- 사용하는 버튼 설정
        vars['startBtn']:setVisible(use_primary_btn)
        vars['startBtn2']:setVisible(not use_primary_btn)
    end

    if (g_clanWarData:getMyClanGroup() == self.m_focusGroup) then
        vars['startBtnLabel']:setString(Str('오늘의 경기'))
        vars['startBtnLabel2']:setString(Str('오늘의 경기'))
    else
        vars['startBtnLabel']:setString(Str('내 클랜 보기'))
        vars['startBtnLabel2']:setString(Str('내 클랜 보기'))
    end
end

-------------------------------------
-- function getStructClanWarLeague
-- @brief 특정 조의 정보 획득. 통신이 필요할 수 있어서 리턴이 아닌 콜백의 매개변수로 전달.
-- @param group
-- @param cb function(struct_clan_war_league)
-------------------------------------
function UI_ClanWar_GroupStage:getStructClanWarLeague(group, cb)

    -- 캐싱되어 있는 데이터가 있을 경우
    if self.m_structLeaguecache[group] then
        local struct_clan_war_league = self.m_structLeaguecache[group]
        cb(struct_clan_war_league) -- <- 리턴 개념
        return
    end

    -- 캐싱되어 있는 데이터가 없을 경우
	local success_cb = function(ret)

        -- UI가 닫힌 상황에서는 동작하지 않음
        if (self:isClosed() == true) then
            return
        end

		local struct_clan_war_league = StructClanWarLeague(ret)
        self.m_structLeaguecache[group] = struct_clan_war_league

        cb(struct_clan_war_league) -- <- 리턴 개념
	end

    g_clanWarData:request_clanWarLeagueInfo(group, success_cb)
end


-------------------------------------
-- function setGroupRankList
-- @brief 조별 순위 UI
-------------------------------------
function UI_ClanWar_GroupStage:setGroupRankList(struct_league)
    local vars = self.vars

    vars['rankListNode']:removeAllChildren()

    local struct_clanwar_league = struct_league or self.m_structLeague
	local l_rank = struct_clanwar_league:getClanWarLeagueRankList()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['rankListNode'])
    table_view.m_defaultCellSize = cc.size(620, 75 + 0)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ListItem_ClanWarGroupStageRankInGroup)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank, false)

    self.m_tableViewGroupRank = table_view
end

-------------------------------------
-- function setGroupMatchList
-- @brief 조별 경기 리스트 UI
-------------------------------------
function UI_ClanWar_GroupStage:setGroupMatchList()
    local vars = self.vars

    vars['leagueListScrollNode']:removeAllChildren()

    local struct_clanwar_league = self.m_structLeague
    local l_league = struct_clanwar_league:getClanWarLeagueMatchList()
    local group_cnt = g_clanWarData:getGroupCnt()/2
    local list_idx = 1
	local l_list = {}
    local match_count = table.count(l_league)
    for idx, data in ipairs(l_league) do
        data['idx'] = list_idx
        table.insert(l_list, data)
        list_idx = list_idx + 1

        -- 날짜 사이마다 간격이 있는 것 처럼 보여주기위해  더미 UI를 하나 찍음
        if (idx ~= match_count) and (idx % group_cnt == 0) then
            table.insert(l_list, {['my_clan_id'] = 'blank'})
            list_idx = list_idx + 1
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['leagueListScrollNode'])
    --self.m_tableView:setUseVariableSize(true)
    --table_view.m_defaultCellSize = cc.size(660, 55 + 5)
    table_view:setUseVariableSize(true)    -- 가변 사이즈를 쓰기 위해서 선언
    table_view.m_defaultCellSize = cc.size(660, 42)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ListItem_ClanWarGroupStageMatch, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_list, false)

	-- 6일째 후는 토너먼트, 토너먼트에서 리그를 호출했다는 것은 지난 리그 정보 보여주기 위함
	-- 맨 위를 포커싱해줌
	local day_of_group_stage = nil
	if (g_clanWarData:isGroupStage()) then
		day_of_group_stage = g_clanWarData.m_clanWarDay
    end

    if day_of_group_stage then
        -- 리스트 아이템 중 day가 같은 첫번째 아이템을 찾아서 포커싱 한다.
        for idx, match_data in ipairs(l_list) do
            if (match_data['day'] == day_of_group_stage) then
                table_view:relocateContainerFromIndex(idx)
                break
            end
        end
    end

    self.m_tableViewGroupMatch = table_view
end

-------------------------------------
-- function setAllGroupRankList
-- @brief 전체 보기(모든 그룹 순위)
-------------------------------------
function UI_ClanWar_GroupStage:setAllGroupRankList()
    local vars = self.vars
	local struct_clan_war = self.m_structLeague

	local l_team = struct_clan_war:getAllClanWarLeagueRankList()
	
    local create_cb = function(ui, data)
        ui.vars['moveBtn']:registerScriptTapHandler(function() self.m_groupPaging:setGroup(ui.m_leagueNumber) end)
		ui.vars['teamLabel']:setColor(cc.c3b(40, 40, 40))
	end
    
    vars['allRankTabMenu']:removeAllChildren()

	-- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(vars['allRankTabMenu'])
    table_view_td.m_cellSize = cc.size(420, 316)
    table_view_td.m_nItemPerCell = 3
	table_view_td:setCellUIClass(UI_ListItem_ClanWarGroupStageRankInAll, create_cb)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_team)

    self.m_tableViewAllGroupRank = table_view_td
end

-------------------------------------
-- function click_startBtn
-------------------------------------
function UI_ClanWar_GroupStage:click_startBtn()

    -- 클랜전에 참여중이지 않은 유저 (조별리그에서는 참여를 했는데 탈락하는 경우는 없다)
    if (g_clanWarData:getMyClanState() == ServerData_ClanWar.CLANWAR_CLAN_STATE['NOT_PARTICIPATING']) then
        local msg = Str('소속된 클랜이 클랜전에 참가하지 못했습니다.')
        local sub_msg = Str('각종 클랜 활동 기록으로 참가 클랜이 결정됩니다.\n꾸준한 클랜 활동을 이어가 주시기 바랍니다.')
        MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
        return
    end

    -- 내 클랜이 포함되지 않은 조를 보고있을 경우
    if (g_clanWarData:getMyClanGroup() ~= self.m_focusGroup) then
        local group = g_clanWarData:getMyClanGroup()
        if group then
            self.m_groupPaging:setGroup(group)
        else
            UIManager:toastNotificationRed('임시 텍스트, 클래전에 참여중이지 않은 유저')
        end
        return
    end
    
    -- 1.오픈 여부 확인
	local is_open, msg = g_clanWarData:checkClanWarState_League()
	if (not is_open) then
		MakeSimplePopup(POPUP_TYPE.OK, msg)
		return
	end

    local success_cb = function(struct_match, match_info)
        -- 상대가 유령클랜이거나 클랜정보가 없는 경우
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

        local ui_clan_war_matching = UI_ClanWarMatchingScene(struct_match)

        -- 리그 통신에서 들고 있더 클랜 세트 승리수 전달
        local struct_league = self.m_structLeague
        local my_win_cnt, enemy_win_cnt = struct_league:getMyClanMatchScore()
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb)
end

-------------------------------------
-- function click_refreshBtn
-- @brief 현재 화면을 최신으로 갱신
-------------------------------------
function UI_ClanWar_GroupStage:click_refreshBtn()
    local func_check_cooldown -- 1. 쿨타임 체크
    local func_refresh -- 2. 갱신 (현재 페이지를 갱신)

    -- 1. 쿨타임 체크
    func_check_cooldown = function()
        -- 갱신 가능 시간인지 체크한다
	    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local RENEW_INTERVAL = 10
	    if (curr_time - self.m_preRefreshTime > RENEW_INTERVAL) then
		    self.m_preRefreshTime = curr_time
		    -- 일반적인 갱신
		    func_refresh()
	
	    -- 시간이 되지 않았다면 몇초 남았는지 토스트 메세지를 띄운다
	    else
		    local ramain_time = math_ceil(RENEW_INTERVAL - (curr_time - self.m_preRefreshTime) + 1)
		    UIManager:toastNotificationRed(Str('{1}초 후에 갱신 가능합니다.', ramain_time))
	    end
    end

    -- 2. 갱신 (현재 페이지를 갱신)
    func_refresh = function(struct_match, match_info)
        self.m_structLeaguecache = {} -- 캐싱된 데이터를 초기화
        self:onGroupChange(self.m_focusGroup)
    end


    -- 시작 함수 호출
    func_check_cooldown()
end

-------------------------------------
-- function showLastRankPopup
-------------------------------------
function UI_ClanWar_GroupStage:showLastRankPopup()

    -- 기록된 클랜전 day가 같을 경우 오늘 이미 보았다는 가정
	local day = g_settingData:getClanWarDay()
	if (day == g_clanWarData.m_clanWarDay) then
		return
	end

    -- sgkim 구조가 매우 이상하지만...
    -- self.m_structLeague에서 day가 어제인 날을 찾아서 내 클랜 경기가 있는지 찾는다.
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

    -- 어제의 경기 데이터가 없으면 pass
	if (not last_match_data) then
		return
	end

	UI_ClanWarMatchInfoDetailPopup.createYesterdayResultPopup(last_match_data)
	g_settingData:setClanWarDay(g_clanWarData.m_clanWarDay)
end