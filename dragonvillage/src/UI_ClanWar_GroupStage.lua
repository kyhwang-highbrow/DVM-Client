local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())
-------------------------------------
-- class UI_ClanWar_GroupStage
-------------------------------------
UI_ClanWar_GroupStage = class(PARENT, {
        -- 외부에서 설정되어야 할 데이터 (ServerData)
        m_groupCount = 'number',    -- 조별리그 조의 수 (32개조, 64개조 ...)
        m_structLeague = 'StructClanWarLeague',
        m_structLeaguecache = 'table[group] = struct',


        -- 8개 조를 1개의 페이지로 묶어서 탭으로 동작
        m_groupPaging = 'UI_ClanWar_GroupPaging',
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
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWar_GroupStage:init(ret)
    self:initVariable()

    local vars = self:load('clan_war_group_stage.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:closeUI() end, 'UI_ClanWar_GroupStage')
	
    --self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 초기화
    self:initUI(ret)
    self:initButton()
    self:refresh()

    -- 씬 전환 효과
    self:sceneFadeInAction(function()
        --[[
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
        --]]
    end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWar_GroupStage:initUI(ret)
    local vars = self.vars

    local function group_change_callback(group)
        -- 전체 보기의 경우
        if (group == 'all') then
            group = 99
        end

        self:getStructClanWarLeague(group, function(struct)
            self.m_structLeague = struct

            -- 모든 리스트 삭제
            vars['rankListNode']:removeAllChildren() -- 1개의 조에서 클랜 순위
            vars['leagueListScrollNode']:removeAllChildren() -- 1개의 조에서 경기 일정/결과
            vars['allRankTabMenu']:removeAllChildren() -- 전체 보기에서 모든 클랜

            if (group == 99) then
                -- 전체 보기 (모든 그룹 순위)
                self:setAllGroupRankList()
            else
                -- 조별 순위 리스트
                self:setGroupRankList()

                -- 조별 경기(일정) 리스트
                self:setGroupMatchList()
            end
            
        end)
    end

    require('UI_ClanWar_GroupPaging')
    self.m_groupPaging = UI_ClanWar_GroupPaging(vars, self.m_groupCount)
    self.m_groupPaging:setGroupChangeCB(group_change_callback)

    -- 처음에 포커싱될 그룹 지정
    --self.m_groupPaging:setPage(3)
    self.m_groupPaging:setGroup(1)


    -- 처음 들어왔을 때에는 자신의 조로 버튼을 세팅
    -- team 이 nil로 들어오는 경우 첫 화면/전체 랭킹
    --[[
    if (not team) then
        local my_clan_id = g_clanWarData:getMyClanId()
		local struct_league_item = self.m_structLeague:getLeagueInfo(my_clan_id)
		if (struct_league_item) then
			self.m_selctedTeam = struct_league_item:getLeague()
            self.m_myLeagueInfo = struct_league_item
		end
    end
    --]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWar_GroupStage:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWar_GroupStage:refresh()
    local vars = self.vars
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
    table_view.m_defaultCellSize = cc.size(660, 60 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarLeagueRankListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank, false)
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
-- function setAllGroupRankList
-- @brief 전체 보기(모든 그룹 순위)
-------------------------------------
function UI_ClanWar_GroupStage:setAllGroupRankList()
    local vars = self.vars
	local struct_clan_war = self.m_structLeague

	local l_team = struct_clan_war:getAllClanWarLeagueRankList()
	
    local create_cb = function(ui, data)
        ui.vars['moveBtn']:registerScriptTapHandler(function() self.m_groupPaging:setGroup(ui.m_leagueNumber) end)
    end
    
    vars['allRankTabMenu']:removeAllChildren()

	-- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(vars['allRankTabMenu'])
    table_view_td.m_cellSize = cc.size(420, 316)
    table_view_td.m_nItemPerCell = 3
	table_view_td:setCellUIClass(UI_ClanWarAllRankListItem, create_cb)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_team)
end