local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_StatisticsPopup
-------------------------------------
UI_StatisticsPopup = class(PARENT, {
		m_isColosseum = 'mode',
		
		m_charList_A = 'list',
		m_charList_B = 'list',
		
		m_tableView_A = 'tableView',
		m_tableView_B = 'tableView',
     })
	
-- TAB LIST
UI_StatisticsPopup.TAB_DEALT = 1
UI_StatisticsPopup.TAB_TAKEN = 2
UI_StatisticsPopup.TAB_HEAL = 3

-------------------------------------
-- function init
-------------------------------------
function UI_StatisticsPopup:init(world)
	local vars = self:load('ingame_result_stats_popup.ui')
	UIManager:open(self, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_StatisticsPopup')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

	-- 멤버 변수 초기화
	self.m_isColosseum = (world.m_gameMode == GAME_MODE_COLOSSEUM)
	self.m_charList_A = world.m_myDragons
	self.m_charList_B = (self.m_isColosseum) and world.m_lEnemyDragons or nil

	-- UI 초기화
    self:initUI()
	self:initTab()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StatisticsPopup:initUI()
	local vars = self.vars
	local node = vars['listNode1']

	-- 모드에 따라 테이블 뷰 사이즈 조정
	if (self.m_isColosseum) then
		self.vars['frameNode']:setContentSize(1130, 600)
	end

	-- 입힌 데미지로 가정하고 log_key 생성
	local log_key = self:getLogKey(UI_StatisticsPopup.TAB_DEALT)
	
	-- 정렬 후 테이블 뷰 생성
	BattleStatisticsHelper:sortByValue(self.m_charList_A, log_key)
	self.m_tableView_A = self:makeTableView(self.m_charList_A, vars['listNode1'])

	-- 콜로세움 관련 처리
	if (self.m_isColosseum) then
		-- 정렬 후 테이블 뷰 생성
		BattleStatisticsHelper:sortByValue(self.m_charList_B, log_key)	
		self.m_tableView_B = self:makeTableView(self.m_charList_B, vars['listNode2'])
		
		-- 유저 정보 출력
		do
			vars['userNode1']:setVisible(true)
			local user_info = g_colosseumData.m_playerUserInfo
			vars['name1']:setString(user_info.m_nickname)
			local tamer_type = g_tamerData:getTamerInfo('type')
			local profile_icon = IconHelper:getTamerProfileIcon(tamer_type)
			vars['tamerNode1']:addChild(profile_icon)
		end

		-- 상대 정보 출력
		do
			local user_info = g_colosseumData.m_vsUserInfo
			vars['userNode2']:setVisible(true)
			vars['name2']:setString(user_info.m_nickname)

			local tid = user_info:getTamer()
			if (tid == 0) then
				tid = 110001
			end
			local t_tamer = TableTamer():get(tid)
			local tamer_type = t_tamer['type']
			local profile_icon = IconHelper:getTamerProfileIcon(tamer_type)
			vars['tamerNode2']:addChild(profile_icon)
		end
	end
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_StatisticsPopup:initTab()
    local vars = self.vars
    self:addTab(UI_StatisticsPopup.TAB_DEALT, vars['dealtBtn'])
    self:addTab(UI_StatisticsPopup.TAB_TAKEN, vars['takenBtn'])
	self:addTab(UI_StatisticsPopup.TAB_HEAL, vars['healingBtn'])
	self:setTab(UI_StatisticsPopup.TAB_DEALT)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StatisticsPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_StatisticsPopup:refresh()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_StatisticsPopup:onChangeTab(tab, first)
	self:refreshTableView(self.m_tableView_A, tab)

	if (self.m_isColosseum) then
		self:refreshTableView(self.m_tableView_B, tab)
	end
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_StatisticsPopup:makeTableView(l_char_list, node)
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(514, 95)
    table_view:setCellUIClass(UI_StatisticsListItem, nil)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

	local make_item = true
    table_view:setItemList(l_char_list, make_item)

	return table_view
end

-------------------------------------
-- function refreshTableView
-------------------------------------
function UI_StatisticsPopup:refreshTableView(table_view, tab)
	local vars = self.vars
	local l_item = table_view.m_itemList
	local log_key = self:getLogKey(tab)

	-- 해당 키의 최고 수치를 찾는다.
	local best_value = BattleStatisticsHelper:findBestValueForTable(l_item, log_key)

	-- 해당 키로 정렬한다.
	BattleStatisticsHelper:sortByValueForTable(l_item, log_key)

	-- ui에 적용시킨다.
	for i, item in pairs(l_item) do
		local ui = item['ui'] or item['generated_ui']
		if (ui) then
			ui.m_rank = i
			ui.m_logKey = log_key
			ui.m_bestValue = best_value
			ui:refresh()
		end
	end

	table_view:setDirtyItemList()
end

-------------------------------------
-- function getLogKey
-------------------------------------
function UI_StatisticsPopup:getLogKey(key_idx)
	local log_key

	if (key_idx == UI_StatisticsPopup.TAB_DEALT) then
		log_key = 'damage'

	elseif (key_idx == UI_StatisticsPopup.TAB_TAKEN) then
		log_key = 'be_damaged'

	elseif (key_idx == UI_StatisticsPopup.TAB_HEAL) then
		log_key = 'heal'

	end

	return log_key
end












-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_StatisticsPopup:click_closeBtn()
    local function finish_cb()
        UI.close(self)
    end

    -- @UI_ACTION
    self:doActionReverse(finish_cb, 1, false)
end


--@CHECK
UI:checkCompileError(UI_StatisticsPopup)