local PARENT = UI

-------------------------------------
-- class UI_ClanWarListScene
-------------------------------------
UI_ClanWarListScene = class(PARENT, {

     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarListScene:init()
    local vars = self:load('clan_war_list_scene.ui')
    UIManager:open(self, UIManager.POPUP)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarListScene')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarListScene:initButton()
	local vars = self.vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarListScene:initUI()
	local vars = self.vars

	self:myClanTableView()
	self:enemyClanTableView()
end

-------------------------------------
-- function myClanTableView
-------------------------------------
function UI_ClanWarListScene:myClanTableView()
	local vars = self.vars
	local node = vars['clanA']

	local list = {}
	for i=1,5 do
		table.insert(list, {})
	end

	-- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(500, 140)
	table_view:setCellUIClass(UI_ClanWarListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(list, false)
end

-------------------------------------
-- function enemyClanTableView
-------------------------------------
function UI_ClanWarListScene:enemyClanTableView()
	local vars = self.vars
	local node = vars['clanB']
	
	local list = {}
	for i=1,5 do
		table.insert(list, {})
	end

	-- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(500, 140)
	table_view:setCellUIClass(UI_ClanWarListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(list, false)
end