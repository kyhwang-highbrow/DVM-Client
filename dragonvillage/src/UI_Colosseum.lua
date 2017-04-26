local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Colosseum
-------------------------------------
UI_Colosseum = class(PARENT, {
        m_weekRankTableView = 'UIC_TableView',
        m_topRankTableView = 'UIC_TableView',
        m_friendRankTableView = 'UIC_TableView',

        m_weekRankOffset = 'number', -- 서버에 랭킹 리스트 요청용
        m_topRankOffset = 'number', -- 서버에 랭킹 리스트 요청용
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Colosseum:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Colosseum'
    self.m_titleStr = Str('콜로세움')
	self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_Colosseum:init()
    local vars = self:load('colosseum_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Colosseum')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 보상 안내 팝업
    local function finich_cb()
		if (g_colosseumData.m_hasWeeklyReward) then
			UI_ColosseumRankingReward()
		end
    end

    self:sceneFadeInAction(nil, finich_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Colosseum:click_exitBtn()
    local scene = SceneLobby()
    scene:runScene()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Colosseum:initUI()
    self:initTab()

    local vars = self.vars

    local player_info = g_colosseumData:getPlayerInfo()

    -- 티어
    local icon = player_info:getTierIcon()
    cca.uiReactionSlow(icon)
    vars['myTierIconNode']:addChild(icon)
    vars['myTierLabel']:setString(player_info:getTierText())
    
    -- 플레이어 정보
    vars['myRankLabel']:setString(player_info:getRankText())
    vars['myPointLabel']:setString(player_info:getRPText())
    vars['myWinRateLabel']:setString(player_info:getWinRateText())
    vars['myWinstreakLabel']:setString(player_info:getWinstreakText())

    -- 콜로세움 오픈 시간 표시
    vars['timeLabel']:setString(g_colosseumData:getWeekTimeText())
    vars['timeGauge']:setPercentage(g_colosseumData:getWeekTimePercent())

    vars['rewardInfoBtn']:registerScriptTapHandler(function() self:click_rewardInfoBtn() end)
    vars['honorShopBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"명예 상점" 준비 중') end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Colosseum:initButton()
    local vars = self.vars
    vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Colosseum:refresh()
end

-------------------------------------
-- function click_secretBtn
-------------------------------------
function UI_Colosseum:click_readyBtn()
	UI_ColosseumReadyScene()
end


-------------------------------------
-- function initTab
-------------------------------------
function UI_Colosseum:initTab()
    local vars = self.vars
    self:addTab('weekRank', vars['weekRankBtn'], vars['weekRankTableViewNode'])
    self:addTab('topRank', vars['topRankBtn'], vars['topRankTableViewNode'])
    self:addTab('friendRank', vars['friendRankBtn'], vars['friendRankTableViewNode'])

    self:setTab('weekRank')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Colosseum:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    if (not first) then
        return
    end

    if (tab == 'weekRank') then
        local function finish_cb(ret)
            self.m_weekRankOffset = g_colosseumRankData.m_globalRankOffset
            self:init_weekRankTableView()
        end
        g_colosseumRankData:request_globalRank(finish_cb)

    elseif (tab == 'topRank') then
        local function finish_cb(ret)
            self.m_topRankOffset = 1
            self:init_topRankTableView()
        end
        g_colosseumRankData:request_topRank(finish_cb)

    elseif (tab == 'friendRank') then
        local function finish_cb(ret)
            self:init_friendRankTableView()
        end
        g_colosseumRankData:request_friendRank(finish_cb)

    end
end

-------------------------------------
-- function init_weekRankTableView
-------------------------------------
function UI_Colosseum:init_weekRankTableView()
    local node = self.vars['weekRankTableViewNode']
    --node:removeAllChildren()

    local l_item_list = g_colosseumRankData.m_lGlobalRank

    if (1 < self.m_weekRankOffset) then
        local prev_data = {m_rank = 'prev'}
        l_item_list['prev'] = prev_data
    end

    local next_data = {m_rank = 'next'}
    l_item_list['next'] = next_data

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_previousButton()
            self:update_weekRankTableView(self.m_weekRankOffset - 30)
        end
        ui.vars['previousButton']:registerScriptTapHandler(click_previousButton)

        local function click_nextButton()
            self:update_weekRankTableView(self.m_weekRankOffset + 30)
        end
        ui.vars['nextButton']:registerScriptTapHandler(click_nextButton)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(840, 100 + 5)
    table_view:setCellUIClass(UI_ColosseumRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    --table_view_td:makeDefaultEmptyDescLabel(Str('보유한 드래곤이 없습니다.'))

    -- 정렬
    g_colosseumRankData:sortColosseumRank(table_view.m_itemList)
    self.m_weekRankTableView = table_view
end

-------------------------------------
-- function update_weekRankTableView
-------------------------------------
function UI_Colosseum:update_weekRankTableView(target_offset)
    local function finish_cb(ret, rank_list)
        self.m_weekRankOffset = ret['offset']

        if (1 < self.m_weekRankOffset) then
            local prev_data = {m_rank = 'prev'}
            rank_list['prev'] = prev_data
        end

        local next_data = {m_rank = 'next'}
        rank_list['next'] = next_data

        self.m_weekRankTableView:mergeItemList(rank_list)
        g_colosseumRankData:sortColosseumRank(self.m_weekRankTableView.m_itemList)
    end

    g_colosseumRankData:request_rankManual(target_offset, finish_cb)
end

-------------------------------------
-- function init_topRankTableView
-------------------------------------
function UI_Colosseum:init_topRankTableView()
    local node = self.vars['topRankTableViewNode']
    --node:removeAllChildren()

    local l_item_list = g_colosseumRankData.m_lTopRank

    if (1 < self.m_topRankOffset) then
        local prev_data = {m_rank = 'prev'}
        l_item_list['prev'] = prev_data
    end

    local next_data = {m_rank = 'next'}
    l_item_list['next'] = next_data

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_previousButton()
            self:update_topRankTableView(self.m_topRankOffset - 30)
        end
        ui.vars['previousButton']:registerScriptTapHandler(click_previousButton)

        local function click_nextButton()
            self:update_topRankTableView(self.m_topRankOffset + 30)
        end
        ui.vars['nextButton']:registerScriptTapHandler(click_nextButton)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(840, 100 + 5)
    table_view:setCellUIClass(UI_ColosseumRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    --table_view_td:makeDefaultEmptyDescLabel(Str('보유한 드래곤이 없습니다.'))

    -- 정렬
    g_colosseumRankData:sortColosseumRank(table_view.m_itemList)
    self.m_topRankTableView = table_view
end

-------------------------------------
-- function update_topRankTableView
-------------------------------------
function UI_Colosseum:update_topRankTableView(target_offset)
    local function finish_cb(ret, rank_list)
        self.m_topRankOffset = ret['offset']

        if (1 < self.m_topRankOffset) then
            local prev_data = {m_rank = 'prev'}
            rank_list['prev'] = prev_data
        end

        local next_data = {m_rank = 'next'}
        rank_list['next'] = next_data

        self.m_topRankTableView:mergeItemList(rank_list)
        g_colosseumRankData:sortColosseumRank(self.m_topRankTableView.m_itemList)
    end

    g_colosseumRankData:request_rankManual(target_offset, finish_cb)
end

-------------------------------------
-- function init_friendRankTableView
-------------------------------------
function UI_Colosseum:init_friendRankTableView()
    local node = self.vars['friendRankTableViewNode']
    --node:removeAllChildren()

    local l_item_list = g_colosseumRankData.m_lFriendRank

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(840, 100+5)
    table_view:setCellUIClass(UI_ColosseumFriendRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    --table_view_td:makeDefaultEmptyDescLabel(Str('보유한 드래곤이 없습니다.'))

    -- 정렬
    g_colosseumRankData:sortColosseumRank(table_view.m_itemList)
    self.m_topRankTableView = table_view
end

-------------------------------------
-- function click_rewardInfoBtn
-------------------------------------
function UI_Colosseum:click_rewardInfoBtn()
    UI_ColosseumRewardPopup()
end

--@CHECK
UI:checkCompileError(UI_Colosseum)
