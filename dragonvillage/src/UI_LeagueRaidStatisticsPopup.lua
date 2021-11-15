local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_LeagueRaidStatisticsPopup
-------------------------------------
UI_LeagueRaidStatisticsPopup = class(PARENT, {
		m_charList_A = 'list',
		m_charList_B = 'list',
		m_charList_C = 'list',
		
		m_tableView_A = 'tableView',
		m_tableView_B = 'tableView',
		m_tableView_C = 'tableView',
     })
	
-- TAB LIST
UI_LeagueRaidStatisticsPopup.TAB_DEALT = 1
UI_LeagueRaidStatisticsPopup.TAB_TAKEN = 2
UI_LeagueRaidStatisticsPopup.TAB_HEAL = 3

-------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidStatisticsPopup:init(world)
	local vars = self:load('ingame_result_stats_popup.ui')
	UIManager:open(self, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_LeagueRaidStatisticsPopup')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

    --world.m_myDragons
	-- 멤버 변수 초기화
	self.m_charList_A = g_leagueRaidData.m_attackedChar_A
	self.m_charList_B = g_leagueRaidData.m_attackedChar_B
	self.m_charList_C = g_leagueRaidData.m_attackedChar_C

	-- UI 초기화
    self:initUI()
	self:initTab()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LeagueRaidStatisticsPopup:initUI()
	local vars = self.vars

	-- 입힌 데미지로 가정하고 log_key 생성
	local log_key = self:getLogKey(UI_LeagueRaidStatisticsPopup.TAB_DEALT)
	
    vars['listNode1']:setPositionX(0)
    if (vars['league_raidMenu']) then vars['league_raidMenu']:setVisible(true) end

    local has_record_data_1 = self.m_charList_A ~= nil
    local has_record_data_2 = self.m_charList_B ~= nil
    local has_record_data_3 = self.m_charList_C ~= nil

	-- 정렬 후 테이블 뷰 생성
	BattleStatisticsHelper:sortByValue(self.m_charList_A, log_key)
	self.m_tableView_A = self:makeTableView(self.m_charList_A, vars['listNode1'])

    if (self.m_charList_B) then
	    BattleStatisticsHelper:sortByValue(self.m_charList_B, log_key)
	    self.m_tableView_B = self:makeTableView(self.m_charList_B, vars['listNode1'])
        self.m_tableView_B:setVisible(false)

    end
    
    if (self.m_charList_C) then
	    BattleStatisticsHelper:sortByValue(self.m_charList_C, log_key)
	    self.m_tableView_C = self:makeTableView(self.m_charList_C, vars['listNode1'])
        self.m_tableView_C:setVisible(false)

    end


    if (vars['teamTabBtn1']) then 
        vars['teamTabBtn1']:setVisible(has_record_data_1) 
        vars['teamTabBtn1']:registerScriptTapHandler(function() self:click_tab(1) end)
    end

    if (vars['teamTabBtn2']) then 
        vars['teamTabBtn2']:setVisible(has_record_data_2) 
        vars['teamTabBtn2']:registerScriptTapHandler(function() self:click_tab(2) end)
    end

    if (vars['teamTabBtn3']) then 
        vars['teamTabBtn3']:setVisible(has_record_data_3) 
        vars['teamTabBtn3']:registerScriptTapHandler(function() self:click_tab(3) end)
    end


end


-------------------------------------
-- function initTab
-------------------------------------
function UI_LeagueRaidStatisticsPopup:click_tab(index)
    local is_first = index == 1
    local is_second = index == 2
    local is_third = index == 3

    if (self.m_tableView_A) then self.m_tableView_A:setVisible(is_first) end
    if (self.m_tableView_B) then self.m_tableView_B:setVisible(is_second) end
    if (self.m_tableView_C) then self.m_tableView_C:setVisible(is_third) end

end


-------------------------------------
-- function initTab
-------------------------------------
function UI_LeagueRaidStatisticsPopup:initTab()
    local vars = self.vars
    self:addTab(UI_LeagueRaidStatisticsPopup.TAB_DEALT, vars['dealtBtn'])
    self:addTab(UI_LeagueRaidStatisticsPopup.TAB_TAKEN, vars['takenBtn'])
	self:addTab(UI_LeagueRaidStatisticsPopup.TAB_HEAL, vars['healingBtn'])
	self:setTab(UI_LeagueRaidStatisticsPopup.TAB_DEALT)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LeagueRaidStatisticsPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LeagueRaidStatisticsPopup:refresh()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_LeagueRaidStatisticsPopup:onChangeTab(tab, first)
    local table_view
    --[[
    if (self.m_tableView_A:isVisible()) then
        table_view = self.m_tableView_A
    elseif (self.m_tableView_B:isVisible()) then
        table_view = self.m_tableView_B
    else
        table_view = self.m_tableView_C
    end]]

    if (self.m_tableView_A) then self:refreshTableView(self.m_tableView_A, tab) end
	if (self.m_tableView_B) then self:refreshTableView(self.m_tableView_B, tab) end
	if (self.m_tableView_C) then self:refreshTableView(self.m_tableView_C, tab) end

end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_LeagueRaidStatisticsPopup:makeTableView(l_char_list, node)
    node:setVisible(true)
    
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
function UI_LeagueRaidStatisticsPopup:refreshTableView(table_view, tab)
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
function UI_LeagueRaidStatisticsPopup:getLogKey(key_idx)
	local log_key

	if (key_idx == UI_LeagueRaidStatisticsPopup.TAB_DEALT) then
		log_key = 'damage'

	elseif (key_idx == UI_LeagueRaidStatisticsPopup.TAB_TAKEN) then
		log_key = 'be_damaged'

	elseif (key_idx == UI_LeagueRaidStatisticsPopup.TAB_HEAL) then
		log_key = 'heal'

	end

	return log_key
end












-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_LeagueRaidStatisticsPopup:click_closeBtn()
    local function finish_cb()
        UI.close(self)
    end

    -- @UI_ACTION
    self:doActionReverse(finish_cb, 1, false)
end


--@CHECK
UI:checkCompileError(UI_LeagueRaidStatisticsPopup)