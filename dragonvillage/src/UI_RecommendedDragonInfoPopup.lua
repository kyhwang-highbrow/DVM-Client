local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_RecommendedDragonInfoPopup
-------------------------------------
UI_RecommendedDragonInfoPopup = class(PARENT,{
		m_modeID = 'num',
		m_dungeonLV = 'num',
		m_selectStageID = 'num',

		m_selecetStageInfoParty = 'server-info',
		m_selecetStageInfoDragon = 'server-info',

		m_tableViewDungeon = 'TableView',
		m_tableViewParty = 'TableView',
		m_tableViewDragon = 'TableView',
		m_uicSortList = 'UICSortList',

		m_mStageInfoMap = 'Map',
    })

UI_RecommendedDragonInfoPopup.PARTY = 'party'
UI_RecommendedDragonInfoPopup.DRAGON = 'dragon'

--[[
	['key'] = ['mode_id']
	['data'] = {
		['ani']='nest_dungeon_gold';
		['is_open']=1;
		['sub_mode']=0;
		['t_name']='황금 던전';
		['res']=
		['bonus_rate']=0;
		['mode_id']=1240000;
		['major_day']='mon';
		['bonus_value']='';
		['next_invalid_at']=1494183600000;
		['days']='mon,tue,wed,thu,fri,sat,sun';
		['mode']=4;
		['t_info']='골드 획득 가능';
		['next_valid_at']=1493609251000;
	}
--]]

-------------------------------------
-- function init
-------------------------------------
function UI_RecommendedDragonInfoPopup:init(info)
    local vars = self:load('dragon_ranking.ui')
    UIManager:open(self, UIManager.SCENE)

	-- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RecommendedDragonInfoPopup')

	self.m_modeID = info['data']['mode_id']
	self.m_dungeonLV = 1
	self.m_mStageInfoMap = {}

	-- 통신 후 UI 출력
	local cb_func = function()
		self:initUI()
		self:initTab()
		self:initButton()
		self:refresh()
	end 
	self:getStageServerInfo(cb_func)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_RecommendedDragonInfoPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RecommendedDragonInfoPopup'
    self.m_titleStr = Str('공략 드래곤 정보')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RecommendedDragonInfoPopup:initUI()
    local vars = self.vars

	self:makeTableView_dungeon()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_RecommendedDragonInfoPopup:initTab()
    local vars = self.vars
    self:addTabAuto(UI_RecommendedDragonInfoPopup.PARTY, vars, vars['partyNode'])
    self:addTabAuto(UI_RecommendedDragonInfoPopup.DRAGON, vars, vars['dragonNode'])
    self:setTab(UI_RecommendedDragonInfoPopup.PARTY)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RecommendedDragonInfoPopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RecommendedDragonInfoPopup:refresh(mode_id, dungeon_lv)
	self.m_modeID = mode_id or self.m_modeID
	self.m_dungeonLV = dungeon_lv or self.m_dungeonLV

	-- dungeonTable update
	if (mode_id) then
		for i, v in pairs(self.m_tableViewDungeon.m_itemList) do
			local ui = v['ui']
			if (ui) then
				ui:refresh(mode_id)
			end
		end
	end

	-- RankingTable update
	local function cb_func()
		self:makeTableView_dragon(UI_RecommendedDragonInfoPopup.PARTY)
		self:makeTableView_dragon(UI_RecommendedDragonInfoPopup.DRAGON)
	end
	self:getStageServerInfo(cb_func)
end

-------------------------------------
-- function refresh_sortList
-------------------------------------
function UI_RecommendedDragonInfoPopup:refresh_sortList(mode_id)
    local vars = self.vars

    -- 이전 리스트 해제
    if (self.m_uicSortList) then
        self.m_uicSortList.m_node:removeFromParent()
        self.m_uicSortList = nil
    end

    -- 새 리스트 생성
	local uic_sort_list = self:makeUICSortList_DungeonLV(vars['levelBtn'], vars['levelLabel'])
        	
    -- 던전 모드 파악하여 레벨 수 부여
    local t_dungeon_info = g_nestDungeonData:parseNestDungeonID(mode_id)
    local dungeon_mode = t_dungeon_info['dungeon_mode']
    local max_dungeon_lv = 10
    --if (dungeon_mode == NEST_DUNGEON_NIGHTMARE) then
        --max_dungeon_lv = 10
    --else
        --max_dungeon_lv = 6
    --end

    -- 레벨 add
	for i = 1, max_dungeon_lv do
		uic_sort_list:addSortType(i, Str('{1}단계', i))
	end

	-- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
		self:refresh(nil, sort_type)
    end
	uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 멤버 변수 등록
    self.m_uicSortList = uic_sort_list
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_RecommendedDragonInfoPopup:onChangeTab(tab, first)
	local vars = self.vars
	
	-- 최초 생성만 실행
	if (first) then
		self:makeTableView_dragon(tab)
	end
end

