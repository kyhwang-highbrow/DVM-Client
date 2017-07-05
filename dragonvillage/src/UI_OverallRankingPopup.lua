local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_OverallRankingPopup
-------------------------------------
UI_OverallRankingPopup = class(PARENT,{
		m_tableView = 'TableView',
    })

UI_OverallRankingPopup.OVERALL = 0
UI_OverallRankingPopup.COMBAT = 1
UI_OverallRankingPopup.QUEST = 2
UI_OverallRankingPopup.COLOSSEUM = 3
UI_OverallRankingPopup.BOOK = 4

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

	vars['scoreLabel'] = NumberLabel(vars['scoreLabel'], 0, COMMON_UI_ACTION_TIME)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_OverallRankingPopup:initTab()
    local vars = self.vars
    self:addTab(UI_OverallRankingPopup.OVERALL, vars['totalBtn'], vars['totalNode'])
    self:addTab(UI_OverallRankingPopup.COMBAT, vars['cpBtn'], vars['cpNode'])
	self:addTab(UI_OverallRankingPopup.QUEST, vars['questBtn'], vars['questNode'])
	self:addTab(UI_OverallRankingPopup.COLOSSEUM, vars['pvpBtn'], vars['pvpNode'])
	self:addTab(UI_OverallRankingPopup.BOOK, vars['collectionBtn'], vars['collectionNode'])

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
function UI_OverallRankingPopup:refresh()
	local vars = self.vars
	-- my rank
	do
		local t_my_rank = g_rankData:getRankData(self.m_currTab)['my_rank']

		-- rank
		local rank = t_my_rank['rank']
		if (rank <= 100) then
			vars['rankingLabel']:setString(rank)
		else
			local rank_ratio = t_my_rank['rate'] * 100
			vars['rankingLabel']:setString(string.format('%.2f%%', rank_ratio))
		end

		-- 리더 드래곤 아이콘
		local dragon_icon = UI_DragonCard(t_my_rank['leader'])
		vars['iconNode']:addChild(dragon_icon.root)

		-- 유저 이름
		local user_name = t_my_rank['nick']
		vars['nameLabel']:setString(user_name)

		-- 스코어
		local score = t_my_rank['rp']
		vars['scoreLabel']:setNumber(score)

		if (self.m_currTab == UI_OverallRankingPopup.COLOSSEUM) then
			vars['scoreLabel'].m_label:runAction(cc.MoveTo:create(COMMON_UI_ACTION_TIME/2, cc.p(-190, 0)))
			vars['pvpTierNode']:setVisible(true)
			vars['pvpTierNode']:removeAllChildren()

			local tier = t_my_rank['tier']
			local icon = ColosseumUserInfo:makeTierIcon(tier, 'small')
			vars['pvpTierNode']:addChild(icon)
		else
			vars['scoreLabel'].m_label:runAction(cc.MoveTo:create(COMMON_UI_ACTION_TIME, cc.p(-100, 0)))
			vars['pvpTierNode']:setVisible(false)
		end
	end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_OverallRankingPopup:onChangeTab(tab, first)
	local vars = self.vars
	
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
function UI_OverallRankingPopup:makeTableViewRanking(tab)
	local vars = self.vars
	local t_tab_data = self.m_mTabData[tab]
	local node = t_tab_data['tab_node_list'][1]

	local l_rank = g_rankData:getRankData(tab)['rank']

	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 생성 콜백
		local function create_cb_func(ui)
			if (tab == UI_OverallRankingPopup.COLOSSEUM) then
				ui.m_isColosseum = true
				ui:refresh()
			end
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1200, 105)
        table_view:setCellUIClass(UI_OverallRankingListItem, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank)

        self.m_tableView = table_view
    end
end

-------------------------------------
-- function getStageServerInfo
-- @brief 서버로 부터 정보를 가져와서 저장한다.
-------------------------------------
function UI_OverallRankingPopup:getStageServerInfo(cb_func)
	g_rankData:request_getRank(nil, nil, cb_func)
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
