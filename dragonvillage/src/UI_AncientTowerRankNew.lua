local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_AncientTowerRankNew
-------------------------------------
UI_AncientTowerRankNew = class(PARENT, {
        m_uiScene = 'UI_AncientTower',

        m_rewardInfo = 'table',
        m_typeRadioButton = 'UIC_RadioButton',

        m_rankTableView = 'UIC_TableView',  -- 랭크 리스트
        m_rewardTableView = 'UIC_TableView',  -- 보상 리스트

        m_clanRankTableView = 'UIC_TableView',
        m_clanRewardTableView = 'UIC_TableView',
        m_hasMyClan = 'table',

        m_rankOffset = 'number',
        m_clanRankOffset = 'number',
        m_rankType = 'string',
    })

local OFFSET_GAP = 20 -- 한번에 보여주는 랭커 수
local CLAN_OFFSET_GAP = 20
-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerRankNew:init()
    local vars = self:load('tower_rank_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AncientTowerRankNew')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

UI_AncientTowerRankNew.RANKING = 'rankingList'
UI_AncientTowerRankNew.REWARD = 'rewardList'
UI_AncientTowerRankNew.CLAN_RANKING = 'clanRankingList'
UI_AncientTowerRankNew.CLAN_REWARD = 'clanRewardList'

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerRankNew:initUI()
    local vars = self.vars
    self.m_rankOffset = 1
    self.m_clanRankOffset = 1
    self.m_rewardInfo = {}


    self:addTabAuto('userRank', vars, vars['userRankTabMenu'])
    self:addTabAuto('clanRank', vars, vars['clanRankTabMenu'])

    self:setTab('userRank')
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)

    self:make_UIC_SortList()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerRankNew:refresh()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_AncientTowerRankNew:onChangeTab(tab, first)
    local vars = self.vars
    if (tab == 'clanRank') and (first) then
        self:makeClanRank()
        if (not self.m_clanRewardTableView) then
            self:init_clanRewardTableView()
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerRankNew:initButton()
    local vars = self.vars
    vars['randomShopBtn']:registerScriptTapHandler(function() self:click_ancientShopBtn() end)
    vars['clancoinShopBtn']:registerScriptTapHandler(function() self:click_clancoinShopBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_AncientTowerRankNew:make_UIC_SortList()
    local vars = self.vars

    -- 내 순위 필터
    local button = vars['userRankBtn']
    local label = vars['rankLabel1']

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


    uic:addSortType('my', Str('내 랭킹'))
    uic:addSortType('top', Str('최상위 랭킹'))
    uic:addSortType('friend', Str('친구 랭킹'))
    uic:addSortType('clan', Str('클랜원 랭킹'))

    uic:setSortChangeCB(function(sort_type) self:onChangeRankingType(sort_type) end)
    uic:setSelectSortType('top')

    -- 클랜 순위 필터
    local button = vars['clanRankListBtn']
    local label = vars['rankLabel2']

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


    uic:addSortType('my', Str('내 클랜 랭킹'))
    uic:addSortType('top', Str('최상위 클랜 랭킹'))

    uic:setSortChangeCB(function(sort_type) self:onChangeRankingType_Clan(sort_type) end)
    
	-- 클랜 가입하지 않은 상태라면 최상위 클랜 선
	local focus_tab = 'my'
    if (g_clanData) then
        if (g_clanData:isClanGuest()) then 
            focus_tab = 'top'
            vars['clanRankListBtn']:setEnabled(false)
        end
    end
    uic:setSelectSortType(focus_tab)
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_AncientTowerRankNew:onChangeRankingType(type)
    if (g_clanData) then
        if (type == 'clan' and g_clanData:isClanGuest()) then
            local msg = Str('소속된 클랜이 없습니다.')
            UIManager:toastNotificationRed(msg)
            return
        end
    end
    
    if (type == 'my') then
        self.m_rankType = 'world'
        self.m_rankOffset = -1

    elseif (type == 'top') then
        self.m_rankType = 'world'
        self.m_rankOffset = 1

    elseif (type == 'friend') then
        self.m_rankType = 'friend'
        self.m_rankOffset = 1

    elseif (type == 'clan') then
        self.m_rankType = 'clan'
        self.m_rankOffset = 1
    end

    self:request_Rank()
    
    if (self.m_rewardTableView) then 
        return 
    end

    -- 보상 테이블 정보는 고대의 탑 들어올 때 받음
    self.m_rewardInfo = g_ancientTowerData.m_rewardTable
    if (self.m_rewardInfo) then
        self:init_rewardTableView()
    end
end

-------------------------------------
-- function onChangeRankingType_Clan
-- @brief
-------------------------------------
function UI_AncientTowerRankNew:onChangeRankingType_Clan(type)
    local l_attr = getAttrTextList() 

    if (g_clanData) then
        if (type == 'my' and g_clanData:isClanGuest()) then
            local msg = Str('소속된 클랜이 없습니다.')
            UIManager:toastNotificationRed(msg)
            return
        end
    end
    
    if (type == 'my') then
        for i,v in pairs(l_attr) do
            self.m_rankOffset = -1
        end
    elseif (type == 'top') then
        for i,v in pairs(l_attr) do
            self.m_rankOffset = 1
        end
    end

    self:makeClanRank()
end

-------------------------------------
-- function request_Rank
-------------------------------------
function UI_AncientTowerRankNew:request_Rank()
    local function finish_cb()
        self:init_rankTableView()
        self:focusInRankReward()
    end
    local offset = self.m_rankOffset
    g_ancientTowerData:request_ancientTowerRank(offset, finish_cb, self.m_rankType)
end

-------------------------------------
-- function focusInRankReward
-------------------------------------
function UI_AncientTowerRankNew:focusInRankReward()
    local l_rank_list = self.m_rewardInfo

    -- 받을 수 있는 포상에 포커싱
    local reward, idx = g_ancientTowerData:getPossibleReward()

    if (self.m_rankOffset == 1) then
        idx = 1
    end
    self.m_rewardTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    self.m_rewardTableView:relocateContainerFromIndex(idx or 1)

end

-------------------------------------
-- function request_clanRank
-------------------------------------
function UI_AncientTowerRankNew:request_clanRank()
    local rank_type = CLAN_RANK['ANCT']
    local offset = self.m_clanRankOffset

    local cb_func = function()
        -- 최초 생성
        if (not self.m_clanRankTableView) then
            self:makeMyClanRankNode()
        end
        self:init_clanRankingTableView()
    end
    g_clanRankData:request_getRank(rank_type, offset, cb_func)
end

-------------------------------------
-- function init_rankTableView
-------------------------------------
function UI_AncientTowerRankNew:init_rankTableView()
    local node      = self.vars['userListNode']
    local my_node   = self.vars['userMeNode']

    node:removeAllChildren()
    my_node:removeAllChildren()
    
    -- 최상위 랭크 필터인 경우 포커스를 첫번째 랭킹에 맞춤
    local is_top = false
    if (self.m_rankOffset == 1 and self.m_rankType == 'world') then
        is_top = true
    end

    -- 내 순위
	do
        local season_rank = g_ancientTowerData.m_nTotalRank
        local ui = UI_AncientTowerRankListItemNew(g_ancientTowerData.m_playerUserInfo)
        local rank_str = g_ancientTowerData:getRankText()
        local rank_rate = g_ancientTowerData.m_nTotalRate or 0
        if (season_rank > 0) then
            ui.vars['rankingLabel']:setString(string.format('%s\n(%d', Str(rank_str), rank_rate*100) .. '%)') -- 10위(4%)
        else
            ui.vars['rankingLabel']:setString(string.format('%s', Str(rank_str)))
        end
        
        my_node:addChild(ui.root)
	end

    local l_item_list = g_ancientTowerData.m_lGlobalRank

    if (g_ancientTowerData.m_nGlobalOffset > 1) then
        local prev_data = { m_tag = 'prev' }
        l_item_list['prev'] = prev_data
    end

    if (#l_item_list > 0) then
        local next_data = { m_tag = 'next' }
        l_item_list['next'] = next_data
    end

    -- 이전 랭킹 보기
    local function click_prevBtn()
        local prev_ind 
        if (#l_item_list>0) then
            prev_ind = l_item_list[1]['m_rank'] - OFFSET_GAP -- 가져온 랭킹의 가장 첫 번째 - OFFSET_GAP
        else
            prev_ind = self.m_rankOffset - OFFSET_GAP
        end
        self.m_rankOffset = prev_ind
        self.m_rankOffset = math_max(self.m_rankOffset, 0)
        self:request_Rank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local next_ind = l_item_list[#l_item_list]['m_rank'] -- 가져온 랭킹의 가장 마지막 + 1
        if (#l_item_list < OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_rankOffset = next_ind + 1
        self:request_Rank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(550, 55 + 5)
    table_view:setCellUIClass(UI_AncientTowerRankListItemNew, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_rankTableView = table_view

    do -- 테이블 뷰 정렬
        local function sort_func(a, b)
            local a_data = a['data']
            local b_data = b['data']

            -- 이전, 다음 버튼 정렬
            if (a_data.m_tag == 'prev') then
                return true
            elseif (b_data.m_tag == 'prev') then
                return false
            elseif (a_data.m_tag == 'next') then
                return false
            elseif (b_data.m_tag == 'next') then
                return true
            end

            -- 랭킹으로 선별
            local a_rank = conditionalOperator((0 < a_data.m_rank), a_data.m_rank, 9999999)
            local b_rank = conditionalOperator((0 < b_data.m_rank), b_data.m_rank, 9999999)

            return a_rank < b_rank
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    local uid = g_userData:get('uid')
    local idx = 1
    for i, data in ipairs(table_view.m_itemList) do
        if (data['data']) then
            if (data['data']['m_uid'] == uid) then
                idx = i
                break
            end
        end
    end
    

    if (is_top) then
        idx = 1
    end
    
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(idx or 1)
    table_view:makeDefaultEmptyDescLabel('')
end

-------------------------------------
-- function init_rewardTableView
-------------------------------------
function UI_AncientTowerRankNew:init_rewardTableView()
    local node = self.vars['userRewardNode']

    local l_item_list = self.m_rewardInfo

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 55 + 5)
    table_view:setCellUIClass(UI_AncientTowerRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_rewardTableView = table_view

    table_view:makeDefaultEmptyDescLabel('')  
end

-------------------------------------
-- function makeClanRank
-------------------------------------
function UI_AncientTowerRankNew:makeClanRank()
    self:request_clanRank()
end

-------------------------------------
-- function makeMyClanRankNode
-------------------------------------
function UI_AncientTowerRankNew:makeMyClanRankNode()
    local vars = self.vars
    local info = g_clanRankData:getMyRankData(CLAN_RANK['ANCT'])

    -- 자기 클랜이 있는 경우
    if (info) then
        vars['clanMeNode']:setVisible(true)

        local my_node = vars['clanMeNode']
        my_node:removeAllChildren()
        local ui = UI_AncientTowerClanRankListItem(info)
        my_node:addChild(ui.root)

    -- 무적자
    else
        vars['clanMeNode']:setVisible(false)
    end
end

-------------------------------------
-- function init_clanRankingTableView
-------------------------------------
function UI_AncientTowerRankNew:init_clanRankingTableView()
    local vars = self.vars

    -- 최상위 랭크 필터인 경우 포커스를 첫번째 랭킹에 맞춤
    local is_top = false
    if (self.m_rankOffset == 1) then
        is_top = true
    end

    -- 전체 순위
    do
        local node = vars['clanListNode']
        node:removeAllChildren()

        local l_item_list = g_clanRankData:getRankData(CLAN_RANK['ANCT'])
        
        -- 이전 보기 추가
        if (1 < self.m_clanRankOffset) then
            l_item_list['prev'] = 'prev'
        end

        -- 다음 보기 추가.. 
        if (#l_item_list > 0) then
            l_item_list['next'] = 'next'
        end
        
        -- 이전 랭킹 보기
        local function click_prevBtn()
            self.m_clanRankOffset = math_max(self.m_clanRankOffset - CLAN_OFFSET_GAP, 1)
            self:request_clanRank()
        end
        -- 다음 랭킹 보기
        local function click_nextBtn()
            if (table.count(l_item_list) < CLAN_OFFSET_GAP) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
                return
            end
            self.m_clanRankOffset = self.m_clanRankOffset + CLAN_OFFSET_GAP
            self:request_clanRank()
        end

        -- 생성 콜백
        local function create_func(ui, data)
            if (data == 'prev') then
                ui.vars['prevBtn']:setVisible(true)
                ui.vars['itemMenu']:setVisible(false)
                ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
            elseif (data == 'next') then
                ui.vars['nextBtn']:setVisible(true)
                ui.vars['itemMenu']:setVisible(false)
                ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
            end
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(550, 55 + 5)
        table_view:setCellUIClass(UI_AncientTowerClanRankListItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_item_list)

        do-- 테이블 뷰 정렬
            local function sort_func(a, b)
                local a_data = a['data']
                local b_data = b['data']

                -- 이전, 다음 버튼 정렬
                if (a_data == 'prev') then
                    return true
                elseif (b_data == 'prev') then
                    return false
                elseif (a_data == 'next') then
                    return false
                elseif (b_data == 'next') then
                    return true
                end

                -- 랭킹으로 선별
                local a_rank = a_data:getRank()
                local b_rank = b_data:getRank()
                return a_rank < b_rank
            end

            table.sort(table_view.m_itemList, sort_func)
        end

        self.m_clanRankTableView = table_view
        -- 정산 문구 분기
        local empty_str
        if (g_clanRankData:isSettlingDown()) then
            empty_str = Str('현재 클랜 순위를 정산 중입니다. 잠시만 기다려주세요.')
        else
            empty_str = Str('랭킹 정보가 없습니다.')
        end
        table_view:makeDefaultEmptyDescLabel(empty_str)


        local indx = 1
        local my_clan_info = g_clanRankData:getMyRankData(CLAN_RANK['ANCT'])
        if (my_clan_info) then
            for ind, data in ipairs(l_item_list) do
                if (data['rank'] == my_clan_info['rank']) then
                    indx = ind
                end
            end
        end

        if (is_top) then
            indx = 1
        end

        table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
        table_view:relocateContainerFromIndex(indx or 1)

    end
end

-------------------------------------
-- function init_clanRewardTableView
-------------------------------------
function UI_AncientTowerRankNew:init_clanRewardTableView()
    local node = self.vars['clanRewardNode']

    -- 고대의 탑 보상 정보만 빼온다.
    local l_item_list = {}
    for rank_id, t_data in pairs(TABLE:get('table_clan_reward')) do
        if (t_data['category'] == CLAN_RANK['ANCT']) and (t_data['week'] == 1) then
            table.insert(l_item_list, t_data)
        end
    end

    -- 테이블 정렬
    table.sort(l_item_list, function(a, b) 
        return tonumber(a['rank_id']) < tonumber(b['rank_id'])
    end)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 52 + 5)
    table_view:setCellUIClass(UI_AncientTowerClanRewardListItem, nil)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list or {})
    self.m_clanRewardTableView = table_view
    table_view:makeDefaultEmptyDescLabel('')

    local my_data = g_clanRankData:getMyRankData(CLAN_RANK['ANCT'])
    if (not my_data) then
        return
    end

    local my_rank = my_data['rank'] 
    
    if (my_rank == -1) then
        return
    end

    local idx = 1
    for i,data in ipairs(l_item_list) do
        -- 받을 수 있는 포상에 하이라이트
        local rank_type = nil
        local rank_value = 1
            
        local rank_min = tonumber(data['rank_min'])
        local rank_max = tonumber(data['rank_max'])

        local ratio_min = tonumber(data['ratio_min'])
        local ratio_max = tonumber(data['ratio_max'])

        -- 순위 필터
        if (rank_min and rank_max) then
            if (rank_min <= my_rank) and (my_rank <= rank_max) then
                idx = i
                break
            end
        end
    end

    self.m_clanRewardTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    self.m_clanRewardTableView:relocateContainerFromIndex(idx or 1)
end

-------------------------------------
-- function click_ancientShopBtn
-------------------------------------
function UI_AncientTowerRankNew:click_ancientShopBtn()
    -- 마녀의 상점으로 변경
    UINavigator:goTo('shop_random')
end

-------------------------------------
-- function click_clancoinShopBtn
-------------------------------------
function UI_AncientTowerRankNew:click_clancoinShopBtn()
    local ui_shop_popup = UI_Shop()
    ui_shop_popup:setTab('clancoin')
end
