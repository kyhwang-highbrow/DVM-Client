local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_OverallRankingPopup
-------------------------------------
UI_OverallRankingPopup = class(PARENT,{
		m_tableView = 'TableView',
    })

UI_OverallRankingPopup.OVERALL = 1
UI_OverallRankingPopup.COMBAT = 2
UI_OverallRankingPopup.QUEST = 3
UI_OverallRankingPopup.COLLOSEUM = 4
UI_OverallRankingPopup.COLLECTION = 5

-------------------------------------
-- function init
-------------------------------------
function UI_OverallRankingPopup:init(info)
    local vars = self:load('total_ranking.ui')
    UIManager:open(self, UIManager.SCENE)

	-- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_OverallRankingPopup')

	-- 통신 후 UI 출력
	local cb_func = function()
	end 
	self:getStageServerInfo(cb_func)

	self:initUI()
	self:initTab()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_OverallRankingPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_OverallRankingPopup'
    self.m_titleStr = Str('종합 랭킹')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_OverallRankingPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_OverallRankingPopup:initTab()
    local vars = self.vars
    self:addTab(UI_OverallRankingPopup.OVERALL, vars['totalBtn'], vars['totalNode'])
    self:addTab(UI_OverallRankingPopup.COMBAT, vars['cpBtn'], vars['cpNode'])
	self:addTab(UI_OverallRankingPopup.QUEST, vars['questBtn'], vars['questNode'])
	self:addTab(UI_OverallRankingPopup.COLLOSEUM, vars['pvpBtn'], vars['pvpNode'])
	self:addTab(UI_OverallRankingPopup.COLLECTION, vars['collectionBtn'], vars['collectionNode'])

    self:setTab(UI_OverallRankingPopup.OVERALL)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_OverallRankingPopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_OverallRankingPopup:refresh(mode_id, dungeon_lv)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_OverallRankingPopup:onChangeTab(tab, first)
	local vars = self.vars
	
	-- 최초 생성만 실행
	if (first) then
		self:makeTableViewRanking(tab)
	end
end

-------------------------------------
-- function makeTableViewRanking
-------------------------------------
function UI_OverallRankingPopup:makeTableViewRanking(tab)
	local vars = self.vars
	local t_tab_data = self.m_mTabData[tab]
	local node = t_tab_data['tab_node_list'][1]

	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 생성 콜백
		local create_cb_func = function(ui)
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(320, 125)
        table_view:setCellUIClass(UI_OverallRankingListItem, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList({})

        self.m_tableView = table_view
    end
end

-------------------------------------
-- function getStageServerInfo
-- @brief 서버로 부터 정보를 가져와서 저장한다.
-------------------------------------
function UI_OverallRankingPopup:getStageServerInfo(cb_func)
end

-------------------------------------
-- function makeDataPretty
-- @brief 서버로부터 가져온 정보를 사용하기 좋게 가공한다.
-------------------------------------
function UI_OverallRankingPopup:makeDataPretty(ret)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_OverallRankingPopup:click_exitBtn()
	self:close()
end


--@CHECK
UI:checkCompileError(UI_OverallRankingPopup)
