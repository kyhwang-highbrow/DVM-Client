local PARENT = UI

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
    self.m_rankOffset = 1
    self.m_clanRankOffset = 1
    self.m_rewardInfo = {}

    self:make_UIC_SortList()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerRankNew:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerRankNew:initButton()
    local vars = self.vars
    vars['randomShopBtn']:registerScriptTapHandler(function() self:click_ancientShopBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_AncientTowerRankNew:make_UIC_SortList()
    local vars = self.vars
    local button = vars['rankBtn']
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

    uic:setSortChangeCB(function(sort_type) self:onChangeRankingType(sort_type) end)
    uic:setSelectSortType('my')
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_AncientTowerRankNew:onChangeRankingType(type)
    local l_attr = getAttrTextList() 
    if (type == 'my') then
        for i,v in pairs(l_attr) do
            self.m_rankOffset = -1
        end
    elseif (type == 'top') then
        for i,v in pairs(l_attr) do
            self.m_rankOffset = 1
        end
    end

    local function finish_cb(ret)
            self.m_rewardInfo = ret['table_ancient_rank']
            self:init_rewardTableView()
    end

    if (not self.m_rewardTableView) then
        g_ancientTowerData:request_ancientTowerSeasonRankInfo(finish_cb)
    end

    self:request_Rank()
end

-------------------------------------
-- function onChangeOption
-------------------------------------
function UI_AncientTowerRankNew:onChangeOption()
    
end

-------------------------------------
-- function request_Rank
-------------------------------------
function UI_AncientTowerRankNew:request_Rank()
    local function finish_cb()
        self.m_rankOffset = g_ancientTowerData.m_nGlobalOffset
        self:init_rankTableView()
    end
    local offset = self.m_rankOffset
    g_ancientTowerData:request_ancientTowerRank(offset, finish_cb)
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

    -- 내 순위
	do
        local ui = UI_AncientTowerRankListItem(g_ancientTowerData.m_playerUserInfo)
        my_node:addChild(ui.root)
	end

    local l_item_list = g_ancientTowerData.m_lGlobalRank

    if (self.m_rankOffset > 1) then
        local prev_data = { m_tag = 'prev' }
        l_item_list['prev'] = prev_data
    end

    if (#l_item_list > 0) then
        local next_data = { m_tag = 'next' }
        l_item_list['next'] = next_data
    end

    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_rankOffset = self.m_rankOffset - OFFSET_GAP
        self.m_rankOffset = math_max(self.m_rankOffset, 0)
        self:request_Rank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local add_offset = #g_ancientTowerData.m_lGlobalRank
        if (add_offset < OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_rankOffset = self.m_rankOffset + add_offset
        self:request_Rank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(550, 60)
    table_view:setCellUIClass(UI_AncientTowerRankListItem, create_func)
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
            local a_rank = a_data.m_rank
            local b_rank = b_data.m_rank 
            return a_rank < b_rank
            
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))   
end

-------------------------------------
-- function init_rewardTableView
-------------------------------------
function UI_AncientTowerRankNew:init_rewardTableView()
    local node = self.vars['userRewardNode']

    local l_item_list = self.m_rewardInfo

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 60)
    table_view:setCellUIClass(UI_AncientTowerRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_rewardTableView = table_view

    table_view:makeDefaultEmptyDescLabel(Str('보상 정보가 없습니다.'))  
end

-------------------------------------
-- function makeTableViewRanking
-------------------------------------
function UI_AncientTowerRankNew:makeMyClanRankNode()
    local vars = self.vars
    local info = g_clanRankData:getMyRankData(CLAN_RANK['ANCT'])

    -- 자기 클랜이 있는 경우
    if (info) then
        vars['userListNode']:setVisible(true)
        vars['userMeNode']:setVisible(false)

        local my_node = vars['userMeNode']
        my_node:removeAllChildren()
        local ui = UI_AncientTowerClanRankListItem(info)
        my_node:addChild(ui.root)

        self.m_hasMyClan = true

    -- 무적자
    else
        vars['userListNode']:setVisible(false)
        vars['userMeNode']:setVisible(true)
        self.m_hasMyClan = false
    end
end

-------------------------------------
-- function init_clanRankingTableView
-------------------------------------
function UI_AncientTowerRankNew:init_clanRankingTableView()
    local vars = self.m_uiScene.vars

    -- 전체 순위
    do
        local node = vars['userListNode']
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
        table_view.m_defaultCellSize = cc.size(640, 100 + 5)
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
    end
end

-------------------------------------
-- function init_clanRewardTableView
-------------------------------------
function UI_AncientTowerRankNew:init_clanRewardTableView()
    local node = self.vars['userRewardNode']

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
    table_view.m_defaultCellSize = cc.size(640, 100 + 5)
    table_view:setCellUIClass(UI_AncientTowerClanRewardListItem, nil)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list or {})
    self.m_clanRewardTableView = table_view

    table_view:makeDefaultEmptyDescLabel(Str('보상 정보가 없습니다.'))  
end

-------------------------------------
-- function click_ancientShopBtn
-------------------------------------
function UI_AncientTowerRankNew:click_ancientShopBtn()
    -- 마녀의 상점으로 변경
    UINavigator:goTo('shop_random')
end
