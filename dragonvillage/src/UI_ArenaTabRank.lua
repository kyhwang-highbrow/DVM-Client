local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-- g_arenaData -> g_arenaData 변경 필요, 아직 서버 api 분리안됨

-------------------------------------
-- class UI_ArenaTabRank
-- @brief 개인, 클랜 랭킹 탭
-------------------------------------
UI_ArenaTabRank = class(PARENT,{
        vars = '',
        
        m_rankTableView = 'UIC_TableView',
        m_rankOffset = 'number',
        
        m_clanRankTableView = 'UIC_TableView',
        m_clanRankOffset = 'number',

        m_hasMyClan = 'bool',
    })
    
UI_ArenaTabRank['PRSN'] = 'personalRanking'
UI_ArenaTabRank['CLAN'] = 'clanRanking'

local OFFSET_GAP = 30 -- 한번에 보여주는 랭커 수
local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaTabRank:init(owner_ui)
    self.root = owner_ui.vars['rankingMenu'] -- root가 있어야 보임
    self.vars = owner_ui.vars
    self.m_rankOffset = 1
    self.m_clanRankOffset = 1
    self.m_hasMyClan = nil

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaTabRank:initUI()
    self:initTab()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ArenaTabRank:initTab()
    local vars = self.vars

    if (not g_arenaData:isStartClanWarContents()) then
        self:addTabAuto(UI_ArenaTabRank['PRSN'], vars, vars['rankNode'])
        self:addTabAuto(UI_ArenaTabRank['CLAN'], vars, vars['clanRankNode'])
        
        self:setTab(UI_ArenaTabRank['PRSN'])
    else
        self:request_rank()
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ArenaTabRank:onChangeTab(tab, first)
    local vars = self.vars
    
    if (tab == UI_ArenaTabRank['CLAN']) then
        vars['myClanRankingListNode1']:setVisible(self.m_hasMyClan)
        vars['myClanRankingListNode2']:setVisible(not self.m_hasMyClan)

        -- 처음 init 할 때, 다 꺼준다
        if (self.m_hasMyClan == nil) then
            vars['myClanRankingListNode1']:setVisible(false)
            vars['myClanRankingListNode2']:setVisible(false)
        end
    end

    if (not first) then
        return
    end

    if (tab == UI_ArenaTabRank['PRSN']) then
        self:request_rank()
    elseif (tab == UI_ArenaTabRank['CLAN']) then
        self:request_clanRank()
    end
end

-------------------------------------
-- function request_rank
-------------------------------------
function UI_ArenaTabRank:request_rank()
    local function finish_cb()
        self.m_rankOffset = g_arenaData.m_nGlobalOffset
        self:makeRankTableView()
    end
    local offset = self.m_rankOffset
    g_arenaData:request_arenaRank(offset, nil, finish_cb)
end

-------------------------------------
-- function makeRankTableView
-------------------------------------
function UI_ArenaTabRank:makeRankTableView()
    local vars = self.vars
    local node = vars['rankingListNode']
    local my_node = vars['myRankingListNode']

    node:removeAllChildren()
    my_node:removeAllChildren()
    
	do-- 내 순위
        local ui = UI_ArenaRankListItem(g_arenaData.m_playerUserInfo)
        my_node:addChild(ui.root)
	end

    local l_item_list = g_arenaData.m_lGlobalRank

    if (1 < self.m_rankOffset) then
        local prev_data = { m_tag = 'prev' }
        l_item_list['prev'] = prev_data
    end

    local next_data = { m_tag = 'next' }
    l_item_list['next'] = next_data
    
    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_rankOffset = self.m_rankOffset - OFFSET_GAP
        self.m_rankOffset = math_max(self.m_rankOffset, 0)
        self:request_rank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local add_offset = #g_arenaData.m_lGlobalRank
        if (add_offset < OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_rankOffset = self.m_rankOffset + add_offset
        self:request_rank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 100 + 5)
    table_view:setCellUIClass(UI_ArenaRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    do-- 테이블 뷰 정렬
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
    self.m_rankTableView = table_view
end

-------------------------------------
-- function request_clanRank
-------------------------------------
function UI_ArenaTabRank:request_clanRank()
    local rank_type = CLAN_RANK['AREN']
    local offset = self.m_clanRankOffset
    local cb_func = function()
        if (not self.m_clanRankTableView) then
            self:makeMyClanRankNode()
        end
        self:makeClanRankTableView()
    end

    g_clanRankData:request_getRank(rank_type, offset, cb_func)
end

-------------------------------------
-- function makeMyClanRankNode
-------------------------------------
function UI_ArenaTabRank:makeMyClanRankNode()
    local vars = self.vars
    local info = g_clanRankData:getMyRankData(CLAN_RANK['AREN'])

    -- 자기 클랜이 있는 경우
    if (info) then
        vars['myClanRankingListNode1']:setVisible(true)
        vars['myClanRankingListNode2']:setVisible(false)

        local my_node = vars['myClanRankingListNode1']
        my_node:removeAllChildren()
        local ui = UI_ArenaClanRankListItem(info)
        my_node:addChild(ui.root)

        self.m_hasMyClan = true

    -- 무적자
    else
        vars['myClanRankingListNode1']:setVisible(false)
        vars['myClanRankingListNode2']:setVisible(true)
        self.m_hasMyClan = false

        vars['clanBtn']:registerScriptTapHandler(function()
            UINavigator:goTo('clan')
        end)
    end
end

-------------------------------------
-- function makeClanRankTableView
-------------------------------------
function UI_ArenaTabRank:makeClanRankTableView()
    local vars = self.vars

	do -- 테이블 뷰 생성
        local node = vars['clanRankingListNode']
        node:removeAllChildren()
	    
        local l_rank_list = g_clanRankData:getRankData(CLAN_RANK['AREN'])
        
        -- 이전 보기 추가
        if (1 < self.m_clanRankOffset) then
            l_rank_list['prev'] = 'prev'
        end

        -- 다음 보기 추가.. 
        if (#l_rank_list > 0) then
            l_rank_list['next'] = 'next'
        end

        -- 이전 랭킹 보기
        local function click_prevBtn()
            self.m_clanRankOffset = math_max(self.m_clanRankOffset - CLAN_OFFSET_GAP, 1)
            self:request_clanRank()
        end

        -- 다음 랭킹 보기
        local function click_nextBtn()
            if (table.count(l_rank_list) < CLAN_OFFSET_GAP) then
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
        table_view.m_defaultCellSize = cc.size(720, 100 + 5)
        table_view:setCellUIClass(UI_ArenaClanRankListItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank_list)

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

        -- 정산 문구 분기
        local empty_str
        if (g_clanRankData:isSettlingDown()) then
            empty_str = Str('현재 클랜 순위를 정산 중입니다. 잠시만 기다려주세요.')
        else
            empty_str = Str('랭킹 정보가 없습니다.')
        end
        table_view:makeDefaultEmptyDescLabel(empty_str)
        self.m_clanRankTableView = table_view
    end
end