-------------------------------------
-- function makeTableView_dungeon
-------------------------------------
function UI_RecommendedDragonInfoPopup:makeTableView_dungeon()
	local vars = self.vars
	local node = vars['dungeonNode']

	local l_dungeon_list = g_nestDungeonData:getNestDungeonInfo()

    -- 고대 유적 던전 - 공략 드래곤 노출 X
    for i, v in ipairs(l_dungeon_list) do
        local mode = v['mode']
        if (mode) and (mode == NEST_DUNGEON_ANCIENT_RUIN) then
            table.remove(l_dungeon_list, i)
            break
        end
    end

	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 생성 콜백
		local create_cb_func = function(ui, data)
			-- 버튼 콜백 등록
            local function click_dungeonBtn()
				self:refresh(data['mode_id'])
                self:refresh_sortList(data['mode_id'])
			end
			ui.vars['dungeonBtn']:registerScriptTapHandler(click_dungeonBtn)
            
            -- ui 최초 선택 갱신
            if (data['mode_id'] == self.m_modeID) then
                ui:refresh(data['mode_id'])
                self:refresh_sortList(data['mode_id'])
            end
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(320, 125)
        table_view:setCellUIClass(UI_RecommendedDragonInfoListItem_Dungeon, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_dungeon_list)

        self.m_tableViewDungeon = table_view
    end

    -- 최초 선택 던전 포커스
    for i, v in pairs(l_dungeon_list) do
        if (v['mode_id'] == self.m_modeID) then
            self.m_tableViewDungeon:update(0)           
            self.m_tableViewDungeon:relocateContainerFromIndex(i, true)
        end
    end
end

-------------------------------------
-- function makeTableView_dragon
-------------------------------------
function UI_RecommendedDragonInfoPopup:makeTableView_dragon(tab)
	local vars = self.vars
	local node
	local l_data
	local ui_class

	-- 사용할 변수 정의
	if (tab == UI_RecommendedDragonInfoPopup.PARTY) then
		node = vars['partyNode']
		l_data = self.m_selecetStageInfoParty
		ui_class = UI_RecommendedDragonInfoListItem_Party

	elseif (tab == UI_RecommendedDragonInfoPopup.DRAGON) then
		node = vars['dragonNode']
		l_data = self.m_selecetStageInfoDragon
		ui_class = UI_RecommendedDragonInfoListItem_Dragon
	end

	do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(870, 125)
        table_view:setCellUIClass(ui_class)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_data)

        if (tab == UI_RecommendedDragonInfoPopup.PARTY) then
			self.m_tableViewParty = table_view

		elseif (tab == UI_RecommendedDragonInfoPopup.DRAGON) then
			self.m_tableViewDragon = table_view

		end
    end
end

-------------------------------------
-- function makeUICSortList_DungeonLV
-------------------------------------
function UI_RecommendedDragonInfoPopup:makeUICSortList_DungeonLV(button, label)
    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()
	
	uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
	uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    
    uic:init_container()
    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    return uic
end

-------------------------------------
-- function getStageServerInfo
-- @brief 서버로 부터 정보를 가져와서 저장한다. (game/stage/info)
-------------------------------------
function UI_RecommendedDragonInfoPopup:getStageServerInfo(cb_func)
	local stage_id = self.m_modeID + self.m_dungeonLV

	-- 저장해둔 정보가 있다면 꺼내온다.
	if (self.m_mStageInfoMap[stage_id]) then
		local ret = self.m_mStageInfoMap[stage_id]
		self:makeDataPretty(ret)
		if cb_func then
			cb_func()
		end

	-- 없다면 서버에 요청한다.
	else
		local function finish_cb(ret)
			if ret then
				self:makeDataPretty(ret)
				self.m_mStageInfoMap[stage_id] = ret
			end
			if cb_func then
				cb_func()
			end
		end

		-- request
		g_stageData:requestStageInfo(stage_id, finish_cb)

	end
end

-------------------------------------
-- function makeDataPretty
-- @brief 서버로부터 가져온 정보를 사용하기 좋게 가공한다.
-------------------------------------
function UI_RecommendedDragonInfoPopup:makeDataPretty(ret)
	-- 공략 파티 정보
	self.m_selecetStageInfoParty = {}
	for i, data in pairs(ret['team_rank']) do
		local idx = tonumber(i)
		local t_data = {rank = idx, data = data}
		self.m_selecetStageInfoParty[idx] = t_data
	end

	-- 공략 드래곤 정보
	self.m_selecetStageInfoDragon = {}
	for i, v in pairs(ret['dragon_rank']) do
		local t_data = {did = tonumber(i), percent = tonumber(v)}
		table.insert(self.m_selecetStageInfoDragon, t_data)
	end
	table.sort(self.m_selecetStageInfoDragon, function(a, b) 
		return (a['percent'] > b['percent'])
	end)
	for i, t_data in pairs(self.m_selecetStageInfoDragon) do
		t_data['rank'] = i
	end
end

-------------------------------------
-- function click_levelBtn
-------------------------------------
function UI_RecommendedDragonInfoPopup:click_levelBtn()
	self.m_uicSortList:toggleVisibility()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RecommendedDragonInfoPopup:click_exitBtn()
	self:close()
end


--@CHECK
UI:checkCompileError(UI_RecommendedDragonInfoPopup)
