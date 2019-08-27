local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_HallOfFameRank
-------------------------------------
UI_HallOfFameRank = class(PARENT,{
	m_tableView_book = 'TableView',
	m_tableView_quest = 'TableView',
})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameRank:init()
    local vars = self:load('hall_of_fame_rank_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HallOfFameRank')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameRank:initUI()
    local vars = self.vars

	self:addTabAuto('hall_of_fame', vars, vars['hall_of_fameTabMenu'])
    self:addTabAuto('quest', vars, vars['questTabMenu'])
	self:addTabAuto('book', vars, vars['bookTabMenu'])
    self:setTab('hall_of_fame')

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameRank:initButton()
    local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameRank:onChangeTab(tab, first)
	if (tab == 'hall_of_fame') then
		return
	end

		-- 최초 생성만 실행
	if (first) then
		local function cb_func()
			self:makeTableViewRanking(tab)
			self:refresh()
		end
		g_rankData:request_getRank(tab, nil, cb_func)
	else
		self:refresh()
	end
end

-------------------------------------
-- function makeTableViewRanking
-------------------------------------
function UI_HallOfFameRank:makeTableViewRanking(tab)
	local vars = self.vars
	local node = vars[tab .. 'ListNode']
	local l_rank = g_rankData:getRankData(tab)['rank']

	do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(995, 55)
        table_view:setCellUIClass(UI_HallOfFameRankListItem)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank)
    end

	self['m_tableView_' .. tab] = table_view

	local t_my_rank = g_rankData:getRankData(tab)['my_rank']
	local ui = UI_HallOfFameRankListItem(t_my_rank)
	vars[tab .. 'MeNode']:addChild(ui.root)
	ui.vars['meSprite']:setVisible(true)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HallOfFameRank:refresh()
end