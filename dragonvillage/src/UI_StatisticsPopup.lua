local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_StatisticsPopup
-------------------------------------
UI_StatisticsPopup = class(PARENT, {
		m_charList = 'list',
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
	self.m_charList = table.clone(world:getDragonList())

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
	local vars = self.vars
	local node = vars['listNode1']
	
	-- 최초 생성만 실행
	if (first) then 
		self:makeQuestTableView(tab, node)
	end
end

-------------------------------------
-- function makeQuestTableView
-------------------------------------
function UI_StatisticsPopup:makeQuestTableView(tab, node)
    local vars = self.vars

	-- 아군 정보
	local l_dragon = self.m_charList
	
    do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(514, 95)
        table_view:setCellUIClass(UI_GameResult_StatisticsListItem, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_dragon)
    end
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