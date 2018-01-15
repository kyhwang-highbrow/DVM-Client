local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_OverallRankingPopup
-------------------------------------
UI_OverallRankingPopup = class(PARENT,{
		m_tableView = 'TableView',
    })

UI_OverallRankingPopup.OVERALL = 0
UI_OverallRankingPopup.PVP = 1
UI_OverallRankingPopup.QUEST = 2
UI_OverallRankingPopup.COMBAT = 3
UI_OverallRankingPopup.COLLECTION = 4

local T_DESC = {
    [0] = Str('다른 항목의 순위가 반영된 최종 순위입니다.'), 
    [1] = Str('콜로세움 공격 덱에 배치한 드래곤들의 전투력 합계 순위입니다.'), 
    [2] = Str('달성한 퀘스트들의 점수 순위입니다.'), 
    [3] = Str('현재 보유하고 있거나 보유했던 드래곤의 역대 최고 전투력 순위입니다.'), 
    [4] = Str('도감에서 확인 가능한 수집 현황 순위입니다.'), 
    }

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

    local l_rank_word = {[0] = 'total', 'pvp', 'quest', 'cp', 'book'}
    for idx, tab in pairs(l_rank_word) do
        self:addTabWithLabel(idx, vars[tab .. 'TabBtn'], vars[tab .. 'TabLabel'], vars[tab .. 'Node'])
    end

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

    -- desc
    do
        if (T_DESC[self.m_currTab]) then
            vars['dscLabel']:setString(Str(T_DESC[self.m_currTab]))
        end
    end

	-- my rank
	do
		local t_my_rank = g_rankData:getRankData(self.m_currTab)['my_rank']

		-- rank
		local rank = t_my_rank['rank']
		if (rank <= 100) then
			vars['rankingLabel']:setString(rank)
		else
            -- rate가 소수와 정수 두개로 옴
            local percent = (t_my_rank['rate'] < 1) and 100 or 1
			local rank_ratio = t_my_rank['rate'] * percent
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

        vars['pvpTierNode']:setVisible(false)
        vars['bookLabel']:setVisible(false)

		if (self.m_currTab == UI_OverallRankingPopup.PVP) then
			vars['scoreLabel'].m_label:runAction(cc.MoveTo:create(COMMON_UI_ACTION_TIME/2, cc.p(-190, 0)))
			vars['pvpTierNode']:setVisible(true)
			vars['pvpTierNode']:removeAllChildren()

			local tier = t_my_rank['tier']
			local icon = StructUserInfoColosseum():makeTierIcon(tier, 'small')
			vars['pvpTierNode']:addChild(icon)
       
        elseif (self.m_currTab == UI_OverallRankingPopup.COLLECTION) then
            vars['scoreLabel'].m_label:runAction(cc.MoveTo:create(COMMON_UI_ACTION_TIME/2, cc.p(-165, 0)))
            local total_cnt = table.count(g_bookData:getBookList())
            vars['bookLabel']:setVisible(true)
            vars['bookLabel']:setString(Str('/{1}', total_cnt))

		else
			vars['scoreLabel'].m_label:runAction(cc.MoveTo:create(COMMON_UI_ACTION_TIME, cc.p(-100, 0)))
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
			if (tab == UI_OverallRankingPopup.PVP) then
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
